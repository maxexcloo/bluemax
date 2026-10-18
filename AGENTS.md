# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- Keep image recipes in `recipes/`.
- Keep static files in `files/`. Only `files/system/` ships in the image;
  `files/edid/` is generator source.
- Add new paths that do not affect the image to the skip list in
  `.github/workflows/build.yaml`.

## Streaming

- KDE mode switching in `polaris-display-mode` targets the `DP-3` output.
- Regenerate `streaming.bin` with `python3 files/edid/generate.py`; it requires
  `edid-decode`.

## Verification

- Run the inherited global checks (`mise run check`) and
  `bluebuild validate recipes/recipe.yaml`, then confirm the CI image build.
