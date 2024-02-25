#!/usr/bin/env bash

set -euo pipefail

git clone https://github.com/Vanilla-OS/vanilla-backgrounds.git /tmp/vanilla
bgdir='/usr/share/backgrounds/vanilla'
mkdir -p ${bgdir}
cp /tmp/vanilla/backgrounds/*{svg,webp} ${bgdir}
sed "s|@BACKGROUNDDIR@|${bgdir}|g" /tmp/vanilla/backgrounds/vanilla.xml.in \
      >/usr/share/gnome-background-properties/vanilla.xml
rm -rf /tmg/vanilla
