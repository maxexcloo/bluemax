# bluemax &nbsp; [![bluebuild build badge](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml/badge.svg)](https://github.com/maxexcloo/bluemax/actions/workflows/build.yaml)

bluemax is a personal [Bazzite Deck](https://bazzite.gg/) image for handheld
gaming and remote access. It follows Bazzite's `stable` channel and adds
Cloudflare Tunnel, KDE Partition Manager, Sunshine, and a curated set of gaming
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

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/maxexcloo/bluemax
```
