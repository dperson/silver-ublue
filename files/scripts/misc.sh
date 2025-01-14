#!/usr/bin/env -S bash

set -euxo pipefail

get_git_pkg() { local prj="$1" out="$3" url \
      filter=".[0].assets[]|select(.name|test(\"$2\")).browser_download_url"
  PATH=/bin:/usr/bin:/usr/local/bin type -p "${4:-${prj##*/}}" >/dev/null &&
        return 1 || :
  url=$(curl -LSs "https://api.github.com/repos/$prj/releases" |
        jq -r "$filter")
  curl -LSs "$url" -o "$out"
}

[[ $(sed -En '/VERSION_ID/s/.*=//p' /etc/os-release) -eq 40 ]] &&
      /usr/bin/bootupctl backend generate-update-metadata

# Install chezmoi
get_git_pkg "twpayne/chezmoi" "linux-amd64$" "/usr/bin/chezmoi"
URL="https://github.com/twpayne/chezmoi/raw/master/completions"
P="/usr/share/bash-completion/completions"
curl -LSs "${URL}/chezmoi-completion.bash" -o "${P}/chezmoi"
P="/usr/share/zsh/site-functions"
curl -LSs "${URL}/chezmoi.zsh" -o "${P}/_chezmoi"
chmod +x /usr/bin/chezmoi

# Install kanata
get_git_pkg "jtroo/kanata" "^kanata$" "/usr/bin/kanata"
chmod +x /usr/bin/kanata

# Install kind, kubectx, & kubens
get_git_pkg "kubernetes-sigs/kind" "^kind-linux-amd64$" "/usr/bin/kind"
URL="https://raw.githubusercontent.com/ahmetb"
curl -LSs "${URL}/kubectx/master/kubectx" -o /usr/bin/kubectx
curl -LSs "${URL}/kubens/master/kubens" -o /usr/bin/kubens
chmod +x /usr/bin/kind /usr/bin/kubectx /usr/bin/kubens

# Install mdcat
get_git_pkg "swsnr/mdcat" "linux" "/tmp/mdcat.tgz"
tar -C /tmp -xf /tmp/mdcat.tgz
cp /tmp/mdcat*/mdcat /usr/bin
cp /tmp/mdcat*/mdcat.1/mdcat.1 /usr/share/man/man1
rm -rf /tmp/mdcat*
chmod +x /usr/bin/mdcat

# Install rust-parallel
get_git_pkg "aaronriekenberg/rust-parallel" "x86_64.*linux" "/tmp/parallel.tgz"
tar -C /tmp -xf /tmp/parallel.tgz
cp /tmp/rust-parallel /usr/bin/parallel
rm -rf /tmp/*parallel*
chmod +x /usr/bin/parallel

# Fix terminal apps showing in the GUI
grep -irl 'Terminal=true' /usr/share/applications | while read -r i; do
  echo "Hidden=true" >>"${i}"
done

# Fix justfile import logic and add syntax highlighting
#sed -Ei '/grep/s|F(xq '"'"'import) |\1.*|' /etc/profile.d/ublue-os-just.sh
URL="https://github.com/NoahTheDuke/vim-just/raw/main/syntax"
curl -LSs "${URL}/just.vim" -o /usr/share/nvim/runtime/syntax/just.vim

# Fix Pretty Name
sed -Ei '/^PRETTY_NAME/s/Silverblue/silver-ublue/' /usr/lib/os-release

# Fix power button
sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' \
      /usr/lib/systemd/logind.conf

# Enable faillock in PAM authentication profile
authselect enable-feature with-faillock -q

# Fix waydroid
sed -Ei 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' \
      /usr/lib/waydroid/data/scripts/waydroid-net.sh
sed -i 's@=waydroid first-launch@=/usr/bin/waydroid-launcher first-launch\
X-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\
X-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\
X-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\
X-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-capsule.png\
X-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop
url='https://raw.githubusercontent.com/Quackdoc/waydroid-scripts/main'
curl -LSs ${url}/waydroid-choose-gpu.sh -o /usr/bin/waydroid-choose-gpu
chmod +x /usr/bin/waydroid-choose-gpu

# Add HUD toy flatpaks
{
  echo "org.freedesktop.Platform.VulkanLayer.gamescope//24.08"
  echo "org.freedesktop.Platform.VulkanLayer.MangoHud//24.08"
} >>/usr/share/bluebuild/default-flatpaks/system/install

# Fix GUI sudo prompt
sed -Ei 's|#(Path askpass /usr/libexec/openssh/gnome-ssh-askpass)|\1|' \
      /etc/sudo.conf

# Make needed directory
mkdir -pv /etc/containers/registries.d/ghcr.io