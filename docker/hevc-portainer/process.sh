#!/bin/sh

exec_upload() {
  find . -name '*.mp4' ! -name '*-hevc.mp4' | while read FILE; do
    echo "Processing $FILE"

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
    echo "Uploading $FILE"
    aws s3api put-object --no-cli-pager --bucket mdekort.hevc --key TODO/$KEY --body $FILE
  done
}

keep_going() {
  TODO=$(aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix TODO --query "length(Contents)" --output text 2>/dev/null || echo 0)
  DONE=$(aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix DONE --query "length(Contents)" --output text 2>/dev/null || echo 0)

  [ "$DONE" -gt 0 ] || [ "$TODO" -gt 0 ] && return 0
  return 1
}

exec_download() {
  # List files that are ready for download
  aws s3api list-objects-v2 --no-cli-pager --bucket mdekort.hevc --prefix DONE --query "Contents[].Key" --output text | tr '\t' '\n' | \
  while read KEY; do
    echo "Downloading $KEY"

    # Download processed file
    TARGET="$(echo $KEY | sed 's#^DONE/##')"
    aws s3api get-object --no-cli-pager --bucket mdekort.hevc --key "$KEY" "$TARGET" || :

    # Delete downloaded file
    aws s3api delete-object --no-cli-pager --bucket mdekort.hevc --key "$KEY" || :

    # Delete unprocessed file on disk after processed file is downloaded
    ORIGINAL="$(echo $TARGET | sed 's/-hevc.mp4$/.mp4/')"
    if [[ -f "$ORIGINAL" ]]; then
      rm -f "$ORIGINAL"
    fi
  done
}

exec_upload

while keep_going; do
  exec_download
  sleep 300
done
