defmodule Cognit.DatePicker do
  @moduledoc """
  Date picker: an input-styled trigger that opens a `Cognit.Calendar` in a popover.

  Dates are submitted as ISO 8601 strings (`"2026-08-06"`), the same value a
  native `<input type="date">` sends, so an Ecto `:date` field casts them
  directly. The trigger always shows dates as `dd.mm.yyyy`. Weeks start on
  Monday; month and weekday names follow the current Gettext locale.

  ## Modes

  * `"single"` (default) - Picks one date and closes. Picking the selected day
    again clears the value: the form then submits an empty string, which Ecto
    casts to `nil`, and `on-value-changed` receives `%{"value" => nil}`.
  * `"range"` - The first pick starts the range, the second ends it and
    closes; a day before the start restarts the range instead. The value only
    changes once the range is complete, and closing halfway keeps the previous
    range. The start is submitted under `name` and the end under `end-name`.
    Picking the start of a selected range again clears it.

  `Cognit.Components.FormField.form_field/1` renders this structure for
  `type="date-picker"`.

  ## Forms and events

  In a form, pass `field` (or `name`): the date is submitted like any input,
  `phx-change` fires when it changes, and changeset errors mark the component
  invalid. Without a form, handle `on-value-changed` instead. The two work
  independently, so a component in a form can push the event too.

  ## Examples

      <.date_picker id="due-date" name="due_on">
        <.date_picker_trigger class="w-[240px]">
          <:leading><.icon name="calendar_today" size="xs" decorative /></:leading>
          <.date_picker_value placeholder="Set date" />
        </.date_picker_trigger>
        <.date_picker_content />
      </.date_picker>

      <.date_picker
        field={@form[:due_on]}
        min={Date.utc_today()}
        disabled-dates={@holidays}
        on-value-changed="date_changed"
      >
        <.date_picker_trigger>
          <.date_picker_value />
        </.date_picker_trigger>
        <.date_picker_content align="end">
          <p class="mt-3 border-t pt-3 text-xs text-muted-foreground">Weekends aren't available.</p>
        </.date_picker_content>
      </.date_picker>

      <.date_picker mode="range" field={@form[:starts_on]} end-field={@form[:ends_on]}>
        <.date_picker_trigger class="w-[260px]">
          <.date_picker_value placeholder="Set dates" />
        </.date_picker_trigger>
        <.date_picker_content />
      </.date_picker>

  ## Keyboard

  * `Enter` / `Space` on the trigger opens the calendar
  * Arrow keys move by a day (left/right) or a week (up/down)
  * `Home` / `End` move to the start or end of the week
  * `PageUp` / `PageDown` move by a month, with `Shift` by a year
  * `Enter` / `Space` picks the focused day
  * `Escape` closes the calendar
  """
  use Cognit, :component

  import Cognit.CalendarView

  @doc """
  Renders a date picker. Holds the value, the constraints, and the open state
  shared by its `date_picker_trigger/1` and `date_picker_content/1`.

  ## Attributes

  * `:id` - Unique identifier, required unless `:field` is given.
  * `:mode` - `"single"` (default) or `"range"`.
  * `:name` - Name of the submitted date, or of the range start.
  * `:value` - Selected date, or range start, as a `Date`, an ISO 8601 string, or `nil`.
  * `:field` - A form field struct, for example `@form[:due_on]`.
  * `:end-name` / `:end-value` / `:end-field` - Same as above for the range end.
  * `:min` / `:max` - Earliest and latest selectable date (inclusive).
  * `:disabled-dates` - Dates that can't be selected. A range may span them.
  * `:use-portal` - Whether to render the calendar in a portal. Defaults to `false`.
  * `:portal-container` - CSS selector for the portal container.
  * `:on-value-changed` - Event pushed with `%{"value" => "2026-08-06"}`, or
    `%{"value" => nil}` when the date is cleared. In range mode, with
    `%{"value" => %{"from" => "2026-08-06", "to" => "2026-08-12"}}` once the
    range is complete, or with both `nil` when it's cleared.
  * `:on-open` / `:on-close` - Handlers for the calendar opening and closing.
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

  attr :"use-portal", :boolean, default: false, doc: "Whether to render the calendar in a portal"
  attr :"portal-container", :string, default: nil, doc: "CSS selector for the portal container"
  attr :"on-value-changed", :any, default: nil, doc: "Handler for value changed event"
  attr :"on-open", :any, default: nil, doc: "Handler for calendar open event"
  attr :"on-close", :any, default: nil, doc: "Handler for calendar close event"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def date_picker(assigns) do
    assigns = assigns |> prepare_assign() |> prepare_end_assign()

    event_map =
      %{}
      |> add_event_mapping(assigns, "value-changed", :"on-value-changed")
      |> add_event_mapping(assigns, "opened", :"on-open")
      |> add_event_mapping(assigns, "closed", :"on-close")

    options =
      assigns
      |> calendar_options()
      |> Map.merge(%{
        usePortal: assigns[:"use-portal"],
        portalContainer: assigns[:"portal-container"],
        animations: get_animation_config()
      })

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
      class={classes(["group/field relative inline-flex w-full", @class])}
      data-component="date-picker"
      data-part="root"
      data-state="closed"
      data-options={@options}
      data-event-mappings={@event_map}
      phx-hook="SaladUI"
      phx-mounted={JS.ignore_attributes(["data-state"])}
      {@rest}
    >
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
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the input-styled button that opens the calendar.

  Put `date_picker_value/1` inside to show the selected date. The content is
  free-form, so an icon on its own works too, restyled through `:class`.

  ## Attributes

  * `:class` - Additional CSS classes.
  * `:rest` - `disabled` disables the whole picker.
  """
  attr :class, :any, default: nil
  slot :inner_block, required: true
  slot :leading, doc: "optional leading icon rendered before the value"
  attr :rest, :global, include: ~w(disabled form)

  def date_picker_trigger(assigns) do
    ~H"""
    <button
      type="button"
      data-part="trigger"
      data-action="toggle"
      aria-haspopup="dialog"
      aria-expanded="false"
      phx-mounted={JS.ignore_attributes(["data-state", "aria-expanded", "data-placeholder"])}
      class={
        classes([
          "flex h-9 w-full items-center gap-2 whitespace-nowrap rounded-md border border-input bg-input-30 px-3 py-2 text-left text-sm shadow-xs focus:outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 data-[state=open]:border-ring data-[state=open]:ring-[3px] data-[state=open]:ring-ring/50 data-[placeholder]:text-muted-foreground group-aria-invalid/field:border-destructive group-aria-invalid/field:ring-[3px] group-aria-invalid/field:ring-destructive/40 disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])
      }
      {@rest}
    >
      <span
        :if={@leading != []}
        data-part="leading"
        class="!flex size-4 shrink-0 items-center justify-center"
      >
        {render_slot(@leading)}
      </span>
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders the selected date as `dd.mm.yyyy`, a range as
  `dd.mm.yyyy – dd.mm.yyyy`, or the placeholder while nothing is selected.

  ## Attributes

  * `:placeholder` - Text shown while no date is selected. Defaults to a
    translated "Set date".
  * `:class` - Additional CSS classes.
  """
  attr :placeholder, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def date_picker_value(assigns) do
    assigns =
      assign(
        assigns,
        :placeholder,
        assigns.placeholder || pgettext("date picker placeholder", "Set date")
      )

    ~H"""
    <span
      data-part="value"
      class={classes(["pointer-events-none min-w-0 flex-1 truncate text-start", @class])}
      data-placeholder={@placeholder}
      {@rest}
    >
    </span>
    """
  end

  @doc """
  Renders the popover holding the calendar. Anything inside is rendered below
  the calendar, e.g. a footer note.

  ## Attributes

  * `:side` - Preferred side of the trigger: `"bottom"` (default) or `"top"`.
    Flips when there isn't enough room.
  * `:align` - Alignment along the trigger: `"start"` (default), `"center"`, or `"end"`.
  * `:class` - Additional CSS classes.
  """
  attr :side, :string, values: ~w(top bottom), default: "bottom"
  attr :align, :string, values: ~w(start center end), default: "start"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, doc: "content rendered below the calendar"

  def date_picker_content(assigns) do
    ~H"""
    <div
      data-part="content"
      data-side={@side}
      data-align={@align}
      role="dialog"
      aria-modal="true"
      aria-label={pgettext("date picker", "Choose date")}
      hidden
      phx-mounted={JS.ignore_attributes(["data-state", "data-placement", "hidden", "style"])}
      class={
        classes([
          "absolute z-50 rounded-md border bg-popover p-3 text-popover-foreground shadow-md outline-none data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=top]:slide-in-from-bottom-2",
          @class
        ])
      }
      {@rest}
    >
      <.calendar_view />
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp get_animation_config do
    %{
      "open_to_closed" => %{
        duration: 130,
        target_part: "content"
      }
    }
  end
end
