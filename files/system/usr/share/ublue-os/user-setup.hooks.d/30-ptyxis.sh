#!/usr/bin/env -S bash
set -euxo pipefail

# Ensure custom ptyxis theme is present
PTYXIS_THEME_DIR="/etc/skel/.local/share/org.gnome.Ptyxis/palettes"
PTYXIS_DIR="$HOME/.local/share/org.gnome.Ptyxis/palettes"
mkdir -p "$PTYXIS_DIR"
if [[ ! -f "$PTYXIS_DIR/catppuccin-dynamic.palette" ]]; then
  cp "$PTYXIS_THEME_DIR/"* "$PTYXIS_DIR/"
fi