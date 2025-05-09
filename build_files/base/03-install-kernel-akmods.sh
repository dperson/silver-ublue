#!/usr/bin/env -S bash

echo "::group:: ===$(basename "$0")==="
set -euxo pipefail

# Beta Updates Testing Repo...
if [[ "${UBLUE_IMAGE_TAG}" == "beta" ]]; then
  dnf config-manager setopt updates-testing.enabled=1
fi

# Remove Existing Kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core \
      kernel-modules-extra; do
  rpm --erase $pkg --nodeps
done

# Fetch Common AKMODS & Kernel RPMS
url="docker://ghcr.io/ublue-os/akmods:${AKMODS_FLAVOR}-$(rpm -E %fedora)"
skopeo copy --retry-times 3 "${url}-${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json |cut -d: -f2)
tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/
# NOTE: kernel-rpms should auto-extract into correct location

# Install Kernel
dnf install --setopt=install_weak_deps=False -y \
      /tmp/kernel-rpms/kernel-[0-9]*.rpm \
      /tmp/kernel-rpms/kernel-core-*.rpm \
      /tmp/kernel-rpms/kernel-modules-*.rpm

# TODO: Figure out why akmods cache is pulling in akmods/kernel-devel
# dnf install --setopt=install_weak_deps=False -y \
#       /tmp/kernel-rpms/kernel-devel-*.rpm

dnf versionlock add kernel kernel-core kernel-modules kernel-modules-core \
        kernel-modules-extra # kernel-devel kernel-devel-matched

# Everyone
if [[ "${UBLUE_IMAGE_TAG}" == "beta" ]]; then
  dnf install --setopt=install_weak_deps=False -y \
        /tmp/akmods/kmods/*framework-laptop*.rpm \
        /tmp/akmods/kmods/*openrazer*.rpm \
        /tmp/akmods/kmods/*xone*.rpm || :
else
  dnf install --setopt=install_weak_deps=False -y \
        /tmp/akmods/kmods/*framework-laptop*.rpm \
        /tmp/akmods/kmods/*openrazer*.rpm \
        /tmp/akmods/kmods/*xone*.rpm
fi

# Nvidia AKMODS
if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
  # Fetch Nvidia RPMs
  url="docker://ghcr.io/ublue-os/akmods-nvidia-open:${AKMODS_FLAVOR}"
  skopeo copy --retry-times 3 "${url}-$(rpm -E %fedora)-${KERNEL}" \
        dir:/tmp/akmods-rpms
  NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json |
        cut -d: -f2)
  tar -xvzf /tmp/akmods-rpms/"$NVIDIA_TARGZ" -C /tmp/
  mv /tmp/rpms/* /tmp/akmods-rpms/

  # Exclude the Golang Nvidia Container Toolkit in Fedora Repo
  dnf config-manager setopt excludepkgs=golang-github-nvidia-container-toolkit

  # Install Nvidia RPMs
  # Change when nvidia-install.sh updates
  url="https://raw.githubusercontent.com/ublue-os/main/main/build_files"
  ghcurl "$url/nvidia-install.sh" -o /tmp/nvidia-install.sh
  chmod +x /tmp/nvidia-install.sh
  IMAGE_NAME="${BASE_IMAGE_NAME}" RPMFUSION_MIRROR="" /tmp/nvidia-install.sh
  rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
  ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
  kargs='"rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", '
  kargs+='"nvidia-drm.modeset=1", '
  kargs+='"initcall_blacklist=simpledrm_platform_driver_init"'
  tee /usr/lib/bootc/kargs.d/00-nvidia.toml <<-EOF
		kargs = [$kargs]
		EOF
fi
echo "::endgroup::"