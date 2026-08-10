# AGENTS.md

## Structure

- Keep image recipes in `recipes/`.
- Keep only `AGENTS.md` and `README.md` as root Markdown files; put other project
  documentation in `docs/`.
- Keep optional modules in `modules/`.
- Keep static files in `files/`.

## Style

- Preserve `LICENSE` and its legal text; never relicense without explicit approval.
- Preserve meaningful list order, including module dependency order.
- Sort unordered peer entries by value shape: simple or single-line values first,
  then structured or multiline values, alphabetically within each group.
- Sort unordered peer headings, lists, and table rows alphabetically. Preserve
  narrative, procedural, dependency, interface, priority, and chronological order.
- Use `.yaml`, never `.yml`, for project-owned YAML files unless external tooling
  requires a fixed filename.
- Use Australian English throughout authored prose and every project-owned name,
  including identifiers, configuration keys, environment variables, paths, CLI
  commands, and options. Update every producer and consumer together; preserve only
  externally defined names and terminology.

## Verification

- Build via the BlueBuild GitHub workflow or local `bluebuild`.
