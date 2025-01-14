#!/usr/bin/env -S bash
[[ -d /home/linuxbrew/.linuxbrew ]] && [[ $- == *i* ]] &&
      ! grep linuxbrew <<<"$PATH" && {
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
  export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  export PATH="${HOMEBREW_PREFIX}/sbin:${PATH}"
  export PATH="${HOMEBREW_PREFIX}/bin:${PATH}"
  export MANPATH="${HOMEBREW_PREFIX}/share/man${MANPATH+:$MANPATH}"
  export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}"
}