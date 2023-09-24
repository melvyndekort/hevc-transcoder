FROM alpine:latest

RUN apk add --update --no-cache rclone aws-cli

COPY nextcloud-sync.sh /
COPY upload.sh /
COPY download.sh /
