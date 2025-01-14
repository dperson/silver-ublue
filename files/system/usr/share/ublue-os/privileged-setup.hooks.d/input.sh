#!/usr/bin/env -S bash

# Allow input access
for user in $(getent group wheel | cut -d ":" -f 4 | tr ',' '\n'); do
  usermod -aG input "$user"
  usermod -aG uinput "$user"
done
