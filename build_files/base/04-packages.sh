#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
version="${FEDORA_MAJOR_VERSION}"
set -euxo pipefail

# build list of all packages requested for inclusion
readarray -t INCLUDED_PACKAGES < <(jq -r "[(.all.include | \
      (select(.all != null).all)[]), \
      (select(.\"$version\" != null).\"$version\".include | \
      (select(.all != null).all)[])] | sort | unique[]" /tmp/packages.json)

# build list of all packages requested for exclusion
readarray -t EXCLUDED_PACKAGES < <(jq -r "[(.all.exclude | \
      (select(.all != null).all)[]), \
      (select(.\"$version\" != null).\"$version\".exclude | \
      (select(.all != null).all)[])] | sort | unique[]" /tmp/packages.json)

# Filter out excluded packages from the include list
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 &&
      "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  readarray -t INCLUDED_PACKAGES < <(printf '%s\n' "${INCLUDED_PACKAGES[@]}" |
        grep -Fvxf <(printf '%s\n' "${EXCLUDED_PACKAGES[@]}"))
fi

# Install Packages
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  dnf5 install --setopt=install_weak_deps=False -y "${INCLUDED_PACKAGES[@]}"
else
  echo "No packages to install."
fi

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