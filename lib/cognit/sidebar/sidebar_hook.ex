defmodule Cognit.SidebarHook do
  @moduledoc """
  LiveView hook that restores sidebar state from connect_params or session.

  Priority:
  1. connect_params (for live navigation)
  2. session (for initial SSR)
  3. "expanded" (default)
  """

  import Phoenix.Component
  import Phoenix.LiveView

  @valid_states ["expanded", "collapsed"]
  @default_state "expanded"

  def on_mount(_default, _params, session, socket) do
    sidebar_state =
      get_connect_params(socket)
      |> get_sidebar_state()
      |> case do
        nil -> get_sidebar_state(session)
        state -> state
      end
      |> Kernel.||(@default_state)

    {:cont, assign(socket, :sidebar_state, sidebar_state)}
  end

  defp get_sidebar_state(%{"sidebar_state" => state}) when state in @valid_states, do: state
  defp get_sidebar_state(_), do: nil
end
