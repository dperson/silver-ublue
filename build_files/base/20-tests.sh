#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# If this file is not on the image bazaar will automatically be removed from
# users systems :( See:
# https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-preinstall
test -f /usr/share/flatpak/preinstall.d/bazaar.preinstall

# Basic smoke test to check if the flatpak version is from our copr
flatpak preinstall --help

# Make sure this garbage never makes it to an image
test -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service && false

IMPORTANT_PACKAGES=(
  distrobox
  flatpak
  gdm
  gnome-shell
  mutter
  neovim
  pipewire
  ptyxis
  systemd
  tailscale
  wireplumber
  zsh
)

for package in "${IMPORTANT_PACKAGES[@]}"; do
  rpm -q "${package}" >/dev/null ||
        { echo "Missing package: ${package}... Exiting"; exit 1 ; }
done

# these packages are supposed to be removed
# and are considered footguns
UNWANTED_PACKAGES=(
  firefox
  gnome-software
  gnome-software-rpm-ostree
  gtk2
  perl
)

for package in "${UNWANTED_PACKAGES[@]}"; do
  if rpm -q "${package}" >/dev/null 2>&1; then
    echo "Unwanted package found: ${package}... Exiting"; exit 1
  fi
done

if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
  NV_PACKAGES=(
    libnvidia-container-tools
    kmod-nvidia
    nvidia-driver-cuda
  )
  for package in "${NV_PACKAGES[@]}"; do
    rpm -q "${package}" >/dev/null ||
          { echo "Missing NVIDIA package: ${package}... Exiting"; exit 1 ; }
  done
fi

IMPORTANT_UNITS=(
  brew-update.timer
  brew-upgrade.timer
  flatpak-system-update.timer
  rpm-ostreed-automatic.timer
  rpm-ostree-countme.timer
  tailscaled.service
  ublue-system-setup.service
)

for unit in "${IMPORTANT_UNITS[@]}"; do
  if ! systemctl is-enabled "$unit" 2>/dev/null | grep -q "^enabled$"; then
    echo "${unit} is not enabled"
    exit 1
  fi
done
echo "::endgroup::"