# Bluemax &nbsp; [![BlueBuild Build Badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax is a personal [Bazzite Deck](https://bazzite.gg/) image for handheld
gaming and remote access. It follows Bazzite's `stable` channel and adds
Cloudflare Tunnel, KDE Partition Manager, Polaris, Reims, and a curated set of gaming
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

## macOS VMs

Run `reims-ctl doctor` to check host readiness, then `reims-ctl` to create and
manage VMs. Follow [Reims setup instructions](https://github.com/steelbrain/reims-vgpu#x86-64-guest-on-linux-kvm)
for macOS installation. Update Reims through image updates.

For an installed VM named `mac`, stop it before enabling its private console
and boot service:

```bash
reims-ctl stop mac
reims-ctl set --audio-backend dbus --env REIMS_VGPU_WINDOW=0 --extra-args '-global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 -display dbus,gl=off' mac
systemctl --user enable --now reims@mac.service
loginctl enable-linger
```

Disabling S3/S4 keeps macOS from suspending the VM. Its service also keeps the
host awake while the VM runs. Copy
[`reims.toml`](files/system/usr/share/moonshine/reims.toml) to
`~/.config/moonshine/config.toml`, set its private listening address, then enable
`moonshine.service` with `systemctl --user enable --now moonshine.service`.
Moonshine appears as a separate macOS host in Moonlight. The fullscreen native
QEMU viewer attaches to the running VM over D-Bus, including its audio;
disconnecting closes the viewer while the VM keeps running. Polaris remains
available for games, including during a local Gamescope session.

On hosts with multiple GPUs, set `compositor.gpu` in Moonshine's configuration
and `MESA_VK_DEVICE_SELECT` in `~/.config/moonshine/environment` to select the
same GPU for rendering and encoding. Reims still copies guest frames into this
display path; `gl=off` does not disable guest GPU acceleration. Check the selected
device in
`journalctl --user -u moonshine.service`. Add this host to Moonlight using its
configured HTTP port.

## Streaming

The image includes a Desktop-only Polaris app template and
[`polaris-display-mode`](files/system/usr/bin/polaris-display-mode), which matches
the client's resolution and refresh rate in KDE or Gamescope and restores the
previous mode on disconnect. KDE currently targets `DP-3`; Gamescope uses its
active display. Only modes advertised by the display are selected. Changing
desktop sessions during a stream can prevent restoration until that desktop is
available again.

The optional [streaming EDID](files/system/usr/lib/firmware/edid/streaming.bin)
adds display modes for compatible external displays. It is included in the
image's initramfs. Edit [`generate.py`](files/edid/generate.py) and run
`python3 files/edid/generate.py` with `edid-decode` installed to regenerate it.

To enable the override, replace `CONNECTOR` with your external display's DRM
connector name, then reboot:

```bash
sudo rpm-ostree kargs --append-if-missing="drm.edid_firmware=CONNECTOR:edid/streaming.bin"
```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/maxexcloo/bluemax
```
