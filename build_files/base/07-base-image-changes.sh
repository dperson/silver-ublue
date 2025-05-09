#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Add Mutter experimental-features
if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
  sed -i "/experimental-features/ s|\\[|['kms-modifiers',|" \
        /etc/dconf/db/distro.d/03-bluefin-gnome
fi
echo "::endgroup::"