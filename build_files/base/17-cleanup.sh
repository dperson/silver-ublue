#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Setup Systemd
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service
systemctl enable dconf-update.service
systemctl enable ublue-guest-user.service
systemctl --global enable bazaar.service
systemctl enable brew-setup.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl enable ublue-fix-hostname.service
systemctl enable ublue-system-setup.service
systemctl --global enable ublue-user-setup.service
systemctl --global enable podman-auto-update.timer
systemctl enable btrfs-dedup.timer
systemctl enable cec-onboot.service
systemctl enable cec-onpoweroff.service
systemctl enable cec-onsleep.service
systemctl enable check-sb-key.service
systemctl enable fwupd-refresh.timer
systemctl enable libvirt-workaround.service
systemctl enable podman-auto-update.timer
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable ublue-etc-merge.service
systemctl disable pmie.service
systemctl disable pmlogger.service
systemctl disable waydroid-container.service

# run flatpak preinstall once at startup
systemctl enable flatpak-preinstall.service

# Updater
if systemctl cat -- uupd.timer &>/dev/null; then
  systemctl enable uupd.timer
else
  systemctl enable rpm-ostreed-automatic.timer
  systemctl enable flatpak-system-update.timer
  systemctl --global enable flatpak-user-update.timer
fi

# Hide Desktop Files. Hidden removes mime associations
grep -irl 'Terminal=true' /usr/share/applications | while read -r i; do
  sed -i 's|\[Desktop Entry\]|\[Desktop Entry\]\nHidden=true|g' "${i}"
done

#Add the Flathub Flatpak remote and remove the Fedora Flatpak remote
flatpak remote-add --system --if-not-exists flathub \
      https://flathub.org/repo/flathub.flatpakrepo
systemctl mask flatpak-add-fedora-repos.service || :

# NOTE: With isolated COPR installation, most repos are never enabled globally.
# We only need to clean up repos that were enabled during the build process.

# Disable third-party repos
for repo in fedora-cisco-openh264 negativo17-fedora-multimedia tailscale; do
  if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
  fi
done

# Disable Terra repos
for i in /etc/yum.repos.d/terra*.repo; do
  if [[ -f "$i" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "$i"
  fi
done

# Disable all COPR repos (should already be disabled by helpers, but ensure)
for i in /etc/yum.repos.d/_copr:*.repo; do
  if [[ -f "$i" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "$i"
  fi
done

# NOTE: we won't use dnf copr plugin for ublue-os/akmods until our upstream
# provides the COPR standard naming
if [[ -f "/etc/yum.repos.d/_copr_ublue-os-akmods.repo" ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
fi

# Disable RPM Fusion repos
for i in /etc/yum.repos.d/rpmfusion-*.repo; do
  if [[ -f "$i" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "$i"
  fi
done

# Disable fedora-coreos-pool if it exists
if [ -f /etc/yum.repos.d/fedora-coreos-pool.repo ]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-coreos-pool.repo
fi
echo "::endgroup::"