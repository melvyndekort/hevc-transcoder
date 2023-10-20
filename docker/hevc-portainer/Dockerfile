FROM python:3-slim AS build

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY *.py /opt/venv/bin/


FROM python:3-alpine AS runtime

LABEL org.opencontainers.image.source http://github.com/melvyndekort/hevc-encoder

RUN apk add --update --no-cache rclone aws-cli
RUN mkdir /hevc

COPY --from=build /opt/venv /opt/venv
COPY *.sh /hevc/

ENV PATH="/opt/venv/bin:/hevc:$PATH"
