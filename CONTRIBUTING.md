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

- **Components**: see [Authoring a component](#authoring-a-component).
- **Class attrs**: `attr :class, :any` and merge through `classes/1`; never concatenate class strings.
- **User-facing text** goes through Gettext. Add the `msgstr` for every locale under `priv/gettext/`, not just `en`.
- **Tests** for behaviour, in `test/`. Don't assert on CSS classes.
- **Storybook**: add or update the story under `storybook/storybook/` for any visible change.
- **Breaking changes**: call them out in the PR description so they land under *Compatibility* in the changelog.

## Authoring a component

Primitives live in `lib/cognit/<name>.ex`; composed app-shell pieces (page, topbar, side navs, form field) in `lib/cognit/components/`. Start the module with `use Cognit, :component`, which brings in `Phoenix.Component`, Gettext, `Cognit.Helpers`, and the `classes/1` merge helper. Add the module to the import list in `lib/cognit.ex` so `use Cognit` picks it up.

Interactive components (anything with open/close, selection, or keyboard state) are driven by a client-side state machine:

1. The root element carries a required `id`, `data-component="<name>"`, `phx-hook="SaladUI"`, and `phx-mounted={JS.ignore_attributes(["data-state"])}` so LiveView patches don't reset client state. Parts carry `data-part`. Options go in `data-options` as JSON, event-to-LiveView mappings in `data-event-mappings`.
2. The JS side lives in `assets/js/ui/components/<name>.js`: extend `Component` from `../core/component.js`, return `stateMachine`, `events`, `hiddenConfig`, and `ariaConfig` from `getComponentConfig()`, and register the class with the registry at module level. Import the file in `assets/index.js`.
3. Server-side control goes through `Cognit.LiveView.send_command/4`; client-side through `Cognit.JS.dispatch_command/3`. Any transition name the state machine defines is a valid command.

Form-capable components accept either `field` (a `Phoenix.HTML.FormField`) or `name`/`value`; `Cognit.Helpers.prepare_assign/1` normalises both. Variants go through `Cognit.Helpers.variant_class/2`; button-like things reuse `button_variant/1`.

## Updating bundled assets

- **Icons**: `mix icons.update` pulls the latest Material Symbols release (needs `curl` and [`uv`](https://docs.astral.sh/uv/)). The font keeps the full glyph set and only the `FILL` axis. Installed version: `assets/fonts/material_symbols/VERSION`.
- **Fonts**: `mix fonts.update` rebuilds the static latin-subset Open Sans files per weight from the upstream variable font. Installed version: `assets/fonts/open_sans/VERSION`.

## Releasing

Maintainers only, from an up-to-date `main`:

1. Bump `@version` in `mix.exs`. In `CHANGELOG.md`, rename `## Unreleased` to `## X.Y.Z` (or add the section if nobody wrote entries) and align the entries with the merged PRs.
2. Commit as `X.Y.Z` with nothing else in the commit.
3. Run `mix release`. It runs `mix check`, tags `X.Y.Z`, and pushes `main` and the tag.

An agent may do steps 1–2 when a maintainer asks for a release on `main`; step 3 stays manual.

Semver: breaking change to a public component or attr → minor while we are on `0.x` (and note it under *Compatibility*); everything else → patch or minor by scope.
