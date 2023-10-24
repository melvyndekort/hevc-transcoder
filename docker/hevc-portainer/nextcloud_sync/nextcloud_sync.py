#!/usr/bin/env python3

import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def main(basedir):
  logger.error('nextcloud-sync is not yet implemented!')

# # File operations using rclone
# for USER in $(env | grep "^NC_PASS_" | cut -d= -f1 | sed 's/^NC_PASS_//'); do
#   OBS_PASS="$(env | grep "^NC_PASS_${USER}" | cut -d= -f2- | rclone obscure -)"
# 
#   rclone config create \
#     --non-interactive \
#     $USER \
#     webdav \
#     url "http://nextcloud/remote.php/dav/files/$USER" \
#     vendor nextcloud \
#     user "$USER" \
#     pass "$OBS_PASS"
# 
#   rclone move -M -v "$USER:InstantUpload/Camera" "$TARGET/Smartphones/$USER"
# 
#   rclone config delete "$USER"
# done
# 
# # Fix permissions of target folder
# echo chown -R root:root "$TARGET"
# echo chmod -R ugo-x,u+rwX,go+rX,go-w "$TARGET"
