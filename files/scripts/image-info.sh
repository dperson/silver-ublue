#!/usr/bin/env -S bash

set -euxo pipefail

BASE_IMAGE_NAME="silver-ublue"
FEDORA_MAJOR_VERSION="$(awk -F'=' '/VERSION_ID/ {print $2}' /etc/os-release)"
IMAGE_FLAVOR="main"
IMAGE_VENDOR="dperson"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

case $FEDORA_MAJOR_VERSION in
  40) IMAGE_TAG="gts" ;;
  41) IMAGE_TAG="stable" ;;
  42) IMAGE_TAG="beta,latest" ;;
  *) IMAGE_TAG="$FEDORA_MAJOR_VERSION" ;;
esac

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$IMAGE_FLAVOR",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag": "$IMAGE_TAG",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_MAJOR_VERSION"
}
EOF