#!/usr/bin/env -S bash
echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

rm -rf /tmp/* || :
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree \
      -exec rm -fr {} \;
echo "::endgroup::"