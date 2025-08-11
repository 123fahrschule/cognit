defmodule CognitStorybookWeb.Router do
  use CognitStorybookWeb, :router

  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CognitStorybookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", CognitStorybookWeb do
    pipe_through :browser

    live_storybook("/", backend_module: CognitStorybookWeb.Storybook)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CognitStorybookWeb do
  #   pipe_through :api
  # end
end
