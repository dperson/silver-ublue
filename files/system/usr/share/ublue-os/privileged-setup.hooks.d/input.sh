#!/usr/bin/env -S bash

# Allow input access
#for user in $(getent group wheel | cut -d ":" -f 4 | tr ',' '\n'); do
#done
usermod -aG input "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
usermod -aG uinput "$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
