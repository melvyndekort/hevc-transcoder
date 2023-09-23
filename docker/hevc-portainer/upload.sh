#!/bin/sh

find . -name '*.mp4' ! -name '*-hevc.mp4' | while read FILE; do
  DONE_FILE="$(echo $FILE | sed 's/.mp4$/-hevc.mp4/')"
  if [[ -f "$DONE_FILE" ]]; then
    echo rm -f "$FILE"
    continue
  fi
  KEY="$(echo $FILE | sed 's/^.\///')"
  DONE_KEY="$(echo $KEY | sed 's/.mp4$/-hevc.mp4/')"
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key DONE/$DONE_KEY && continue
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key TODO/$KEY && continue
  aws s3api put-object --no-cli-pager --bucket mdekort.hevc --key TODO/$KEY --body $FILE
done
