# silver-ublue

[![build-ublue][1]][2]

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for instructions
for setting up your own repository based on this template.

## Installation

> **Warning**
> [This is an experimental feature][3], try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and
policies installed:
  ```bash
  rpm-ostree rebase \
        ostree-unverified-registry:ghcr.io/dperson/silver-ublue:latest
  ```
- Reboot to complete the rebase:
  ```bash
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```bash
  rpm-ostree rebase \
        ostree-image-signed:docker://ghcr.io/dperson/silver-ublue:latest
  ```
- Reboot again to complete the installation
  ```bash
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will
still always use the Fedora version specified in `recipe.yml`, so you won't get
accidentally updated to the next major version.

## ISO

This project includes a Github Action that builds an ISO.

The action creates the image, but isnn't allowed to make it a 'Release' due to
size constraints. Please look in [actions][4] for the latest "Generate ISO" and
download the artifact.

Note that this release-iso action is not a replacement for a full-blown release
automation like [release-please](https://github.com/googleapis/release-please).

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s
[cosign](https://github.com/sigstore/cosign). You can verify the signature by
downloading the `cosign.pub` file from this repo and running the following
command:

```bash
cosign verify --key cosign.pub ghcr.io/dperson/silver-ublue
```

[1]: https://github.com/dperson/silver-ublue/actions/workflows/build.yml/badge.svg
[2]: https://github.com/dperson/silver-ublue/actions/workflows/build.yml
[3]: https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable
[4]: https://github.com/dperson/silver-ublue/actions/workflows/release-iso.yml
