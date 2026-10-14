#!/usr/bin/env bash
set -euo pipefail

viewer_revision=6ffedb95967dcd864991e1ac581d9e9d62d3e84a
rdw_revision=d7c38aed1c2cf4743833d587a9135744a745893f
viewer_source=/var/tmp/qemu-display
rdw_source=/var/tmp/rdw

# Build the native D-Bus viewer separately from the host image.
dnf install -y cargo cargo-c gcc gcc-c++ git gstreamer1-devel \
  gstreamer1-plugins-base-devel gtk4-devel libepoxy-devel libusb1-devel \
  make pixman-devel usbredir-devel

git clone --depth 1 --revision "$viewer_revision" \
  https://gitlab.com/marcandre.lureau/qemu-display.git "$viewer_source"
git clone --depth 1 --recurse-submodules --revision "$rdw_revision" \
  https://gitlab.gnome.org/malureau/rdw.git "$rdw_source"

# The upstream demo has no fullscreen option. Use GTK's native window properties.
cat > "$viewer_source/qemu-rdw/src/main.ui" <<'UI'
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <object class="GtkApplicationWindow" id="window">
    <property name="decorated">false</property>
    <property name="fullscreened">true</property>
  </object>
</interface>
UI
sed -i '/window.set_application(Some(app));/a\            window.set_title(opt.borrow().vm_name.as_deref());' \
  "$viewer_source/qemu-rdw/src/main.rs"

export CARGO_BUILD_JOBS=3
export CARGO_PROFILE_RELEASE_DEBUG=0
export LD_LIBRARY_PATH=/out/usr/lib64
cargo generate-lockfile --manifest-path "$rdw_source/Cargo.toml"
cargo cinstall --destdir /out --features capi --libdir /usr/lib64 --locked \
  --manifest-path "$rdw_source/rdw4/Cargo.toml" --prefix /usr --release
# pkg-config names /usr, so make the built library available to the viewer linker.
cp -a /out/usr/. /usr/
cargo build --locked --manifest-path "$viewer_source/Cargo.toml" \
  --package qemu-rdw --release
install -Dm755 "$viewer_source/target/release/qemu-rdw" /out/usr/bin/qemu-rdw
install -Dm644 "$viewer_source/LICENSE-MIT" /out/usr/share/licenses/qemu-rdw/LICENSE-MIT
install -Dm644 "$rdw_source/LICENSE" /out/usr/share/licenses/qemu-rdw/RDW-LICENSE
/out/usr/bin/qemu-rdw --version

# Only runtime libraries and the executable belong in the host image.
rm -rf /out/usr/include /out/usr/lib64/pkgconfig /out/usr/lib64/*.a \
  "$rdw_source" "$viewer_source" "$HOME/.cache" "$HOME/.cargo"
