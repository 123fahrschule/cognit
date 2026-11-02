# Cognit

Phoenix LiveView component library, installed as a git dependency.

Developing Cognit itself (the working directory is this repo)? Read `CONTRIBUTING.md` before any change. Never bump the version or tag in a PR.

## Using Cognit in an app

- Never edit files under `deps/cognit/`: `mix deps.get` overwrites them. Fix upstream or wrap the component in the app.
- `use Cognit` imports two layers: primitives (`Cognit.Button`, `Cognit.Table`, …) and composites (`Cognit.Components.Page`, `.Pagination`, `.FormField`, …). Prefer a composite when one exists.
- Attrs and slots are defined in `lib/cognit/**`; examples live in `storybook/storybook/`. Check them before guessing an attr.
- `class` is merged via `classes/1`; pass overrides through `class` instead of forking the component.
- `<.pagination>`: without `on_change` it patches `?page=&page_size=` into the URL (needs `id`; handle in `handle_params/3`); with `on_change` it pushes an event.
- Setup and upgrading: `README.md`. Tokens and rebranding: `guides/theming.md`. Moving off another library: `guides/migrating.md`.
