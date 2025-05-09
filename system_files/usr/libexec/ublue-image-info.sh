#!/usr/bin/env -S bash

# shellcheck disable=2046
IMAGE_INFO_FILE="${IMAGE_INFO_FILE:-/usr/share/ublue-os/image-info.json}"
IMAGE_NAME="$(jq -r '.["image-name"]' <"${IMAGE_INFO_FILE}")"
IMAGE_TAG="$(jq -r '.["image-tag"]' <"${IMAGE_INFO_FILE}")"

echo -n "${IMAGE_NAME}:${IMAGE_TAG}"

# bootc-only images (Dakota, Utah) ship no rpm-ostree; print no marker there.
if command -v rpm-ostree >/dev/null 2>&1; then
  if [[ "$(rpm-ostree status --booted)" =~ "signed" ]]; then
    echo -n " 🔐"
  else
    echo -n -e " \033[5m🔓\033[0m"
  fi
fi