#!/usr/bin/env -S bash
set -euxo pipefail

# Clear flatpak font cache
flatpak list --app --columns=application,runtime | grep org.gnome.Platform | \
      awk -F '\t' '{print "flatpak run --command=fc-cache " $1 " -f -v"}' | \
      xargs -I % echo "%" | sh