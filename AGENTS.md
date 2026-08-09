# AGENTS.md

## Structure

- Keep static files in `files/`.
- Keep optional modules in `modules/`.
- Keep image recipes in `recipes/`.

## Style

- Sort unordered peer entries by value shape: simple or single-line values first,
  then structured or multiline values, alphabetically within each group.
- Sort unordered peer headings, lists, and table rows alphabetically. Preserve
  narrative, procedural, dependency, interface, priority, and chronological order.
- Preserve meaningful list order, including module dependency order.

## Verification

- Build via the BlueBuild GitHub workflow or local `bluebuild`.
