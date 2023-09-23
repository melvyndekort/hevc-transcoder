#!/bin/sh

set -e

rsync --dry-run -a --remove-source-files /source/melvyndekort/files/InstantUpload/Camera/ /target/Smartphones/melvyn/
rsync --dry-run -a --remove-source-files /source/kaatjeislief/files/InstantUpload/Camera/ /target/Smartphones/karin/
rsync --dry-run -a --remove-source-files /source/daandekort/files/InstantUpload/Camera/   /target/Smartphones/daan/

find /source/melvyndekort/files -type d -empty -delete
find /source/kaatjeislief/files -type d -empty -delete
find /source/daandekort/files   -type d -empty -delete

chown -R root:root /target
find /target -type d -exec chmod 755 {} \;
find /target -type f -exec chmod 644 {} \;
