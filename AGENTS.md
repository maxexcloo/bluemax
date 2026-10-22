# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- Only `files/system/` ships in the image; `files/edid/` is generator source.

## Verification

- Run `bluebuild validate recipes/recipe.yaml`, then confirm the CI image build.
