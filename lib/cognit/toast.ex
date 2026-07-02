defmodule Cognit.Toast do
  @moduledoc """
  Sonner-style toast notifications.

  Toasts are rendered client-side by the `Cognit.Toaster` hook. Add a single
  `<.toaster />` to your root layout, then push toasts from any LiveView with
  `send_toast/3`.

  ## Examples:

      # root layout (outside .sidebar_provider, like flash_group)
      <.toaster />

      # any LiveView
      socket
      |> Cognit.Toast.send_toast(:success,
        title: gettext("Course created"),
        description: gettext("Express course is now available.")
      )

      # with an action button that pushes an event back to the LiveView
      Cognit.Toast.send_toast(socket, :info,
        title: "Update available",
        action: %{label: "Refresh", event: "refresh-page"}
      )
  """
  use Cognit, :component

  @kinds ~w(default success error warning info)a

  @doc """
  Renders the toast viewport. Add once to your root layout.

  ## Options

  * `:id` - DOM id. Defaults to `"toaster"`.
  * `:position` - Corner to render toasts in. Defaults to `"bottom-right"`.
  * `:duration` - Default auto-dismiss in ms. Defaults to `5000`.
  """
  attr :id, :string, default: "toaster"

  attr :position, :string,
    values: ~w(top-left top-right bottom-left bottom-right),
    default: "bottom-right"

  attr :duration, :integer, default: 5000
  attr :class, :any, default: nil
  attr :rest, :global

  def toaster(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Cognit.Toaster"
      data-position={@position}
      data-duration={@duration}
      class={
        classes([
          "fixed z-[100] flex w-full flex-col gap-2 p-4 sm:max-w-sm pointer-events-none",
          toaster_position(@position),
          @class
        ])
      }
      {@rest}
    >
    </div>
    """
  end

  @doc """
  Push a toast to the client from a LiveView.

  ## Parameters

  - `socket` - The LiveView socket.
  - `kind` - One of `:default`, `:success`, `:error`, `:warning`, `:info`.
  - `opts`:
    * `:title` - Toast title (required unless `:description` given).
    * `:description` - Secondary line.
    * `:duration` - Override auto-dismiss in ms. `0` disables auto-dismiss.
    * `:action` - `%{label: "...", event: "..."}` — optional `params: %{}`.
      Clicking pushes `event` to the LiveView.
  """
  def send_toast(socket, kind \\ :default, opts) when kind in @kinds do
    Phoenix.LiveView.push_event(socket, "cognit:toast", %{
      kind: kind,
      title: opts[:title],
      description: opts[:description],
      duration: opts[:duration],
      action: opts[:action]
    })
  end

  defp toaster_position("bottom-right"), do: "bottom-0 right-0 items-end"
  defp toaster_position("bottom-left"), do: "bottom-0 left-0 items-start"
  defp toaster_position("top-right"), do: "top-0 right-0 items-end"
  defp toaster_position("top-left"), do: "top-0 left-0 items-start"
end
