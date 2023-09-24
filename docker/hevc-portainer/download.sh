#!/bin/sh

set -e

# List files that are ready for download
aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix DONE --query "Contents[].Key" --output text | tr '\t' '\n' | \
while read KEY; do
  # Download processed file
  TARGET="$(echo $KEY | sed 's#^DONE/##')"
  aws s3api get-object --no-cli-pager --bucket mdekort.hevc --key "$KEY" "$TARGET"

  # Delete downloaded file
  aws s3api delete-object --no-cli-pager --bucket mdekort.hevc --key "$KEY"

  # Delete unprocessed file on disk after processed file is downloaded
  ORIGINAL="$(echo $TARGET | sed 's/-hevc.mp4$/.mp4/')"
  if [[ -f "$ORIGINAL" ]]; then
    rm -f "$ORIGINAL"
  fi
done
