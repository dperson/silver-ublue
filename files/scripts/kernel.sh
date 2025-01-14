#!/usr/bin/env -S bash

set -euo pipefail

# inspired by: https://github.com/antuan1996/formile-cachyos-ublue

ver=""

echo 'Enable SElinux policy'
setsebool -P domain_kernel_load_modules on

FEDORA_MAJOR_VERSION=$(awk -F'=' '/VERSION_ID/ {print $2}' /etc/os-release)
if [[ $FEDORA_MAJOR_VERSION -lt 41 ]]; then
  repo='copr:copr.fedorainfracloud.org:sentry:kernel-fsync'
else
  repo='copr:copr.fedorainfracloud.org:sentry:kernel-blu'
fi

echo 'fsync kernel override'
rpm-ostree cliwrap install-to-root / &&
rpm-ostree override replace --experimental --freeze --from repo="$repo" \
      kernel${ver:+-$ver} \
      kernel-core${ver:+-$ver} \
      kernel-modules${ver:+-$ver} \
      kernel-modules-core${ver:+-$ver} \
      kernel-modules-extra${ver:+-$ver}