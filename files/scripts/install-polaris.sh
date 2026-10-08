#!/usr/bin/env bash
set -euo pipefail

polaris_version=1.4.13
polaris_fedora=44
polaris_sha256=047cc021f6e40212be48f8b922d1b591f18df4399690c31c3006421252e9a297

# Release RPMs must match the base image; review this pin on Fedora upgrades.
if [[ $(rpm -E '%fedora') != "$polaris_fedora" || $(uname -m) != x86_64 ]]; then
    echo "Polaris requires a reviewed Fedora ${polaris_fedora} x86_64 base." >&2
    exit 1
fi

polaris_directory=$(mktemp -d)
trap 'rm -rf "$polaris_directory"' EXIT
polaris_rpm="${polaris_directory}/Polaris-fedora${polaris_fedora}-x86_64.rpm"

curl --fail --location --retry 3 --output "$polaris_rpm" \
    "https://github.com/papi-ux/polaris/releases/download/v${polaris_version}/Polaris-fedora${polaris_fedora}-x86_64.rpm"
printf '%s  %s\n' "$polaris_sha256" "$polaris_rpm" | sha256sum --check --strict
dnf -y install "$polaris_rpm"
dnf clean all

# Host input permissions and service activation are deliberate post-boot steps.
test -x /usr/bin/polaris
test -f /usr/lib/systemd/user/polaris.service
command -v labwc
command -v wlr-randr
