# Bluemax &nbsp; [![Build Badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax builds my personal [Bazzite](https://bazzite.gg/) images. Both follow
Bazzite's `stable` channel, including Fedora major version upgrades once Bazzite
promotes them, and add KDE Partition Manager, the Eden & Eglantine AppImages and
a set of gaming Flatpaks I've picked from
[`recipes/common.yaml`](recipes/common.yaml).

| Image             | Base           | Adds                                       |
| ----------------- | -------------- | ------------------------------------------ |
| `bluemax-deck`    | `bazzite-deck` | Polaris streaming for handheld remote play |
| `bluemax-desktop` | `bazzite`      | Nothing beyond the shared configuration    |

Each image's configuration is in its `recipes/recipe-*.yaml`.

## Building

On an x86-64 Linux host with
[BlueBuild](https://github.com/blue-build/cli#installation) and a supported
container engine installed, build locally without publishing:

```bash
bluebuild build recipes/recipe-deck.yaml
```

## Installation

To rebase an existing atomic Fedora installation to the latest build, replace
`IMAGE` with `bluemax-deck` or `bluemax-desktop`.

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
adds display modes for compatible external displays and is included in the
image's initramfs. Edit [`generate.py`](files/edid/generate.py) and run
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
