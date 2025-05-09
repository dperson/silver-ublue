#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Setup Systemd
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service
systemctl enable dconf-update.service
systemctl enable ublue-guest-user.service
systemctl enable brew-setup.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl enable check-sb-key.service
systemctl enable ublue-fix-hostname.service
systemctl enable ublue-system-setup.service
systemctl --global enable ublue-user-setup.service
systemctl --global enable podman-auto-update.timer
systemctl enable btrfs-dedup.timer
systemctl enable cec-onboot.service
systemctl enable cec-onpoweroff.service
systemctl enable cec-onsleep.service
systemctl enable fwupd-refresh.timer
systemctl enable libvirt-workaround.service
systemctl enable podman-auto-update.timer
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable ublue-etc-merge.service
systemctl enable flatpak-add-fedora-repos.service
systemctl disable pmie.service
systemctl disable pmlogger.service
systemctl disable waydroid-container.service

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

# Disable all COPRs and RPM Fusion Repos
dnf5 copr disable -y ublue-os/staging
dnf5 copr disable -y ublue-os/packages
dnf5 copr disable -y kylegospo/bazzite
#dnf5 copr disable -y ryanabx/cosmic-epoch
dnf5 copr disable -y karmab/kcli
#dnf5 copr disable -y yalter/niri
dnf5 copr disable -y gmaglione/podman-bootc
dnf5 copr disable -y ganto/umoci
# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream
# provides the COPR standard naming
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
for i in /etc/yum.repos.d/{fedora-coreos,negativo17,rpmfusion,terra}*; do
  if [[ -f $i ]]; then
    sed -i 's@enabled=1@enabled=0@g' "$i"
  fi
done
echo "::endgroup::"