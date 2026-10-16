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
    // your app's existing globs, then:
    "../deps/cognit/**/*.*ex",
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

The locale plug and hook put the current locale into the session and LiveView assigns. The sidebar plug and hook carry the collapsed/expanded state across reloads.

### 7. Configuration

All keys are optional.

```elixir
# config/config.exs
config :cognit,
  default_locale: "en",
  locales: ["de", "en", "fr"]

# config/test.exs
config :cognit, :default_locale, "en"
```

Both keys are read at **compile time**, so they belong in `config/config.exs` or a file it imports, never in `runtime.exs`, and a change needs `mix deps.compile cognit --force`. Pinning the locale in `test.exs` keeps assertions on rendered text independent of the app default.

Defaults and accepted values are documented in `Cognit.LocalePlug`; the changeset error translator hooks in `Cognit.Helpers.translate_error/1`.

### Umbrella projects

Deps live at the umbrella root, so every relative `deps/cognit/...` path in steps 2 and 3 needs one more `../` segment when written from `apps/my_app_web/assets/`.

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
