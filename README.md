# bluemax &nbsp; [![bluebuild build badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax is a personal [Bazzite Deck](https://bazzite.gg/) image for handheld
gaming and remote access. It follows Bazzite's `stable` channel and adds
Cloudflare Tunnel, KDE Partition Manager, Polaris, and a curated set of gaming
Flatpaks. The complete image configuration is in
[`recipes/recipe.yaml`](recipes/recipe.yaml).

## Building

On an x86-64 Linux host with [BlueBuild](https://github.com/blue-build/cli#installation) and a
supported container engine installed, build locally without publishing:

```bash
bluebuild build recipes/recipe.yaml
```

The GitHub workflow builds pull requests without publishing or signing them.
Pushes to `main`, daily scheduled builds, and manual runs on `main` publish the
signed image using the repository's `SIGNING_SECRET`.

## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:

  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/maxexcloo/bluemax:latest
  ```

- Reboot to complete the rebase:

  ```bash
  systemctl reboot
  ```

- Then rebase to the signed image, like so:

  ```bash
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/maxexcloo/bluemax:latest
  ```

- Reboot again to complete the installation:

  ```bash
  systemctl reboot
  ```

The `latest` tag automatically points to the newest build. The image follows Bazzite Deck's upstream `stable` channel, including Fedora major-version transitions when Bazzite promotes them.

## Licence

Apache-2.0 - see [LICENSE](LICENSE).

## Streaming

The image includes a Desktop-only Polaris app template and
[`polaris-display-mode`](files/system/usr/bin/polaris-display-mode), which matches
the client's resolution and refresh rate in KDE or Gamescope and restores the
previous mode on disconnect. KDE uses Mandu's `DP-3` output; Gamescope uses its
active display. Only modes advertised by the display are selected. Changing
desktop sessions during a stream can prevent restoration until that desktop is
available again.

The [streaming EDID](files/system/usr/lib/firmware/edid/streaming.bin) preserves
Mandu's original LG TV audio, HDR and VRR data, adding 14 sizes at 60 and 120 Hz,
including MacBook, 3440×1440 and 5120×2160 modes. It is included in the image's
initramfs using BlueBuild's [initramfs module](https://blue-build.org/reference/modules/initramfs/).
Advertised modes do not guarantee physical-display or streaming performance.
Edit the resolution list in [`generate.py`](files/edid/generate.py) and run
`python3 files/edid/generate.py` on a system with `edid-decode` installed to
regenerate it from the preserved original EDID.

Enable the EDID on Mandu once, then reboot:

```bash
sudo rpm-ostree kargs --append-if-missing=drm.edid_firmware=DP-3:edid/streaming.bin
```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/maxexcloo/bluemax
```
