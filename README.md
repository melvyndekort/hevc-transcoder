# HEVC-ENCODER

## Badges

### Quality

[![codecov](https://codecov.io/gh/melvyndekort/hevc-encoder/graph/badge.svg?token=nRCqhWXgk5)](https://codecov.io/gh/melvyndekort/hevc-encoder) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/486c1b59dad14aedbcac48b252759f83)](https://app.codacy.com/gh/melvyndekort/hevc-encoder/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade) [![Maintainability](https://api.codeclimate.com/v1/badges/9dee905ee45a47d97c9f/maintainability)](https://codeclimate.com/github/melvyndekort/hevc-encoder/maintainability)

### Workflows

![docker hevc-portainer](https://github.com/melvyndekort/hevc-encoder/actions/workflows/docker-hevc-portainer.yml/badge.svg) ![docker hevc-processor](https://github.com/melvyndekort/hevc-encoder/actions/workflows/docker-hevc-processor.yml/badge.svg) ![terraform](https://github.com/melvyndekort/hevc-encoder/actions/workflows/terraform.yml/badge.svg)

## Purpose

Re-encode all H.264 encoded video files to H.265.

## Technology

Since recoding is a slow and resource hungry, we'd like to have the power of scaling out.

* Docker - self-contained and immutable container platform
* Amazon ECS - fully managed container orchestrator
* AWS Fargate - serverless compute engine
* Amazon S3 - temporary block storage for video files
* Amazon EventBridge - event bus which triggers ECS on S3 events
* FFmpeg - open source transcoder

## Process

The entire process looks like this:

1. hevc-portainer searches the filesystem and uploads video files to S3 (`TODO/` prefix)
2. S3 sends an upload event to EventBridge
3. EventBridge triggers a new ECS task (hevc-processor)
4. hevc-processor downloads the file from S3
5. hevc-processor transcodes the file to H.265
6. hevc-processor uploads the file to S3 (`DONE/` prefix)
7. hevc-portainer downloads the file from S3

![Flow diagram](docs/flow.png "Flow")

## Build & deploy

GitHub actions workflows will build the Docker containers and configure the AWS infrastructure with Terraform.
The `hevc-portainer` container gets deployed by [dockersetup](https://github.com/melvyndekort/dockersetup).

## Development

There are basically 3 main folders within this repository:

* hevc-portainer
* hevc-processor
* terraform

### hevc-portainer

This folder contains a Python project which does the local processing.
The project uses **poetry** for dependency management and **pytest** for unit testing.
There is a **Dockerfile** to build the deployable container.

### hevc-processor

This folder contains a simple **bash** script that coordinates S3 and ffmpeg.
There is a **Dockerfile** to build the deployable container.

### terraform

This folder contains all the **terraform** code to set up the entire infrastructure within AWS.

## Makefile

There is a **Makefile** with a few targets to make life easier:

* `clean` - delete all generated files
* `install` - download and install the Python dependencies
* `test` - run unit tests
* `build` - create a build (Python wheel)
* `full-build` - build the **hevc-portainer** docker container
* `plan` - run `terraform plan`
* `apply` - run `terraform apply`
