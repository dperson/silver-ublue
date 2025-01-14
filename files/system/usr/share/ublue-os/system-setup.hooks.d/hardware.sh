#!/usr/bin/env -S bash
#shellcheck disable=SC2076

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR=$(jq -r '."image-flavor"' <$IMAGE_INFO)

CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{print $2}')
KARGS=$(rpm-ostree kargs)
NEEDED_KARGS=()
SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"
VEN_ID="$(cat /sys/devices/virtual/dmi/id/chassis_vendor)"

echo "Current kargs: $KARGS"

ARG="initcall_blacklist=simpledrm_platform_driver_init"
if [[ "$IMAGE_FLAVOR" =~ "nvidia" ]] && [[ ! "$KARGS" =~ "$ARG" ]]; then
  NEEDED_KARGS+=("--append-if-missing=$ARG")
fi

if [[ $KARGS =~ "nomodeset" ]]; then
  echo "Removing nomodeset"
  NEEDED_KARGS+=("--delete-if-present=nomodeset")
fi

KEYMAP="$(awk -F'"' '/^KEYMAP/ {print $2}' /etc/vconsole.conf)"
if [[ "$KEYMAP" ]] && [[ ! "$KARGS" =~ "keymap=$KEYMAP" ]]; then
  NEEDED_KARGS+=("--append-if-missing=vconsole.keymap=$KEYMAP")
fi

# FRAMEWORK FIXES
if [[ ":Framework:" =~ ":$VEN_ID:" ]] && [[ $SYS_ID == "Laptop 13 ("* ]]; then
  if [[ "AuthenticAMD" == "$CPU_VENDOR" ]]; then
    if [[ ! $KARGS =~ "dcdebugmask=0x10" ]]; then
      NEEDED_KARGS+=("--append-if-missing=amdgpu.dcdebugmask=0x10")
    fi
    if [[ $KARGS =~ "sg_display=0" ]]; then
      NEEDED_KARGS+=("--delete-if-present=amdgpu.sg_display=0")
    fi
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
    if [[ ! $KARGS =~ "blacklist=hid_sensor_hub" ]]; then
      NEEDED_KARGS+=("--append-if-missing=module_blacklist=hid_sensor_hub")
    fi
  fi
  systemctl enable --now framework-ectool.service
  systemctl enable --now fw-fanctrl.service
fi

#shellcheck disable=SC2128
if [[ -n "$NEEDED_KARGS" ]]; then
  echo "Found needed karg changes, applying the following: ${NEEDED_KARGS[*]}"
  plymouth display-message \
        --text="Updating kargs - Please wait, this may take a while" || true
  rpm-ostree kargs "${NEEDED_KARGS[*]}" || exit 1
else
  echo "No karg changes needed"
fi