FROM python:3-slim AS base

RUN pip install --upgrade pip
RUN pip install "poetry>=1.6,<1.7"


RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"


FROM base as build

COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt | pip install -r /dev/stdin

COPY . .
RUN poetry build && pip install dist/*.whl


FROM python:3-alpine AS runtime

LABEL org.opencontainers.image.source http://github.com/melvyndekort/hevc-encoder

RUN apk add --update --no-cache ffmpeg x265

COPY --from=build /venv /venv

ENV PATH="/venv/bin:$PATH"

CMD ["python3", "-m", "hevc_transcoder.processor"]
