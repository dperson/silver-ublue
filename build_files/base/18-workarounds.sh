#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Remove broken setting that got pulled in (will be removed in F43)
if [[ "${FEDORA_MAJOR_VERSION}" -lt 43 ]]; then
  rm -f /usr/lib/sysctl.d/10-default-yama-scope.conf || :
fi

# Fix power button
sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' \
      /usr/lib/systemd/logind.conf

# Enable faillock in PAM authentication profile
authselect enable-feature with-faillock -q

# Fix waydroid
sed -Ei 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' \
      /usr/lib/waydroid/data/scripts/waydroid-net.sh
sed -i 's@=waydroid first-launch@=/usr/bin/waydroid-launcher first-launch\
X-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\
X-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\
X-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\
X-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-capsule.png\
X-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop
url='https://raw.githubusercontent.com/Quackdoc/waydroid-scripts/main'
ghcurl "${url}/waydroid-choose-gpu.sh" -o /usr/bin/waydroid-choose-gpu
chmod +x /usr/bin/waydroid-choose-gpu

# Make needed directory
mkdir -pv /etc/containers/registries.d/ghcr.io

# Fix some broken apps libdrm links
cp -d /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so
echo "::endgroup::"