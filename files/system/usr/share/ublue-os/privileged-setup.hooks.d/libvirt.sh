#!/usr/bin/env -S bash

# Allow libvirt access
#for user in $(getent group wheel | cut -d ":" -f 4 | tr ',' '\n'); do
#done
usermod -aG libvirt "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
