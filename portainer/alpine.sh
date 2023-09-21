#!/bin/sh

docker container run --rm -it -v $PWD:/scripts -w /scripts alpine:latest /bin/sh
