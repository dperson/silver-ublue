#!/usr/bin/env bash

set -oue pipefail

# Make systemd targets
mkdir -p /usr/lib/systemd/user
QUADLET_TARGETS=(
    "toolbox"
    "alpine-toolbox"
)
for i in "${QUADLET_TARGETS[@]}"; do
  cat >"/usr/lib/systemd/user/${i}.target" <<-EOF
	[Unit]
	Description=${i}"target for ${i} quadlet

	[Install]
	WantedBy=default.target
	EOF

  # Add ptyxis integration and have autostart tied to systemd targets
  cat /usr/share/ublue-os/bluefin-cli/ptyxis-integration \
        >>/usr/etc/containers/systemd/users/"$i".container
  printf "\n\n[Install]\nWantedBy=%s.target" "$i" \
        >>/usr/etc/containers/systemd/users/"$i".container
done