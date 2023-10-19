FROM alpine:latest

LABEL org.opencontainers.image.source http://github.com/melvyndekort/hevc-encoder

RUN apk add --update --no-cache ffmpeg x265 aws-cli

COPY run.sh /

CMD [ "/bin/sh", "-c", "/run.sh" ]
