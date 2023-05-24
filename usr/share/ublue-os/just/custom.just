!include /usr/share/ublue-os/just/bling.just

# install all flatpaks defined in recipe.yml
setup-flatpaks:
  #!/usr/bin/env bash
  echo 'Installing flatpaks from the ublue recipe ...'
  flatpaks=$(yq -- '.firstboot.flatpaks[]' "/usr/share/ublue-os/recipe.yml")
  for pkg in $flatpaks; do \
      echo "Installing: ${pkg}" && \
      flatpak install --user --noninteractive flathub $pkg; \
  done

# Include some of your custom scripts here!

intelone:
  #!/usr/bin/env bash
  echo 'Installing NerdFont of IntelOneMono ...'
  curl -L https://github.com/intel/intel-one-mono/releases/download/V1.2.1/otf.zip \
              -o /tmp/otf.zip
  unzip -d /tmp -q /tmp/otf.zip
  podman run --rm -v /tmp/otf:/in:z \
              -v $HOME/.local/share/fonts/NerdFonts:/out:z \
              nerdfonts/patcher \
              --mono --quiet --complete --careful --progressbars
  podman rmi nerdfonts/patcher
  rm -rf /tmp/otf*
  fc-cache -vf $HOME/.local/share/fonts/NerdFonts

prompt:
  #!/usr/bin/env bash
  echo 'Installing Starship ...'
  curl -Ss https://starship.rs/install.sh | sh
  [[ -d $HOME/.local/share/fonts/NerdFonts ]] || {
      echo 'Installing NerdFont of SourceCodePro (SauceCodePro) ...'
      podman run --rm -v /usr/share/fonts/adobe-source-code-pro:/in:z \
                  -v $HOME/.local/share/fonts/NerdFonts:/out:z \
                  nerdfonts/patcher \
                  --mono --quiet --complete --careful --progressbars
      podman rmi nerdfonts/patcher
      fc-cache -vf $HOME/.local/share/fonts/NerdFonts
  }

ubuntufont:
  #!/usr/bin/env bash
  echo 'Installing NerdFont of Ubuntu ...'
  curl -L https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip \
              -o /tmp/ubuntu.zip
  unzip -d /tmp -q /tmp/ubuntu.zip ubuntu-font-family*/UbuntuMono*.ttf
  podman run --rm -v /tmp/ubuntu-font*:/in:z \
              -v $HOME/.local/share/fonts/NerdFonts:/out:z \
              nerdfonts/patcher \
              --mono --quiet --complete --careful --progressbars
  podman rmi nerdfonts/patcher
  rm -rf /tmp/ubuntu*
  fc-cache -vf $HOME/.local/share/fonts/NerdFonts