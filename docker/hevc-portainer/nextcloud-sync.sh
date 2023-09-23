#!/bin/sh

set -e

rsync --dry-run -a --remove-from-source /source/melvyndekort/files/InstantUpload/Camera/ /target/Smartphones/melvyn/
rsync --dry-run -a --remove-from-source /source/kaatjeislief/files/InstantUpload/Camera/ /target/Smartphones/karin/
rsync --dry-run -a --remove-from-source /source/daandekort/files/InstantUpload/Camera/   /target/Smartphones/daan/

chown -R root:root /target
find /target -type d -exec chmod 755 {} \;
find /target -type f -exec chmod 644 {} \;
