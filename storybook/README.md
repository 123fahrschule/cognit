# Cognit Storybook

Phoenix Storybook app for developing and reviewing Cognit components. It depends on the library through a path dependency on the parent directory and hot-reloads it (`reloadable_apps: [:cognit]`), so edits under `lib/` and `assets/` show up without a restart. Adding a new story file does need a restart.

```bash
mix setup        # deps + assets
mix phx.server   # http://localhost:4000, or PORT=5001 mix phx.server
```

Routes are mounted at the root, no `/storybook` prefix: `/components/button`, `/examples/app_shell`. Every `:example` story also renders bare at `/visual_tests/<path>` for screenshots.

## Layout

| Folder                       | Purpose                                                                  |
| ---------------------------- | ------------------------------------------------------------------------ |
| `storybook/examples/`        | Composed flows (app shell, login page, CRUD, booking) as `:example` LiveViews |
| `storybook/components/`      | One story per component, mostly `:component` with variation groups         |
| `storybook/foundation/`      | Colors, typography, shadows and radii straight from `theme.css`           |
| `storybook/bug_reproductions/` | Minimal repros that stay in the tree until the bug is fixed              |

Story conventions:

- `:component` stories declare `function: &Cognit.X.x/1` and list variations. A form-bound variation gets its field via a `<.form :let={f}>` template and `field={f[:name]}`, not through `attributes:`.
- `:example` stories are LiveViews (`mount/3`, `handle_event/3`) for anything that needs server round trips.
- `:page` stories are static HEEx and cannot declare `attr`.
- A `template:` cannot be set per variation inside a `VariationGroup`; pull such a variation out on its own.
- Folder order comes from `_*.index.exs`; a missing `folder_index` sorts last.

Icons are Material Symbols; browse names at <https://fonts.google.com/icons>.
