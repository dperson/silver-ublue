#!/usr/bin/env -S sh

LOGO="$(find /usr/share/ublue-os/bluefin-logos/symbols/ | shuf -n 1)"

#shellcheck disable=SC2139
alias fastfetch="fastfetch --logo ${LOGO} \
      --color $(/usr/libexec/ublue-bling-fastfetch) \
      -c /usr/share/ublue-os/ublue-os.jsonc"
alias neofetch=fastfetch
unset LOGO