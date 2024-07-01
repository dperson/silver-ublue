#!/usr/bin/env bash

set -euo pipefail

curl -LSs $(curl -LSs https://api.github.com/repos/rsms/inter/releases |
      jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip
mkdir -p /tmp/inter /usr/share/fonts/inter
unzip /tmp/inter.zip -d /tmp/inter/
cp /tmp/inter/extras/otf/*.otf /usr/share/fonts/inter/
rm -rf /tmp/inter*
fc-cache --system-only --really-force --verbose