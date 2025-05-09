#!/usr/bin/env -S bash

set -euxo pipefail

mkdir -p /var/roothome

echo "::group:: Copy Files"
# Copy ISO list for `install-system-flaptaks`
install -Dm0644 -t /etc/ublue-os/ /ctx/build_files/iso/*.list

# Copy Files to Container
rsync -Krtv /ctx/system_files/ /

mkdir -p /tmp/scripts/helpers
install -Dm0755 /ctx/build_files/utils/ghcurl /tmp/scripts/helpers/ghcurl
export PATH="/tmp/scripts/helpers:$PATH"
echo "::endgroup::"

# Generate image-info.json
/ctx/build_files/base/00-image-info.sh

# Install Kernel and Akmods
/ctx/build_files/base/03-install-kernel-akmods.sh

# Install Additional Packages
/ctx/build_files/base/04-packages.sh

# Install Overrides and Fetch Install
/ctx/build_files/base/05-override-install.sh

# Get Firmare for Framework
/ctx/build_files/base/08-firmware.sh

## late stage changes

# Install fonts
/ctx/build_files/base/12-fonts.sh

# Setup quadlets
/ctx/build_files/base/13-quadlets.sh

# Systemd and Remove Items
/ctx/build_files/base/17-cleanup.sh

# Run workarounds for lf (Likely not needed)
/ctx/build_files/base/18-workarounds.sh

# Regenerate initramfs
/ctx/build_files/base/19-initramfs.sh

# Validate all repos are disabled before committing
/ctx/build_files/validate-repos.sh

# Clean Up
echo "::group:: Cleanup"
/ctx/build_files/clean-stage.sh
mkdir -p /var/tmp && chmod -R 1777 /var/tmp

ostree container commit
echo "::endgroup::"

# Simple Tests
/ctx/build_files/base/20-tests.sh