# hevc-encoder

HEVC encode all the MP4 files that are uploaded to an S3 bucket

This repository contains 3 main functions:
* Move files from Nextcloud to persistent storage
* Upload .mp4 files to S3 for processing (conversion to H265 format)
* Download processed files from S3 to persistent storage

## Moving files from Nextcloud to persistent storage
Files will be moved from source to target over the WebDAV protocol of Nextcloud using `rclone`.
Not only .mp4 files will be moved, but all files found in the `InstantUpload/Camera` folders of the configured users.
Since this is a server side operation, it runs in a Docker container (`melvyndekort/hevc-portainer`).

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
cd portainer
./alpine.sh
./nextcloud-sync.sh
```

## Uploading .mp4 files to AWS S3
Files will be uploaded from persistent storage and uploaded to AWS S3.
Events will be published for each file which will trigger AWS ECS Fargate containers to start processing.
Since uploading is a server side operation, it runs in a Docker container (`melvyndekort/hevc-portainer`).
The processing itself happens in the `melvyndekort/hevc-processor` Docker image.

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
cd portainer
./alpine.sh
./upload.sh
```

## Downloading processed .mp4 files from AWS S3
After files have been processed by AWS ECS Fargate, they will get pushed to a separate prefix (`DONE/`) in AWS S3.
The download script will download these files and place them in persistent storage.
Since this is a server side operation, it runs in a Docker container (`melvyndekort/hevc-portainer`).

It's possible to run this container on Portainer using a script for convenience purposes:
```bash
cd portainer
./alpine.sh
./download.sh
```
