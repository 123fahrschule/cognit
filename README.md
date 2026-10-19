# Cognit

Phoenix LiveView UI component library: 40+ accessible, interactive components built with function components, client-side state machines, LiveView hooks, Tailwind CSS and Gettext.

Fork of [SaladUI](https://github.com/bluzky/salad_ui). See [CHANGELOG.md](CHANGELOG.md) for release notes and [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Requirements

- Elixir ~> 1.18
- Phoenix ~> 1.7
- Phoenix LiveView ~> 1.1
- Tailwind CSS 3.4+

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

Use the newest version listed at the top of [CHANGELOG.md](CHANGELOG.md), then run `mix deps.get`. Moving up several releases at once: see [Upgrading](#upgrading).

### 2. CSS and fonts

```css
/* assets/css/app.css */
@import "../../deps/cognit/assets/css/styles.css";

@tailwind base;
@tailwind components;
@tailwind utilities;
```

`styles.css` holds the component styles, theme tokens and typography. The Open Sans and Material Symbols fonts stay in the dependency: `Cognit.Static` serves them and `Cognit.Assets.head` links them from the root layout.

```elixir
# lib/my_app_web/endpoint.ex
plug Plug.Static, at: "/", from: :my_app, gzip: false, only: MyAppWeb.static_paths()
plug Cognit.Static
```

```heex
<%!-- lib/my_app_web/components/layouts/root.html.heex --%>
<head>
  <Cognit.Assets.head />
  <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
</head>
```

Every URL it produces carries a content hash, so browsers and CDNs cache the files for a year and pick up an update on the next release. A layout that renders no Cognit components can load Open Sans alone with `<Cognit.Assets.head fonts={[:open_sans]} />`.

### 3. Tailwind

```javascript
// assets/tailwind.config.js
module.exports = {
  presets: [require("../deps/cognit/assets/tailwind_preset.js")],
  content: [
    // your app's existing globs, then:
    "../deps/cognit/lib/**/*.*ex",
    "../deps/cognit/assets/js/**/*.*js",
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

The bare `"cognit"` specifier resolves through `deps/cognit/package.json` because the esbuild config Phoenix generates sets `NODE_PATH` to the deps directory. If your esbuild args drop that `env`, add a `"cognit": "file:../deps/cognit"` entry to `assets/package.json` instead. Import through the index rather than by file path; deep imports miss hooks added in later releases.

### 5. Import components

`use Cognit` imports every component. The catalogue is in the `Cognit` module doc (`h Cognit` in IEx) and in the [storybook](storybook/).

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

`use Cognit, :component` is for authoring your own components in the same style: it brings in `Phoenix.Component`, the Cognit Gettext backend, `Cognit.Helpers` and a `classes/1` helper that merges Tailwind classes, without importing the components.

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

`Cognit.LocalePlug` resolves the locale from the `locale` query param or the `app_locale` cookie and sets `@locale` on the conn and in the session. `Cognit.SidebarPlug` reads the `sidebar_state` cookie and sets `@sidebar_state` (`"expanded"` or `"collapsed"`) the same way. The two hooks set the same assigns on the socket, from connect params first and the session second.

Both plugs are needed even in an all-LiveView app: a layout that reads `@sidebar_state` or `@locale` raises `KeyError` the first time a controller renders it without them.

The hooks can also live in your `live_view/0` helper instead of `live_session`, which covers every LiveView without listing it in the router:

```elixir
# lib/my_app_web.ex
def live_view do
  quote do
    use Phoenix.LiveView
    on_mount Cognit.LocaleHook
    on_mount Cognit.SidebarHook
    # ...
  end
end
```

`Cognit.Toast.send_toast/3` renders nothing until a `<.toaster />` is in the layout; step 8 places it.

### 7. Configuration

All keys are optional.

```elixir
# config/config.exs
config :cognit,
  default_locale: "en",
  locales: ["de", "en", "fr"],
  error_translator_function: {MyAppWeb.CoreComponents, :translate_error}

# config/test.exs
config :cognit, :default_locale, "en"
```

| Key                             | Read at      | Default        | Purpose                                                                   |
| ------------------------------- | ------------ | -------------- | ------------------------------------------------------------------------- |
| `default_locale`                | compile time | `"de"`         | Locale when neither query param nor cookie sets one                       |
| `locales`                       | compile time | `["de", "en"]` | Accepted locales; also the list `locale_select` offers                    |
| `static_at`                     | compile time | `"/assets"`    | URL prefix `Cognit.Static` serves the fonts under (`<prefix>/fonts/…`)   |
| `error_translator_function`     | runtime      | none           | `{module, function}` taking `{msg, opts}` for changeset errors            |
| `use_default_error_translator`  | runtime      | `true`         | Try Cognit's bundled `errors` translations (EN, DE) before your function |

The compile-time keys belong in `config/config.exs` or a file it imports, never in `runtime.exs`, and a change needs `mix deps.compile cognit --force`. Pinning the locale in `test.exs` keeps assertions on rendered text independent of the app default; without it tests render in German.

Form errors resolve in this order: the bundled `errors` domain (when `use_default_error_translator` is on), then `error_translator_function`, then the raw message with `%{key}` interpolated. See `Cognit.Helpers.translate_error/1`.

### Umbrella projects

Deps live at the umbrella root, so every relative `deps/cognit/...` path in steps 2 and 3 needs one more `../` segment when written from `apps/my_app_web/assets/`. The `file:` entry from step 4 becomes `"cognit": "file:../../../deps/cognit"`. `Cognit.Static` finds the fonts by app name and needs no extra segment; add it to every endpoint whose layouts render `Cognit.Assets.head`.

### Using Cognit from a library

A library that renders Cognit components inside a host app should not ship the preset, the CSS or its own JS bundle; the host's step 2 to 4 cover them. Declare the dep `optional: true` so the host's pin wins instead of forcing `override: true` onto hosts on a newer tag:

```elixir
{:cognit, github: "123fahrschule/cognit", tag: "X.Y.Z", optional: true}
```

On the host side, add the library's templates to the Tailwind content globs (`"../deps/my_lib/lib/**/*.*ex"`) and import Cognit JS through the index so hooks the library relies on arrive with the host's upgrade.

### Upgrading

Each release with a *Compatibility* section in [CHANGELOG.md](CHANGELOG.md) needs a manual edit. Coming from an older tag, check every one between it and the target:

- **0.2.14**: LiveView hook names gained the `Cognit.` prefix (`Cognit.Sidebar`, `Cognit.Pagination`, …) and built-in component ids the `cognit-` prefix (`cognit-sidebar`, `cognit-locale-select`, …). Update JS and tests that reference them.
- **0.12.0**: Color tokens re-synced and `shadow-*` classes now resolve to the design system's shadows, so your own markup using them changes appearance.
- **0.13.0**: Broad visual refresh of form controls, dialogs, sheets, tabs, tables and menus. `alert_dialog` lost its built-in close button; `rounded-sm`/`rounded-md` shrank by 2px.
- **0.16.0**: `toaster` lost the `position` attribute; toasts always render top center.
- **0.20.0**: Open Sans files renamed to `open-sans-*.woff2`; Material Symbols weight, grade and optical size are fixed, so `wght`/`GRAD`/`opsz` overrides no longer apply.

## Scaffolding an app

### 8. App shell

Most apps want the same layout: a sidebar on the left, a topbar across the top, and a page area below. Compose it once in your `Layouts` module:

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

    {@inner_content}
  </.sidebar_inset>
</.sidebar_provider>

<.flash_group flash={@flash} />
<.toaster />
```

`sidebar_provider` owns the open/collapsed state and must wrap both the sidebar and the inset. `topbar` is sticky and lays its children out as a flex row. `flash_group` and `toaster` stay outside `sidebar_provider`; inside it they inherit the sidebar layout and can be hidden when it collapses. The full reference is [`storybook/storybook/examples/app_shell.story.exs`](storybook/storybook/examples/app_shell.story.exs); each part is documented in its module (`Cognit.Sidebar`, `Cognit.Components.AppSideNav`, `Cognit.Components.UserSideNav`, `Cognit.Components.Topbar`, `Cognit.Components.Page`).

### 9. First page

A LiveView inside that shell renders a `page` with a header and content, binds a form through `form_field`, and reports the result with a toast:

```elixir
defmodule MyAppWeb.ProfileLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"name" => ""}, as: :profile))}
  end

  def handle_event("save", %{"profile" => params}, socket) do
    {:noreply,
     socket
     |> assign(form: to_form(params, as: :profile))
     |> Cognit.Toast.send_toast(:success, title: gettext("Profile saved"))}
  end

  def render(assigns) do
    ~H"""
    <.page>
      <.page_header title={gettext("Profile")}>
        <:actions>
          <.button form="profile-form" type="submit">{gettext("Save")}</.button>
        </:actions>
      </.page_header>

      <.page_content>
        <.form for={@form} id="profile-form" phx-submit="save">
          <.form_field field={@form[:name]} label={gettext("Name")} />
        </.form>
      </.page_content>
    </.page>
    """
  end
end
```

A complete CRUD page with filters, a table, pagination and an edit sheet is in [`storybook/storybook/examples/employee_crud.story.exs`](storybook/storybook/examples/employee_crud.story.exs).

### 10. Brand it

Colors are HSL triplets in CSS custom properties. Override them after importing `styles.css`, once for light and once for dark:

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

Dark mode is class-based: add `class="dark"` to `<html>` to switch. Token families and how to add your own are in [guides/theming.md](guides/theming.md).

## Further reading

- `Cognit` module doc: component catalogue by category
- `Cognit.LiveView` and `Cognit.JS`: driving dialogs, sheets and menus from the server or the client
- [guides/theming.md](guides/theming.md): token families, radius and shadow scales, custom tokens
- [guides/migrating.md](guides/migrating.md): adopting Cognit next to another Tailwind component library
- [storybook/](storybook/): every component with its variations, foundation tokens and composed examples such as the app shell and a CRUD page; its README says how to run it
- [CONTRIBUTING.md](CONTRIBUTING.md): workflow, authoring a component, updating bundled icons and fonts
