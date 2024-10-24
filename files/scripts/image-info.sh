#!/usr/bin/env -S bash

set -euxo pipefail

BASE_IMAGE_NAME="silverblue"
FEDORA_MAJOR_VERSION=40
IMAGE_FLAVOR="main"
IMAGE_VENDOR="dperson"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

case $FEDORA_MAJOR_VERSION in
  39)
    IMAGE_TAG="gts"
    ;;
  40)
    IMAGE_TAG="latest"
    ;;
  *)
    IMAGE_TAG="$FEDORA_MAJOR_VERSION"
    ;;
esac

cat > $IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$IMAGE_FLAVOR",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"$IMAGE_TAG",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_MAJOR_VERSION"
}
EOF