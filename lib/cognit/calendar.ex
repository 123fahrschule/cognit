defmodule Cognit.Calendar do
  @moduledoc """
  Month calendar for picking a single date or a date range.

  The calendar shows one month at a time, with weeks starting on Monday. Month
  and weekday names follow the current Gettext locale. Dates are submitted as
  ISO 8601 strings (`"2026-08-06"`), the same value a native
  `<input type="date">` sends, so an Ecto `:date` field casts them directly.

  ## Modes

  * `"single"` (default) - Picks one date, submitted under `name`. Picking the
    selected day again clears it.
  * `"range"` - The first pick starts the range and the second ends it; a day
    before the start restarts the range instead. The start is submitted under
    `name` and the end under `end-name`, so a range maps to two `:date` fields.
    Picking the start of a selected range again clears it.

  `calendar/1` shows the calendar inline. To open it from an input-like
  trigger, use `Cognit.DatePicker`, which renders the same calendar in a
  popover.

  ## Forms and events

  In a form, pass `field` (or `name`): the date is submitted like any input,
  `phx-change` fires when it changes, and changeset errors mark the component
  invalid. Without a form, handle `on-value-changed` instead. The two work
  independently, so a component in a form can push the event too.

  ## Examples

      <.calendar id="due-date" name="due_on" class="rounded-md border" />

      <.calendar
        field={@form[:due_on]}
        min={Date.utc_today()}
        disabled-dates={@holidays}
        on-value-changed="date_changed"
      />

      <.calendar
        mode="range"
        field={@form[:starts_on]}
        end-field={@form[:ends_on]}
        class="rounded-md border"
      />

  ## Keyboard

  * Arrow keys move by a day (left/right) or a week (up/down)
  * `Home` / `End` move to the start or end of the week
  * `PageUp` / `PageDown` move by a month, with `Shift` by a year
  * `Enter` / `Space` picks the focused day
  """
  use Cognit, :component

  import Cognit.CalendarView

  @doc """
  Renders an inline calendar.

  ## Attributes

  * `:id` - Unique identifier, required unless `:field` is given.
  * `:mode` - `"single"` (default) or `"range"`.
  * `:name` - Name of the submitted date, or of the range start.
  * `:value` - Selected date, or range start, as a `Date`, an ISO 8601 string, or `nil`.
  * `:field` - A form field struct, for example `@form[:due_on]`.
  * `:end-name` / `:end-value` / `:end-field` - Same as above for the range end.
  * `:min` / `:max` - Earliest and latest selectable date (inclusive).
  * `:disabled-dates` - Dates that can't be selected. A range may span them.
  * `:on-value-changed` - Event pushed with `%{"value" => "2026-08-06"}`, or
    `%{"value" => nil}` when the date is cleared. In range mode, with
    `%{"value" => %{"from" => "2026-08-06", "to" => "2026-08-12"}}` on every
    pick, `"to"` being `nil` until the end is picked.
  * `:class` - Additional CSS classes.
  """
  attr :id, :string, default: nil
  attr :mode, :string, values: ~w(single range), default: "single"
  attr :name, :any, default: nil
  attr :value, :any, default: nil, doc: "The selected date: a `Date`, an ISO 8601 string, or nil"
  attr :"default-value", :any, default: nil, doc: "The date used when `value` is nil"

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:due_on]"

  attr :"end-name", :any, default: nil, doc: "Name of the submitted range end"

  attr :"end-value", :any,
    default: nil,
    doc: "The range end: a `Date`, an ISO 8601 string, or nil"

  attr :"end-field", Phoenix.HTML.FormField,
    doc: "a form field struct for the range end, for example: @form[:ends_on]"

  attr :min, :any, default: nil, doc: "Earliest selectable date (inclusive)"
  attr :max, :any, default: nil, doc: "Latest selectable date (inclusive)"
  attr :"disabled-dates", :list, default: [], doc: "Dates that can't be selected"

  attr :"on-value-changed", :any, default: nil, doc: "Handler for value changed event"
  attr :class, :any, default: nil
  attr :rest, :global

  def calendar(assigns) do
    assigns = assigns |> prepare_assign() |> prepare_end_assign()

    event_map = add_event_mapping(%{}, assigns, "value-changed", :"on-value-changed")
    options = calendar_options(assigns)
    rest = maybe_set_aria_invalid(assigns.rest, assigns[:errors])

    assigns =
      assigns
      |> assign(:rest, rest)
      |> assign(:iso_value, options.value)
      |> assign(:end_name, assigns[:"end-name"])
      |> assign(:end_iso_value, options.endValue)
      |> assign(:event_map, json(event_map))
      |> assign(:options, json(options))

    ~H"""
    <div
      id={@id}
      class={classes(["w-fit bg-background p-3", @class])}
      data-component="calendar"
      data-part="root"
      data-options={@options}
      data-event-mappings={@event_map}
      phx-hook="SaladUI"
      {@rest}
    >
      <.calendar_view />
      <input
        type="text"
        name={@name}
        value={@iso_value}
        data-part="input"
        hidden
        tabindex="-1"
        aria-hidden="true"
      />
      <input
        :if={@mode == "range"}
        type="text"
        name={@end_name}
        value={@end_iso_value}
        data-part="end-input"
        hidden
        tabindex="-1"
        aria-hidden="true"
      />
    </div>
    """
  end
end
