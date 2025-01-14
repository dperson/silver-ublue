# Include some of your custom scripts here!

# Update homebrew
[group('Tools')]
brew-update:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euxo pipefail
    brew update --auto-update
    brew upgrade
    brew autoremove
    brew cleanup -s
    rm -rf $(brew --cache)/*

# Change shell
[group('System')]
chsh shell="":
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    echo "${b}Setting default user shell${n}"
    if [[ "{{ shell }}" ]]; then
      if [[ "$(grep -m1 {{ shell }} /etc/shells)" ]]; then
        sudo lchsh "$USER" "$(grep -m1 {{ shell }} /etc/shells)"
      else
        echo "ERROR: shell {{ shell }} not found in '/etc/shells'!" && exit 1
      fi
    else
      sudo lchsh -i
    fi

# Install system flatpaks for rebasers
[group('System')]
install-system-flatpaks:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    url="https://raw.githubusercontent.com/ublue-os2/bluefin/main/build_files"
    flatpaks="$(curl -LSfs "$url/iso_filesiso/system-flatpaks.txt"|tr '\n' ' ')"
    flatpak --system -y install --or-update ${flatpaks}

# Install gaming flatpaks
[group('Apps')]
install-gaming-flatpaks:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euxo pipefail
    flatpak remote-add --if-not-exists flathub \
          https://flathub.org/repo/flathub.flatpakrepo
    flatpak --system -y install --or-update \
          app/com.valvesoftware.Steam//stable \
          app/com.vysp3r.ProtonPlus//stable \
          app/com.dec05eba.gpu_screen_recorder//stable \
          app/com.github.Matoking.protontricks//stable \
          runtime/org.freedesktop.Platform.VulkanLayer.gamescope//24.08 \
          runtime/org.freedesktop.Platform.VulkanLayer.gamescope//23.08 \
          runtime/org.freedesktop.Platform.VulkanLayer.MangoHud//24.08 \
          runtime/org.freedesktop.Platform.VulkanLayer.MangoHud//23.08 \
          runtime/com.valvesoftware.Steam.Utility.steamtinkerlaunch//stable

# Install OpenTabletDriver, an open source, user-mode tablet driver
[group('Apps')]
install-opentabletdriver:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    echo "Installer for OpenTabletDriver..."
    echo "${bold}Install or Remove OpenTabletDriver${normal}"
    OPTION=$(Choose "Install" "Uninstall" "Exit")
    if [[ "${OPTION,,}" =~ ^install ]]; then
      echo "Installing OpenTabletDriver..."
      file=/tmp/OpenTabletDriver.tgz
      filter='.assets | sort_by(.created_at) | .[] | select '
      filter+='select (.name|test("opentab.*tar.gz$")) | .browser_download_url'
      url="https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver"
      url+="/releases/latest"
      curl -LSfso "$file" $(curl -LSfs "$url" | jq -r "$filter")
      mkdir -p /tmp/OpenTabletDriver
      tar --strip-components=1 -C /tmp/OpenTabletDriver -xvzf "$file"
      file="/tmp/OpenTabletDriver/etc/udev/rules.d/70-opentabletdriver.rules"
      pkexec cp "$file" "${file#/tmp/OpenTabletDriver}"
      rm -rf /tmp/OpenTabletDriver*
      flatpak remote-add --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo
      flatpak --system install -y flathub net.opentabletdriver.OpenTabletDriver
      mkdir -p $HOME/.config/OpenTabletDriver
      flatpak override --user --filesystem=xdg-config/OpenTabletDriver \
            net.opentabletdriver.OpenTabletDriver
      mkdir -p $HOME/.config/systemd/user
      url="https://raw.githubusercontent.com/flathub/net.opentabletdriver."
      url+="OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service"
      curl -LSfso "$HOME/.config/systemd/user/opentabletdriver.service" "$url"
      systemctl --user daemon-reload
      systemctl enable --user --now opentabletdriver.service
    elif [[ "${OPTION,,}" =~ ^uninstall ]]; then
      echo "Uninstalling OpenTabletDriver..."
      systemctl disable --user --now opentabletdriver.service
      rm "$HOME/.config/systemd/user/opentabletdriver.service"
      systemctl --user daemon-reload
      pkexec rm /etc/udev/rules.d/70-opentabletdriver.rules
      flatpak --system remove -y flathub net.opentabletdriver.OpenTabletDriver
    else
      echo "Have a good day :)!"
    fi

# Add additional boot parameters for additional hardening (requires reboot)
[group('System')]
kargs-hardening:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Setting security boot parameters${n}"
    set -euxo pipefail
    # Zero newly allocated pages and heaps, mitigating use-after-free
    # Fills freed pages and heaps with zeroes, mitigating use-after-free
    # Disables the merging of slabs, increasing difficulty of heap exploits
    # Disable CPU-based entropy sources as it's not auditable
    # Disable trusting the use of the a seed passed by the bootloader
    rpm-ostree kargs \
          --append-if-missing="init_on_alloc=1" \
          --append-if-missing="init_on_free=1" \
          --append-if-missing="slab_nomerge" \
          --append-if-missing="random.trust_cpu=off" \
          --append-if-missing="random.trust_bootloader=off"

# Install mono fonts
# [group('Fonts')]
# monofonts:
#     #!/usr/bin/env -S bash
#     source /usr/lib/ujust/ujust.sh
#     set -euo pipefail
#     echo "${b}Mono NerdFonts Installation${n}"
#     mkdir -p /tmp/fonts "${HOME}/.config/fontconfig/conf.d" \
#           "${HOME}/.local/share/fonts/NerdFonts"
#     (cd /tmp/fonts
#     url='https://api.github.com/repos' && \
#     curl -LSfs $(curl -LSfs ${url}/microsoft/cascadia-code/releases | \
#           jq -r '.[0].assets[0].browser_download_url') -o /tmp/CascadiaCode.zip
#     unzip -j /tmp/CascadiaCode.zip otf/static/CascadiaCode-Regular.otf -d .
#     url='https://github.com/intel/intel-one-mono/raw/main/fonts/otf'
#     curl -LOSfs "${url}/IntelOneMono-Regular.otf"
#     url='https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/otf'
#     curl -LOSfs "${url}/JetBrainsMono-Regular.otf"
#     url='https://github.com/githubnext/monaspace/raw/main/fonts/otf'
#     for i in Argon Krypton Neon Radon Xenon; do
#       curl -LOSfs "${url}/Monaspace${i}-Regular.otf"
#     done
#     url='https://github.com/adobe-fonts/source-code-pro/raw/release/OTF'
#     curl -LOSfs "${url}/SourceCodePro-Regular.otf";)
#     podman run --rm -v /tmp/fonts:/in:z \
#           -v ${HOME}/.local/share/fonts/NerdFonts:/out:z \
#           nerdfonts/patcher --quiet --complete --careful --progressbars
#     podman rmi nerdfonts/patcher
#     rm -rf /tmp/CascadiaCode.zip /tmp/fonts
#     url="https://github.com/powerline/powerline/raw/develop/font"
#     curl -LSfso "${HOME}/.local/share/fonts/PowerlineSymbols.otf" \
#           "${url}/PowerlineSymbols.otf"
#     curl -LSfso "${HOME}/.config/fontconfig/conf.d/10-powerline-symbols.conf" \
#           "${url}/10-powerline-symbols.conf"
#     fc-cache --really-force --verbose ${HOME}/.local/share/fonts

alias ptyxis-opacity := ptyxis-transparency

# Ptyxis terminal transparency
[group('System')]
ptyxis-transparency opacity="0.95":
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    if [[ -n "$(echo "{{ opacity }}" | grep -v '^[.0-9]*$')" ]]; then
      printf "Value must be numeric: %s.\n" "{{ opacity }}"
    elif [[ $(echo "0<{{ opacity }} && 1>={{ opacity }}" | bc -q) -eq 1 ]]; then
      raw="$(dconf read /org/gnome/Ptyxis/profile-uuids)"
      uuids="$(sed -En 's|[^0-9a-z]*||g; s|([0-9a-z]{32})|\1\n|gp' <<<${raw})"
      for i in ${uuids}; do location="/org/gnome/Ptyxis/Profiles/${i}/"
        dconf write "${location}" opacity "{{ opacity }}"
      done
      printf "Ptyxis opacity is now %s.\n" "{{ opacity }}"
    else
      printf "Value must be greater than 0 and less than or equal to 1: %s.\n" \
            "{{ opacity }}"
    fi

# Regenerate GRUB config, useful in dual-boot scenarios
[group('System')]
regenerate-grub:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    if [[ -d /sys/firmware/efi ]]; then
      sudo grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      sudo grub2-mkconfig -o /etc/grub2.cfg
    fi

alias configure-waydroid := setup-waydroid

# Launch Waydroid configuration helper
[group('Apps')]
setup-waydroid ACTION="":
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    IMAGE_NAME=$(jq -r '."image-name"' <"$IMAGE_INFO")
    OPTION={{ ACTION }}
    if [[ "$OPTION" == "help" ]]; then
      echo "Usage: ujust configure-waydroid <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'init' to select Initialize Waydroid"
      echo "  Use 'configure' to select Configure Waydroid"
      echo "  Use 'gpu' to choose Select GPU for Waydroid"
      echo "  Use 'integration' to enable desktop Waydroid window integration"
      echo "  Use 'reset' to select Configure Waydroid"
      exit 0
    elif [[ "$OPTION" == "" ]]; then
      echo "${bold}Waydroid Setup${normal}"
      url="https://docs.bazzite.gg/Installing_and_Managing_Software/"
      url+="Waydroid_Setup_Guide/"
      echo "Please read the $(Urllink "$url" "Waydroid setup documentation")"
      echo "before continuing"
      OPTION=$(Choose "Initialize Waydroid" "Configure Waydroid" \
            "Select GPU for Waydroid" \
            "Reset Waydroid (also removes related files from home directory)")
    fi
    if [[ "${OPTION,,}" =~ ^init ]]; then
      sudo systemctl enable --now waydroid-container
      sudo waydroid init -c 'https://ota.waydro.id/system' \
            -v 'https://ota.waydro.id/vendor'
      sudo restorecon -R /var/lib/waydroid
      echo -n "Waydroid has been initialized, please run waydroid once before"
      echo " you Configure Waydroid"
    elif [[ "${OPTION,,}" =~ ^configure ]]; then
      git clone https://github.com/ublue-os/waydroid_script.git --depth 1 \
            /tmp/waydroid_script
      python -m venv /tmp/waydroid_script/venv
      source /tmp/waydroid_script/venv/bin/activate
      sudo pip install -r /tmp/waydroid_script/requirements.txt
      sudo /tmp/waydroid_script/main.py
      deactivate
      sudo rm -rf /tmp/waydroid_script
    elif [[ "${OPTION,,}" =~ gpu ]]; then
      sudo /usr/bin/waydroid-choose-gpu
    elif [[ "${OPTION,,}" =~ integration ]]; then
      waydroid prop set persist.waydroid.multi_windows true
    elif [[ "${OPTION,,}" =~ ^reset ]]; then
      echo "Resetting Waydroid"
      sudo systemctl disable --now waydroid-container
      bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid \
            ~/.share/waydroid ~/.local/share/applications/*aydroid* \
            ~/.local/share/waydroid'
      echo "Waydroid has been reset"
    fi

# Turn automatic updates on or off
[group('System')]
toggle-updates ACTION="prompt":
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    CURRENT_STATE="Disabled"
    if systemctl -q is-enabled ublue-update.timer; then
      CURRENT_STATE="Enabled"
    elif systemctl -q is-enabled rpm-ostreed-automatic.timer; then
      CURRENT_STATE="Enabled"
    fi
    OPTION={{ ACTION }}
    if [[ "$OPTION" == "prompt" ]]; then
      echo "Automatic updates are currently: ${bold}${CURRENT_STATE}${normal}"
      echo "Enable or Disable automatic updates?"
      OPTION=$(ugum choose Enable Disable)
    elif [[ "$OPTION" == "help" ]]; then
      echo "Usage: ujust toggle-updates <option>"
      echo "  <option>: Specify the quick option - 'enable' or 'disable'"
      echo "  Use 'enable' to Enable automatic updates."
      echo "  Use 'disable' to Disable automatic updates."
      exit 0
    fi
    if [[ "${OPTION,,}" == "enable" ]]; then
      if systemctl is-enabled ublue-update.timer 2>/dev/null |
            grep -q not-found; then
        sudo systemctl unmask brew-update.timer brew-upgrade.timer \
              flatpak-system-update.timer rpm-ostreed-automatic.timer
        sudo systemctl enable brew-update.timer brew-upgrade.timer \
              flatpak-system-update.timer rpm-ostreed-automatic.timer
        sudo systemctl unmask flatpak-user-update.timer
        sudo systemctl enable --global flatpak-user-update.timer
      else
        sudo systemctl unmask ublue-update.timer brew-update.timer \
            brew-upgrade.timer
        sudo systemctl enable ublue-update.timer brew-update.timer \
            brew-upgrade.timer
        sudo systemctl disable flatpak-system-update.timer \
              rpm-ostreed-automatic.timer
        sudo systemctl mask flatpak-system-update.timer \
              rpm-ostreed-automatic.timer
        sudo systemctl disable --global flatpak-user-update.timer
        sudo systemctl mask flatpak-user-update.timer
      fi
    elif [[ "${OPTION,,}" == "disable" ]]; then
      if systemctl is-enabled ublue-update.timer 2>/dev/null |
            grep -q not-found; then
        sudo systemctl disable brew-update.timer brew-upgrade.timer \
              flatpak-system-update.timer rpm-ostreed-automatic.timer
        sudo systemctl mask brew-update.timer brew-upgrade.timer \
              flatpak-system-update.timer rpm-ostreed-automatic.timer
        sudo systemctl disable --global flatpak-user-update.timer
        sudo systemctl mask flatpak-user-update.timer
      else
        sudo systemctl disable ublue-update.timer brew-update.timer \
              brew-upgrade.timer flatpak-system-update.timer \
              rpm-ostreed-automatic.timer
        sudo systemctl mask ublue-update.timer brew-update.timer \
              brew-upgrade.timer flatpak-system-update.timer \
              rpm-ostreed-automatic.timer
        sudo systemctl disable --global flatpak-user-update.timer
        sudo systemctl mask flatpak-user-update.timer
      fi
    fi

# Install ubuntu font
[group('Fonts')]
ubuntufont:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    echo "${b}Ubuntu Fonts Installation${n}"
    curl -LSfso /tmp/ubuntu.zip \
          https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip
    unzip -d /tmp -q /tmp/ubuntu.zip
    mkdir -p ${HOME}/.local/share/fonts/Ubuntu
    cp /tmp/ubuntu*/*.ttf ${HOME}/.local/share/fonts/Ubuntu/
    rm -rf /tmp/ubuntu*
    fc-cache --really-force --verbose ${HOME}/.local/share/fonts

# A preview of what the update system would look like in the future
[group('Tools')]
update-ng:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euxo pipefail
    /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --keep

# Wayland overides for flatpaks
[group('System')]
wayland-flapak:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Flatpak overides to run on Wayland${n}"
    CURSORS="/run/host/user-share/icons:/run/host/share/icons"
    set -euxo pipefail
    sudo flatpak override --env=ELECTRON_OZONE_PLATFORM_HINT=auto \
          --socket=wayland --talk-name=org.freedesktop.secrets
    sudo flatpak override --env=MOZ_ENABLE_WAYLAND=1 --filesystem="~/.mozilla" \
          org.mozilla.firefox
    sudo flatpak override --env=XCURSOR_PATH=$CURSORS io.freetubeapp.FreeTube