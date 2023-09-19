#!/bin/sh

set -e

REGION="$(aws configure get region)"
ENDPOINT="https://s3.dualstack.${REGION}.amazonaws.com"
TARGET_OBJECT_KEY="$(echo $S3_OBJECT_KEY | sed 's/^TODO/DONE/; s/.mp4$/-hevc.mp4/')"

echo "Processing $S3_OBJECT_KEY from $S3_BUCKET_NAME"

echo "Downloading source file from S3"
aws s3api get-object \
  --no-paginate \
  --bucket $S3_BUCKET_NAME \
  --key "$S3_OBJECT_KEY" \
  --endpoint-url $ENDPOINT \
  source.mp4

echo "Converting file to HEVC format"
ffmpeg -nostdin \
  -i source.mp4 \
  -c:v libx265 \
  -crf 26 \
  -preset fast \
  -c:a copy \
  target.mp4

echo "Uploading converted file back to S3"
aws s3api put-object \
  --no-paginate \
  --bucket $S3_BUCKET_NAME \
  --key "$TARGET_OBJECT_KEY" \
  --body target.mp4 \
  --endpoint-url $ENDPOINT

echo "Deleting original file from S3"
aws s3api delete-object \
  --no-paginate \
  --bucket $S3_BUCKET_NAME \
  --key "$S3_OBJECT_KEY" \
  --endpoint-url $ENDPOINT
