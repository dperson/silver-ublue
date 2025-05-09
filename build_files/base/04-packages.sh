#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
version="${FEDORA_MAJOR_VERSION}"
set -euxo pipefail

# build list of all packages requested for inclusion
readarray -t INCLUDED_PACKAGES < <(jq -r "[(.all.include | \
      (select(.all != null).all)[]), \
      (select(.\"$version\" != null).\"$version\".include | \
      (select(.all != null).all)[])] | sort | unique[]" /tmp/packages.json)

# Install Packages
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  dnf5 install --setopt=install_weak_deps=False -y "${INCLUDED_PACKAGES[@]}"
else
  echo "No packages to install."
fi

# build list of all packages requested for exclusion
readarray -t EXCLUDED_PACKAGES < <(jq -r "[(.all.exclude | \
      (select(.all != null).all)[]), \
      (select(.\"$version\" != null).\"$version\".exclude | \
      (select(.all != null).all)[])] | sort | unique[]" /tmp/packages.json)

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  readarray -t EXCLUDED_PACKAGES < \
        <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}")
fi

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  dnf5 remove -y "${EXCLUDED_PACKAGES[@]}"
else
  echo "No packages to remove."
fi
echo "::endgroup::"