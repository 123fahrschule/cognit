# Cognit

Phoenix LiveView UI component library providing 40+ accessible, interactive components built with function components, JavaScript state machines, and LiveView hooks.

Fork of [SaladUI](https://github.com/bluzky/salad_ui). See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Features

- 40+ accessible, interactive components
- Phoenix function components with HEEx templates
- Client-side state machines for interactivity
- Tailwind CSS styling with TwMerge
- Internationalization with Gettext
- Material Symbols icons ([browse icons](https://fonts.google.com/icons))

## Requirements

- Elixir ~> 1.18
- Phoenix ~> 1.7
- Phoenix LiveView ~> 1.1
- Tailwind CSS 3.4+

---

## Installation

### 1. Add Dependency

```elixir
# mix.exs
defp deps do
  [
    {:cognit, github: "123fahrschule/cognit", tag: "0.1.0"}
  ]
end
```

```bash
mix deps.get
```

### 2. Configuration

Cognit ships with English and German translations for common Ecto changeset
errors out of the box — `form_message` will translate field errors automatically
via `Cognit.Gettext` with no extra configuration.

```elixir
# config/test.exs
config :cognit, :default_locale, "en"
```

Optional — provide a custom translator to handle msgids not covered by the
bundled translations (used as a fallback):

```elixir
# config/config.exs
config :cognit, :error_translator_function, {MyAppWeb.CoreComponents, :translate_error}
```

To opt out of the bundled translations entirely and rely only on your own
translator:

```elixir
config :cognit, :use_default_error_translator, false
```

For fonts, add to esbuild args: `--loader:.woff2=file`

### 3. JavaScript

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

### 4. CSS

```css
/* assets/css/app.css */
@import "../../deps/cognit/assets/css/styles.css";

@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 5. Tailwind

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

### 6. Import Components

`use Cognit` imports all components:

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    # ...
    use Cognit
  end
end
```

For custom components that need only specific imports:

```elixir
import Cognit.Button
import Cognit.Dialog
```

### 7. Router

```elixir
# lib/my_app_web/router.ex

# Add plugs to browser pipeline
pipeline :browser do
  # ...
  plug Cognit.LocalePlug
  plug Cognit.SidebarPlug
end

# Add hooks to live_session
live_session :default,
  on_mount: [
    Cognit.LocaleHook,
    Cognit.SidebarHook
  ] do
  live "/", HomeLive
end
```

### Umbrella Projects

In an umbrella, deps live at the umbrella root, so the relative paths in steps
4 and 5 need an extra `../` segment. From `apps/my_app_web/assets/`:

```css
/* assets/css/app.css */
@import "../../../../deps/cognit/assets/css/styles.css";
```

```javascript
// assets/tailwind.config.js
module.exports = {
  presets: [require("../../../deps/cognit/assets/tailwind_preset.js")],
  content: [
    "../../../deps/cognit/**/*.*ex",
    "../../../deps/cognit/assets/js/**/*.*js",
    ...
  ],
};
```

---

## Building an app shell

Most apps want the same layout: a sidebar on the left, a topbar across the
top, and a page area below. Cognit ships the composed shell components for
this in `Cognit.Components.*` (`app_side_nav`, `user_side_nav`, `topbar`,
`page`, `login_layout`, etc.) — all imported by `use Cognit`, so they're
available anywhere you compose the shell (typically your `Layouts` module).

A complete shell looks like this:

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

The canonical reference is
[`storybook/storybook/examples/app_shell.story.exs`](storybook/storybook/examples/app_shell.story.exs).

### Component roles

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

### Sidebar state persistence

Sidebar collapsed/expanded state survives reloads automatically: the JS hook
writes a `sidebar_state` cookie on toggle, `Cognit.SidebarPlug` reads it and
puts it in session, `Cognit.SidebarHook` propagates it into LiveView assigns.
No host-app wiring is required beyond installing the plug and hook (step 7
above).

### Pinning a sidebar group to the bottom

There is no dedicated "footer-adjacent" slot. Use `class="mt-auto"` on a
sidebar group to push it to the bottom of `<.sidebar_content>`:

```heex
<.sidebar_group class="mt-auto">
  <.sidebar_group_label>Dev Tools</.sidebar_group_label>
  ...
</.sidebar_group>
```

### Sidebar menu buttons: links vs actions

`<.sidebar_menu_button>` forwards `navigate`, `patch`, `href`, plus standard
HTML link attrs (`target`, `rel`, etc.). External links work as expected:

```heex
<.sidebar_menu_button href="https://example.com" target="_blank" rel="noopener noreferrer">
  External
</.sidebar_menu_button>
```

For buttons that trigger JS state instead of navigating, set `as="button"`.

### Dropdown menu items: links vs actions

`<.dropdown_menu_item>` is a non-navigating row — use it with `on-select` for
an action (logout, open dialog, etc.):

```heex
<.dropdown_menu_item on-select={JS.push("sign_out")}>Sign out</.dropdown_menu_item>
```

`<.dropdown_menu_link_item>` renders an actual link — use it for navigation:

```heex
<.dropdown_menu_link_item navigate={~p"/profile"}>Profile</.dropdown_menu_link_item>
```

A `<.dropdown_menu_item>` with no `on-select` is a static row that does
nothing on click.

### Icons

`<.icon name="...">` renders [Material Symbols](https://fonts.google.com/icons).
Use the snake_case form of the icon name (e.g. `dashboard`, `account_circle`,
`keyboard_arrow_down`).

---

## Programmatic control

Interactive components (`dialog`, `sheet`, `dropdown_menu`, `popover`,
`tooltip`, `sidebar`, etc.) are JavaScript state machines. Each component
listens for `salad_ui:command` events keyed by its `id`, so you can drive
state transitions from either the server or the client.

### From the server: `Cognit.LiveView.send_command/4`

Use this inside a LiveView `handle_event/3` when the command depends on
server-side state — e.g. close a sheet after a successful form save.

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

Signature: `send_command(socket, component_id, command, params \\ %{})`.
`command` is any state-machine transition the component supports — typically
`"open"`, `"close"`, `"toggle"` for overlays.

### From the client: `Cognit.JS.dispatch_command/3`

Use this for pure UI interactions that don't need a server round-trip — e.g.
a button that opens a dialog.

```heex
<.button phx-click={Cognit.JS.dispatch_command("open", to: "#confirm-dialog")}>
  Delete
</.button>
```

`dispatch_command/3` returns a `Phoenix.LiveView.JS` struct, so you can chain
it with other JS commands:

```heex
<.button phx-click={
  %JS{}
  |> JS.push("track_click")
  |> Cognit.JS.dispatch_command("open", to: "#confirm-dialog")
}>
  Delete
</.button>
```

**Rule of thumb:** server-side `send_command/4` when the action follows data
(form save → close sheet); client-side `dispatch_command/3` when it's pure UI
(button → open dialog).

---

## Configuration notes

### `:default_locale` placement

`Cognit.LocalePlug` reads `:default_locale` at **compile time**, so the
placement of the config call matters:

- If your app's primary language is German, leave `:default_locale` unset in
  `config/config.exs` (Cognit defaults to `"de"`) and set it only in
  `config/test.exs` if your tests need a fixed locale.
- If your app's primary language is anything else, set
  `config :cognit, :default_locale, "en"` in `config/config.exs`.

### Custom error translator

If you configure `:error_translator_function`, the function receives a
`{msg, opts}` tuple — the same shape Phoenix changeset errors use — and must
return a translated string:

```elixir
def translate_error({msg, opts}) do
  Gettext.dgettext(MyApp.Gettext, "errors", msg, opts)
end
```

This is only consulted as a fallback when Cognit's bundled translations
don't cover the msgid. Set
`config :cognit, :use_default_error_translator, false` to bypass the bundled
translations entirely.

---

## Parallel adoption

Adopting Cognit into an app that already uses shadcn/ui, SaladUI,
PhoenixUiComponents, or another Tailwind-based system risks clashes —
duplicate `@tailwind base` rules, conflicting CSS variables, conflicting
preset configs.

The safe pattern is a **parallel asset pipeline**:

1. **Separate CSS entrypoint** — e.g. `assets/css/cognit.css` that imports
   `deps/cognit/assets/css/styles.css` and emits Cognit's Tailwind layers.
2. **Separate Tailwind config** — `assets/tailwind.cognit.config.js`
   extending Cognit's preset, scoped to Cognit-using templates only.
3. **Separate esbuild profile** — emit `priv/static/assets/cognit.css` and
   `cognit.js` alongside your existing `app.*` bundle.
4. **Separate root layout** — Cognit-rendered LiveViews use a layout that
   includes only the Cognit bundle; legacy pages keep their existing layout.

Migrate routes from the legacy layout to the Cognit layout one at a time.
Once the last legacy page is gone, collapse the two pipelines back into one.

---

## Usage

See the [Storybook](storybook/) for component examples and documentation.
