#!/bin/sh

set -e

aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix DONE --query "Contents[].Key" --output yaml | \
sed 's#^- ##' | \
while read FILE; do
  TARGET="$(echo $FILE | sed 's#DONE/##')"
  aws s3api get-object --no-cli-pager --bucket mdekort.hevc --key "$FILE" "/data/$TARGET"
  aws s3api delete-object --no-cli-pager --bucket mdekort.hevc --key "$FILE"

  ORIGINAL="$(echo $TARGET | sed 's/-hevc.mp4$/.mp4/')"
  if [[ -f "/data/$ORIGINAL" ]]; then
    rm -f "/data/$ORIGINAL"
  fi
done
