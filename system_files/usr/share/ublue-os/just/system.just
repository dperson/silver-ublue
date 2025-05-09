# vim: set ft=make :
# This file should only contain bluefin specific stuff

# Configure Bluefin-CLI Terminal Experience with Brew
[group('System')]
[no-exit-message]
bluefin-cli:
    brew bundle --file=/usr/share/ublue-os/homebrew/cli.Brewfile


# Configure docker, container manager, and serial permissions
[group('System')]
dx-group:
    #!/usr/bin/pkexec bash
    append_group() {
      local group_name="$1"
      if ! grep -q "^$group_name:" /etc/group; then
        echo "Appending $group_name to /etc/group"
        grep "^$group_name:" /usr/lib/group |
              sudo tee -a /etc/group > /dev/null
      fi
    }

    GROUPS_ADD=("docker" "libvirt" "dialout")

    for GROUP_ADD in "${GROUPS_ADD[@]}" ; do
      append_group $GROUP_ADD
      usermod -aG $GROUP_ADD {{ `id -un` }}
    done

    echo -n "Reboot system and log back in to use docker, libvirt, and "
    echo "serial connections."


# Set up the VM stack: virt-manager flatpak + QEMU extension (UEFI, TPM, USB passthrough)
# Idempotent — safe to run multiple times. Called by toggle-vms and toggle-devmode.
[group('System')]
setup-vms:
    #!/usr/bin/env -S bash
    set -euo pipefail
    flatpak install --system --noninteractive flathub \
          org.virt_manager.virt-manager \
          org.virt_manager.virt_manager.Extension.Qemu
    mkdir -p ~/.config/libvirt
    if ! grep -q "uri_default" ~/.config/libvirt/libvirt.conf 2>/dev/null; then
      echo 'uri_default = "qemu:///session"' >> ~/.config/libvirt/libvirt.conf
    fi
    echo "VM stack ready. Launch Virtual Machine Manager from the app menu."
    echo "Supports: Linux/Windows VMs, Windows 11 (UEFI + TPM), USB passthrough."


# Toggle the VM stack on or off
[group('System')]
toggle-vms:
    #!/usr/bin/env -S bash
    set -euo pipefail
    if flatpak list --system --columns=application 2>/dev/null |
          grep -q "org.virt_manager.virt-manager"; then
      gum confirm "Remove the VM stack (virt-manager + QEMU)?" || exit 0
      flatpak uninstall --system --noninteractive \
            org.virt_manager.virt-manager \
            org.virt_manager.virt_manager.Extension.Qemu || true
      sed -i '/uri_default.*session/d' ~/.config/libvirt/libvirt.conf \
            2>/dev/null || true
      echo "VM stack removed."
    else
      gum confirm "Install the VM stack (virt-manager + QEMU)?" || exit 0
      ujust setup-vms
    fi


# Check Secure Boot status and key enrollment
[group('System')]
check-sb-key:
    #!/usr/bin/env -S bash
    set -euo pipefail
    path="/sys/firmware/efi/efivars/"
    path+="SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c"
    echo "== Secure Boot Status =="
    if [ -d /sys/firmware/efi ]; then
      if command -v mokutil &> /dev/null; then
        mokutil --sb-state
      else
        echo "mokutil not available — checking EFI vars..."
        if [[ -f $path ]]; then
          SB=$(od -An -t u1 "$path" | awk '{print $NF}')
          [[ $SB == "1" ]] && echo "SecureBoot is enabled" ||
                echo "SecureBoot is disabled"
        else
          echo "Cannot determine Secure Boot status"
        fi
      fi
      echo -e "\n== Machine Owner Key (MOK) Status =="
      if command -v mokutil &> /dev/null; then
        mokutil --list-enrolled 2>/dev/null | head -6 ||
              echo "No MOK keys enrolled or mokutil requires sudo"
      fi
      echo -e "\n== Kernel Signature =="
      uname -r
      if command -v sbverify &> /dev/null; then
        sbverify --list /boot/vmlinuz-$(uname -r) 2>/dev/null ||
              echo "sbverify not available (install sbsigntools)"
      fi
    else
      echo "Not an EFI system — Secure Boot does not apply."
    fi