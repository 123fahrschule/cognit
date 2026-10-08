defmodule Storybook.CognitComponents.Calendar do
  @moduledoc """
  Storybook documentation for the Cognit Calendar component.

  An inline month calendar for picking a single date or a date range.
  """
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Calendar.calendar/1

  def description do
    """
    The Calendar component shows one month at a time for picking a single date
    or a date range, inline on the page. Dates are submitted as ISO 8601
    strings (2026-08-06). Weeks start on Monday; month and weekday names follow
    the Gettext locale. Click the selected day again to clear it.
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default calendar",
        attributes: %{
          id: "calendar",
          name: "date",
          class: "rounded-md border",
          "on-value-changed": "value_changed"
        }
      },
      %Variation{
        id: :with_value,
        description: "A pre-selected date. Click the selected day again to clear it",
        attributes: %{
          id: "calendar-value",
          name: "date",
          value: "2026-08-06",
          class: "rounded-md border"
        }
      },
      %Variation{
        id: :range,
        description:
          "Range mode: the first pick starts the range, the second ends it. Click the start again to clear it",
        attributes: %{
          id: "calendar-range-mode",
          mode: "range",
          name: "starts_on",
          "end-name": "ends_on",
          value: "2026-08-10",
          "end-value": "2026-08-14",
          class: "rounded-md border",
          "on-value-changed": "value_changed"
        }
      },
      %Variation{
        id: :min_max_disabled_dates,
        description:
          "Only dates from 3 August to 30 September can be picked, and 14 and 21 August are disabled",
        attributes: %{
          id: "calendar-range",
          name: "date",
          value: "2026-08-12",
          min: "2026-08-03",
          max: "2026-09-30",
          "disabled-dates": ["2026-08-14", "2026-08-21"],
          class: "rounded-md border"
        }
      }
    ]
  end
end
