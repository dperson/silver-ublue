#!/usr/bin/env -S bash
set -euxo pipefail

# Set up Firefox default configuration
ARCH=$(arch)
if [[ "$ARCH" != "aarch64" ]]; then
  dir="/var/lib/flatpak/extension/org.mozilla.firefox.systemconfig"
	mkdir -p "${dir}/${ARCH}/stable/defaults/pref"
	rm -f "${dir}/${ARCH}/stable/defaults/pref/*bluefin*.js"
	/usr/bin/cp -rf /usr/share/ublue-os/firefox-config/* \
        "${dir}/${ARCH}/stable/defaults/pref/"
fi
