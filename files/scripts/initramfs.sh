#!/usr/bin/env -S bash

set -euo pipefail

SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$SUFFIX"'-)(\d+\.\d+\.\d+)' |
      sed -E 's/kernel-(|'"$SUFFIX"'-)//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly \
      --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree \
      -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"