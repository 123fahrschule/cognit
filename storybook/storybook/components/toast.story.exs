defmodule Storybook.Examples.Toast do
  @moduledoc """
  Example story for the Sonner-style toast component.

  Toasts are pushed from the server via `Cognit.Toast.send_toast/3` and
  rendered client-side by the `Cognit.Toaster` hook, so a live example
  (rather than a plain component story) is required to demo them.
  """
  use PhoenixStorybook.Story, :example

  import Cognit.Toast
  import Cognit.Button

  alias Cognit.Toast
  alias Phoenix.LiveView.JS

  def doc, do: "Sonner-style toasts pushed from the server with send_toast/3."

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 p-8">
      <h2 class="text-lg font-semibold">Toast</h2>
      <p class="text-sm text-muted-foreground">
        Click a button to push a toast from the server. Hover a toast to pause
        its auto-dismiss timer. Click a toast to dismiss it.
      </p>

      <div class="flex flex-wrap gap-2">
        <.button phx-click="toast-default">Default</.button>
        <.button variant="success" phx-click="toast-success">Success</.button>
        <.button variant="destructive" phx-click="toast-error">Error</.button>
        <.button variant="warning" phx-click="toast-warning">Warning</.button>
        <.button variant="outline" phx-click="toast-action">With action</.button>
        <.button variant="ghost" phx-click="toast-sticky">Sticky (no auto-dismiss)</.button>
      </div>

      <.toaster />
    </div>
    """
  end

  @impl true
  def handle_event("toast-default", _params, socket) do
    {:noreply, Toast.send_toast(socket, :default, title: "Event has been created")}
  end

  def handle_event("toast-success", _params, socket) do
    {:noreply,
     Toast.send_toast(socket, :success,
       title: "Course created",
       description: "Express course is now available."
     )}
  end

  def handle_event("toast-error", _params, socket) do
    {:noreply,
     Toast.send_toast(socket, :error,
       title: "Something went wrong",
       description: "The course could not be saved."
     )}
  end

  def handle_event("toast-warning", _params, socket) do
    {:noreply,
     Toast.send_toast(socket, :warning,
       title: "Heads up",
       description: "This configuration is close to the daily driving limit."
     )}
  end

  def handle_event("toast-action", _params, socket) do
    {:noreply,
     Toast.send_toast(socket, :info,
       title: "Update available",
       description: "A new version of the schedule was published.",
       action: %{label: "Undo", command: JS.push("toast-undo")}
     )}
  end

  def handle_event("toast-sticky", _params, socket) do
    {:noreply,
     Toast.send_toast(socket, :default,
       title: "I stay until clicked",
       duration: 0
     )}
  end

  def handle_event("toast-undo", _params, socket) do
    {:noreply, Toast.send_toast(socket, :success, title: "Action undone")}
  end
end
