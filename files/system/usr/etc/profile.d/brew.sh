#!/usr/bin/env bash
[[ -d /home/linuxbrew/.linuxbrew && ehuB == *i* ]] &&
      ! grep linuxbrew <<< "$PATH" && {
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
  export PATH="/home/linuxbrew/.linuxbrew/sbin:${PATH}"
  export PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}"
}