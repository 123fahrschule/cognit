defmodule Storybook.Examples.DateTime.ShiftPlanner.Shift do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:date, :date)
    field(:starts_at, :time)
    field(:ends_at, :time)
  end

  def changeset(shift \\ %__MODULE__{}, attrs \\ %{}) do
    shift
    |> cast(attrs, [:date, :starts_at, :ends_at])
    |> validate_required([:date, :starts_at, :ends_at], message: "can't be blank")
    |> validate_order()
  end

  defp validate_order(changeset) do
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)

    if starts_at && ends_at && Time.compare(ends_at, starts_at) != :gt,
      do: add_error(changeset, :ends_at, "must be after the start"),
      else: changeset
  end
end

defmodule Storybook.Examples.DateTime.ShiftPlanner do
  @moduledoc """
  Example: collecting shifts in a list with a date picker and two time pickers.

  Each submit validates the row and appends it to a table; the form is reset
  for the next entry, keeping the date so several shifts on the same day are
  quick to add. Rows can be removed again.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.DateTime.ShiftPlanner.Shift

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:shifts, [])
     |> assign(:next_id, 1)
     |> assign_form(Shift.changeset())}
  end

  @impl true
  def handle_event("validate", %{"shift" => params}, socket) do
    changeset =
      %Shift{}
      |> Shift.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("add", %{"shift" => params}, socket) do
    changeset = Shift.changeset(%Shift{}, params)

    if changeset.valid? do
      shift = changeset |> Ecto.Changeset.apply_changes() |> Map.put(:id, socket.assigns.next_id)

      {:noreply,
       socket
       |> update(:shifts, &sort_shifts([shift | &1]))
       |> update(:next_id, &(&1 + 1))
       |> assign_form(Shift.changeset(%Shift{}, %{"date" => shift.date}))}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def handle_event("remove", %{"id" => id}, socket) do
    {:noreply,
     update(socket, :shifts, &Enum.reject(&1, fn shift -> to_string(shift.id) == id end))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto flex max-w-2xl flex-col gap-6 p-8">
      <div>
        <h2 class="text-lg font-semibold">Shift planner</h2>
        <p class="text-sm text-muted-foreground">Add the shifts for the coming weeks.</p>
      </div>

      <.form
        for={@form}
        phx-change="validate"
        phx-submit="add"
        class="grid grid-cols-1 items-start gap-4 md:grid-cols-[1fr_8rem_8rem_auto]"
      >
        <.form_field
          type="date-picker"
          field={@form[:date]}
          label="Date"
          min={Date.utc_today()}
          max={Date.add(Date.utc_today(), 28)}
        />
        <.form_field type="time-picker" field={@form[:starts_at]} label="From" step={15} />
        <.form_field type="time-picker" field={@form[:ends_at]} label="To" step={15} />
        <.button type="submit" class="md:mt-[1.625rem]">Add</.button>
      </.form>

      <.table>
        <.table_header>
          <.table_row>
            <.table_head>Date</.table_head>
            <.table_head>From</.table_head>
            <.table_head>To</.table_head>
            <.table_head>Hours</.table_head>
            <.table_head></.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row :for={shift <- @shifts}>
            <.table_cell>{Calendar.strftime(shift.date, "%a %d.%m.%Y")}</.table_cell>
            <.table_cell class="tabular-nums">
              {Calendar.strftime(shift.starts_at, "%H:%M")}
            </.table_cell>
            <.table_cell class="tabular-nums">
              {Calendar.strftime(shift.ends_at, "%H:%M")}
            </.table_cell>
            <.table_cell class="tabular-nums">{hours(shift)}</.table_cell>
            <.table_cell class="text-right">
              <.button
                variant="ghost"
                size="icon"
                aria-label="Remove shift"
                phx-click="remove"
                phx-value-id={shift.id}
              >
                <.icon name="delete" size="xs" />
              </.button>
            </.table_cell>
          </.table_row>
          <.table_empty colspan={5}>No shifts yet.</.table_empty>
        </.table_body>
      </.table>

      <p :if={@shifts != []} class="text-sm text-muted-foreground">
        Total: {@shifts |> Enum.map(&hours/1) |> Enum.sum() |> Float.round(2)} hours
      </p>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "shift"))
  end

  defp sort_shifts(shifts) do
    Enum.sort_by(shifts, &{&1.date, &1.starts_at}, fn {d1, t1}, {d2, t2} ->
      case Date.compare(d1, d2) do
        :eq -> Time.compare(t1, t2) != :gt
        :lt -> true
        :gt -> false
      end
    end)
  end

  defp hours(shift) do
    Float.round(Time.diff(shift.ends_at, shift.starts_at, :minute) / 60, 2)
  end
end
