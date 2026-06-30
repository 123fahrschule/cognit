defmodule Storybook.Examples.FormField.InfiniteScroll do
  @moduledoc """
  Example: `form_field` select and combobox paginating their options as you scroll.

  `form_field` renders the options list internally, so list-targeting attributes
  (`id` and the `phx-viewport-*` bindings) are set on the `<:select_content>`
  slot — they are forwarded onto the internal `select_content`/`combobox_list`.
  The LiveView appends the next page on the `load-more` events.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  @dataset for i <- 1..500, n = String.pad_leading(to_string(i), 3, "0"), do: "Item #{n}"
  @page_size 25

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:total, length(@dataset))
     |> assign(:select_loaded, @page_size)
     |> assign(:combo_loaded, @page_size)
     |> assign_options()
     |> assign_form()}
  end

  @impl true
  def handle_event("load-more-select", _params, socket) do
    {:noreply, socket |> update(:select_loaded, &(&1 + @page_size)) |> assign_options()}
  end

  def handle_event("load-more-combo", _params, socket) do
    {:noreply, socket |> update(:combo_loaded, &(&1 + @page_size)) |> assign_options()}
  end

  def handle_event("validate", %{"demo" => params}, socket),
    do: {:noreply, assign_form(socket, params)}

  defp assign_options(socket) do
    socket
    |> assign(:select_options, Enum.take(@dataset, socket.assigns.select_loaded))
    |> assign(:select_end?, socket.assigns.select_loaded >= length(@dataset))
    |> assign(:combo_options, Enum.take(@dataset, socket.assigns.combo_loaded))
    |> assign(:combo_end?, socket.assigns.combo_loaded >= length(@dataset))
  end

  defp assign_form(socket, params \\ %{}), do: assign(socket, :form, to_form(params, as: :demo))

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-6 p-8">
      <div>
        <h2 class="text-lg font-semibold">Infinite scroll via form_field</h2>
        <p class="text-sm text-muted-foreground">
          {@total} options total. Open either field and scroll to the bottom to load the
          next page.
        </p>
      </div>

      <.form for={@form} phx-change="validate" class="space-y-4">
        <.form_field type="select" field={@form[:select_item]} label="Select">
          <:select_content
            id="ff-select-options"
            phx-viewport-bottom={!@select_end? && "load-more-select"}
          >
            <.select_item :for={item <- @select_options} value={item}>{item}</.select_item>
          </:select_content>
        </.form_field>

        <.form_field type="combobox" field={@form[:combo_item]} label="Combobox">
          <:select_content
            id="ff-combo-options"
            phx-viewport-bottom={!@combo_end? && "load-more-combo"}
          >
            <.combobox_item :for={item <- @combo_options} value={item}>{item}</.combobox_item>
          </:select_content>
        </.form_field>
      </.form>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div>
          <span class="font-medium">Select:</span> {@form[:select_item].value || "—"} ({length(
            @select_options
          )} of {@total} loaded)
        </div>
        <div>
          <span class="font-medium">Combobox:</span> {@form[:combo_item].value || "—"} ({length(
            @combo_options
          )} of {@total} loaded)
        </div>
      </div>
    </div>
    """
  end
end
