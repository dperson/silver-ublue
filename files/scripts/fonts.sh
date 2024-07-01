#!/usr/bin/env -S bash

set -euxo pipefail

get_git_file() { local prj="$1" filter="$2" out="$3" url
  url=$(curl -LSs "https://api.github.com/repos/$prj/releases"| jq -r "$filter")
  curl -LSs "$url" -o "$out"
}

# Inter
f='.[0].assets[0].browser_download_url'
get_git_file "rsms/inter" "$f" "/tmp/inter.zip"
mkdir -p /tmp/inter /usr/share/fonts/inter
unzip -q /tmp/inter.zip -d /tmp/inter/
cp /tmp/inter/extras/otf/*.otf /usr/share/fonts/inter/
rm -rf /tmp/inter*

# CascadiaCode
f='.[0].assets[]|select(.name|test("CascadiaCode.zip")).browser_download_url'
get_git_file "ryanoasis/nerd-fonts" "$f" "/tmp/caskaydia.zip"
mkdir -p /tmp/caskaydia /usr/share/fonts/NerdFonts
unzip -q /tmp/caskaydia.zip -d /tmp/caskaydia/
cp /tmp/caskaydia/CaskaydiaCoveNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/CaskaydiaCoveNerdFont.ttf
rm -rf /tmp/caskaydia*

# Intel One
f='.[0].assets[]|select(.name|test("IntelOneMono.zip")).browser_download_url'
get_git_file "ryanoasis/nerd-fonts" "$f" "/tmp/intone.zip"
mkdir -p /tmp/intone /usr/share/fonts/NerdFonts
unzip -q /tmp/intone.zip -d /tmp/intone/
cp /tmp/intone/IntoneMonoNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/IntoneMonoNerdFont.ttf
rm -rf /tmp/intone*

# JetBrains
f='.[0].assets[]|select(.name|test("JetBrainsMono.zip")).browser_download_url'
get_git_file "ryanoasis/nerd-fonts" "$f" "/tmp/jet.zip"
mkdir -p /tmp/jet /usr/share/fonts/NerdFonts
unzip -q /tmp/jet.zip -d /tmp/jet/
cp /tmp/jet/JetBrainsMonoNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/JetBrainsMonoNerdFont.ttf
rm -rf /tmp/jet*

# Monaspace
f='.[0].assets[]|select(.name|test("Monaspace.zip")).browser_download_url'
get_git_file "ryanoasis/nerd-fonts" "$f" "/tmp/mona.zip"
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
f='.[0].assets[]|select(.name|test("SourceCodePro.zip")).browser_download_url'
get_git_file "ryanoasis/nerd-fonts" "$f" "/tmp/sauce.zip"
mkdir -p /tmp/sauce /usr/share/fonts/NerdFonts
unzip -q /tmp/sauce.zip -d /tmp/sauce/
cp /tmp/sauce/SauceCodeProNerdFontPropo-Regular.ttf \
      /usr/share/fonts/NerdFonts/SauceCodeProNerdFont.ttf
rm -rf /tmp/sauce*

fc-cache --system-only --really-force --verbose