#!/usr/bin/env -S bash

set -oue pipefail

# Make systemd targets
mkdir -p /usr/lib/systemd/user
QUADLET_TARGETS=(
    "toolbox"
    "alpine-toolbox"
)
for i in "${QUADLET_TARGETS[@]}"; do
  file=/usr/etc/containers/systemd/users/"${i}".container

  cat >"/usr/lib/systemd/user/${i}.target" <<-EOF
	[Unit]
	Description=${i} target for ${i} quadlet

	[Install]
	WantedBy=default.target
	EOF

  # Set to auto-update
  grep -q 'io.containers.autoupdate=registry' "$file" ||
    sed -i '/Label=manager=distrobox/a Label=io.containers.autoupdate=registry'\
          "$file"
  # Add ptyxis integration and have autostart tied to systemd targets
  cat /usr/share/ublue-os/bluefin-cli/ptyxis-integration >>"$file"
  printf "\n\n[Install]\nWantedBy=%s.target" "$i" >>"$file"
done