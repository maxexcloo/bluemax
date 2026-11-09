# Bluemax &nbsp; [![Build Badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax builds my personal [Bazzite](https://bazzite.gg/) images for handheld
and desktop gaming and a [uCore](https://projectucore.org/) image for homelab
servers.

Choose an image:

- [`bluemax-deck`](recipes/recipe-deck.yaml) for handheld gaming and Polaris streaming.
- [`bluemax-desktop`](recipes/recipe-desktop.yaml) for desktop gaming.
- [`bluemax-server`](recipes/recipe-server.yaml) for homelab servers.

## Building

On an x86-64 Linux host with
[BlueBuild](https://github.com/blue-build/cli#installation) and a supported
container engine installed, build locally without publishing:

```bash
bluebuild build recipes/recipe-deck.yaml
```

## Installation

To rebase an existing atomic Fedora installation to the latest build, replace
`IMAGE` with `bluemax-deck`, `bluemax-desktop` or `bluemax-server`.

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

The Deck image includes a Desktop-only Polaris app template and
[`polaris-display-mode`](files/deck/usr/bin/polaris-display-mode). It matches
the client's resolution and refresh rate in KDE or Gamescope and restores the
previous mode on disconnect. KDE currently targets `DP-3`, and Gamescope uses its
active display. It only picks modes the display advertises. If you switch desktop
sessions during a stream, the old mode may not come back until that desktop is
available again.

Polaris starts at login in Game Mode and Desktop Mode. Enable lingering once so
it keeps running while you switch between them; an active stream still drops at
the switch, so reconnect afterwards:

```bash
sudo loginctl enable-linger "$USER"
```

The optional [streaming EDID](files/deck/usr/lib/firmware/edid/streaming.bin)
adds display modes for compatible external displays. Edit
[`generate.py`](files/edid/generate.py) and run
`python3 files/edid/generate.py` with `edid-decode` installed to regenerate it.

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
