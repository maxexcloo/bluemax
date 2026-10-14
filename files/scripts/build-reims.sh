#!/usr/bin/env bash
set -euo pipefail

reims_revision=86d492197228df29514a87c3de62b2ce59f2188f
reims_source=/var/tmp/reims-source

# Use Fedora's native dependencies; only the runtime output is copied out.
dnf install -y \
  alsa-lib-devel binutils bison bzip2 ca-certificates clang cmake curl \
  dbus-devel flex gcc gcc-c++ git glib2-devel libX11-devel \
  libXScrnSaver-devel libXcursor-devel libXext-devel libXfixes-devel \
  libXi-devel libXrandr-devel libXtst-devel libdecor-devel libdrm-devel libepoxy-devel \
  libfdt-devel libglvnd-devel libslirp-devel libxkbcommon-devel lld make \
  mesa-libEGL-devel mesa-libGL-devel mesa-libgbm-devel ninja-build \
  pipewire-devel pixman-devel pkgconf-pkg-config pulseaudio-libs-devel \
  python3 python3-pip systemd-devel vulkan-loader-devel \
  wayland-devel wayland-protocols-devel zlib-devel

git clone --depth 1 --revision "$reims_revision" \
  https://github.com/steelbrain/reims-vgpu.git "$reims_source"

export CARGO_INSTALL_ROOT=/out/usr/lib/reims
bash "$reims_source/scripts/install-ctl.sh" --yes

# QEMU's D-Bus display needs its own OpenGL support alongside Reims's Vulkan renderer.
for feature in DBUS_DISPLAY OPENGL; do
  grep -Eq "^#define CONFIG_$feature([[:space:]]+1)?$" \
    "$HOME/.cache/reims-ctl/qemu-build-linux-x86_64/config-host.h"
done
cp -a "$HOME/.local/share/reims-ctl/qemu/current/." "$CARGO_INSTALL_ROOT/qemu"

mkdir -p /out/usr/share/licenses/reims
cp "$reims_source/LICENSE" /out/usr/share/licenses/reims/LICENSE
cp "$reims_source/vendor/qemu/COPYING" /out/usr/share/licenses/reims/QEMU-COPYING
cp "$reims_source/vendor/qemu/COPYING.LIB" /out/usr/share/licenses/reims/QEMU-COPYING.LIB

"$CARGO_INSTALL_ROOT/bin/reims-ctl" --version
"$CARGO_INSTALL_ROOT/bin/reims-util" --version
"$CARGO_INSTALL_ROOT/qemu/bin/qemu-system-x86_64" -device help | grep -F apple-gfx-pci

# Discard source and toolchain caches before committing the build stage.
rm -rf "$reims_source" "$HOME/.cache" "$HOME/.cargo" "$HOME/.config" \
  "$HOME/.local" "$HOME/.rustup"
