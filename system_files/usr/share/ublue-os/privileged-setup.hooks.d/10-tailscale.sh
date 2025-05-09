#!/usr/bin/env -S bash
set -euxo pipefail

# Allow Tailscale Control
tailscale set --operator="$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"