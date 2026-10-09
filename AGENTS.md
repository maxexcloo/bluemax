# AGENTS.md

## Structure

- Keep `cosign.pub` at the repository root as required by BlueBuild.
- Keep image recipes in `recipes/`.
- Keep optional modules in `modules/`.
- Keep static files in `files/`.

## Style

- Preserve meaningful list order, including module dependency order.

## Verification

- Build via the BlueBuild GitHub workflow or local `bluebuild`.
