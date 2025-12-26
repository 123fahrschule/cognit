defmodule Cognit.SidebarHook do
  import Phoenix.Component

  def on_mount(_default, _params, %{"sidebar_state" => state}, socket) do
    {:cont, assign(socket, :sidebar_state, state)}
  end

  def on_mount(_default, _params, _session, socket) do
    {:cont, assign(socket, :sidebar_state, "expanded")}
  end
end
