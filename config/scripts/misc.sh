#!/usr/bin/env bash

set -euo pipefail

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
curl -L "${URL}/kind-$(uname)-amd64" -o /usr/bin/kind
URL="https://raw.githubusercontent.com/ahmetb"
curl -L "${URL}/kubectx/master/kubectx" -o /usr/bin/kubectx
curl -L "${URL}/kubens/master/kubens" -o /usr/bin/kubens
chmod +x /usr/bin/kind /usr/bin/kubectx /usr/bin/kubens

# Install mdcat
P='.[0].assets[] | select(.name|test("linux")) | .browser_download_url'
URL="https://api.github.com/repos/swsnr/mdcat/releases"
curl -LSs "$(curl -LSs "${URL}" | jq -r "${P}")" -o /tmp/mdcat.tgz
tar --exclude=\*.ps1 --exclude=\*.fish -C /tmp -xf /tmp/mdcat.tgz
cp /tmp/mdcat*/mdcat /usr/bin
cp /tmp/mdcat*/mdcat.1 /usr/share/man/man1
cp /tmp/mdcat*/completions/*.bash /usr/share/bash-completion/completions
cp /tmp/mdcat*/completions/_* /usr/share/zsh/site-functions
chmod +x /usr/bin/mdcat

# Install quickemu
URL="https://github.com/quickemu-project/quickemu/raw/master"
curl -L "${URL}/macrecovery" -o /usr/bin/macrecovery
curl -L "${URL}/quickemu" -o /usr/bin/quickemu
curl -L "${URL}/quickget" -o /usr/bin/quickget
curl -L "${URL}/windowskey" -o /usr/bin/windowskey
chmod +x /usr/bin/macrecovery /usr/bin/quick{emu,get} /usr/bin/windowskey

# Fix terminal apps showing in the GUI
for i in $(grep -irl 'Terminal=true' /usr/share/applications); do
  echo "Hidden=true" >>"${i}"
done

# Fix justfile import logic and add syntax highlighting
sed -Ei '/grep/s|F(xq '"'"'import) |\1.*|' /etc/profile.d/ublue-os-just.sh
URL="https://github.com/NoahTheDuke/vim-just/raw/main/syntax"
curl -L "${URL}/just.vim" -o /usr/share/nvim/runtime/syntax/just.vim

# Fix Pretty Name
sed -Ei '/^PRETTY_NAME/s/Silverblue/silver-ublue/' /usr/lib/os-release

# Fix timeouts on shutdown to be sane
sed -i 's/#\(DefaultTimeoutStopSec\).*/\1=15s/' /etc/systemd/user.conf
sed -i 's/#\(DefaultTimeoutStopSec\).*/\1=15s/' /etc/systemd/system.conf

# Enabling faillock in PAM authentication profile
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
systemctl disable waydroid-container.service
url='https://raw.githubusercontent.com/Quackdoc/waydroid-scripts/main'
curl -LSs ${url}/waydroid-choose-gpu.sh -o /usr/bin/waydroid-choose-gpu
chmod +x /usr/bin/waydroid-choose-gpu
