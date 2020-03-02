FROM alpine/git

RUN apk add --no-cache bash curl jq bc grep

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
