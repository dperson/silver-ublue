#!/usr/bin/env -S bash
set -euxo pipefail

# Ensure custom skel files are present
find /etc/skel -type f | while read -r i; do
  j="${i/\/etc\/skel/$HOME}"

  if [[ ! -d $(dirname "$j") ]]; then
    mkdir -p "$(dirname "$j")" || continue
  else
    continue
  fi

  if [[ ! -f "$j" ]]; then
    cp --reflink=auto -ai "$i" "$j"
  fi
done