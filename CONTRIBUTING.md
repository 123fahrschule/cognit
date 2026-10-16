# Contributing

Applies to everyone who opens a pull request, human or AI agent. Agents: `AGENTS.md` is the short form of this file.

## The one rule that breaks installs

**Never change the version or create a tag in a pull request.**

Consumers install Cognit by git tag:

```elixir
{:cognit, github: "123fahrschule/cognit", tag: "X.Y.Z"}
```

A tag on an unmerged branch ships unreviewed code to every consumer pinned to it, and a version bump in a PR conflicts with every other open PR and the release commit.

In a PR, do not:

- edit `@version` in `mix.exs`
- add a `## X.Y.Z` heading to `CHANGELOG.md`
- run `mix release`
- run `git tag` or `git push --tags`

Releases are cut by a maintainer from `main` after merge. See [Releasing](#releasing).

## Workflow

1. Branch off `origin/main`: `git switch -c <type>/<short-topic> origin/main --no-track`
2. Make the change. Keep the PR to one topic; don't bundle unrelated cleanups.
3. Run `mix check` and `mix test`. Both must pass.
4. Open a PR against `main`.

### Commits

Conventional commit subject, single line, English: `fix(select): keep value when options re-render`. No version numbers in subjects.

### Pull request description

Describe the change as a user of the library sees it: which component, what changed, whether an existing call site must change. The maintainer turns this into the changelog entry at release time, so write it with that reader in mind.

### Changelog (optional)

You may add the entry yourself under a `## Unreleased` heading at the top of `CHANGELOG.md`, in the existing `### Features` / `### Bug Fixes` / `### Compatibility` groups and in the same style as the entries below it. Create the heading if it is missing. Never add a `## X.Y.Z` heading; the maintainer renames `Unreleased` and edits the entries at release.

## What a change needs

- **Components**: follow the authoring guide in `README.md`. Interactive components need a unique `id`, `data-component`, `data-part`, and a JS state machine under `assets/js/ui/components/`.
- **Class attrs**: `attr :class, :any` and merge through `classes/1`; never concatenate class strings.
- **User-facing text** goes through Gettext. Add the `msgstr` for every locale under `priv/gettext/`, not just `en`.
- **Tests** for behaviour, in `test/`. Don't assert on CSS classes.
- **Storybook**: add or update the story under `storybook/storybook/` for any visible change.
- **Breaking changes**: call them out in the PR description so they land under *Compatibility* in the changelog.

## Releasing

Maintainers only, from an up-to-date `main`:

1. Bump `@version` in `mix.exs`. In `CHANGELOG.md`, rename `## Unreleased` to `## X.Y.Z` (or add the section if nobody wrote entries) and align the entries with the merged PRs.
2. Commit as `X.Y.Z` with nothing else in the commit.
3. Run `mix release`. It runs `mix check`, tags `X.Y.Z`, and pushes `main` and the tag.

Semver: breaking change to a public component or attr → minor while we are on `0.x` (and note it under *Compatibility*); everything else → patch or minor by scope.
