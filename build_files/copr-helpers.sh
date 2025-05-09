#!/usr/bin/env -S bash
set -euo pipefail

copr_install_isolated() {
  local copr_name="$1"
  shift
  local packages=("$@")

  if [[ ${#packages[@]} -eq 0 ]]; then
    echo "ERROR: No packages specified for copr_install_isolated"
    return 1
  fi

  repo_id="copr:copr.fedorainfracloud.org:${copr_name//\//:}"

  echo "Installing ${packages[*]} from COPR $copr_name (isolated)"

  dnf copr enable -y "$copr_name"
  dnf copr disable -y "$copr_name"
  dnf install --enablerepo="$repo_id" --setopt=install_weak_deps=False -y \
        "${packages[@]}"

  echo "Installed ${packages[*]} from $copr_name"
}