#!/usr/bin/env -S bash
if [[ $- == *i* ]]; then
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-coreutils/libexec/uubin" ]] &&
    ! grep uutils-coreutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-coreutils/libexec/uubin:$PATH"
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-diffutils/libexec/uubin" ]] &&
    ! grep uutils-diffutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-diffutils/libexec/uubin:$PATH"
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-findutils/libexec/uubin" ]] &&
    ! grep uutils-findutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-findutils/libexec/uubin:$PATH"
  export PATH
fi