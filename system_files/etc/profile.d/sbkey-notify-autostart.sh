#!/usr/bin/env -S bash

if [[ $(id -u) -gt 0 ]] && [[ -d $HOME ]]; then
  if [[ ! -e $HOME/.config/autostart/sb-key-notify.desktop ]]; then
    mkdir -p "$HOME/.config/autostart"
    cp -f /etc/skel/.config/autostart/sb-key-notify.desktop \
          "$HOME/.config/autostart"
  fi
fi