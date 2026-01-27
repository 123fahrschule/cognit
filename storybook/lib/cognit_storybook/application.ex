defmodule CognitStorybook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: CognitStorybook.PubSub},
      # Start a worker by calling: CognitStorybook.Worker.start_link(arg)
      # {CognitStorybook.Worker, arg},
      # Start to serve requests, typically the last entry
      CognitStorybookWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CognitStorybook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CognitStorybookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
