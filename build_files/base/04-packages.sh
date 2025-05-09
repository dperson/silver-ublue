#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
version="${FEDORA_MAJOR_VERSION}"
set -euxo pipefail

# All DNF-related operations should be done here whenever possible

# shellcheck source=build_files/copr-helpers.sh
source /ctx/build_files/copr-helpers.sh

# NOTE:
# Packages are split into FEDORA_PACKAGES and COPR_PACKAGES to prevent
# malicious COPRs from injecting fake versions of Fedora packages.
# Fedora packages are installed first in bulk (safe).
# COPR packages are installed individually with isolated enablement.

# Base packages from Fedora repos - common to all versions
FEDORA_PACKAGES=(
  GraphicsMagick
  adcli
  adw-gtk3-theme
  adwaita-fonts-all
  android-tools
  apptainer
  bat
  bpftop
  bpftrace
  btop
  cage
  cockpit-bridge
  cockpit-files
  cockpit-machines
  cockpit-networkmanager
  cockpit-ostree
  cockpit-podman
  cockpit-selinux
  cockpit-storaged
  cockpit-system
  compat-lua
  compat-lua-devel
  cryfs
  davfs2
  docker-compose
  fastfetch
  fd-find
  firewall-config
  fuse-encfs
  fzf
  gh
  git-delta
  git-subtree
  glow
  gnome-shell-extension-gsconnect
  gnome-tweaks
  gum
  ibus-speech-to-text
  ifuse
  input-remapper
  iotop-c
  krb5-workstation
  libcec
  libsss_autofs
  libvirt-daemon-driver-storage-disk
  libvirt-nss
  luarocks
  nautilus-gsconnect
  neovim
  nicstat
  nmap
  nodejs-npm
  numactl
  openssh-askpass
  osbuild-selinux
  p7zip
  p7zip-plugins
  playerctl
  podlet
  podman-docker
  podman-machine
  podman-tui
  powertop
  python3-colorama
  python3-eyed3
  python3-packaging
  python3-pip
  python3-pyclip
  python3-pygit2
  python3-ramalama
  python3-tqdm
  python3-virtualenv
  qemu-kvm
  qemu-user-binfmt
  rclone
  restic
  ripgrep
  rocm-opencl
  rocm-smi
  setools-console
  sssd-ad
  sssd-krb5
  strace
  switcheroo-control
  sysprof
  tailscale
  tio
  tiptop
  trace-cmd
  udica
  usbip
  uv
  virt-viewer
  waydroid
  waypipe
  wlr-randr
  wl-clipboard
  ydotool
  yt-dlp
  yt-dlp-bash-completion
  yt-dlp-zsh-completion
  zenity
  zoxide
  zsh
)
# cosmic-desktop
# git-credential-libsecret
# lm_sensors
# rocm-hip
# waybar #niri

# Version-specific Fedora package additions
case "$FEDORA_MAJOR_VERSION" in
  # 41) FEDORA_PACKAGES+=(
  #   ) ;;
  42) FEDORA_PACKAGES+=(
      complyctl
      evolution-ews-core
    ) ;;
  43) FEDORA_PACKAGES+=(
      complyctl
      evolution-ews-core
    ) ;;
esac

# Install all Fedora packages (bulk - safe from COPR injection)
echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf install --setopt=install_weak_deps=False -y "${FEDORA_PACKAGES[@]}"

# Install COPR packages using isolated enablement (secure)
echo "Installing COPR packages with isolated repo enablement..."

# From ublue-os/staging
copr_install_isolated "ublue-os/staging" \
      "gnome-shell-extension-logo-menu" \
      "gnome-shell-extension-search-light"

# From ublue-os/packages
copr_install_isolated "ublue-os/packages" \
      "ublue-brew" \
      "ublue-motd" \
      "ublue-polkit-rules"

# From karmab/kcli
copr_install_isolated "karmab/kcli" \
      "kcli"

# From yalter/niri
# copr_install_isolated "yalter/niri" \
#       "niri"

# From gmaglione/podman-bootc
# copr_install_isolated "gmaglione/podman-bootc" \
#       "podman-bootc"

# From ganto/umoci
copr_install_isolated "ganto/umoci" \
      "umoci"

# Version-specific COPR packages
case "$FEDORA_MAJOR_VERSION" in
  # 41) ;;
  42) copr_install_isolated "ublue-os/staging" "fw-ectool" "fw-fanctrl" ;;
  # 43) copr_install_isolated "ublue-os/packages" "bazaar" ;;
esac

# Packages to exclude - common to all versions
EXCLUDED_PACKAGES=(
  fedora-bookmarks
  fedora-chromium-config
  fedora-chromium-config-gnome
  firefox
  firefox-langpacks
  gnome-extensions-app
  gnome-terminal-nautilus
  mesa-libxatracker
  yelp
)

# Version-specific package exclusions
case "$FEDORA_MAJOR_VERSION" in
#   41) EXCLUDED_PACKAGES+=() ;;
  42) EXCLUDED_PACKAGES+=(gnome-software) ;;
  43) EXCLUDED_PACKAGES+=(gnome-software) ;;
esac

# Remove excluded packages if they are installed
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  readarray -t INSTALLED_EXCLUDED < <(rpm -qa --queryformat='%{NAME}\n' \
        "${EXCLUDED_PACKAGES[@]}" 2>/dev/null || true)
    if [[ "${#INSTALLED_EXCLUDED[@]}" -gt 0 ]]; then
      dnf remove -y "${INSTALLED_EXCLUDED[@]}"
    else
      echo "No excluded packages found to remove."
    fi
fi


# shellcheck disable=SC2016
thirdparty_repo_install "terra" \
      'terra,https://repos.fyralabs.com/terra$releasever' \
      "terra-release" \
      "terra-release-extras" \
      "terra*"

# Enable Terra repo
# shellcheck disable=SC2016
for i in mesa-filesystem mesa-dri-drivers mesa-libEGL mesa-libGL mesa-libgbm \
      mesa-va-drivers mesa-vulkan-drivers; do
  dnf swap --repo="terra, terra-extras, terra-mesa" \
        --setopt=install_weak_deps=False -y "$i" "$i"
  dnf versionlock add "$i"
done

# Fix for ID in fwupd
dnf swap --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
      --setopt=install_weak_deps=False -y fwupd fwupd

# TODO: remove me on next flatpak release when preinstall landed
if [[ "${FEDORA_MAJOR_VERSION}" -gt 41 ]]; then
  dnf copr enable -y ublue-os/flatpak-test
  dnf copr disable -y ublue-os/flatpak-test
  for i in flatpak flatpak-libs flatpak-session-helper; do
    dnf swap --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test \
          --setopt=install_weak_deps=False -y "$i" "$i"
  done
  # print information about flatpak package, it should say from our copr
  rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
fi

# Pins and Overrides
# Use this section to pin packages in order to avoid regressions
# Remember to leave a note with rationale/link to issue for each pin!
#
# Example:
# if [ "$FEDORA_MAJOR_VERSION" -eq "41" ]; then
#  # Workaround pkcs11-provider regression, see issue #1943
#  rpm-ostree override replace \
#        https://bodhi.fedoraproject.org/updates/FEDORA-2024-dd2e9fb225
# fi

# Use dnf list --showduplicates package
echo "::endgroup::"