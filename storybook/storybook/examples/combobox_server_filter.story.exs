defmodule Storybook.Examples.ComboboxServerFilter.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :country, :string
  end

  def changeset(booking \\ %__MODULE__{}, attrs \\ %{}) do
    booking
    |> cast(attrs, [:country])
    |> validate_required([:country], message: "please choose a country")
  end
end

defmodule Storybook.Examples.ComboboxServerFilter do
  @moduledoc """
  Example: combobox with server-side filtering, bound to a form.

  The combobox is wired to an Ecto `embedded_schema` through `to_form/1` and
  `field={@form[:country]}`. The LiveView owns the option list and re-renders a
  filtered subset on the `on-search` event, while the selected value round-trips
  through the form.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.ComboboxServerFilter.Booking

  @countries [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Cape Verde",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Comoros",
    "Congo",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Estonia",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "North Korea",
    "North Macedonia",
    "Norway",
    "Oman",
    "Pakistan",
    "Panama",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Somalia",
    "South Africa",
    "South Korea",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Togo",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Uruguay",
    "Uzbekistan",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Zambia",
    "Zimbabwe"
  ]

  @max_results 20

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:total, length(@countries))
     |> assign(:max_results, @max_results)
     |> assign(:options, Enum.take(@countries, @max_results))
     |> assign(:submitted, nil)
     |> assign_form(Booking.changeset())}
  end

  def handle_event("search", %{"query" => query}, socket) do
    q = String.downcase(query)

    options =
      @countries
      |> Enum.filter(&String.contains?(String.downcase(&1), q))
      |> Enum.take(@max_results)

    {:noreply, assign(socket, query: query, options: options)}
  end

  def handle_event("validate", %{"booking" => params}, socket) do
    changeset =
      %Booking{}
      |> Booking.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"booking" => params}, socket) do
    changeset = Booking.changeset(%Booking{}, params)

    if changeset.valid? do
      booking = Ecto.Changeset.apply_changes(changeset)

      {:noreply,
       socket
       |> assign(:submitted, booking.country)
       |> assign_form(Booking.changeset(%Booking{}, params))}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <div>
        <h2 class="text-lg font-semibold">Server-side filtered combobox in a form</h2>
        <p class="text-sm text-muted-foreground">
          Bound to an Ecto <code>embedded_schema</code>
          via <code>to_form/1</code>
          and a <code>field</code>
          assign. The LiveView owns the full country list
          ({@total} total) and returns the top {@max_results} matches on <code>on-search</code>; the selected value round-trips through the form.
        </p>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <div class="space-y-1.5">
          <.combobox field={@form[:country]} filter="server" on-search="search" debounce={300}>
            <.combobox_trigger class="w-full">
              <.combobox_value placeholder="Select a country" />
            </.combobox_trigger>
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
          <.form_message field={@form[:country]} />
        </div>

        <.button type="submit">Save</.button>
      </.form>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Query:</span> {inspect(@query)}</div>
        <div><span class="font-medium">Current value:</span> {inspect(@form[:country].value)}</div>
        <div><span class="font-medium">Last submitted:</span> {inspect(@submitted)}</div>
        <div><span class="font-medium">Visible options:</span> {length(@options)}</div>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "booking"))
  end
end
