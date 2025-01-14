#!/usr/bin/env -S bash
set -euxo pipefail

# Allow libvirt access
if ! grep -q "^libvirt:" /etc/group; then
  echo "Appending libvirt to /etc/group"
  grep "^libvirt:" /usr/lib/group | tee -a /etc/group >/dev/null
fi
usermod -aG libvirt "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"