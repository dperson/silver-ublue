# Include some of your custom scripts here!

# Install Homebrew for Linux
brew:
    #!/usr/bin/env bash
    echo 'Installing homebrew...'
    url='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
    set -euxo pipefail
    /bin/bash -c "$(curl -fsSL ${url})"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew completions link

# Add Homebrew to shell rc files
brew-shell:
    #!/usr/bin/env bash
    echo 'Adding homebrew to shell configuration...'
    set -euxo pipefail
    for file in ${HOME}/.zprofile ${HOME}/.bash_profile; do
      [[ -e ${file} ]] || touch ${file}
      if grep -q 'linuxbrew' ${file}; then
        echo "Brew configuration already present in ${file##*/}"
      else
        echo "Adding Brew configuration to ${file##*/}"
        echo 'if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then' >${file}
        echo '  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'>>${file}
        echo '  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"' \
              >>${file}
        echo 'fi' >>${file}
      fi
    done

# Update homebrew
brew-update:
    #!/usr/bin/env bash
    set -euxo pipefail
    brew update --auto-update
    brew upgrade
    brew autoremove
    brew cleanup -s
    rm -rf $(brew --cache)/*

# Discord / gtkcord4 install
discord:
    #!/usr/bin/env bash
    url='https://api.github.com/repos'
    echo 'Installing latest custom discord...'
    sudo find /usr/local/ -type f -iname \*gtkcord4\* -exec rm -v {} \;
    set -euxo pipefail
    curl -LSs $(curl -LSs ${url}/diamondburned/gtkcord4/releases | \
          jq -r '.[0].assets[0].browser_download_url') -o /tmp/gtkcord4.tar.zst
    sudo tar -C /usr/local -xf /tmp/gtkcord4.tar.zst ./bin/gtkcord4 ./share/\*
    sudo chown -Rh root: /usr/local/bin/gtkcord4 /usr/local/share/*
    sudo chmod -R go=rX /usr/local/bin/gtkcord4 /usr/local/share/*
    rm /tmp/gtkcord4.tar.zst

# Install recommended GNOME extensions
gnome-extensions:
    #!/usr/bin/env bash
    echo 'Installing Gnome extensions...'
    pip install --upgrade gnome-extensions-cli
    gext install appindicatorsupport@rgcjonas.gmail.com
    gext install auto-move-windows@gnome-shell-extensions.gcampax.github.com
    gext install Bluetooth-Battery-Meter@maniacx.github.com
    gext install blur-my-shell@aunetx
    gext install burn-my-windows@schneegans.github.com
    gext install caffeine@patapon.info
    gext install clipboard-history@alexsaveau.dev
    gext install compiz-windows-effect@hermes83.github.com
    gext install dash-to-dock@micxgx.gmail.com
    gext install gTile@vibou
    gext install hide-universal-access@akiirui.github.io
    gext install power-profile-switcher@eliapasquali.github.io
    gext install rounded-window-corners@yilozt
    gext install tailscale@joaophi.github.com

monofonts:
    #!/usr/bin/env bash
    echo 'Installing Nice Mono NerdFonts...'
    mkdir -p /tmp/fonts "${HOME}/.config/fontconfig/conf.d" \
          "${HOME}/.local/share/fonts/NerdFonts"
    (cd /tmp/fonts
    url='https://api.github.com/repos' && \
    curl -LSs $(curl -LSs ${url}/microsoft/cascadia-code/releases | \
          jq -r '.[0].assets[0].browser_download_url') -o /tmp/CascadiaCode.zip
    unzip -j /tmp/CascadiaCode.zip otf/static/CascadiaCode-Regular.otf -d .
    url='https://github.com/intel/intel-one-mono/raw/main/fonts/otf'
    curl -LOSs ${url}/IntelOneMono-Regular.otf
    url='https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/otf'
    curl -LOSs ${url}/JetBrainsMono-Regular.otf
    url='https://github.com/githubnext/monaspace/raw/main/fonts/otf'
    for i in Argon Krypton Neon Radon Xenon; do
      curl -LOSs ${url}/Monaspace${i}-Regular.otf
    done
    url='https://github.com/adobe-fonts/source-code-pro/raw/release/OTF'
    curl -LOSs ${url}/SourceCodePro-Regular.otf;)
    podman run --rm -v /tmp/fonts:/in:z \
          -v ${HOME}/.local/share/fonts/NerdFonts:/out:z \
          nerdfonts/patcher --quiet --complete --careful --progressbars
    podman rmi nerdfonts/patcher
    rm -rf /tmp/CascadiaCode.zip /tmp/fonts
    url="https://github.com/powerline/powerline/raw/develop/font"
    curl -L ${url}/PowerlineSymbols.otf -o \
          "${HOME}/.local/share/fonts/PowerlineSymbols.otf"
    curl -L ${url}/10-powerline-symbols.conf -o \
          "${HOME}/.config/fontconfig/conf.d/10-powerline-symbols.conf"
    fc-cache -vf ${HOME}/.local/share/fonts

# Ptyxis terminal transparency
ptyxis-transparency opacity="0.95":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "$(echo "{{ opacity }}" | grep -v '^[.0-9]*$')" ]]; then
      printf "Value must be numeric: %s.\n" "{{ opacity }}"
    elif [[ $(echo "0<{{ opacity }} && 1>{{ opacity }}" | bc -q) -eq 1 ]]; then
      raw="$(gsettings get org.gnome.Ptyxis profile-uuids)"
      uuids="$(sed -En 's|[^0-9a-z]*||g; s|([0-9a-z]{32})|\1\n|gp' <<<${raw})"
      for i in ${uuids}; do
        location="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${i}/"
        gsettings set "${location}" opacity "{{ opacity }}"; done
      printf "Ptyxis opacity is now %s.\n" "{{ opacity }}"
    else
      printf "Value must be between 0 and 1: %s.\n" "{{ opacity }}"
    fi

ubuntufont:
    #!/usr/bin/env bash
    echo 'Installing Ubuntu fonts...'
    curl -L https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip \
          -o /tmp/ubuntu.zip
    unzip -d /tmp -q /tmp/ubuntu.zip
    mkdir -p ${HOME}/.local/share/fonts/Ubuntu
    cp /tmp/ubuntu*/*.ttf ${HOME}/.local/share/fonts/Ubuntu/
    rm -rf /tmp/ubuntu*
    fc-cache -vf ${HOME}/.local/share/fonts

# A preview of what the update system would look like in the future
update-ng:
    #!/usr/bin/env bash
    echo 'Upgrading system...'
    sudo bootc upgrade
    [[ -x $(which brew 2>&-)]] && \
          echo 'Upgrading brew...' && \
          brew update --auto-update && brew upgrade && brew autoremove && \
          brew cleanup -s
    echo 'Upgrading flatpaks...'
    flatpak update -y && flatpak uninstall --delete-data --unused
    echo 'Assembling and replacing distroboxes...'
    file='/etc/distrobox/distrobox.ini'
    [[ -e ${file} ]] || file="/usr/${file}"
    distrobox assemble create --replace --file ${file}

# Launch Waydroid configuration helper
waydroid-configure:
    #!/usr/bin/env bash
    url='https://github.com/ublue-os/waydroid_script.git'
    git clone ${url} --depth 1 /tmp/waydroid_script
    python -m venv /tmp/waydroid_script/venv
    source /tmp/waydroid_script/venv/bin/activate
    sudo pip install -r /tmp/waydroid_script/requirements.txt
    sudo /tmp/waydroid_script/main.py
    deactivate
    sudo rm -rf /tmp/waydroid_script

# Quickly initialize a waydroid image
waydroid-init:
    #!/usr/bin/env bash
    sudo waydroid init -c 'https://ota.waydro.id/system' \
          -v 'https://ota.waydro.id/vendor'

# Remove all waydroid-related files in your user folders
waydroid-reset:
    #!/usr/bin/env bash
    bash -c 'sudo rm -rf /var/lib/waydroid \
          /home/.waydroid \
          ~/waydroid \
          ~/.share/waydroid \
          ~/.local/share/applications/*aydroid* \
          ~/.local/share/waydroid'

# Wayland overides for flatpaks
wayland-flapak:
    #!/usr/bin/env bash
    sudo flatpak override --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox
    sudo flatpak override --env=ELECTRON_OZONE_PLATFORM_HINT=auto --socket=wayland
