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

      # with an action button running a JS command (pushes an event, same as
      # any other `phx-click={JS...}` in the app)
      Cognit.Toast.send_toast(socket, :info,
        title: "Update available",
        action: %{label: "Refresh", command: JS.push("refresh-page")}
      )
  """
  use Cognit, :component

  import Cognit.Icon

  @kinds ~w(default success error warning info)a

  @doc """
  Renders the toast viewport. Add once to your root layout.

  ## Options

  * `:id` - DOM id. Defaults to `"toaster"`.
  * `:position` - Corner to render toasts in. Defaults to `"bottom-right"`.
  * `:duration` - Default auto-dismiss in ms. Defaults to `4000`.
  """
  attr :id, :string, default: "toaster"

  attr :position, :string,
    values: ~w(top-left top-right bottom-left bottom-right),
    default: "bottom-right"

  attr :duration, :integer, default: 4000
  attr :class, :any, default: nil
  attr :rest, :global

  def toaster(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Cognit.Toaster"
      phx-update="ignore"
      data-position={@position}
      data-duration={@duration}
      class={
        classes([
          "fixed z-[100] flex w-full flex-col gap-3.5 p-4 sm:max-w-sm sm:p-8 pointer-events-none",
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
    * `:action` - `%{label: "...", command: %Phoenix.LiveView.JS{}}` — clicking
      the button runs `command`, exactly like a `phx-click={JS...}` binding
      anywhere else (push an event, navigate, exec another command, ...).
  """
  def send_toast(socket, kind \\ :default, opts) when kind in @kinds do
    html =
      %{kind: kind, title: opts[:title], description: opts[:description], action: opts[:action]}
      |> toast()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    Phoenix.LiveView.push_event(socket, "cognit:toast", %{
      html: html,
      duration: opts[:duration]
    })
  end

  @doc """
  Renders a single toast card.

  Used internally by `send_toast/3` to build the pushed HTML; also usable
  directly to preview toast styles statically (e.g. in Storybook).
  """
  attr :kind, :atom, default: :default, values: @kinds
  attr :title, :string, default: nil
  attr :description, :string, default: nil

  attr :action, :map,
    default: nil,
    doc: "%{label: \"...\", command: %Phoenix.LiveView.JS{}}"

  def toast(assigns) do
    assigns =
      Map.merge(assigns, %{
        icon: toast_icon(assigns.kind),
        color_class: toast_color(assigns.kind)
      })

    ~H"""
    <div
      class={
        classes([
          "pointer-events-auto flex w-full items-center gap-6 rounded-[18px] border bg-popover p-4",
          "text-popover-foreground shadow-lg transition-all duration-300 ease-out"
        ])
      }
      role="status"
    >
      <div class="flex min-w-0 flex-1 items-center gap-2">
        <.icon :if={@icon} name={@icon} size="xs" class={@color_class} decorative />
        <div class="flex min-w-0 flex-1 flex-col gap-0.5">
          <p :if={@title} class={classes(["text-sm", @color_class])}>{@title}</p>
          <p :if={@description} class="text-sm text-muted-foreground/90">{@description}</p>
        </div>
      </div>
      <button
        :if={@action}
        type="button"
        class="h-7 shrink-0 rounded-sm bg-primary px-2.5 text-xs font-semibold text-primary-foreground hover:bg-primary/90"
        phx-click={@action.command}
      >
        {@action.label}
      </button>
    </div>
    """
  end

  defp toast_icon(:success), do: "check_circle"
  defp toast_icon(:warning), do: "warning"
  defp toast_icon(:error), do: "cancel"
  defp toast_icon(:info), do: "info"
  defp toast_icon(:default), do: nil

  defp toast_color(:success), do: "text-success"
  defp toast_color(:warning), do: "text-warning"
  defp toast_color(:error), do: "text-destructive"
  defp toast_color(_kind), do: nil

  defp toaster_position("bottom-right"), do: "bottom-0 right-0 items-end"
  defp toaster_position("bottom-left"), do: "bottom-0 left-0 items-start"
  defp toaster_position("top-right"), do: "top-0 right-0 items-end"
  defp toaster_position("top-left"), do: "top-0 left-0 items-start"
end
