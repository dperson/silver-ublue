#!/usr/bin/env -S bash
if [[ $- == *i* ]]; then
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-findutils/libexec/uubin" ]] &&
    ! grep uutils-findutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-findutils/libexec/uubin:$PATH"
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-diffutils/libexec/uubin" ]] &&
    ! grep uutils-diffutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-diffutils/libexec/uubin:$PATH"
  [[ -d "/home/linuxbrew/.linuxbrew/opt/uutils-coreutils/libexec/uubin" ]] &&
    ! grep uutils-coreutils <<<"$PATH" &&
    PATH="/home/linuxbrew/.linuxbrew/opt/uutils-coreutils/libexec/uubin:$PATH"
  export PATH
  [[ -d /home/linuxbrew/.linuxbrew ]] && ! grep -q linuxbrew/bin <<<"$PATH" && {
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
    export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
    export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}"
    export MANPATH="${HOMEBREW_PREFIX}/share/man${MANPATH+:$MANPATH}"
    export INFOPATH="${HOMEBREW_PREFIX}/share/info${INFOPATH+:$INFOPATH}"
  }
fi