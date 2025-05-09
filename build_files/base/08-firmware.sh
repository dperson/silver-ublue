#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
url="https://gitlab.com/kernel-firmware/linux-firmware/-/raw"
url+="/8f08053b2a7474e210b03dbc2b4ba59afbe98802/mediatek"
set -euxo pipefail

mkdir -p /tmp/mediatek-firmware
curl --retry 3 -LSfso /tmp/mediatek-firmware/WIFI_MT7922_patch_mcu_1_1_hdr.bin \
      "${url}/WIFI_MT7922_patch_mcu_1_1_hdr.bin?inline=false"
curl --retry 3 -LSfso /tmp/mediatek-firmware/WIFI_RAM_CODE_MT7922_1.bin \
      "${url}/WIFI_RAM_CODE_MT7922_1.bin?inline=false"
xz --check=crc32 /tmp/mediatek-firmware/WIFI_MT7922_patch_mcu_1_1_hdr.bin
xz --check=crc32 /tmp/mediatek-firmware/WIFI_RAM_CODE_MT7922_1.bin
mv -vf /tmp/mediatek-firmware/* /usr/lib/firmware/mediatek/
rm -rf /tmp/mediatek-firmware
echo "::endgroup::"