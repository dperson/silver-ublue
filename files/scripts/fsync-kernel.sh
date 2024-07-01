#!/usr/bin/env -S bash

set -euo pipefail

# inspired by: https://github.com/antuan1996/formile-cachyos-ublue

ver=""

echo 'Enable SElinux policy'
setsebool -P domain_kernel_load_modules on

echo 'fsync kernel override'
rpm-ostree cliwrap install-to-root / &&
rpm-ostree override replace --experimental --freeze \
      --from repo='copr:copr.fedorainfracloud.org:sentry:kernel-fsync' \
      kernel${ver:+-$ver} \
      kernel-core${ver:+-$ver} \
      kernel-modules${ver:+-$ver} \
      kernel-modules-core${ver:+-$ver} \
      kernel-modules-extra${ver:+-$ver}