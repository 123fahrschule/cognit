# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cognit_storybook,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :cognit_storybook, CognitStorybookWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CognitStorybookWeb.ErrorHTML, json: CognitStorybookWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CognitStorybook.PubSub,
  live_view: [signing_salt: "Bs3Z6D2d"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.8",
  storybook: [
    args:
      ~w(js/storybook.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/images/* --loader:.woff2=file),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" =>
        Enum.join([Path.expand("../deps", __DIR__), Path.expand("../..", __DIR__)], ":")
    }
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.17",
  storybook: [
    args: ~w(
      --input=css/storybook.css
      --output=../priv/static/assets/storybook_tailwind.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
