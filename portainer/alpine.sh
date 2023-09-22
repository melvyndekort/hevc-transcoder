#!/bin/sh

docker \
  container run \
  --rm \
  -it \
  -v $PWD:/scripts \
  -w /scripts \
  $(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  /bin/sh
