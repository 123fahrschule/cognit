defmodule Storybook.Examples.DateTime.LessonBooking.Booking do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:student, :string)
    field(:starts_on, :date)
    field(:ends_on, :date)
    field(:starts_at, :time)
    field(:duration, :string, default: "90")
  end

  def changeset(booking \\ %__MODULE__{}, attrs \\ %{}) do
    booking
    |> cast(attrs, [:student, :starts_on, :ends_on, :starts_at, :duration])
    |> validate_required([:student, :starts_on, :ends_on, :starts_at], message: "can't be blank")
    |> validate_date_order()
    |> validate_span()
    |> validate_change(:starts_at, fn :starts_at, time ->
      if Time.compare(time, ~T[08:00:00]) == :lt or Time.compare(time, ~T[19:00:00]) == :gt,
        do: [starts_at: "lessons run between 08:00 and 19:00"],
        else: []
    end)
  end

  defp validate_date_order(changeset) do
    starts_on = get_field(changeset, :starts_on)
    ends_on = get_field(changeset, :ends_on)

    if starts_on && ends_on && Date.compare(ends_on, starts_on) == :lt,
      do: add_error(changeset, :ends_on, "must be on or after the start"),
      else: changeset
  end

  defp validate_span(changeset) do
    starts_on = get_field(changeset, :starts_on)
    ends_on = get_field(changeset, :ends_on)

    if starts_on && ends_on && Date.diff(ends_on, starts_on) > 13,
      do: add_error(changeset, :ends_on, "a course spans at most two weeks"),
      else: changeset
  end
end

defmodule Storybook.Examples.DateTime.LessonBooking do
  @moduledoc """
  Example: booking a lesson course with a date range and a start time.

  The date picker runs in `mode="range"` and binds its start and end to two
  `:date` fields through `field` and `end-field`. The time picker binds to a
  `:time` field. Both are validated by the changeset on `phx-change`, so
  errors appear as soon as the user picks something invalid.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.DateTime.LessonBooking.Booking

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:booked, nil)
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

  def handle_event("book", %{"booking" => params}, socket) do
    changeset = Booking.changeset(%Booking{}, params)

    if changeset.valid? do
      {:noreply,
       socket
       |> assign(:booked, Ecto.Changeset.apply_changes(changeset))
       |> assign_form(Booking.changeset())}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto flex max-w-lg flex-col gap-6 p-8">
      <div>
        <h2 class="text-lg font-semibold">Book a course</h2>
        <p class="text-sm text-muted-foreground">
          Pick the first and last day, then the daily start time.
        </p>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="book" class="flex flex-col gap-4">
        <.form_field field={@form[:student]} label="Student" placeholder="Ada Lovelace" />

        <.form_field
          type="date-picker"
          mode="range"
          field={@form[:starts_on]}
          end-field={@form[:ends_on]}
          label="Course days"
          min={Date.utc_today()}
          disabled-dates={weekends(Date.utc_today(), 60)}
          placeholder="First – last day"
          description="Weekdays only, up to two weeks."
        >
          <:leading><.icon name="date_range" size="xs" decorative /></:leading>
        </.form_field>

        <div class="grid grid-cols-2 gap-4">
          <.form_field
            type="time-picker"
            field={@form[:starts_at]}
            label="Start time"
            min="08:00"
            max="19:00"
            step={30}
            placeholder="Set time"
          >
            <:leading><.icon name="schedule" size="xs" decorative /></:leading>
          </.form_field>

          <.form_field type="select" field={@form[:duration]} label="Duration">
            <:select_content>
              <.select_item value="45">45 min</.select_item>
              <.select_item value="90">90 min</.select_item>
              <.select_item value="135">135 min</.select_item>
            </:select_content>
          </.form_field>
        </div>

        <div class="flex justify-end pt-2">
          <.button type="submit">Book</.button>
        </div>
      </.form>

      <div :if={@booked} class="rounded-md border border-success/40 bg-success-soft/40 p-4 text-sm">
        <p class="font-medium">Course booked for {@booked.student}</p>
        <p class="mt-1 text-muted-foreground">
          {Calendar.strftime(@booked.starts_on, "%d.%m.%Y")} – {Calendar.strftime(
            @booked.ends_on,
            "%d.%m.%Y"
          )}, daily at {Calendar.strftime(@booked.starts_at, "%H:%M")} for {@booked.duration} min
        </p>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "booking"))
  end

  defp weekends(from, days) do
    for offset <- 0..days,
        date = Date.add(from, offset),
        Date.day_of_week(date) in [6, 7],
        do: date
  end
end
