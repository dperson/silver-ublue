#!/usr/bin/env -S bash

set -euxo pipefail

[[ $(sed -En '/VERSION_ID/s/.*=//p' /etc/os-release) -eq 40 ]] &&
      /usr/bin/bootupctl backend generate-update-metadata

# Install chezmoi
P='.[0].assets[]|select(.name|test("linux-amd64$"))|.browser_download_url'
URL="https://api.github.com/repos/twpayne/chezmoi/releases"
curl -LSs "$(curl -LSs "${URL}" | jq -r "${P}")" -o /usr/bin/chezmoi
URL="https://github.com/twpayne/chezmoi/raw/master/completions"
P="/usr/share/bash-completion/completions"
curl -LSs "${URL}/chezmoi-completion.bash" -o "${P}/chezmoi"
P="/usr/share/zsh/site-functions"
curl -LSs "${URL}/chezmoi.zsh" -o "${P}/_chezmoi"
chmod +x /usr/bin/chezmoi

# Install kind, kubectx, & kubens
URL="https://github.com/kubernetes-sigs/kind/releases/latest/download"
curl -LSs "${URL}/kind-$(uname)-amd64" -o /usr/bin/kind
URL="https://raw.githubusercontent.com/ahmetb"
curl -LSs "${URL}/kubectx/master/kubectx" -o /usr/bin/kubectx
curl -LSs "${URL}/kubens/master/kubens" -o /usr/bin/kubens
chmod +x /usr/bin/kind /usr/bin/kubectx /usr/bin/kubens

# Install mdcat
P='.[0].assets[] | select(.name|test("linux")) | .browser_download_url'
URL="https://api.github.com/repos/swsnr/mdcat/releases"
curl -LSs "$(curl -LSs "${URL}" | jq -r "${P}")" -o /tmp/mdcat.tgz
tar -C /tmp -xf /tmp/mdcat.tgz
cp /tmp/mdcat*/mdcat /usr/bin
cp /tmp/mdcat*/mdcat.1 /usr/share/man/man1
rm -rf /tmp/mdcat*
chmod +x /usr/bin/mdcat

# Install rust-parallel
P='.[0].assets[] | select(.name|test("x86_64.*linux")) | .browser_download_url'
URL="https://api.github.com/repos/aaronriekenberg/rust-parallel/releases"
curl -LSs "$(curl -LSs "${URL}" | jq -r "${P}")" -o /tmp/parallel.tgz
tar -C /tmp -xf /tmp/parallel.tgz
cp /tmp/rust-parallel /usr/bin/parallel
rm -rf /tmp/*parallel*
chmod +x /usr/bin/parallel

# Fix terminal apps showing in the GUI
for i in $(grep -irl 'Terminal=true' /usr/share/applications); do
  echo "Hidden=true" >>"${i}"
done

# Fix justfile import logic and add syntax highlighting
sed -Ei '/grep/s|F(xq '"'"'import) |\1.*|' /etc/profile.d/ublue-os-just.sh
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
  echo "org.freedesktop.Platform.VulkanLayer.gamescope//23.08"
  echo "org.freedesktop.Platform.VulkanLayer.MangoHud//23.08"
} >>/usr/share/bluebuild/default-flatpaks/system/install