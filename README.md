# Bluemax &nbsp; [![Build Badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax builds my personal [Bazzite](https://bazzite.gg/) images for handheld
and desktop gaming and a [uCore](https://projectucore.org/) image for homelab
servers.

## Building

On an x86-64 Linux host with
[BlueBuild](https://github.com/blue-build/cli#installation) and a supported
container engine installed, build locally without publishing:

```bash
bluebuild build recipes/bazzite.yaml
```

## Installation

To rebase an existing atomic Fedora installation, replace `IMAGE` with the chosen
image name.

- First rebase to the unsigned image to install the signing keys and policies:

  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/maxexcloo/IMAGE:latest
  ```

- Reboot to complete the rebase:

  ```bash
  systemctl reboot
  ```

- Then rebase to the signed image:

  ```bash
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/maxexcloo/IMAGE:latest
  ```

- Reboot again to complete the installation:

  ```bash
  systemctl reboot
  ```

## Streaming

On the Bazzite image, enable lingering once so Polaris keeps running when you
switch between Game Mode and Desktop Mode; an active stream still drops at the
switch, so reconnect afterwards:

```bash
sudo loginctl enable-linger "$USER"
```

The optional [streaming EDID](files/bazzite/usr/lib/firmware/edid/streaming.bin)
adds display modes for compatible external displays. Regenerate it with
`python3 files/edid/generate.py` (needs `edid-decode`).

To enable the override, replace `CONNECTOR` with your external display's DRM
connector name, then reboot:

```bash
sudo rpm-ostree kargs --append-if-missing="drm.edid_firmware=CONNECTOR:edid/streaming.bin"
```

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s
[cosign](https://github.com/sigstore/cosign). To verify the signature, download
`cosign.pub` from this repo and run:

```bash
cosign verify --key cosign.pub ghcr.io/maxexcloo/IMAGE
```

## Licence

AGPL-3.0 - see [LICENSE](LICENSE).
