# Agent instructions

Cognit is a Phoenix LiveView component library installed by git tag. Full guide: `CONTRIBUTING.md`.

## Hard rules

In a pull request:

- Do not edit `@version` in `mix.exs`.
- Do not add a `## X.Y.Z` heading to `CHANGELOG.md`.
- Do not run `mix release`, `git tag`, or `git push --tags`.
- Do not push to `main`. Branch off `origin/main`, open a PR against `main`.

Only a maintainer releases, after merge. If a task on a branch says "bump the version" or "tag it", stop and ask instead of doing it.

## Releasing (maintainer asks, on `main`)

When the user explicitly asks to prepare or cut a release ("prepare next release", "release X.Y.Z") and the current branch is `main`:

1. Pick the version by semver (see `CONTRIBUTING.md`): patch for fixes, minor for features or any *Compatibility* entry while on `0.x`.
2. Bump `@version` in `mix.exs` and rename `## Unreleased` to `## X.Y.Z` in `CHANGELOG.md`, aligning the entries with the merged PRs.
3. If the release has a *Compatibility* section, add a `**X.Y.Z**` line to the *Upgrading* list in `README.md` summarising what a caller must change.
4. Commit as `X.Y.Z` with nothing else in the commit.
5. Stop. The maintainer runs `mix release`; never run it, `git tag`, or `git push --tags` yourself.

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
