FROM alpine:latest

RUN apk add --update --no-cache aws-cli

COPY run.sh /

CMD [ "/bin/sh", "-c", "/run.sh" ]
