FROM alpine:latest

RUN apk add --update --no-cache ffmpeg x265 aws-cli

COPY run.sh /

CMD [ "/bin/sh", "-c", "/run.sh" ]
