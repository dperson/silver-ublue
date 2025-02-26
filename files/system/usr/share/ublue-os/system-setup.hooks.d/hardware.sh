#!/usr/bin/env -S bash
#shellcheck disable=SC2076

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_NAME=$(jq -r '."image-name"' <$IMAGE_INFO)
IMAGE_FLAVOR=$(jq -r '."image-flavor"' <$IMAGE_INFO)

VEN_ID="$(cat /sys/devices/virtual/dmi/id/chassis_vendor)"
CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{print $2}')

# IMAGE IDENTIFIERS
KNOWN_IMAGE_NAME_FILE="/etc/ublue/image_name"
[[ -f "$KNOWN_IMAGE_NAME_FILE" ]] &&
      KNOWN_IMAGE_NAME=$(cat $KNOWN_IMAGE_NAME_FILE)
KNOWN_IMAGE_FLAVOR_FILE="/etc/ublue/image_flavor"
[[ -f "$KNOWN_IMAGE_FLAVOR_FILE" ]] &&
      KNOWN_IMAGE_FLAVOR=$(cat $KNOWN_IMAGE_FLAVOR_FILE)

# Run script if updated
if [[ -f "$KNOWN_IMAGE_NAME_FILE" ]] && [[ -f "$KNOWN_IMAGE_FLAVOR_FILE" ]];then
  # Run script if image has been rebased
  if [[ "$IMAGE_NAME" = "$KNOWN_IMAGE_NAME" ]] &&
        [[ "$IMAGE_FLAVOR" = "$KNOWN_IMAGE_FLAVOR" ]]; then
    echo "Hardware setup has already run. Exiting..."
    exit 0
  fi
fi

# GLOBAL
KARGS=$(rpm-ostree kargs)
NEEDED_KARGS=()
echo "Current kargs: $KARGS"
mkdir -p /etc/ublue

ARG="initcall_blacklist=simpledrm_platform_driver_init"
if [[ "$IMAGE_FLAVOR" =~ "nvidia" ]] && [[ ! "$KARGS" =~ "$ARG" ]]; then
  NEEDED_KARGS+=("--append-if-missing=$ARG")
fi

if [[ $KARGS =~ "nomodeset" ]]; then
  echo "Removing nomodeset"
  NEEDED_KARGS+=("--delete-if-present=nomodeset")
fi

if [[ ":Framework:" =~ ":$VEN_ID:" ]] && [[ "GenuineIntel" == "$CPU_VENDOR" ]]&&
  [[ ! $KARGS =~ "hid_sensor_hub" ]]; then
  echo "Intel Framework Laptop detected, applying needed keyboard fix"
  NEEDED_KARGS+=("--append-if-missing=module_blacklist=hid_sensor_hub")
fi

#shellcheck disable=SC2128
if [[ -n "$NEEDED_KARGS" ]]; then
  echo "Found needed karg changes, applying the following: ${NEEDED_KARGS[*]}"
  plymouth display-message \
        --text="Updating kargs - Please wait, this may take a while" || true
  rpm-ostree kargs "${NEEDED_KARGS[*]}" --reboot || exit 1
else
  echo "No karg changes needed"
fi

SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"

# FRAMEWORK 13 AMD FIXES
if [[ ":Framework:" =~ ":$VEN_ID:" ]] && [[ $SYS_ID == "Laptop 13 ("* ]] &&
      [[ "AuthenticAMD" == "$CPU_VENDOR" ]]; then
  if ! grep -q "amdgpu.sg_display=0" <<<"$(rpm-ostree kargs)"; then
    rpm-ostree kargs --append-if-missing="amdgpu.sg_display=0"
  fi
  if [[ ! -f /etc/modprobe.d/alsa.conf ]]; then
    echo 'Fixing 3.5mm jack'
    tee /etc/modprobe.d/alsa.conf <<< \
          "options snd-hda-intel index=1,0 model=auto,dell-headset-multi"
    echo 0 | tee /sys/module/snd_hda_intel/parameters/power_save
  fi
  if [[ ! -f /etc/udev/rules.d/20-suspend-fixes.rules ]]; then
    echo 'Fixing suspend issue'
    echo -n "ACTION==\"add\", SUBSYSTEM==\"serio\", DRIVERS==\"atkbd\", " \
          >/etc/udev/rules.d/20-suspend-fixes.rules
    echo "ATTR{power/wakeup}=\"disabled\"" \
          >/etc/udev/rules.d/20-suspend-fixes.rules
  fi
fi

if [[ "AuthenticAMD" == "$CPU_VENDOR" ]]; then
  [[ ! -d /etc/modules-load.d ]] && mkdir /etc/modules-load.d
  cp /usr/share/ublue-os/ryzen_smu.conf /etc/modules-load.d/
elif [[ -f /etc/modules-load.d/ryzen_smu.conf ]]; then
  rm /etc/modules-load.d/ryzen_smu.conf
fi

echo "$IMAGE_NAME" >$KNOWN_IMAGE_NAME_FILE
echo "$IMAGE_FLAVOR" >$KNOWN_IMAGE_FLAVOR_FILE
