# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- `files/<image>/` ships in that image and `files/common/` in all of them;
  `files/edid/` is generator source.
- CI builds every `recipes/recipe-<image>.yaml`; name its image `bluemax-<image>`
  and list it in the README.

## Verification

- Run `bluebuild validate` on each changed `recipes/recipe-*.yaml`, then confirm
  the CI image builds.
