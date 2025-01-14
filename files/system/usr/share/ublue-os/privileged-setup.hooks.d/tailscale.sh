#!/usr/bin/env -S bash

# Allow Tailscale Control
tailscale set --operator="$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
