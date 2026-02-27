defmodule Storybook.CognitComponents.Progress do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Progress.progress/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          value: 50
        }
      },
      %Variation{
        id: :progress_bar,
        attributes: %{
          value: 20,
          class: "w-[60%]"
        }
      },
      %Variation{
        id: :thin_progress_bar,
        attributes: %{
          value: 20,
          class: "w-[60%] h-2"
        }
      },
      %Variation{
        id: :high_progress,
        attributes: %{
          value: 80,
          class: "w-[60%]"
        }
      },
      %Variation{
        id: :custom_max,
        attributes: %{
          value: 35,
          max: 50,
          class: "w-[60%]"
        }
      },
      %Variation{
        id: :indeterminate,
        attributes: %{
          indeterminate: true,
          class: "w-[60%]"
        },
        description: "Used when progress value is unknown"
      },
      %VariationGroup{
        id: :colors,
        description: "Custom color via Tailwind class",
        variations:
          for {id, color} <- [
                {:primary, "bg-primary"},
                {:blue, "bg-blue-500"},
                {:green, "bg-green-500"},
                {:amber, "bg-amber-500"},
                {:red, "bg-red-500"},
                {:purple, "bg-purple-500"}
              ] do
            %Variation{
              id: id,
              attributes: %{
                value: 60,
                color: color,
                class: "w-[60%]"
              }
            }
          end
      }
    ]
  end
end
