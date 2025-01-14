#!/usr/bin/env -S bash

VEN_ID="$(cat /sys/devices/virtual/dmi/id/chassis_vendor)"

# INIT
UBLUE_CONFIG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ublue"
mkdir -p "$UBLUE_CONFIG_DIR"

if [[ ":Framework:" =~ ":$VEN_ID:" ]]; then
  if [[ ! -f "$UBLUE_CONFIG_DIR/framework-initialized" ]]; then
    echo 'Setting Framework logo menu'
    dconf write /org/gnome/shell/extensions/Logo-menu/symbolic-icon true
    dconf write /org/gnome/shell/extensions/Logo-menu/menu-button-icon-image 31
    echo 'Setting touch scroll type'
    dconf write /org/gnome/desktop/peripherals/mouse/natural-scroll true
    touch "$UBLUE_CONFIG_DIR/framework-initialized"
  fi
fi
