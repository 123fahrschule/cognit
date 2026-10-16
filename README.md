# Cognit

Phoenix LiveView UI component library: 40+ accessible, interactive components built with function components, client-side state machines, LiveView hooks, Tailwind CSS and Gettext.

Fork of [SaladUI](https://github.com/bluzky/salad_ui). See [CHANGELOG.md](CHANGELOG.md) for release notes and [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Requirements

- Elixir ~> 1.18
- Phoenix ~> 1.7
- Phoenix LiveView ~> 1.1
- Tailwind CSS 3.4+

---

## Installation

### 1. Dependency

```elixir
# mix.exs
defp deps do
  [
    {:cognit, github: "123fahrschule/cognit", tag: "X.Y.Z"}
  ]
end
```

Use the newest version listed at the top of [CHANGELOG.md](CHANGELOG.md), then run `mix deps.get`.

### 2. CSS

```css
/* assets/css/app.css */
@import "../../deps/cognit/assets/css/styles.css";

@tailwind base;
@tailwind components;
@tailwind utilities;
```

`styles.css` loads the bundled Open Sans and Material Symbols fonts, so esbuild needs a loader for them. Add `--loader:.woff2=file` to the esbuild args in `config/config.exs`.

### 3. Tailwind

```javascript
// assets/tailwind.config.js
module.exports = {
  presets: [require("../deps/cognit/assets/tailwind_preset.js")],
  content: [
    "../deps/cognit/**/*.*ex",
    "../deps/cognit/assets/js/**/*.*js",
    ...
  ],
};
```

### 4. JavaScript

```javascript
// assets/js/app.js
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import Cognit from "cognit";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  params: () => ({
    ...Cognit.getCognitParams(),
    _csrf_token: csrfToken,
  }),
  hooks: {
    ...Cognit.Hooks,
  },
});

liveSocket.connect();
window.liveSocket = liveSocket;
```

### 5. Import components

`use Cognit` imports every component listed under [Components](#components):

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    # ...
    use Cognit
  end
end
```

A module that needs only a few can import them directly:

```elixir
import Cognit.Button
import Cognit.Dialog
```

### 6. Router

```elixir
# lib/my_app_web/router.ex

pipeline :browser do
  # ...
  plug Cognit.LocalePlug
  plug Cognit.SidebarPlug
end

live_session :default,
  on_mount: [
    Cognit.LocaleHook,
    Cognit.SidebarHook
  ] do
  live "/", HomeLive
end
```

The locale plug and hook put the current locale into the session and LiveView assigns. The sidebar plug and hook carry the collapsed/expanded state across reloads: the JS hook writes a `sidebar_state` cookie on toggle, the plug reads it into the session, the hook propagates it into assigns.

### 7. Configuration

All keys are optional.

```elixir
# config/config.exs
config :cognit,
  default_locale: "en",
  locales: ["de", "en", "fr"]
```

- `:default_locale` — locale used when the request carries none. Defaults to `"de"`. Read at **compile time** by `Cognit.LocalePlug` and `Cognit.LocaleHook`, so it belongs in `config/config.exs` or an env file it imports, never in `runtime.exs`, and a change needs `mix deps.compile cognit --force`.
- `:locales` — locales the plug and `locale_select` accept. Defaults to `["de", "en"]`. Compile time as well.

Pin the locale for tests so assertions on rendered text do not depend on the default. A German app leaves `:default_locale` unset elsewhere and sets only this:

```elixir
# config/test.exs
config :cognit, :default_locale, "en"
```

Cognit ships English and German translations for the common Ecto changeset errors, so `form_message` translates field errors with no extra setup. Two keys control what happens for a message it does not know:

```elixir
config :cognit, :error_translator_function, {MyAppWeb.CoreComponents, :translate_error}
config :cognit, :use_default_error_translator, false
```

- `:error_translator_function` — `{module, function}` called with the `{msg, opts}` tuple Phoenix changeset errors use; must return a string. Consulted only when the bundled translations have no match.
- `:use_default_error_translator` — set to `false` to skip the bundled translations and use only your translator.

```elixir
def translate_error({msg, opts}) do
  Gettext.dgettext(MyApp.Gettext, "errors", msg, opts)
end
```

### Umbrella projects

Deps live at the umbrella root, so every relative `deps/cognit/...` path in steps 2 and 3 needs one more `../` segment when written from `apps/my_app_web/assets/`.

---

## Components

Everything below is imported by `use Cognit`. Each has a story under `storybook/storybook/components/`; attributes and slots are documented in the module.

### Forms and input

| Component | Module | Purpose |
| --- | --- | --- |
| `button`, `button_group` | `Cognit.Button`, `Cognit.ButtonGroup` | Actions in several variants and sizes. The group joins buttons into one segmented control |
| `input`, `textarea`, `label` | `Cognit.Input`, `Cognit.Textarea`, `Cognit.Label` | Text entry bound to a form `field` or plain `name`/`value` |
| `checkbox`, `switch`, `radio_group`, `slider` | `Cognit.Checkbox`, `Cognit.Switch`, `Cognit.RadioGroup`, `Cognit.Slider` | Boolean and range controls |
| `select`, `combobox` | `Cognit.Select`, `Cognit.Combobox` | Dropdown choice; combobox adds search, multiple selection and server-side filtering |
| `calendar`, `date_picker`, `time_picker` | `Cognit.Calendar`, `Cognit.DatePicker`, `Cognit.TimePicker` | Date, date range and 24-hour time entry |
| `toggle`, `toggle_group` | `Cognit.Toggle`, `Cognit.ToggleGroup` | Pressed-state buttons, single or multiple |
| `form`, `form_item`, `form_label`, `form_control`, `form_message` | `Cognit.Form` | Low-level form structure and error display |
| `form_field` | `Cognit.Components.FormField` | One-liner wrapper: label, control of any `type`, description and errors |

### Overlays

| Component | Module | Purpose |
| --- | --- | --- |
| `dialog`, `alert_dialog`, `confirmation_dialog` | `Cognit.Dialog`, `Cognit.AlertDialog`, `Cognit.ConfirmationDialog` | Modal dialogs; the confirmation variant is a ready-made yes/no with destructive styling |
| `sheet` | `Cognit.Sheet` | Panel sliding in from a screen edge |
| `popover`, `hover_card`, `tooltip` | `Cognit.Popover`, `Cognit.HoverCard`, `Cognit.Tooltip` | Anchored floating content on click, hover with delay, and hover |
| `dropdown_menu`, `menu` | `Cognit.DropdownMenu`, `Cognit.Menu` | Action menus with items, link items, separators and shortcuts |
| `command`, `command_dialog` | `Cognit.Command` | Command palette with filtering |
| `toaster`, `send_toast/3` | `Cognit.Toast` | Toast notifications pushed from any LiveView |

### Navigation and layout

| Component | Module | Purpose |
| --- | --- | --- |
| `sidebar_*` | `Cognit.Sidebar` | Collapsible app sidebar with groups, menus, sub-menus, rail and inset |
| `app_side_nav`, `user_side_nav` | `Cognit.Components.AppSideNav`, `Cognit.Components.UserSideNav` | Branding entry at the top and signed-in user entry at the bottom of the sidebar |
| `topbar`, `page`, `page_header`, `page_content`, `page_footer` | `Cognit.Components.Topbar`, `Cognit.Components.Page` | Content column structure inside the sidebar inset |
| `login_layout`, `logo` | `Cognit.Components.LoginLayout`, `Cognit.Components.Logo` | Centered auth page frame and the brand mark |
| `tabs`, `breadcrumb`, `stepper` | `Cognit.Tabs`, `Cognit.Breadcrumb`, `Cognit.Stepper` | Tabbed content, location trail, multi-step progress |
| `pagination` with `Cognit.PaginationParams` | `Cognit.Components.Pagination` | Page controls driven by a normalized params struct (Scrivener pages, maps or keyword lists) |
| `locale_select`, `user_menu` | `Cognit.Components.LocaleSelect`, `Cognit.Components.UserMenu` | Topbar widgets for switching locale and showing the current user |
| `accordion`, `collapsible`, `scroll_area`, `separator` | `Cognit.Accordion`, `Cognit.Collapsible`, `Cognit.ScrollArea`, `Cognit.Separator` | Expand and collapse, custom scrollbars, dividers |

### Data display and feedback

| Component | Module | Purpose |
| --- | --- | --- |
| `table`, `table_container`, `table_empty` | `Cognit.Table`, `Cognit.Components.Table` | Data tables with a scroll container and an empty-row placeholder |
| `card`, `item`, `item_group`, `list` | `Cognit.Card`, `Cognit.Item`, `Cognit.CoreComponents` | Content containers, media-title-actions rows, title/value lists |
| `avatar`, `badge`, `icon`, `copy_button` | `Cognit.Avatar`, `Cognit.Badge`, `Cognit.Icon`, `Cognit.Components.CopyButton` | Profile images with fallback, status labels, Material Symbols, copy-to-clipboard |
| `alert`, `flash`, `flash_group`, `empty_state`, `progress`, `skeleton` | `Cognit.Alert`, `Cognit.Components.Flash`, `Cognit.EmptyState`, `Cognit.Progress`, `Cognit.Skeleton` | Status messages, LiveView flash, no-data placeholder, progress bars, loading placeholders |
| `chart` | `Cognit.Chart` | Chart.js wrapper fed by data and config attrs |

---

## Theming

Colors are HSL triplets in CSS custom properties, declared in `assets/css/theme.css` for `:root` and overridden under `.dark`. The Tailwind preset registers each pair as a color (`bg-primary`, `text-primary-foreground`, `bg-destructive-soft`, and so on) through `assets/tailwind.colors.json`, so components never hard-code hex values.

Token families:

- **Surface and text**: `background`, `foreground`, `card`, `popover`, `muted`, `accent`, `border`, `input`, `ring`
- **Semantic**: `primary`, `secondary`, `destructive`, `success`, `warning`, `info`, each with a `-foreground` and a tinted `-soft` / `-soft-foreground` pair for badges and alerts
- **Shape and depth**: the whole `rounded-xs` … `rounded-xl` scale is derived from `--radius` with fixed offsets, so changing that one variable moves every corner in step; `--shadow-2xs` through `--shadow-2xl` replace Tailwind's stock `shadow-*` scale
- **Type**: `font-sans` is Open Sans, loaded from `assets/css/open_sans.css`

To rebrand, override the variables after importing `styles.css`, once for light and once for dark:

```css
@import "../../deps/cognit/assets/css/styles.css";

:root {
  --primary: 221 83% 53%;
  --primary-foreground: 0 0% 100%;
  --radius: 0.5rem;
}

.dark {
  --primary: 217 91% 60%;
  --primary-foreground: 222 47% 11%;
}
```

Dark mode is class-based (`darkMode: ["class"]` in the preset). Add `class="dark"` to `<html>` to switch; there is no media-query fallback, so wire the toggle yourself.

Adding a token of your own takes two steps: declare the variable in CSS, then register it under `theme.extend.colors` in your Tailwind config. A variable alone produces no utility class.

---

## Assets

### Icons

`<.icon name="...">` renders [Material Symbols](https://fonts.google.com/icons). Use the snake_case form of the icon name (e.g. `dashboard`, `account_circle`, `keyboard_arrow_down`).

The bundled font carries the full glyph set but only the `FILL` axis; weight, grade and optical size are fixed. To pull the latest upstream release, run `mix icons.update` (needs `curl` and [`uv`](https://docs.astral.sh/uv/)). The installed version is recorded in `assets/fonts/material_symbols/VERSION`.

### Fonts

Open Sans ships as static latin-subset files per weight, built from the upstream variable font. `mix fonts.update` rebuilds them; the version is recorded in `assets/fonts/open_sans/VERSION`.

---

## Building an app shell

Most apps want the same layout: a sidebar on the left, a topbar across the top, and a page area below. The composed shell components (`app_side_nav`, `user_side_nav`, `topbar`, `page`, `login_layout`) are imported by `use Cognit`, so they are available wherever you compose the shell, typically your `Layouts` module.

A complete shell:

```heex
<.sidebar_provider>
  <.sidebar>
    <.sidebar_header>
      <.app_side_nav title="Acme Inc" subtitle="Enterprise">
        <.dropdown_menu_item><.icon name="swap_horiz" /> Switch workspace</.dropdown_menu_item>
        <.dropdown_menu_item><.icon name="settings" /> Settings</.dropdown_menu_item>
      </.app_side_nav>
    </.sidebar_header>

    <.sidebar_content>
      <.sidebar_group>
        <.sidebar_group_label>Main</.sidebar_group_label>
        <.sidebar_group_content>
          <.sidebar_menu>
            <.sidebar_menu_item>
              <.sidebar_menu_button is_active href={~p"/"}>
                <.icon name="dashboard" /> <span>Dashboard</span>
              </.sidebar_menu_button>
            </.sidebar_menu_item>
          </.sidebar_menu>
        </.sidebar_group_content>
      </.sidebar_group>
    </.sidebar_content>

    <.sidebar_footer>
      <.user_side_nav user={@current_user}>
        <.dropdown_menu_item><.icon name="account_circle" /> Profile</.dropdown_menu_item>
        <.dropdown_menu_separator />
        <.dropdown_menu_link_item href={~p"/sign-out"} method="delete">
          <.icon name="logout" /> Sign out
        </.dropdown_menu_link_item>
      </.user_side_nav>
    </.sidebar_footer>
  </.sidebar>

  <.sidebar_inset>
    <.topbar>
      <.breadcrumb class="mr-auto">
        <.breadcrumb_list>
          <.breadcrumb_item><.breadcrumb_page>Home</.breadcrumb_page></.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>
      <.locale_select />
    </.topbar>

    <.page>
      <.page_header title="Dashboard" />
      <.page_content>{@inner_content}</.page_content>
    </.page>
  </.sidebar_inset>
</.sidebar_provider>

<.flash_group flash={@flash} />
```

The canonical reference is [`storybook/storybook/examples/app_shell.story.exs`](storybook/storybook/examples/app_shell.story.exs).

| Component                                        | Purpose                                                                                                                    |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `<.sidebar_provider>`                            | Owns sidebar open/collapsed state. Wraps the sidebar **and** the inset.                                                    |
| `<.sidebar>`                                     | The sidebar itself. Omit `is_desktop` in production — let CSS handle viewport switching.                                   |
| `<.app_side_nav>`                                | Branding entry at the top. Pass `inner_block` for a dropdown, `on_click` for a button, or neither for a static label.      |
| `<.user_side_nav>`                               | Signed-in user entry at the bottom. Pass `user` as a map with `:first_name`, `:last_name`, `:email` (atom or string keys). |
| `<.sidebar_inset>`                               | Content column to the right of the sidebar.                                                                                |
| `<.topbar>`                                      | Sticky bar across the inset. Children are laid out flexbox-style.                                                          |
| `<.page>` / `<.page_header>` / `<.page_content>` | Padded content region inside the inset.                                                                                    |
| `<.flash_group>`                                 | **Must live outside `<.sidebar_provider>`** — otherwise it inherits sidebar layout and can be hidden when collapsed.       |

Sidebar menu buttons, bottom-pinned groups and the difference between menu items and link items are covered in the `Cognit.Sidebar` and `Cognit.DropdownMenu` module docs.

---

## Programmatic control

Interactive components (`dialog`, `sheet`, `dropdown_menu`, `popover`, `tooltip`, `sidebar`, etc.) are JavaScript state machines addressed by their `id`, so you can drive state transitions from either the server or the client.

### From the server: `Cognit.LiveView.send_command/4`

Use this inside a LiveView `handle_event/3` when the command depends on server-side state, e.g. close a sheet after a successful form save.

```elixir
alias Cognit.LiveView, as: CognitLV

def handle_event("save_employee", %{"employee" => params}, socket) do
  case save(params) do
    {:ok, _} ->
      {:noreply,
       socket
       |> put_flash(:info, "Saved")
       |> CognitLV.send_command("employee-sheet", "close")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

Signature: `send_command(socket, component_id, command, params \\ %{})`. `command` is any state-machine transition the component supports, typically `"open"`, `"close"`, `"toggle"` for overlays.

### From the client: `Cognit.JS.dispatch_command/3`

Use this for pure UI interactions that need no server round-trip, e.g. a button that opens a dialog.

```heex
<.button phx-click={Cognit.JS.dispatch_command("open", to: "#confirm-dialog")}>
  Delete
</.button>
```

`dispatch_command/3` returns a `Phoenix.LiveView.JS` struct, so you can chain it with other JS commands:

```heex
<.button phx-click={
  %JS{}
  |> JS.push("track_click")
  |> Cognit.JS.dispatch_command("open", to: "#confirm-dialog")
}>
  Delete
</.button>
```

**Rule of thumb:** server-side `send_command/4` when the action follows data (form save → close sheet); client-side `dispatch_command/3` when it is pure UI (button → open dialog).

---

## Storybook

The [storybook](storybook/) app renders every component with its variations, the foundation tokens, and composed examples such as the app shell and a CRUD page. See its README for how to run it.

---

## Migrating from another component library

Adopting Cognit into an app that already uses shadcn/ui, SaladUI, PhoenixUiComponents, or another Tailwind-based system risks clashes: duplicate `@tailwind base` rules, conflicting CSS variables, conflicting preset configs.

The safe pattern is a **parallel asset pipeline**:

1. **Separate CSS entrypoint**, e.g. `assets/css/cognit.css` that imports `deps/cognit/assets/css/styles.css` and emits Cognit's Tailwind layers.
2. **Separate Tailwind config**, `assets/tailwind.cognit.config.js` extending Cognit's preset, scoped to Cognit-using templates only.
3. **Separate esbuild profile** that emits `priv/static/assets/cognit.css` and `cognit.js` alongside your existing `app.*` bundle.
4. **Separate root layout** so Cognit-rendered LiveViews use a layout that includes only the Cognit bundle; legacy pages keep their existing layout.

Migrate routes from the legacy layout to the Cognit layout one at a time. Once the last legacy page is gone, collapse the two pipelines back into one.
