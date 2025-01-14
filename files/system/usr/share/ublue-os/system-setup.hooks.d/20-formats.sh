#!/usr/bin/env -S bash
set -euo pipefail

if ! grep -q 'TIME_STYLE=iso' /etc/locale.conf; then
  echo 'TIME_STYLE=iso' >>/etc/locale.conf
fi
