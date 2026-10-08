defmodule Storybook.Examples.DateTime.Agenda do
  @moduledoc """
  Example: an inline calendar driving a day agenda, without a form.

  The calendar pushes `on-value-changed` on every pick; the server lists the
  lessons of that day next to it. Days without lessons are disabled. The
  "Today" and "Next lesson" buttons set the value from the server by
  re-rendering the calendar with a new `value`.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    lessons = sample_lessons(today)

    {:ok,
     socket
     |> assign(:today, today)
     |> assign(:lessons, lessons)
     |> assign(:disabled_dates, free_days(today, lessons))
     |> assign(:selected, today)}
  end

  @impl true
  def handle_event("day_changed", %{"value" => value}, socket) do
    selected =
      case value && Date.from_iso8601(value) do
        {:ok, date} -> date
        _ -> nil
      end

    {:noreply, assign(socket, :selected, selected)}
  end

  def handle_event("today", _params, socket) do
    {:noreply, assign(socket, :selected, socket.assigns.today)}
  end

  def handle_event("next_lesson", _params, socket) do
    %{selected: selected, today: today, lessons: lessons} = socket.assigns
    after_date = selected || today

    next =
      lessons
      |> Map.keys()
      |> Enum.filter(&(Date.compare(&1, after_date) == :gt))
      |> Enum.min(Date, fn -> after_date end)

    {:noreply, assign(socket, :selected, next)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto flex max-w-2xl flex-col gap-6 p-8">
      <div>
        <h2 class="text-lg font-semibold">Agenda</h2>
        <p class="text-sm text-muted-foreground">Only days with lessons can be picked.</p>
      </div>

      <div class="flex flex-col gap-6 md:flex-row">
        <div class="flex flex-col gap-3">
          <.calendar
            id="agenda-calendar"
            value={@selected}
            min={Date.add(@today, -30)}
            max={Date.add(@today, 60)}
            disabled-dates={@disabled_dates}
            on-value-changed="day_changed"
            class="rounded-md border"
          />
          <div class="flex gap-2">
            <.button variant="outline" size="sm" phx-click="today">Today</.button>
            <.button variant="outline" size="sm" phx-click="next_lesson">Next lesson</.button>
          </div>
        </div>

        <div class="flex min-w-0 flex-1 flex-col gap-2">
          <h3 class="text-sm font-medium">
            {if @selected, do: Calendar.strftime(@selected, "%A, %d.%m.%Y"), else: "No day selected"}
          </h3>
          <ul :if={@selected} class="flex flex-col gap-2">
            <li
              :for={{time, title} <- Map.get(@lessons, @selected, [])}
              class="flex items-center gap-3 rounded-md border px-3 py-2 text-sm"
            >
              <span class="w-12 tabular-nums text-muted-foreground">{time}</span>
              <span>{title}</span>
            </li>
            <li :if={@lessons[@selected] == nil} class="text-sm text-muted-foreground">
              No lessons on this day.
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  defp sample_lessons(today) do
    for offset <- [0, 2, 3, 7, 9, 14, 16, 21], into: %{} do
      lessons =
        if rem(offset, 2) == 0,
          do: [{"08:30", "Theory: right of way"}, {"10:00", "Driving: city"}],
          else: [{"14:00", "Driving: motorway"}]

      {Date.add(today, offset), lessons}
    end
  end

  defp free_days(today, lessons) do
    for offset <- -30..60,
        date = Date.add(today, offset),
        not Map.has_key?(lessons, date),
        do: date
  end
end
