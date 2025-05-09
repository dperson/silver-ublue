#!/usr/bin/env -S bash
if [[ "$EUID" -ne 0 ]]; then
  bootc() {
    # Check if the command is already running with sudo
    if [[ "$EUID" -eq 0 ]]; then
      bootc "$@"
    else
      sudo bootc "$@"
    fi
  }
fi