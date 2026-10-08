# Polaris trial

The image includes Polaris 1.4.13 alongside Sunshine for a reversible trial.
The [installation script](../files/scripts/install-polaris.sh) pins the Fedora 44
x86-64 release RPM and verifies its SHA-256 digest before installation. A Fedora
major-version change stops the build until a compatible package is reviewed.
Polaris updates require changing both the version and digest, then rebuilding.

## Activation

Pull the updated Bluemax image and reboot before activating Polaris. Do not layer
another Polaris RPM: this image already contains it and its runtime dependencies.

After reboot, confirm the package and inspect the Sunshine services:

```bash
rpm -q polaris
systemctl --user list-unit-files '*sunshine*' '*Sunshine*'
```

On Mandu, stop the existing service before starting Polaris because their ports
overlap. Retain Sunshine's settings and display-mode helper during the trial.

```bash
systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service
sudo -H polaris --setup-host --enable-headless-boot
```

Follow the setup output, including any input-group instructions and required
logout or reboot, before continuing:

```bash
systemctl --user enable --now polaris
systemctl --user is-active polaris
```

Open `https://127.0.0.1:47990` on Mandu to create the Polaris account and pair the
client. Leave automatic trusted-subnet pairing disabled. Start with SDR at
1920×1080 and 60 FPS, then verify the actual capture path and encoder in the
console. Mandu has two AMD GPUs, so explicitly select the intended GPU if
automatic selection chooses the wrong one.

The optional privileged `polaris-kms` package is not included. Normal private and
portal capture do not require it. Host setup must run on the booted machine as
the normal user through `sudo`, not during the image build.

## Recovery

To return to Sunshine without removing either package:

```bash
systemctl --user disable --now polaris
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
```

Keep Polaris's settings for diagnosis or a later retry. Leave user lingering
enabled: Mandu already used it before this trial, and other services may need it.

## Validation

1. In KDE Desktop Mode, test physical-screen mirroring and Private Stream.
2. Check resolution/FPS, controller input, rumble and audio in each mode.
3. Test disconnect/reconnect separately from ending the application, including
   reconnecting with a different client resolution.
4. Check physical display and audio restoration after ending the session.
5. Switch to Game Mode and test screen capture, game launch and reconnect.
   Private Stream is unavailable while the host is in Game Mode.
6. Reboot and check service availability and streaming again.
7. Remove Sunshine packages, service overrides and display-mode references only
   after the trial meets these requirements.

AMD and Bazzite Game Mode need local validation; successful package installation
does not establish working capture. Follow the upstream
[Bazzite guide](https://github.com/papi-ux/polaris/blob/v1.4.13/docs/bazzite.md)
for troubleshooting.
