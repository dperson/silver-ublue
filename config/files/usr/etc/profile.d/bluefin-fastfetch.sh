#!/bin/sh

LOGO_PATH=/usr/share/ublue-os/bluefin-logos/symbols
LOGO_RANDOM="$(shuf -e "$(ls -1 "${LOGO_PATH}")" | head -1)"
LOGO="${LOGO_PATH}/${LOGO_RANDOM}"

#shellcheck disable=SC2139
alias fastfetch="fastfetch --logo ${LOGO} -c /usr/share/ublue-os/ublue-os.jsonc"
alias neofetch="fastfetch --logo ${LOGO} -c /usr/share/ublue-os/ublue-os.jsonc"
unset LOGO LOGO_PATH LOGO_RANDOM