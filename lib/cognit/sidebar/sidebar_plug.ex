defmodule Cognit.SidebarPlug do
  import Plug.Conn

  @default_state "expanded"
  @valid_states ["expanded", "collapsed"]

  def init(options), do: options

  def call(%Plug.Conn{cookies: %{"sidebar_state" => state}} = conn, options) do
    set_sidebar_state(conn, normalize_state(state, options))
  end

  def call(conn, options) do
    set_sidebar_state(conn, Keyword.get(options, :default_state, @default_state))
  end

  defp normalize_state(state, options) do
    if state in Keyword.get(options, :valid_states, @valid_states),
      do: state,
      else: Keyword.get(options, :default_state, @default_state)
  end

  defp set_sidebar_state(conn, state) do
    put_session(conn, :sidebar_state, state)
  end
end
