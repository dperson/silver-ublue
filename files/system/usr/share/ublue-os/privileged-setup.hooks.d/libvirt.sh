#!/usr/bin/env -S bash

# Allow libvirt access
usermod -aG libvirt "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
