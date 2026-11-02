# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- Only `files/deck/` ships, in the Deck image; `files/edid/` is generator source.

## Verification

- Run `bluebuild validate` on each changed `recipes/recipe-*.yaml`, then confirm
  the CI image builds.
