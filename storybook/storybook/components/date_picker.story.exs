defmodule Storybook.CognitComponents.DatePicker do
  @moduledoc """
  Storybook documentation for the Cognit DatePicker component.

  An input-styled trigger that opens a calendar in a popover.
  """
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.DatePicker.date_picker/1

  def imports,
    do: [
      {Cognit.DatePicker,
       [
         date_picker_trigger: 1,
         date_picker_value: 1,
         date_picker_content: 1
       ]},
      {Cognit.Icon, [icon: 1]}
    ]

  def description do
    """
    The DatePicker component combines an input-styled trigger with a calendar
    popover. The selected date is submitted as an ISO 8601 string (2026-08-06)
    and shown as dd.mm.yyyy. Weeks start on Monday; month and weekday names
    follow the Gettext locale. Click the selected day again to clear it. In
    range mode it picks a start and an end date.
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default date picker",
        attributes: %{
          id: "date-picker",
          name: "date",
          "on-value-changed": "value_changed"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]">
            <.date_picker_value />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :with_leading_icon,
        description: "Date picker with a leading icon and a custom placeholder",
        attributes: %{
          id: "date-picker-icon",
          name: "date"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]">
            <:leading><.icon name="calendar_today" size="xs" decorative /></:leading>
            <.date_picker_value placeholder="Pick a date" />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :with_value,
        description: "A pre-selected date. Click the selected day again to clear it",
        attributes: %{
          id: "date-picker-value",
          name: "date",
          value: "2026-08-06"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]">
            <.date_picker_value />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :min_max_disabled_dates,
        description:
          "Only dates from 3 August to 30 September can be picked, and 14 and 21 August are disabled",
        attributes: %{
          id: "date-picker-range",
          name: "date",
          value: "2026-08-12",
          min: "2026-08-03",
          max: "2026-09-30",
          "disabled-dates": ["2026-08-14", "2026-08-21"]
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]">
            <.date_picker_value />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :range,
        description:
          "Range mode: the first pick starts the range, the second ends it. Closing halfway keeps the previous range",
        attributes: %{
          id: "date-picker-range-mode",
          mode: "range",
          name: "starts_on",
          "end-name": "ends_on",
          value: "2026-08-10",
          "end-value": "2026-08-14",
          "on-value-changed": "value_changed"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[260px]">
            <:leading><.icon name="calendar_today" size="xs" decorative /></:leading>
            <.date_picker_value placeholder="Set dates" />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :custom_trigger,
        description: "An icon-only trigger, restyled through its class",
        attributes: %{
          id: "date-picker-custom-trigger",
          name: "date"
        },
        slots: [
          """
          <.date_picker_trigger class="size-9 justify-center p-0" aria-label="Pick a date">
            <.icon name="calendar_today" size="xs" decorative />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      },
      %Variation{
        id: :with_footer,
        description: "Content inside date_picker_content is rendered below the calendar",
        attributes: %{
          id: "date-picker-footer",
          name: "date"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]">
            <.date_picker_value />
          </.date_picker_trigger>
          <.date_picker_content>
            <p class="mt-3 border-t pt-3 text-xs text-muted-foreground">
              Weekends aren't available.
            </p>
          </.date_picker_content>
          """
        ]
      },
      %Variation{
        id: :disabled,
        description: "A disabled date picker",
        attributes: %{
          id: "date-picker-disabled",
          name: "date",
          value: "2026-08-06"
        },
        slots: [
          """
          <.date_picker_trigger class="w-[240px]" disabled>
            <.date_picker_value />
          </.date_picker_trigger>
          <.date_picker_content />
          """
        ]
      }
    ]
  end
end
