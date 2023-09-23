#!/bin/sh

# Sync pictures to their target folders
rsync --dry-run -av --remove-source-files /source/melvyndekort/files/InstantUpload/Camera/ /target/Smartphones/melvyn/
rsync --dry-run -av --remove-source-files /source/kaatjeislief/files/InstantUpload/Camera/ /target/Smartphones/karin/
rsync --dry-run -av --remove-source-files /source/daandekort/files/InstantUpload/Camera/   /target/Smartphones/daan/

# Remove empty directories
find /source/melvyndekort/files -type d -empty -delete
find /source/kaatjeislief/files -type d -empty -delete
find /source/daandekort/files   -type d -empty -delete

# Rebuild the nextcloud index
docker exec --user www-data nextcloud php occ files:scan --all
docker exec --user www-data nextcloud php occ files:repair-tree

# Fix permissions of target folder
chown -R root:root /target
find /target -type d -exec chmod 755 {} \;
find /target -type f -exec chmod 644 {} \;
