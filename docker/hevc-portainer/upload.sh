#!/bin/sh

find /data -name '*.mp4' ! -name '*-hevc.mp4' | while read FILE; do
  NEWFILE="$(echo $FILE | sed 's/.mp4$/-hevc.mp4/')"
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key DONE/$NEWFILE && continue
  aws s3api head-object --no-cli-pager --bucket mdekort.hevc --key TODO/$FILE && continue
  aws s3api put-object --no-cli-pager --bucket mdekort.hevc --key TODO/$FILE --body $FILE
done
