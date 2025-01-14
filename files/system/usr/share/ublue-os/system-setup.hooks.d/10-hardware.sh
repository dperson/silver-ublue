#!/usr/bin/env -S bash
set -euxo pipefail

set_karg() { arg="$1"
  if [[ ! $KARGS =~ $arg ]]; then
    NEEDED_KARGS+=("--append-if-missing=$arg")
  fi
}
unset_karg() { arg="$1"
  if [[ $KARGS =~ $arg ]]; then
    NEEDED_KARGS+=("--delete-if-present=$arg")
  fi
}

# GLOBAL
CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{print $2}')
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR=$(jq -r '."image-flavor"' <$IMAGE_INFO)
KARGS=$(rpm-ostree kargs)
KEYMAP="$(awk -F'"' '/^KEYMAP/ {print $2}' /etc/vconsole.conf)"
NEEDED_KARGS=()
SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"
VEN_ID="$(cat /sys/devices/virtual/dmi/id/chassis_vendor)"

echo "Current kargs: $KARGS"

if [[ "$IMAGE_FLAVOR" =~ nvidia ]]; then
  set_karg "initcall_blacklist=simpledrm_platform_driver_init"
fi

set_karg "rd.luks.options=discard"                  # Allow trim
unset_karg "nomodeset"                              # Don't bream KMS
[[ "$KEYMAP" ]] && set_karg "vconsole.keymap=$KEYMAP" # Set keymap for LUKS <F42
if [[ "AuthenticAMD" == "$CPU_VENDOR" ]]; then
  set_karg "amd_iommu=force_isolation"              # Disable IOMMU bypass
  set_karg "amd_pstate=active"                      # Better CPPC cpu perf
  set_karg "iomem=relaxed"                            # Allow undervolting AMD
  set_karg "tpm_tis.interrupts=0"                   # Fix AMD TPM causing jank
elif [[ "GenuineIntel" == "$CPU_VENDOR" ]]; then
  set_karg "intel_iommu=on"                         # Disable IOMMU bypass
fi
set_karg "efi=disable_early_pci_dma"                # Close IOMMU gap in boot
set_karg "iommu.passthrough=0"                      # Disable IOMMU bypass
set_karg "iommu.strict=1"                           # Sync invalidate IOMMU TLBs
set_karg "iommu=force"                              # Mitigate DMA attacks
set_karg "kvm.ignore_msrs=1"                        # Ignore broken Win VMs
set_karg "kvm.report_ignored_msrs=0"                # Ignore broken Win VMs
set_karg "lockdown=confidentiality"                 # Strictest kernel lockdown
set_karg "module.sig_enforce=1"                     # Only signed kernel modules
set_karg "page_alloc.shuffle=1"                     # Randomize page allocator
set_karg "pti=on"                                   # Page Table Isolation
set_karg "randomize_kstack_offset=on"               # Randomize kernel stack
set_karg "vsyscall=none"                            # Disable obsolete vsyscall

# FRAMEWORK FIXES
if [[ ":Framework:" =~ :$VEN_ID: ]]; then
  if [[ "AuthenticAMD" == "$CPU_VENDOR" ]] && [[ $SYS_ID == "Laptop 13 ("* ]]
  then
    set_karg "amdgpu.dcdebugmask=0x10"              # Bug workaround
    set_karg "amdgpu.gpu_recovery=1"                # Recovery from GPU hangs
    set_karg "amdgpu.reset_method=3"                # Way to recover GPU
    unset_karg "amdgpu.sg_display=0"                # Unneeded workaround
    if [[ ! -f /etc/modprobe.d/alsa.conf ]]; then
      echo 'Fixing 3.5mm jack'
      tee /etc/modprobe.d/alsa.conf <<< \
            "options snd-hda-intel index=1,0 model=auto,dell-headset-multi"
      echo 0 | tee /sys/module/snd_hda_intel/parameters/power_save
    fi
    file=/etc/udev/rules.d/20-suspend-fixes.rules
    if [[ ! -f $file ]]; then
      echo 'Fixing suspend issue'
      echo -n 'ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ' >$file
      echo 'ATTR{power/wakeup}="disabled"' >$file
    fi
  elif [[ "GenuineIntel" == "$CPU_VENDOR" ]]; then
    echo "Intel Framework Laptop detected, applying needed keyboard fix"
    set_karg "blacklist=hid_sensor_hub"             # Bug workaround
  fi
  systemctl enable --now framework-ectool.service
  systemctl enable --now fw-fanctrl.service
fi

#shellcheck disable=SC2128
if [[ -n "$NEEDED_KARGS" ]]; then
  echo "Found needed karg changes, applying the following: ${NEEDED_KARGS[*]}"
  plymouth display-message \
        --text="Updating kargs - Please wait, this may take a while" || true
  rpm-ostree kargs ${NEEDED_KARGS[*]} || exit 1
else
  echo "No karg changes needed"
fi