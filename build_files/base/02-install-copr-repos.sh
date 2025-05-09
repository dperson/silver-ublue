#!/usr/bin/env -S bash
# shellcheck disable=SC2016

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Add Staging repo
dnf5 copr enable -y ublue-os/staging

# Add Packages repo
dnf5 copr enable -y ublue-os/packages

# Add bazzite repo
dnf5 copr enable -y kylegospo/bazzite

# Add cosmic repo
#dnf5 copr enable -y ryanabx/cosmic-epoch

# Add kcli repo
dnf5 copr enable -y karmab/kcli

# Add niri repo
#dnf5 copr enable -y yalter/niri

# Add podman-bootc repo
dnf5 copr enable -y gmaglione/podman-bootc

#umoci
dnf5 copr enable -y ganto/umoci

# Add Tailscale repo
dnf5 config-manager addrepo -y \
      --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

# Add Terra repo
dnf5 install --nogpgcheck -y --repofrompath \
      'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 install --setopt=install_weak_deps=False -y terra-release-extras || :
# dnf5 config-manager setopt "terra*".enabled=0
echo "::endgroup::"