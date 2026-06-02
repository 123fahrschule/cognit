defmodule Storybook.Examples.ComboboxChips.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:countries, {:array, :string}, default: [])
  end

  def changeset(trip \\ %__MODULE__{}, attrs \\ %{}) do
    trip
    |> cast(attrs, [:countries])
    |> validate_length(:countries, min: 1, message: "pick at least one country")
  end
end

defmodule Storybook.Examples.ComboboxChips do
  @moduledoc """
  Example: multi-select combobox rendering chips, with server-side filtering.

  The list is long and only the top matches are loaded at a time, yet some values
  are preselected from the *end* of the list — options that aren't in the current
  page. The `selected` assign carries their labels so the chips render correctly
  even though their `<.combobox_item>` was never sent to the client.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.ComboboxChips.Trip

  @countries ~w(
    Afghanistan Albania Algeria Andorra Angola Argentina Armenia Australia Austria
    Belgium Brazil Bulgaria Canada Chile China Colombia Croatia Cyprus Denmark Egypt
    Estonia Finland France Georgia Germany Greece Hungary Iceland India Indonesia
    Ireland Israel Italy Japan Kenya Latvia Lithuania Luxembourg Malta Mexico Morocco
    Netherlands Norway Poland Portugal Romania Serbia Singapore Slovakia Slovenia Spain
    Sweden Switzerland Thailand Tunisia Turkey Uganda Ukraine Uruguay Uzbekistan
    Venezuela Vietnam Yemen Zambia Zimbabwe
  )

  @max_results 15
  # Preselected from the tail of the list — not present in the initial page.
  @preselected ~w(Vietnam Zambia Zimbabwe)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:total, length(@countries))
     |> assign(:max_results, @max_results)
     |> assign(:options, Enum.take(@countries, @max_results))
     |> assign(:selected, Enum.map(@preselected, &%{value: &1, label: &1}))
     |> assign_form(Trip.changeset(%Trip{countries: @preselected}))}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    q = String.downcase(query)

    options =
      @countries
      |> Enum.filter(&String.contains?(String.downcase(&1), q))
      |> Enum.take(@max_results)

    {:noreply, assign(socket, query: query, options: options)}
  end

  def handle_event("validate", %{"trip" => params}, socket) do
    changeset =
      %Trip{}
      |> Trip.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <div>
        <h2 class="text-lg font-semibold">Multi-select chips with preselected values</h2>
        <p class="text-sm text-muted-foreground">
          {@total} countries, top {@max_results} loaded at a time. Vietnam, Zambia and Zimbabwe
          are preselected from the end of the list — their chips render from the <code>selected</code>
          labels even though those options aren't in the current page.
        </p>
      </div>

      <.form for={@form} phx-change="validate" class="space-y-4">
        <.combobox
          field={@form[:countries]}
          multiple
          filter="server"
          on-search="search"
          selected={@selected}
        >
          <.combobox_trigger class="w-full">
            <.combobox_value placeholder="Select countries" />
          </.combobox_trigger>
          <.combobox_chips class="mt-1.5" />
          <.combobox_content>
            <.combobox_input placeholder="Search country..." />
            <.combobox_empty>No country found.</.combobox_empty>
            <.combobox_list>
              <.combobox_item :for={country <- @options} value={country}>
                {country}
              </.combobox_item>
            </.combobox_list>
          </.combobox_content>
        </.combobox>
      </.form>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Query:</span> {inspect(@query)}</div>
        <div><span class="font-medium">Selected:</span> {inspect(@form[:countries].value)}</div>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "trip"))
  end
end
