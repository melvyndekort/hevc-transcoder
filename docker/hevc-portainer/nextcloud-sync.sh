#!/bin/sh

set -e

# File operations using rclone
for USER in $(env | grep "^NC_PASS_" | cut -d= -f1 | sed 's/^NC_PASS_//'); do
  OBS_PASS="$(env | grep "^NC_PASS_${USER}" | cut -d= -f2- | rclone obscure -)"

  rclone config create \
    --non-interactive \
    $USER \
    webdav \
    url http://nextcloud/remote.php/dav/files/$USER \
    vendor nextcloud \
    user $USER \
    pass $OBS_PASS

  rclone copy --dry-run -v $USER:InstantUpload/Camera /target/Smartphones/$USER
  rclone purge --dry-run -v $USER:InstantUpload/Camera

  rclone config delete $USER
done

# Fix permissions of target folder
chown -R root:root /target
find /target -type d -exec chmod 755 {} \;
find /target -type f -exec chmod 644 {} \;
