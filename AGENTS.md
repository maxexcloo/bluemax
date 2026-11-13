# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- `files/<recipe>/` ships in that recipe; `files/edid/` is generator source.
- Recipe filenames describe source organisation; their `name` fields are published
  image identities. Preserve those names unless migrating their consumers.
- Cloudflared's RPM scripts need `/var/usrlocal/bin` created before installation
  because Atomic images symlink `/usr/local` there.

## Verification

- Run `bluebuild validate` on each changed `recipes/*.yaml`, then confirm
  the CI image builds.
