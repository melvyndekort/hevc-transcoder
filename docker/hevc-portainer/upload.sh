#!/bin/sh

find . -name '*.mp4' ! -name '*-hevc.mp4' | while read FILE; do

  # Delete file when processed file is already present
  DONE_FILE="$(echo $FILE | sed 's/.mp4$/-hevc.mp4/')"
  if [[ -f "$DONE_FILE" ]]; then
    echo rm -f "$FILE"
    continue
  fi

  # Skip if file is already processed and ready for download
  DONE_KEY="$(echo $KEY | sed 's/.mp4$/-hevc.mp4/')"
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key DONE/$DONE_KEY && continue

  # Skip if file is already waiting to be processed on S3
  KEY="$(echo $FILE | sed 's/^.\///')"
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key TODO/$KEY && continue

  # Upload to S3 for processing
  aws s3api put-object --no-cli-pager --bucket mdekort.hevc --key TODO/$KEY --body $FILE
done
