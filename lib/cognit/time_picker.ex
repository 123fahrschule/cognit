defmodule Cognit.TimePicker do
  @moduledoc """
  Time input with separate hour and minute fields, always in 24-hour `hh:mm`.

  It works like a native `<input type="time">`: the colon is always shown,
  typing the hours moves on to the minutes, and `Tab` moves between them.
  Unlike the native input, it shows 24-hour times in every browser, matching
  the `dd.mm.yyyy` dates of `Cognit.DatePicker`. While no time is set, the
  fields show `hh:mm`, or the `placeholder` text when it's given.

  The form receives `"14:30"`, which an Ecto `:time` field casts directly.
  The value is updated when focus leaves the time picker, on `Enter`, and on
  every arrow key step. Leaving it with only the hours filled in sets the
  minutes to `00`. A time with only the minutes is submitted as `"--:30"`, so
  the changeset reports it as invalid. Times outside `min` and `max` are
  marked invalid.

  ## Forms and events

  In a form, pass `field` (or `name`): the time is submitted like any input,
  `phx-change` fires when it changes, and changeset errors mark the component
  invalid. Without a form, handle `on-value-changed` instead. The two work
  independently, so a component in a form can push the event too.

  ## Examples

      <.time_picker id="start-time" name="start_time" />

      <.time_picker
        field={@form[:starts_at]}
        min="07:00"
        max="20:00"
        step={15}
        placeholder="Set time"
      >
        <:leading><.icon name="schedule" size="xs" decorative /></:leading>
      </.time_picker>

  ## Keyboard

  * Digits fill in the focused field. After two digits, or a first hour digit
    above 2, focus moves on to the minutes. `:` or `.` does that too.
  * `ArrowUp` / `ArrowDown` change the focused field. Minutes move by `step`.
  * `ArrowLeft` / `ArrowRight` and `Tab` move between the hours and minutes
  * `Backspace` deletes a digit, then moves back to the hours
  * `Enter` sets the time
  * `Escape` restores the last time
  """
  use Cognit, :component

  # Attributes that belong on the hour and minute fields rather than the root
  @segment_attrs ~w(disabled readonly required form aria-invalid)a

  @doc """
  Renders a time picker.

  ## Attributes

  * `:id` - Unique identifier, required unless `:field` is given. The hour and
    minute fields get the ids `"<id>-hours"` and `"<id>-minutes"`.
  * `:name` - Name of the submitted form value.
  * `:value` - The time as a `Time`, an `"hh:mm"` or `"hh:mm:ss"` string, or `nil`.
  * `:field` - A form field struct, for example `@form[:starts_at]`.
  * `:min` / `:max` - Earliest and latest allowed time, as a `Time` or
    `"hh:mm"`. Times outside are marked invalid.
  * `:step` - Minutes the arrow keys move by. Defaults to `1`.
  * `:placeholder` - Text shown while no time is set and the time picker
    doesn't have focus. Without it, the fields show a translated `hh:mm`.
  * `:on-value-changed` - Event pushed with `%{"value" => "14:30"}`, or
    `%{"value" => nil}` when the time is cleared.
  * `:class` - Additional CSS classes.
  * `:rest` - `disabled`, `readonly`, and `required` apply to the hour and
    minute fields.
  """
  attr :id, :string, default: nil
  attr :name, :any, default: nil
  attr :value, :any, default: nil, doc: "The time: a `Time`, an `\"hh:mm\"` string, or nil"
  attr :"default-value", :any, default: nil, doc: "The time used when `value` is nil"

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:starts_at]"

  attr :min, :any, default: nil, doc: "Earliest allowed time: a `Time` or \"hh:mm\""
  attr :max, :any, default: nil, doc: "Latest allowed time: a `Time` or \"hh:mm\""
  attr :step, :integer, default: 1, doc: "Minutes the arrow keys move by"

  attr :placeholder, :string,
    default: nil,
    doc: "Text shown while no time is set. Without it, the fields show hh:mm"

  attr :"on-value-changed", :any, default: nil, doc: "Handler for value changed event"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled readonly required form)

  slot :leading, doc: "optional leading icon rendered before the time"

  def time_picker(assigns) do
    assigns = prepare_assign(assigns)

    value = format_time(assigns.value)
    {hours, minutes} = segments(value)
    event_map = add_event_mapping(%{}, assigns, "value-changed", :"on-value-changed")
    rest = maybe_set_aria_invalid(assigns.rest, assigns[:errors])

    assigns =
      assigns
      |> assign(:time_value, value)
      |> assign(:hours, hours)
      |> assign(:minutes, minutes)
      |> assign(:rest, Map.drop(rest, @segment_attrs -- [:"aria-invalid"]))
      |> assign(:segment_rest, Map.take(rest, @segment_attrs))
      |> assign(:event_map, json(event_map))
      |> assign(
        :options,
        json(%{
          value: value,
          min: format_time(assigns.min),
          max: format_time(assigns.max),
          step: max(normalize_integer(assigns.step) || 1, 1)
        })
      )

    ~H"""
    <div
      id={@id}
      role="group"
      class={
        classes([
          "group/time flex h-9 w-full cursor-text items-center gap-2 rounded-md border border-input bg-input-30 px-3 py-2 text-base shadow-xs focus-within:border-ring focus-within:ring-[3px] focus-within:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-[3px] aria-invalid:ring-destructive/40 has-[:disabled]:cursor-not-allowed has-[:disabled]:opacity-50 md:text-sm",
          @class
        ])
      }
      data-component="time-picker"
      data-part="root"
      data-placeholder={is_nil(@hours) and is_nil(@minutes)}
      data-options={@options}
      data-event-mappings={@event_map}
      phx-hook="SaladUI"
      {@rest}
    >
      <span
        :if={@leading != []}
        class="pointer-events-none flex size-4 shrink-0 items-center text-muted-foreground"
      >
        {render_slot(@leading)}
      </span>
      <span class="relative flex min-w-0 items-center">
        <span class={[
          "flex items-center tabular-nums",
          @placeholder &&
            "group-data-[placeholder]/time:opacity-0 group-focus-within/time:!opacity-100"
        ]}>
          <.segment
            id={@id && @id <> "-hours"}
            part="hours"
            value={@hours}
            max={23}
            label={pgettext("time picker", "Hours")}
            placeholder={pgettext("time picker placeholder", "hh")}
            rest={@segment_rest}
          />
          <span
            aria-hidden="true"
            class="select-none group-data-[placeholder]/time:text-muted-foreground"
          >
            :
          </span>
          <.segment
            id={@id && @id <> "-minutes"}
            part="minutes"
            value={@minutes}
            max={59}
            label={pgettext("time picker", "Minutes")}
            placeholder={pgettext("time picker placeholder", "mm")}
            rest={@segment_rest}
          />
        </span>
        <span
          :if={@placeholder}
          data-part="placeholder"
          class="pointer-events-none absolute left-0 hidden whitespace-nowrap text-muted-foreground group-data-[placeholder]/time:block group-focus-within/time:!hidden"
        >
          {@placeholder}
        </span>
      </span>
      <input
        type="text"
        name={@name}
        value={@time_value}
        form={@segment_rest[:form]}
        data-part="input"
        hidden
        tabindex="-1"
        aria-hidden="true"
      />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :part, :string, required: true
  attr :value, :string, required: true
  attr :max, :integer, required: true
  attr :label, :string, required: true
  attr :placeholder, :string, required: true
  attr :rest, :map, required: true

  # The hour or minute field. The component handles typing itself, so the
  # caret is hidden and the focused field is highlighted instead. The hidden
  # copy of its text sizes it, so it fits both the digits and the placeholder.
  defp segment(assigns) do
    ~H"""
    <span class="inline-grid">
      <span
        data-part={@part <> "-sizer"}
        aria-hidden="true"
        class="invisible col-start-1 row-start-1 whitespace-nowrap px-0.5"
      >
        {@value || @placeholder}
      </span>
      <input
        type="text"
        id={@id}
        value={@value}
        placeholder={@placeholder}
        role="spinbutton"
        inputmode="numeric"
        autocomplete="off"
        maxlength="2"
        aria-label={@label}
        aria-valuemin="0"
        aria-valuemax={@max}
        aria-valuenow={@value && String.to_integer(@value)}
        data-part={@part}
        class="col-start-1 row-start-1 w-0 min-w-full rounded-sm bg-transparent px-0.5 text-center caret-transparent outline-none placeholder:text-muted-foreground focus:bg-accent focus:text-accent-foreground disabled:cursor-not-allowed"
        {@rest}
      />
    </span>
    """
  end

  # "14:30", "14:30:00", ~T[14:30:00] -> "14:30". Anything else is passed on
  # as given, e.g. "--:30" sent back by a failed changeset.
  defp format_time(%Time{} = time), do: Calendar.strftime(time, "%H:%M")
  defp format_time(%DateTime{} = datetime), do: datetime |> DateTime.to_time() |> format_time()

  defp format_time(%NaiveDateTime{} = datetime),
    do: datetime |> NaiveDateTime.to_time() |> format_time()

  defp format_time(<<hh_mm::binary-size(5), ":", _seconds::binary-size(2)>>), do: hh_mm
  defp format_time(value) when is_binary(value) and value != "", do: value
  defp format_time(_), do: nil

  # "14:30" -> {"14", "30"}, "--:30" -> {nil, "30"}
  defp segments(nil), do: {nil, nil}

  defp segments(value) do
    case String.split(value, ":") do
      [hours, minutes] -> {segment_value(hours), segment_value(minutes)}
      _ -> {nil, nil}
    end
  end

  defp segment_value(value) do
    if value =~ ~r/^\d{1,2}$/, do: String.pad_leading(value, 2, "0")
  end
end
