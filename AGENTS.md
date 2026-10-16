# Agent instructions

Cognit is a Phoenix LiveView component library installed by git tag. Full guide: `CONTRIBUTING.md`.

## Hard rules

- Do not edit `@version` in `mix.exs`.
- Do not add a `## X.Y.Z` heading to `CHANGELOG.md`.
- Do not run `mix release`, `git tag`, or `git push --tags`.
- Do not push to `main`. Branch off `origin/main`, open a PR against `main`.

Only a maintainer releases, after merge. If the task says "bump the version" or "tag it", stop and ask instead of doing it.

## Before opening a PR

```bash
mix check   # format, unused deps, compile --warnings-as-errors
mix test
```

Both must pass. Don't run `mix release`; it tags and pushes.

## Conventions

- One topic per PR. No unrelated cleanups.
- Conventional commit subjects, single line, English.
- `attr :class, :any`, merged via `classes/1`.
- All user-facing text through Gettext, with a `msgstr` for every locale in `priv/gettext/`.
- Tests assert behaviour, not CSS classes.
- Visible changes get a story under `storybook/storybook/`.
- Write the PR description for the changelog reader: component, what changed, what a caller must update.
- Changelog entries are optional. If you add one, put it under `## Unreleased` at the top of `CHANGELOG.md`, never under a version heading.
