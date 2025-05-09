[![Artifact Hub][1]][2]
[![Build Silver-Ublue Latest][3]][4]
[![Build Silver-Ublue GTS][5]][6]
[![Build Silver-Ublue ISO][7]][8]

# Silver-Ublue

* A custom Fedora Atomic image for daily driving, development, work, and gaming.
* Based on ublue-os/main (with parts borrowed from ublue-os/bluefin,
  ublue-os/bazzite, & secureblue/secureblue).
* Security enhancements, extra apps, & CLI tools being the primary
  modifications.
* Primarily intended for myself.

## Variants

Based on Fedora 42, Gnome 48:
* [Latest][9] - `ghcr.io/dperson/silver-ublue:latest`
* [Latest nvidia open][10] - `ghcr.io/dperson/silver-ublue-nvidia-open:latest`

[comment]: # (* [Latest nvidia][11] - `ghcr.io/dperson/silver-ublue-nvidia:latest`)

Based on Fedora 41, Gnome 47:
* [GTS][12] - `ghcr.io/dperson/silver-ublue:gts`
* [GTS nvidia open][13] - `ghcr.io/dperson/silver-ublue-nvidia-open:gts`

[comment]: # (* [GTS nvidia][14] - `ghcr.io/dperson/silver-ublue-nvidia:gts`)

## ISO

Installable ISO (built at least weekly) is available from:
* [latest iso][15]
* [latest iso sha256sum][16]

## Features

### Security

* Kernel tuning via boot args and sysctl
* WiFi & Ethernet MAC randomization

### Software

* Android tools - adb / fastboot / waydroid (run android apps)
* CLI tools - bat / bpftop / btop / chezmoi / delta / eza / fd / fzf / gh
  / kanata / mdcat / neovim / oh-my-posh / rg / rust-parallel / xdg-override
  / zoxide
* Cockpit for remote monitoring, admin, and VM management
* Container tools CLI - distrobox / dive / docker compose / flux / helm / k9s
  / kind / ko / kubectl / kubens / mc / podman (with docker emulation)
* Container tools GUI - Box Buddy / Distro Shelf / Podman Desktop
* Fonts some of the best Nerd Fonts - CascadiaCode / Intel One / JetBrains
  / Monaspace / SourceCodePro
* Gnome extensions to bring in missing functionality
* Virtualization - kvm / libvirt / qemu

## Installation

### Image Verification

Images are signed with [cosign][17]. To verify the signature, run the following:
```bash
cosign verify \
      --key https://github.com/dperson/silver-ublue/raw/main/cosign.pub \
      ghcr.io/dperson/<IMAGE>:<TAG>
```

### Desktop

You can switch an existing Fedora Atomic/Universal Blue installation to
Silver-Ublue image:

```bash
sudo bootc switch --enforce-container-sigpolicy \
      ghcr.io/dperson/silver-ublue:latest
```

OR

```bash
sudo rpm-ostree rebase \
      ostree-image-signed:docker://ghcr.io/dperson/silver-ublue:latest
```

## Custom commands

The following `ujust` commands are also available, in addition to the normal
ones on uBlue images:

```bash
# Change your shell
ujust chsh zsh

# Install great CLI tools
ujust cli-tools

# Install the default flatpaks
ujust install-system-flatpaks

# Install gaming flatpaks
ujust install-gaming-flatpaks

# Kernel args to enhance Security (may impact performance)
ujust kargs-hardening

# Install more great kubernetes tools
ujust k8s-tools

# Set terminal transparency
ujust ptyxis-transparency 0.9

# Configure waydroid
ujust setup-waydroid

# Flatpak settings overrides, to work around issues
ujust wayland-flapak

# Install media apps
ujust get-media-app

# Toggle running user services while not logged in
ujust toggle-linger-services

# Soft reboot into new container image
ujust soft-reboot
```

## Package management

### GUI

As an image based OS, applications can be installed by Flatpak (Bazaar)
or with `flatpak install <application>`.

### CLI

CLI tools can be added with Homebrew via `brew install <package>`, and any OS
can be installed via Distrobox and export it's apps out to the main system.

## Acknowledgments

This project is based on the [Universal Blue image template][18] and builds upon
the shoulders of the giants in the Universal Blue community.

[1]: https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/silver-ublue
[2]: https://artifacthub.io/packages/search?repo=silver-ublue
[3]: https://github.com/dperson/silver-ublue/actions/workflows/build-image-latest-main.yml/badge.svg
[4]: https://github.com/dperson/silver-ublue/actions/workflows/build-image-latest-main.yml
[5]: https://github.com/dperson/silver-ublue/actions/workflows/build-image-gts.yml/badge.svg
[6]: https://github.com/dperson/silver-ublue/actions/workflows/build-image-gts.yml
[7]: https://github.com/dperson/silver-ublue/actions/workflows/build-iso-anaconda.yml/badge.svg
[8]: https://github.com/dperson/silver-ublue/actions/workflows/build-iso-anaconda.yml
[9]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue:latest
[10]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue-nvidia:latest
[11]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue-nvidia-open:latest
[12]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue:gts
[13]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue-nvidia:gts
[14]: ostree-image-signed:docker://ghcr.io/dperson/silver-ublue-nvidia-open:gts
[15]: https://pub-3e297cc6eba24590a47d52faa734b43e.r2.dev/silver-ublue-latest-x86_64.iso
[16]: https://pub-3e297cc6eba24590a47d52faa734b43e.r2.dev/silver-ublue-latest-x86_64.iso-CHECKSUM
[17]: https://docs.sigstore.dev/cosign/overview
[18]: https://github.com/ublue-os/image-template