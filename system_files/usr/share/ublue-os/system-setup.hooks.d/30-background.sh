#!/usr/bin/env -S bash
set -euo pipefail

# Automatic wallpaper changing by month
sed -i "/picture-uri/ s/[0-9][0-9]/$(date +%m)/" \
      /etc/dconf/db/distro.d/03-bluefin-gnome