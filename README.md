# Bluemax &nbsp; [![BlueBuild Build Badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax is my personal [Bazzite Deck](https://bazzite.gg/) image for handheld
gaming and remote access. It follows Bazzite's `stable` channel and adds
Cloudflare Tunnel, KDE Partition Manager, Polaris and a set of gaming Flatpaks
I've picked. The full image configuration is in
[`recipes/recipe.yaml`](recipes/recipe.yaml).

## Building

On an x86-64 Linux host with [BlueBuild](https://github.com/blue-build/cli#installation) and a
supported container engine installed, build locally without publishing:

```bash
bluebuild build recipes/recipe.yaml
```

The GitHub workflow builds pull requests without publishing or signing them.
Documentation and local tooling changes skip the image build but still report the
required check. Changes to image inputs or the workflow build normally. Image
changes on `main`, the daily scheduled build and manual runs on `main` publish
the image, signed with the repository's `SIGNING_SECRET`. Runs queue, so a
documentation change can't cancel an image publication.

## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image to install the signing keys and policies:

  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/maxexcloo/bluemax:latest
  ```

- Reboot to complete the rebase:

  ```bash
  systemctl reboot
  ```

- Then rebase to the signed image:

  ```bash
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/maxexcloo/bluemax:latest
  ```

- Reboot again to complete the installation:

  ```bash
  systemctl reboot
  ```

The `latest` tag always points to the newest build. The image follows Bazzite
Deck's upstream `stable` channel, including Fedora major version upgrades once
Bazzite promotes them.

## Licence

Apache-2.0 - see [LICENSE](LICENSE).

## Streaming

The image includes a Desktop-only Polaris app template and
[`polaris-display-mode`](files/system/usr/bin/polaris-display-mode). It matches
the client's resolution and refresh rate in KDE or Gamescope and restores the
previous mode on disconnect. KDE currently targets `DP-3`, and Gamescope uses its
active display. It only picks modes the display advertises. If you switch desktop
sessions during a stream, the old mode may not come back until that desktop is
available again.

The optional [streaming EDID](files/system/usr/lib/firmware/edid/streaming.bin)
adds display modes for compatible external displays and is included in the
image's initramfs. Edit [`generate.py`](files/edid/generate.py) and run
`python3 files/edid/generate.py` with `edid-decode` installed to regenerate it.

To enable the override, replace `CONNECTOR` with your external display's DRM
connector name, then reboot:

```bash
sudo rpm-ostree kargs --append-if-missing="drm.edid_firmware=CONNECTOR:edid/streaming.bin"
```

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). To verify the signature, download `cosign.pub` from this repo and run:

```bash
cosign verify --key cosign.pub ghcr.io/maxexcloo/bluemax
```
