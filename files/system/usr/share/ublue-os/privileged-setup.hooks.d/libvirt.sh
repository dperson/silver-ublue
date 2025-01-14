#!/usr/bin/env -S bash

# Allow libvirt access
for user in $(getent group wheel | cut -d ":" -f 4 | tr ',' '\n'); do
  usermod -aG libvirt "$user"
done
