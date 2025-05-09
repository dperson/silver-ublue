#!/usr/bin/env -S bash
set -euxo pipefail

# Allow input access
if ! grep -q "^uinput:" /etc/group; then
  echo "Appending uinput to /etc/group"
  grep "^uinput:" /usr/lib/group | tee -a /etc/group >/dev/null
fi
usermod -aG "uinput" "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"