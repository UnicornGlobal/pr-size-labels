## Usage

Create a file named `size_labels.yml` inside the `.gihub/workflows` directory and paste:

```yml
name: PR Size Labels

on:
  pull_request:

jobs:
  labels:
    runs-on: ubuntu-latest
    name: Label the PR size
    steps:
      - uses: UnicornGlobal/pr-size-labels@v1
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Configuration

The labels get applied accordingly

Label | Changes
----- | -------
`size/XS`| 0-9
`size/S`|10-39
`size/M`|30-99
`size/L`|100-499
`size/XL`|500-999
`size/XXL`|1000+

## Why the Fork?

Upstream project: CodelyTV/pr-size-labeler

We needed the following modifications:

- made the sizes and names of the labels match our existing internal setup
- check if a label exists already and exit if it does
- remove any existing labels when the size of the PR changes
- exclude the following lock files from change counts so that PRs with dependency updates can be assessed correctly
  - package-lock.json
  - yarn.lock
  - composer.lock

## License

[MIT](LICENSE)
