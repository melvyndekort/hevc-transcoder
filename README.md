# hevc-encoder

HEVC encode all the MP4 files that are uploaded to an S3 bucket

This repository contains 4 main functions:
* Move files from Nextcloud to persistent storage
* Process .mp4 files by AWS ECS Fargate (conversion to H265 format)
* Re-process uploaded .mp4 files (when processing has failed for some reason)

## Moving files from Nextcloud to persistent storage
Files will be moved from source to target over the WebDAV protocol of Nextcloud using `rclone`.
Not only .mp4 files will be moved, but all files found in the `InstantUpload/Camera` folders of the configured users.
Since this is a server side operation, it runs in a Docker container (`melvyndekort/hevc-portainer`).

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
make sync
```

## Process .mp4 files
Files will be fetched from persistent storage and uploaded to AWS S3 (prefix `TODO/`).
Events will be published for each file which will trigger AWS ECS Fargate containers to start processing.
After files have been processed by AWS ECS Fargate, they will get pushed back to AWS S3 (prefix `DONE/`).
These files will then get downloaded and placed in persistent storage.
Since uploading and downloading are server side operations, it runs in a Docker container (`melvyndekort/hevc-portainer`).
The processing itself happens in the `melvyndekort/hevc-processor` Docker image.

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
make process
```

## Re-process uploaded .mp4 files
In a previous step files have been uploaded to AWS S3, but processing has failed for some reason.
Events will be re-published for each file which will trigger AWS ECS Fargate containers to start processing.
Since uploading is a server side operation, it runs in a Docker container (`melvyndekort/hevc-portainer`).
The processing itself happens in the `melvyndekort/hevc-processor` Docker image.

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
make trigger
```

## TODO
* Implement a skip-upload flag in `process` script
