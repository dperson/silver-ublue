#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

get_git_pkg() { local prj="$1" pat="$2" out="$3" url \
      i="$([[ ${4:-} ]] &&echo "[]|select(.tag_name|test(\"$5\"))"||echo "[0]")"
  local filter=".$i.assets[]|select(.name|test(\"$pat\")).browser_download_url"
  url=$(ghcurl "https://api.github.com/repos/$prj/releases" | jq -r "$filter")
  ghcurl "$url" -o "$out"
}

# Fix broken link
[[ -L /usr/share/fonts/noto-cjk ]] &&
  ln -sf google-noto-sans-mono-cjk-vf-fonts /usr/share/fonts/noto-cjk

# CascadiaCode
get_git_pkg "ryanoasis/nerd-fonts" "CascadiaCode.zip" "/tmp/caskaydia.zip"
mkdir -p /tmp/caskaydia /usr/share/fonts/NerdFonts
unzip -q /tmp/caskaydia.zip -d /tmp/caskaydia/
cp /tmp/caskaydia/CaskaydiaCoveNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/CaskaydiaCoveNerdFont.ttf
rm -rf /tmp/caskaydia*

# Intel One
get_git_pkg "ryanoasis/nerd-fonts" "IntelOneMono.zip" "/tmp/intone.zip"
mkdir -p /tmp/intone /usr/share/fonts/NerdFonts
unzip -q /tmp/intone.zip -d /tmp/intone/
cp /tmp/intone/IntoneMonoNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/IntoneMonoNerdFont.ttf
rm -rf /tmp/intone*

# JetBrains
get_git_pkg "ryanoasis/nerd-fonts" "JetBrainsMono.zip" "/tmp/jet.zip"
mkdir -p /tmp/jet /usr/share/fonts/NerdFonts
unzip -q /tmp/jet.zip -d /tmp/jet/
cp /tmp/jet/JetBrainsMonoNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/JetBrainsMonoNerdFont.ttf
rm -rf /tmp/jet*

# Monaspace
get_git_pkg "ryanoasis/nerd-fonts" "Monaspace.zip" "/tmp/mona.zip"
mkdir -p /tmp/mona /usr/share/fonts/NerdFonts
unzip -q /tmp/mona.zip -d /tmp/mona/
cp /tmp/mona/MonaspiceArNerdFontPropo-Regular.otf \
      /usr/share/fonts/NerdFonts/MonaspiceArNerdFont.otf
cp /tmp/mona/MonaspiceKrNerdFontPropo-Regular.otf \
      /usr/share/fonts/NerdFonts/MonaspiceKrNerdFont.otf
cp /tmp/mona/MonaspiceNeNerdFontPropo-Regular.otf \
      /usr/share/fonts/NerdFonts/MonaspiceNeNerdFont.otf
cp /tmp/mona/MonaspiceRnNerdFontPropo-Regular.otf \
      /usr/share/fonts/NerdFonts/MonaspiceRnNerdFont.otf
cp /tmp/mona/MonaspiceXeNerdFontPropo-Regular.otf \
      /usr/share/fonts/NerdFonts/MonaspiceXeNerdFont.otf
rm -rf /tmp/mona*

# SourceCodePro
get_git_pkg "ryanoasis/nerd-fonts" "SourceCodePro.zip" "/tmp/sauce.zip"
mkdir -p /tmp/sauce /usr/share/fonts/NerdFonts
unzip -q /tmp/sauce.zip -d /tmp/sauce/
cp /tmp/sauce/SauceCodeProNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/SauceCodeProNerdFont.ttf
rm -rf /tmp/sauce*

fc-cache --system-only --really-force --verbose
echo "::endgroup::"