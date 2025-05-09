#!/usr/bin/env -S bash
set -eoux pipefail
url="https://api.github.com/repos/casey/just/releases/latest"
while [[ "${JUST_VERSION:-}" =~ null || -z "${JUST_VERSION:-}" ]]; do
  JUST_VERSION=$(curl -LSfs "${url}" | jq -r '.tag_name')
done
url="https://github.com/casey/just/releases/download/${JUST_VERSION}"
curl -LSOfs "${url}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xvzf "just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" -C /tmp just
sudo mv /tmp/just /usr/local/bin/just
rm -f "just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"