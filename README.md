# Cognit

Phoenix LiveView UI component library providing 40+ accessible, interactive components built with function components, JavaScript state machines, and LiveView hooks.

Fork of [SaladUI](https://github.com/bluzky/salad_ui).

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
- Phoenix LiveView ~> 1.0
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

```elixir
# config/config.exs
config :cognit, :error_translator_function, {MyAppWeb.ErrorHelpers, :translate_error}
```

```elixir
# config/test.exs
config :cognit, :default_locale, "en"
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

---

## Usage

See the [Storybook](storybook/) for component examples and documentation.
