#!/bin/sh

if [ "$S3_BUCKET_NAME" == "" ]; then
  echo "S3_BUCKET_NAME variable wasn't set"
  exit 254
fi
if [ "$S3_OBJECT_KEY" == "" ]; then
  echo "S3_OBJECT_KEY variable wasn't set"
  exit 253
fi

ENDPOINT="https://s3.dualstack.${AWS_REGION}.amazonaws.com"
TARGET_OBJECT_KEY="$(echo $S3_OBJECT_KEY | sed 's/^TODO/DONE/; s/.mp4$/-hevc.mp4/')"

echo "Processing $S3_OBJECT_KEY from $S3_BUCKET_NAME"

echo "Downloading source file from S3"
aws s3api get-object \
  --endpoint-url "$ENDPOINT" \
  --no-cli-pager \
  --bucket "$S3_BUCKET_NAME" \
  --key "$S3_OBJECT_KEY" \
  source.mp4 || exit 252

echo "Converting file to HEVC format"
ffmpeg -nostdin \
  -i source.mp4 \
  -c:v libx265 \
  -crf 26 \
  -preset fast \
  -c:a copy \
  target.mp4 || exit 251

echo "Uploading converted file back to S3"
aws s3api put-object \
  --endpoint-url "$ENDPOINT" \
  --no-cli-pager \
  --bucket "$S3_BUCKET_NAME" \
  --key "$TARGET_OBJECT_KEY" \
  --body target.mp4 || exit 250

echo "Deleting original file from S3"
aws s3api delete-object \
  --endpoint-url "$ENDPOINT" \
  --no-cli-pager \
  --bucket "$S3_BUCKET_NAME" \
  --key "$S3_OBJECT_KEY" || exit 249
