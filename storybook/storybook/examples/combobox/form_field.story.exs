defmodule Storybook.Examples.Combobox.FormField.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :fruit, :string
  end

  def changeset(booking \\ %__MODULE__{}, attrs \\ %{}) do
    booking
    |> cast(attrs, [:fruit])
    |> validate_required([:fruit], message: "pick a fruit")
  end
end

defmodule Storybook.Examples.Combobox.FormField do
  @moduledoc """
  Example: a combobox rendered through `form_field` with `type="combobox"`.

  The dropdown items are passed via the reused `select_content` slot, while the
  label, description, and validation error come from the `form_field` wrapper —
  exactly like the `type="select"` variant.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.Combobox.FormField.Booking

  @fruits ~w(Apple Banana Blueberry Orange Pineapple Strawberry Watermelon)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:fruits, @fruits)
     |> assign(:submitted, nil)
     |> assign_form(Booking.changeset())}
  end

  @impl true
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
       |> assign(:submitted, booking.fruit)
       |> assign_form(Booking.changeset())}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <.form_field
          type="combobox"
          field={@form[:fruit]}
          label="Favourite fruit"
          description="Searchable select, bound to the form via form_field."
        >
          <:select_content>
            <.combobox_item :for={fruit <- @fruits} value={fruit}>{fruit}</.combobox_item>
          </:select_content>
        </.form_field>

        <.button type="submit">Save</.button>
      </.form>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Value:</span> {inspect(@form[:fruit].value)}</div>
        <div><span class="font-medium">Last submitted:</span> {inspect(@submitted)}</div>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "booking"))
  end
end
