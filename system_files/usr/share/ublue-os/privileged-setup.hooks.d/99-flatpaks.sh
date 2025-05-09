#!/usr/bin/env -S bash
set -euxo pipefail

# Set up Firefox default configuration
if [[ "$(arch)" != "aarch64" ]]; then
  dir="/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/$(arch)"
  mkdir -p "${dir}/stable/defaults/pref"
  rm -f "${dir}/stable/defaults/pref/*{bluefin,bazzite}*.js"
  /usr/bin/cp -rf /usr/share/ublue-os/firefox-config/* \
        "${dir}/stable/defaults/pref/"
fi