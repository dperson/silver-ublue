#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

get_git_pkg() { local prj="$1" pat="$2" out="$3" cmd="${4:-${1##*/}}" url \
      i="$([[ ${5:-} ]] &&echo "[]|select(.tag_name|test(\"$5\"))"||echo "[0]")"
  local filter=".$i.assets[]|select(.name|test(\"$pat\")).browser_download_url"
  PATH=/bin:/usr/bin:/usr/local/bin type -p "$cmd" >/dev/null && return 1 || :
  url=$(ghcurl "https://api.github.com/repos/$prj/releases" | jq -r "$filter")
  ghcurl "$url" -o "$out"
}

# Automatic wallpaper changing by month
HARDCODED_MONTH="01"
sed -i "/picture-uri/ s/${HARDCODED_MONTH}/$(date +%m)/" \
      /etc/dconf/db/distro.d/03-bluefin-gnome

# Add Mutter experimental-features
if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
  sed -i "/experimental-features/ s|\\[|['kms-modifiers',|" \
        /etc/dconf/db/distro.d/03-bluefin-gnome
fi

# Create link for alt path name to lua-5.1
ln -irs /usr/bin/lua-5.1 /usr/bin/lua5.1
ln -irs /usr/bin/luac-5.1 /usr/bin/luac5.1

# Install bash-prexec
url="https://raw.githubusercontent.com/rcaloras/bash-preexec/master"
ghcurl "$url/bash-preexec.sh" -o /usr/share/bash-prexec

# Install chezmoi
get_git_pkg "twpayne/chezmoi" "linux-amd64$" /usr/bin/chezmoi
url="https://github.com/twpayne/chezmoi/raw/master/completions"
p="/usr/share/bash-completion/completions"
ghcurl "${url}/chezmoi-completion.bash" -o "${p}/chezmoi"
p="/usr/share/zsh/site-functions"
ghcurl "${url}/chezmoi.zsh" -o "${p}/_chezmoi"
chmod +x /usr/bin/chezmoi

# Install dive, flux, helm, k9s, kind, ko, kubectl, kubectx, kubens, & mc
get_git_pkg "wagoodman/dive" "linux_amd64.rpm$" /tmp/dive.rpm
dnf install --setopt=install_weak_deps=False -y /tmp/dive.rpm
get_git_pkg "fluxcd/flux2" "linux_amd64.tar.gz$" /tmp/flux.tgz flux
tar -C /usr/bin -xf /tmp/flux.tgz flux
url="https://github.com/helm/helm/releases/latest"
ver=$(curl -ILSfs "$url" | sed -n '/^location:/s|.*/||p' | tr -d '\r')
ghcurl "https://get.helm.sh/helm-${ver}-linux-amd64.tar.gz" -o /tmp/helm.tgz
tar -C /tmp -xzf /tmp/helm.tgz
cp /tmp/*/helm /usr/bin/helm
get_git_pkg "derailed/k9s" "linux_amd64.rpm$" /tmp/k9s.rpm
dnf install --setopt=install_weak_deps=False -y /tmp/k9s.rpm
get_git_pkg "kubernetes-sigs/kind" "^kind-linux-amd64$" /usr/bin/kind
get_git_pkg "ko-build/ko" "ko_Linux_x86_64.tar.gz$" /tmp/ko.tgz
tar -C /usr/bin -xf /tmp/ko.tgz ko
ver="$(curl -LSfs https://dl.k8s.io/release/stable.txt)"
curl -LSfso /usr/bin/kubectl \
      "https://dl.k8s.io/release/$ver/bin/linux/amd64/kubectl"
get_git_pkg "ahmetb/kubectx" "^kubectx$" /usr/bin/kubectx
get_git_pkg "ahmetb/kubectx" "^kubens$" /usr/bin/kubens kubens
curl -LSfso /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
chown root: /usr/bin/{flux,helm,kind,ko,kubectl,kubectx,kubens,mc}
chmod 0755 /usr/bin/{flux,helm,kind,ko,kubectl,kubectx,kubens,mc}
rm -fr /tmp/{dive.rpm,flux.tgz,helm*,k9s.rpm,ko.tgz,linux*}

# Install eza
get_git_pkg "eza-community/eza" "x86_64-unknown-linux-gnu.tar.gz" /tmp/eza.tgz
get_git_pkg "eza-community/eza" "completions" /tmp/eza_completions.tgz
tar -C /tmp -xf /tmp/eza.tgz
tar -C /tmp -xf /tmp/eza_completions.tgz
cp /tmp/eza /usr/bin
cp /tmp/target/completions-*/eza /usr/share/bash-completion/completions
cp /tmp/target/completions-*/_eza /usr/share/zsh/site-functions
chmod +x /usr/bin/eza
rm -rf /tmp/eza*

# Install framework_tool
get_git_pkg "FrameworkComputer/framework-system" "framework_tool\$" \
      /usr/bin/framework_tool
chmod +x /usr/bin/framework_tool

# Install kanata
get_git_pkg "jtroo/kanata" "linux-binaries.*-x64.*zip" /tmp/kanata.zip
unzip -d /tmp /tmp/kanata.zip kanata_linux_x64
mv /tmp/kanata_linux_x64 /usr/bin/kanata
chown root:input /usr/bin/kanata
chmod 2755 /usr/bin/kanata
rm /tmp/kanata.zip

# Install mdcat
get_git_pkg "swsnr/mdcat" "linux" /tmp/mdcat.tgz
tar -C /tmp -xf /tmp/mdcat.tgz
cp /tmp/mdcat*/mdcat /usr/bin
cp /tmp/mdcat*/mdcat.1/mdcat.1 /usr/share/man/man1
rm -rf /tmp/mdcat*
chmod +x /usr/bin/mdcat

# Install oh-my-posh
get_git_pkg "JanDeDobbeleer/oh-my-posh" "linux-amd64$" /usr/bin/oh-my-posh
chmod +x /usr/bin/oh-my-posh
echo 'eval "$(oh-my-posh init bash)"' >>/etc/bashrc

# Install rust-parallel
get_git_pkg "aaronriekenberg/rust-parallel" "x86_64.*linux" /tmp/parallel.tgz
tar -C /tmp -xf /tmp/parallel.tgz
cp /tmp/rust-parallel /usr/bin/parallel
rm -rf /tmp/*parallel*
chmod +x /usr/bin/parallel

# Install xdg-override
ghcurl https://github.com/koiuo/xdg-override/raw/refs/heads/main/xdg-override \
      -o /usr/bin/xdg-override
chmod +x /usr/bin/xdg-override

# Fix justfile syntax highlighting
url="https://github.com/NoahTheDuke/vim-just/raw/main/syntax"
ghcurl "${url}/just.vim" -o /usr/share/nvim/runtime/syntax/just.vim

# Install topgrade
pip install --prefix=/usr topgrade

# Install Gnome Extensions
pip install --prefix=/usr gnome-extensions-cli
patch=/ctx/build_files/base/0001-chore-patch-for-GNOME-49.patch
sysext=/usr/share/gnome-shell/extensions
# gtk4-ding@smedius.gitlab.com tasks-in-panel@fthx wiggle@mechtifs
for i in appindicatorsupport@rgcjonas.gmail.com \
      auto-move-windows@gnome-shell-extensions.gcampax.github.com \
      Bluetooth-Battery-Meter@maniacx.github.com blur-my-shell@aunetx \
      caffeine@patapon.info clipboard-history@alexsaveau.dev \
      dash-to-dock@micxgx.gmail.com just-perfection-desktop@just-perfection \
      logomenu@aryan_k rounded-window-corners@fxgn \
      search-light@icedman.github.com tailscale@joaophi.github.com \
      tilingshell@ferrarodomenico.com; do
  gext list --only-uuid | grep -q "$i" && continue || gext install "$i"
  mv "/root/.local/share/gnome-shell/extensions/$i" "$sysext/"
  if [[ $FEDORA_MAJOR_VERSION -eq 43 ]] && [[ $i =~ tailscale ]]; then
    (cd "$sysext/$i" && patch -F3 <"$patch")
  fi
  find "$sysext/$i" -iname \*.gschema.xml | while read -r j; do
    # if [[ $FEDORA_MAJOR_VERSION -eq 43 ]]; then
    #   grep -q '"49"' "$j" || sed -Ei 's|("48")|\1, "49"|p' "$j"
    # fi
    (cd "$(dirname "$j")" && glib-compile-schemas .)
  done
done

# We do not need anything here at all
rm -rf /usr/src/*
rm -rf /usr/share/doc/*
echo "::endgroup::"