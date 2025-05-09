#!/usr/bin/env -S bash
set -euxo pipefail

set_karg() { local arg="$1"
  if [[ ! $KARGS =~ $arg ]]; then
    NEEDED_KARGS+=("--append-if-missing=$arg")
  fi
}
unset_karg() { local arg="$1"
  if [[ $KARGS =~ $arg ]]; then
    NEEDED_KARGS+=("--delete-if-present=$arg")
  fi
}

# GLOBAL
CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{print $2}')
SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"
VEN_ID="$(cat /sys/devices/virtual/dmi/id/chassis_vendor)"
BIOS_VERSION="$(cat /sys/devices/virtual/dmi/id/bios_version 2>/dev/null)"
KARGS=$(rpm-ostree kargs)
KEYMAP="$(awk -F'"' '/^KEYMAP/ {print $2}' /etc/vconsole.conf)"
NEEDED_KARGS=()

echo "Current kargs: $KARGS"

unset_karg "nomodeset"                              # Don't break KMS
set_karg "rd.luks.options=discard"                  # Allow trim
[[ "$KEYMAP" ]] && set_karg "vconsole.keymap=$KEYMAP" # Set keymap for LUKS <F42
if [[ "AuthenticAMD" == "$CPU_VENDOR" ]]; then
  unset_karg "intel_iommu=on"                       # Remove Intel options
  set_karg "amd_iommu=force_isolation"              # Disable IOMMU bypass
  set_karg "amd_pstate=active"                      # Better CPPC cpu perf
  set_karg "iomem=relaxed"                          # Allow undervolting AMD
  set_karg "tpm_tis.interrupts=0"                   # Fix AMD TPM causing jank
elif [[ "GenuineIntel" == "$CPU_VENDOR" ]]; then
  unset_karg "amd_iommu=force_isolation"            # Remove AMD options
  unset_karg "amd_pstate=active"                    # Remove AMD options
  unset_karg "iomem=relaxed"                        # Remove AMD options
  unset_karg "tpm_tis.interrupts=0"                 # Remove AMD options
  set_karg "intel_iommu=on"                         # Disable IOMMU bypass
fi
set_karg "efi=disable_early_pci_dma"                # Close IOMMU gap in boot
set_karg "iommu=force"                              # Mitigate DMA attacks
set_karg "iommu.passthrough=0"                      # Disable IOMMU bypass
set_karg "iommu.strict=1"                           # Sync invalidate IOMMU TLBs
set_karg "kvm.ignore_msrs=1"                        # Ignore broken Win VMs
set_karg "kvm.report_ignored_msrs=0"                # Ignore broken Win VMs
set_karg "lockdown=confidentiality"                 # Strictest kernel lockdown
set_karg "module.sig_enforce=1"                     # Only signed kernel modules
set_karg "page_alloc.shuffle=1"                     # Randomize page allocator
set_karg "pti=on"                                   # Page Table Isolation
set_karg "randomize_kstack_offset=on"               # Randomize kernel stack
set_karg "vsyscall=none"                            # Disable obsolete vsyscall

# FRAMEWORK FIXES
if [[ "Framework" =~ $VEN_ID ]]; then
  # Older versions of this script applied a modprobe flag to fix 3.5 mm jack
  if [[ -f /etc/modprobe.d/alsa.conf ]]; then
    echo "Removing obsolete 3.5mm audio jack fix"
    rm -f /etc/modprobe.d/alsa.conf
  fi

  systemctl enable --now framework-ectool.service
  systemctl enable --now fw-fanctrl.service

  if [[ "AuthenticAMD" == "$CPU_VENDOR" && $SYS_ID == "Laptop 13 ("* ]]; then
    echo "Framework Laptop 13 AMD detected"
    unset_karg "module_blacklist=hid_sensor_hub"    # Remove Intel workaround
    set_karg "amdgpu.dcdebugmask=0x10"              # Bug workaround
    set_karg "amdgpu.gpu_recovery=1"                # Recovery from GPU hangs
    set_karg "amdgpu.reset_method=3"                # Way to recover GPU
    set_karg "amdgpu.sg_display=0"                  # Bug workaround

    # Suspend fix for Framework 13 Ryzen 7040
    # On BIOS versions >= 3.09, the workaround is not needed
    file=/etc/udev/rules.d/20-suspend-fixes.rules
    if [[ "$(printf '%s\n' 03.08 "$BIOS_VERSION" | sort -V | tail -n1)" == \
          "03.08" && "$SYS_ID" == "Laptop 13 (AMD Ryzen 7040Series)" ]]; then
      # BIOS is older, apply workaround
      if [[ ! -f $file ]]; then
        echo "BIOS $BIOS_VERSION < 3.09 — applying suspend workaround"
        echo -n 'ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ' >"$file"
        echo 'ATTR{power/wakeup}="disabled"' >>"$file"
      fi
    else
      # BIOS is >= 3.09, remove workaround if present
      if [[ -f $file ]]; then rm -f "$file"; fi
    fi
  else
    unset_karg "amdgpu.dcdebugmask=0x10"            # Remove AMD workaround
    unset_karg "amdgpu.gpu_recovery=1"              # Remove AMD workaround
    unset_karg "amdgpu.reset_method=3"              # Remove AMD workaround
    unset_karg "amdgpu.sg_display=0"                # Remove AMD workaround
    file=/etc/udev/rules.d/20-suspend-fixes.rules
    if [[ -f $file ]]; then rm -f "$file"; fi
  fi

  if [[ "GenuineIntel" == "$CPU_VENDOR" ]]; then
    echo "Intel Framework Laptop detected, applying needed keyboard fix"
    set_karg "module_blacklist=hid_sensor_hub"      # Bug workaround
  else
    unset_karg "module_blacklist=hid_sensor_hub"    # Remove Intel workaround
  fi
else
  # Remove any Framework fixes
  systemctl disable --now framework-ectool.service
  systemctl disable --now fw-fanctrl.service
  unset_karg "amdgpu.dcdebugmask=0x10"              # Remove AMD workaround
  unset_karg "amdgpu.gpu_recovery=1"                # Remove AMD workaround
  unset_karg "amdgpu.reset_method=3"                # Remove AMD workaround
  unset_karg "amdgpu.sg_display=0"                  # Remove AMD workaround
  unset_karg "module_blacklist=hid_sensor_hub"      # Remove Intel workaround
  file=/etc/udev/rules.d/20-suspend-fixes.rules
  if [[ -f $file ]]; then rm -f "$file"; fi
fi

#shellcheck disable=SC2128
if [[ -n "$NEEDED_KARGS" ]]; then
  echo "Found needed karg changes, applying the following: ${NEEDED_KARGS[*]}"
  plymouth display-message \
        --text="Updating kargs - Please wait, this may take a while" || :
  rpm-ostree kargs ${NEEDED_KARGS[*]} || exit 1
else
  echo "No karg changes needed"
fi