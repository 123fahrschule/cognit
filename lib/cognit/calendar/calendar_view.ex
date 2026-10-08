defmodule Cognit.CalendarView do
  @moduledoc false
  # The calendar markup and options shared by `Cognit.Calendar` and
  # `Cognit.DatePicker`.

  use Cognit, :component

  @doc """
  Renders the month header, weekday row, and day grid. The grid is filled on
  the client.
  """
  def calendar_view(assigns) do
    ~H"""
    <div data-part="calendar" class="flex flex-col gap-4">
      <div class="relative flex h-8 items-center justify-center">
        <button
          type="button"
          data-part="previous-month"
          aria-label={pgettext("calendar", "Previous month")}
          class={nav_button_class("left-0")}
        >
          <.chevron_icon path="m15 18-6-6 6-6" />
        </button>
        <div data-part="caption" aria-live="polite" class="select-none text-sm font-medium"></div>
        <button
          type="button"
          data-part="next-month"
          aria-label={pgettext("calendar", "Next month")}
          class={nav_button_class("right-0")}
        >
          <.chevron_icon path="m9 18 6-6-6-6" />
        </button>
      </div>

      <table data-part="grid" role="grid" class="border-collapse">
        <thead>
          <tr data-part="weekdays" class="flex"></tr>
        </thead>
        <tbody data-part="weeks"></tbody>
      </table>

      <template data-part="weekday-template">
        <th
          scope="col"
          class="flex h-5 w-8 select-none items-center justify-center text-[0.8rem] font-normal text-muted-foreground"
        >
        </th>
      </template>
      <template data-part="week-template">
        <tr class="mt-2 flex"></tr>
      </template>
      <template data-part="day-template">
        <td class="size-8 p-0 text-center data-[range-end]:rounded-r-sm data-[range-start]:rounded-l-sm data-[range-end]:bg-accent data-[range-middle]:bg-accent data-[range-start]:bg-accent">
          <button
            type="button"
            tabindex="-1"
            class="inline-flex size-8 select-none items-center justify-center rounded-sm text-sm font-normal tabular-nums text-foreground outline-none transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 data-[outside]:opacity-50 data-[today]:bg-accent data-[today]:text-accent-foreground data-[range-middle]:rounded-none data-[range-middle]:bg-accent data-[range-middle]:text-accent-foreground data-[selected]:bg-primary data-[selected]:text-primary-foreground data-[disabled]:cursor-not-allowed data-[disabled]:text-muted-foreground data-[disabled]:opacity-50 data-[disabled]:hover:bg-transparent"
          >
          </button>
        </td>
      </template>
    </div>
    """
  end

  @doc """
  Returns the options read by the calendar JS.
  """
  def calendar_options(assigns) do
    %{
      mode: assigns.mode,
      value: assigns.value |> to_date() |> to_iso(),
      endValue: assigns[:"end-value"] |> to_date() |> to_iso(),
      min: assigns.min |> to_date() |> to_iso(),
      max: assigns.max |> to_date() |> to_iso(),
      disabledDates:
        assigns[:"disabled-dates"]
        |> List.wrap()
        |> Enum.map(&to_date/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.map(&to_iso/1),
      # The browser expects "pt-BR" where Gettext uses "pt_BR"
      locale: Cognit.Gettext |> Gettext.get_locale() |> String.replace("_", "-")
    }
  end

  @doc """
  Reads the end of a range from `end-field`, the way `prepare_assign/1` reads
  `field`. Errors from both fields mark the component invalid.
  """
  def prepare_end_assign(%{"end-field": %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:"end-field", nil)
    |> assign(:"end-name", assigns[:"end-name"] || field.name)
    |> assign(:"end-value", assigns[:"end-value"] || field.value)
    |> assign(:errors, (assigns[:errors] || []) ++ field_errors(field))
  end

  def prepare_end_assign(assigns), do: assigns

  attr :path, :string, required: true

  defp chevron_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4"
      aria-hidden="true"
    >
      <path d={@path}></path>
    </svg>
    """
  end

  defp nav_button_class(position) do
    [
      "absolute inline-flex size-8 items-center justify-center rounded-sm text-foreground opacity-50 outline-none transition hover:bg-accent hover:opacity-100 focus-visible:opacity-100 focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-25",
      position
    ]
  end

  defp to_date(%Date{} = date), do: date
  defp to_date(%DateTime{} = datetime), do: DateTime.to_date(datetime)
  defp to_date(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_date(datetime)

  defp to_date(value) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp to_date(_), do: nil

  defp to_iso(nil), do: nil
  defp to_iso(%Date{} = date), do: Date.to_iso8601(date)
end
