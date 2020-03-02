#!/bin/bash
set -e

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "The env variable GITHUB_REPOSITORY is required."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "The env variable GITHUB_EVENT_PATH is required."
  exit 1
fi

# get the branches to compare
git fetch origin $GITHUB_BASE_REF $GITHUB_HEAD_REF

GITHUB_TOKEN="$1"

xs_max_size="$2"
s_max_size="$3"
m_max_size="$4"
l_max_size="$5"
xl_max_size="$6"

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

autolabel() {
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}")

  # count the changes and ignore common lock files
  total_modifications=$(git diff origin/${GITHUB_HEAD_REF}..origin/${GITHUB_BASE_REF} --stat | grep -v 'package.lock' | grep -v 'yarn.lock' | grep -v 'composer.lock' | grep -v '| Bin ' | grep -v ' files changed, ' | tr -s ' ' | cut -d' ' -f4 | awk '{s+=$1}END{print s}')

  echo "Total modifications: ${total_modifications}"

  label_to_add=$(label_for $total_modifications)

  echo "Label to add: ${label_to_add}"

  list=($(echo "$body" | jq .labels | jq .[] | jq .name))

  already_exists=0

  # Check all existing labels and remove any that do not match
  for i in ${list[@]}
  do
    :
    i=$(echo $i | sed -e 's/^"//' -e 's/"$//')
    if [[ $i != ${label_to_add} ]]; then
      # check if it is a size label
      if [[ $i == *"size"* ]]; then
        echo "Removing old size label $i"
        remove $(echo $i | sed -e 's/^"//' -e 's/"$//')
      fi
    else
      echo "The size label already exists"
      already_exists=1
    fi
  done

  # Check if the label already exists
  if [[ ${already_exists} == 1 ]]; then
    exit 0
  fi

  echo "Labeling pull request with $label_to_add"

  curl -sSL \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"labels\":[\"${label_to_add}\"]}" \
    "${URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"
}

remove() {
  curl -sSL \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X DELETE \
    -H "Content-Type: application/json" \
    "${URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels/$1"
}

label_for() {
  if [ "$1" -lt "$xs_max_size" ]; then
    label="size/XS"
  elif [ "$1" -lt "$s_max_size" ]; then
    label="size/S"
  elif [ "$1" -lt "$m_max_size" ]; then
    label="size/M"
  elif [ "$1" -lt "$l_max_size" ]; then
    label="size/L"
  elif [ "$1" -lt "$xl_max_size" ]; then
    label="size/XL"
  else
    label="size/XXL"
  fi

  echo "$label"
}

autolabel

exit $?
