#!/usr/bin/env -S bash

# Allow input access
usermod -aG input "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
usermod -aG uinput "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
