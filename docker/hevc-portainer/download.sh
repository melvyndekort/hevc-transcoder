#!/bin/sh

set -e

aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix DONE --query "Contents[].Key" --output text | tr '\t' '\n' | \
while read KEY; do
  TARGET="$(echo $KEY | sed 's#^DONE/##')"
  aws s3api get-object --no-cli-pager --bucket mdekort.hevc --key "$KEY" "$TARGET"
  aws s3api delete-object --no-cli-pager --bucket mdekort.hevc --key "$KEY"

  ORIGINAL="$(echo $TARGET | sed 's/-hevc.mp4$/.mp4/')"
  if [[ -f "$ORIGINAL" ]]; then
    rm -f "$ORIGINAL"
  fi
done
