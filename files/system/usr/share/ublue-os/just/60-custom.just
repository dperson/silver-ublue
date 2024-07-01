# Include some of your custom scripts here!

# Install Homebrew for Linux
#brew:
#    #!/usr/bin/env -S bash
#    source /usr/lib/ujust/ujust.sh
#    echo "${b}Brew Installation${n}"
#    echo "Please ${b}IGNORE${n} what the installer tells you to do at the end"
#    echo "It is done for you! Just close and re-open the terminal after install"
#    url='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
#    set -euxo pipefail
#    /bin/bash -c "$(curl -fsSL ${url})"
#    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#    brew completions link
#    for file in ${HOME}/.zprofile ${HOME}/.bash_profile; do
#      [[ -e ${file} ]] || touch ${file}
#      if grep -q 'linuxbrew' ${file}; then
#        echo "Brew ${b}configuration already present${n} in ${file##*/}"
#      else
#        echo "${b}Adding Brew configuration${n} to ${file##*/}"
#        echo 'brewp="/home/linuxbrew/.linuxbrew/bin/brew"' >${file}
#        echo 'if [[ -x "${brewp}" && $- == *i* ]]; then' >${file}
#        echo '  eval "$("${brewp}" shellenv)"'>>${file}
#        echo '  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"' \
#              >>${file}
#        echo 'fi' >>${file}
#        echo 'unset brewp' >>${file}
#      fi
#    done

# Update homebrew
brew-update:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euxo pipefail
    brew update --auto-update
    brew upgrade
    brew autoremove
    brew cleanup -s
    rm -rf $(brew --cache)/*

# Install recommended GNOME extensions
gnome-extensions:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Gnome Extensions Installation${n}"
    set -euxo pipefail
    pip install --upgrade gnome-extensions-cli
    gext install appindicatorsupport@rgcjonas.gmail.com
    gext install auto-move-windows@gnome-shell-extensions.gcampax.github.com
    gext install Bluetooth-Battery-Meter@maniacx.github.com
    gext install blur-my-shell@aunetx
    gext install caffeine@patapon.info
    gext install clipboard-history@alexsaveau.dev
    gext install dash-to-dock@micxgx.gmail.com
    gext install gTile@vibou
    gext install just-perfection-desktop@just-perfection
    gext install rounded-window-corners@fxgn
    gext install tailscale@joaophi.github.com

# Add additional boot parameters for system (requires reboot)
kargs-base:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Setting boot parameters${n}"
    set -euxo pipefail
    # Newer and better Collaborative Processor Performance Control (CPPC)
    # Enable recovery from GPU failures
    # Fixing GPU scheduler default
    # Allow undervolting AMD
    # Ignore broken behaviour for Windows VMs
    # Fix AMD TPM causing jank / latency
    # Enables page allocator freelist randomization
    # Randomize kernel stack offset on each syscall
    # Disable vsyscall as it is both obsolete and enable an ROP attack vector
    # Enable kernel lockdown in the strictest mode
    # Mitigate DMA attacks by enabling IOMMU
    # Disable IOMMU bypass
    # Synchronously invalidate IOMMU hardware TLBs
    # Enable kernel page table isolation
    # Only allows kernel modules that have been signed with a valid key
    rpm-ostree kargs \
      --append-if-missing="amd_pstate=active" \
      --append-if-missing="amdgpu.gpu_recovery=1" \
      --append-if-missing="gpu_sched.sched_policy=0" \
      --append-if-missing="iomem=relaxed" \
      --append-if-missing="kvm.ignore_msrs=1" \
      --append-if-missing="kvm.report_ignored_msrs=0" \
      --append-if-missing="tpm_tis.interrupts=0" \
      --append-if-missing="page_alloc.shuffle=1" \
      --append-if-missing="randomize_kstack_offset=on" \
      --append-if-missing="vsyscall=none" \
      --append-if-missing="lockdown=confidentiality" \
      --append-if-missing="iommu=force" \
      --append-if-missing="amd_iommu=force_isolation" \
      --append-if-missing="iommu.passthrough=0" \
      --append-if-missing="iommu.strict=1" \
      --append-if-missing="pti=on" \
      --append-if-missing="module.sig_enforce=1"

# Add additional boot parameters for hardening (requires reboot)
kargs-hardening:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Setting security boot parameters${n}"
    set -euxo pipefail
    # Zero newly allocated pages and heaps, mitigating use-after-free
    # Fills freed pages and heaps with zeroes, mitigating use-after-free
    # Disables the merging of slabs, increasing difficulty of heap exploits
    # Enables page allocator freelist randomization
    # Randomize kernel stack offset on each syscall
    # Disable vsyscall as it is both obsolete and enable an ROP attack vector
    # Enable kernel lockdown in the strictest mode
    # Disable CPU-based entropy sources as it's not auditable
    # Disable trusting the use of the a seed passed by the bootloader
    # Mitigate DMA attacks by enabling IOMMU
    # Disable IOMMU bypass
    # Synchronously invalidate IOMMU hardware TLBs
    # Enable kernel page table isolation
    # Only allows kernel modules that have been signed with a valid key
    # IOMMU protection gap by setting the busmaster bit during early boot
    rpm-ostree kargs \
      --append-if-missing="init_on_alloc=1" \
      --append-if-missing="init_on_free=1" \
      --append-if-missing="slab_nomerge" \
      --append-if-missing="page_alloc.shuffle=1" \
      --append-if-missing="randomize_kstack_offset=on" \
      --append-if-missing="vsyscall=none" \
      --append-if-missing="lockdown=confidentiality" \
      --append-if-missing="random.trust_cpu=off" \
      --append-if-missing="random.trust_bootloader=off" \
      --append-if-missing="iommu=force" \
      --append-if-missing="intel_iommu=on" \
      --append-if-missing="amd_iommu=force_isolation" \
      --append-if-missing="iommu.passthrough=0" \
      --append-if-missing="iommu.strict=1" \
      --append-if-missing="pti=on" \
      --append-if-missing="module.sig_enforce=1" \
      --append-if-missing="efi=disable_early_pci_dma"

monofonts:
    #!/usr/bin/env -S bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    echo "${b}Mono NerdFonts Installation${n}"
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
    fc-cache --really-force --verbose ${HOME}/.local/share/fonts

# Ptyxis terminal transparency
ptyxis-transparency opacity="0.95":
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Setting Ptyxis terminal transparency${n}"
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
    #!/usr/bin/env -S bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    echo "${b}Ubuntu Fonts Installation${n}"
    curl -L https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip \
          -o /tmp/ubuntu.zip
    unzip -d /tmp -q /tmp/ubuntu.zip
    mkdir -p ${HOME}/.local/share/fonts/Ubuntu
    cp /tmp/ubuntu*/*.ttf ${HOME}/.local/share/fonts/Ubuntu/
    rm -rf /tmp/ubuntu*
    fc-cache --really-force --verbose ${HOME}/.local/share/fonts

# A preview of what the update system would look like in the future
update-ng:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    set -euxo pipefail
    /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --keep

alias configure-waydroid := setup-waydroid

# Launch Waydroid configuration helper
setup-waydroid ACTION="":
    #!/usr/bin/env -S bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    IMAGE_NAME=$(jq -r '."image-name"' < $IMAGE_INFO)
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-waydroid <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'init' to select Initialize Waydroid"
      echo "  Use 'configure' to select Configure Waydroid"
      echo "  Use 'gpu' to choose Select GPU for Waydroid"
      echo "  Use 'integration' to enable desktop window integration for Waydroid"
      echo "  Use 'reset' to select Configure Waydroid"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Waydroid Setup${normal}"
      echo "Please read the $(Urllink \
            "https://universal-blue.discourse.group/docs?topic=32" \
            "Waydroid setup documentation") before continuing"
      OPTION=$(Choose "Initialize Waydroid" "Configure Waydroid" \
            "Select GPU for Waydroid" \
            "Reset Waydroid (also removes related files from home directory)")
    fi
    if [[ "${OPTION,,}" =~ ^init ]]; then
      sudo systemctl enable --now waydroid-workaround
      sudo systemctl enable --now waydroid-container
      sudo waydroid init -c 'https://ota.waydro.id/system' \
            -v 'https://ota.waydro.id/vendor'
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
      sudo systemctl disable --now waydroid-workaround
      bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid \
            ~/.share/waydroid ~/.local/share/applications/*aydroid* \
            ~/.local/share/waydroid'
      echo "Waydroid has been reset"
    fi

# Wayland overides for flatpaks
wayland-flapak:
    #!/usr/bin/env -S bash
    source /usr/lib/ujust/ujust.sh
    echo "${b}Flatpak overides to run on Wayland${n}"
    set -euxo pipefail
    sudo flatpak override --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox \
          --filesystem="~/.mozilla" --socket=wayland
    sudo flatpak override --env=ELECTRON_OZONE_PLATFORM_HINT=auto \
          --socket=wayland --talk-name=org.freedesktop.secrets