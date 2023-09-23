FROM alpine:latest

RUN apk add --update --no-cache rsync aws-cli

COPY nextcloud-sync.sh /
COPY upload.sh /
COPY download.sh /
