defmodule Storybook.CognitComponents.TimePicker do
  @moduledoc """
  Storybook documentation for the Cognit TimePicker component.

  A time input with separate hour and minute fields, in 24-hour hh:mm.
  """
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.TimePicker.time_picker/1

  def imports, do: [{Cognit.Icon, [icon: 1]}]

  def description do
    """
    The TimePicker component is a time input with separate hour and minute
    fields, always in 24-hour hh:mm. Typing the hours moves on to the minutes,
    and Tab moves between them. ArrowUp and ArrowDown change the focused field.
    Escape restores the last time. While no time is set, it shows hh:mm or the
    placeholder text.
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default time picker",
        attributes: %{
          id: "time-picker",
          name: "time",
          class: "w-[120px]",
          "on-value-changed": "value_changed"
        }
      },
      %Variation{
        id: :with_value,
        description: "A pre-filled time",
        attributes: %{
          id: "time-picker-value",
          name: "time",
          value: "14:30",
          class: "w-[120px]"
        }
      },
      %Variation{
        id: :with_leading_icon,
        description: "Time picker with a leading icon",
        attributes: %{
          id: "time-picker-icon",
          name: "time",
          class: "w-[120px]"
        },
        slots: [
          """
          <:leading><.icon name="schedule" size="xs" decorative /></:leading>
          """
        ]
      },
      %Variation{
        id: :with_placeholder,
        description:
          "A custom placeholder, shown until the time picker gets focus or a time is set",
        attributes: %{
          id: "time-picker-placeholder",
          name: "time",
          placeholder: "Set time",
          class: "w-[160px]"
        },
        slots: [
          """
          <:leading><.icon name="schedule" size="xs" decorative /></:leading>
          """
        ]
      },
      %Variation{
        id: :min_max_step,
        description:
          "Times outside 07:00 to 20:00 are marked invalid, and the arrow keys move the minutes by 15",
        attributes: %{
          id: "time-picker-range",
          name: "time",
          value: "09:00",
          min: "07:00",
          max: "20:00",
          step: 15,
          class: "w-[120px]"
        }
      },
      %Variation{
        id: :disabled,
        description: "A disabled time picker",
        attributes: %{
          id: "time-picker-disabled",
          name: "time",
          value: "14:30",
          disabled: true,
          class: "w-[120px]"
        }
      }
    ]
  end
end
