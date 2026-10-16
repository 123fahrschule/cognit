defmodule Cognit.LiveView do
  @moduledoc """
  Drives interactive components from the server.

  Interactive components (`dialog`, `sheet`, `dropdown_menu`, `popover`,
  `tooltip`, `sidebar`, ...) are client-side state machines addressed by their
  `id`. Use `send_command/4` when the transition depends on server-side state,
  e.g. closing a sheet after a successful save; use
  `Cognit.JS.dispatch_command/3` when it is pure UI, e.g. a button that opens
  a dialog.
  """

  @doc """
  Pushes a command to the component with the given `id`.

  `command` is any transition the component's state machine supports,
  typically `"open"`, `"close"` or `"toggle"` for overlays. `params` are
  passed through to the component.

  ## Example

      alias Cognit.LiveView, as: CognitLV

      def handle_event("save_employee", %{"employee" => params}, socket) do
        case save(params) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Saved")
             |> CognitLV.send_command("employee-sheet", "close")}

          {:error, changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end
      end
  """
  def send_command(socket, component_id, command, params \\ %{}) do
    Phoenix.LiveView.push_event(socket, "saladui:command", %{
      command: command,
      params: params,
      target: component_id
    })
  end
end

defmodule Cognit.JS do
  @moduledoc """
  Drives interactive components from the client, without a server round-trip.

  Counterpart of `Cognit.LiveView.send_command/4`; the same command names apply.
  """

  @doc """
  Returns a `Phoenix.LiveView.JS` that dispatches `command_name` to the
  component selected by `opts[:to]`.

  `opts[:detail]` carries extra params to the component. Because the result
  is a JS struct it chains with other JS commands.

  ## Examples

      <.button phx-click={Cognit.JS.dispatch_command("open", to: "#confirm-dialog")}>
        Delete
      </.button>

      <.button phx-click={
        %JS{}
        |> JS.push("track_click")
        |> Cognit.JS.dispatch_command("open", to: "#confirm-dialog")
      }>
        Delete
      </.button>
  """
  def dispatch_command(js \\ %Phoenix.LiveView.JS{}, command_name, opts \\ []) do
    details = %{
      command: command_name,
      params: opts[:detail]
    }

    Phoenix.LiveView.JS.dispatch(
      js,
      "salad_ui:command",
      opts |> Keyword.put(:detail, details)
    )
  end
end

# Phoenix LiveView 1.2+ ships its own (identical) Jason.Encoder for
# Phoenix.LiveView.JS; only define ours when an older version lacks it.
unless Code.ensure_loaded?(Jason.Encoder.Phoenix.LiveView.JS) do
  defimpl Jason.Encoder, for: Phoenix.LiveView.JS do
    def encode(value, opts) do
      Jason.Encode.list(value.ops, opts)
    end
  end
end
