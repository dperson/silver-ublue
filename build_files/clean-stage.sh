#!/usr/bin/env -S bash
echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

dnf clean all

rm -fr /.gitkeep
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree \
      -exec rm -fr {} \;

## Verify final image and contents are correct.
bootc container lint
echo "::endgroup::"