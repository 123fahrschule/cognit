defmodule Cognit.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [TwMerge.Cache]
    Supervisor.start_link(children, strategy: :one_for_one, name: Cognit.Supervisor)
  end
end
