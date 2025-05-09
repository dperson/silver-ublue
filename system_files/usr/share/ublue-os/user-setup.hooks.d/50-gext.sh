#!/usr/bin/env -S bash
set -euxo pipefail

# Install Gnome Extensions that don't work installed to system
for i in gtk4-ding@smedius.gitlab.com wiggly@mojarch; do
  gext list --only-uuid | grep -q "$i" || gext install "$i"
done