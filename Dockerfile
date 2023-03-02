FROM alpine:latest

RUN apk add --update --no-cache ffmpeg x265 bash rsync

COPY run.sh /

VOLUME /nextcloud
VOLUME /photos

CMD [ "/bin/bash", "/run.sh" ]
