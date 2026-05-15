defmodule Storybook.CognitComponents.Badge do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  # def function, do: &SaladStorybookWeb.CognitComponents.button/1
  def function, do: &Cognit.Badge.badge/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["Badge"]
      },
      %VariationGroup{
        id: :badge_variants,
        description: "Color variations with `variant` attribute.",
        variations: [
          %Variation{
            id: :color_default,
            slots: ["Default"]
          },
          %Variation{
            id: :color_secondary,
            attributes: %{
              variant: "secondary"
            },
            slots: ["Secondary"]
          },
          %Variation{
            id: :color_outline,
            attributes: %{
              variant: "outline"
            },
            slots: ["Outline"]
          },
          %Variation{
            id: :color_destructive,
            attributes: %{
              variant: "destructive"
            },
            slots: ["Destructive"]
          },
          %Variation{
            id: :color_success,
            attributes: %{
              variant: "success"
            },
            slots: ["Success"]
          }
        ]
      },
      %VariationGroup{
        id: :badge_number,
        description: "Circular badges for displaying counts via `number` attribute.",
        variations: [
          %Variation{
            id: :number_default,
            attributes: %{
              number: true
            },
            slots: ["8"]
          },
          %Variation{
            id: :number_secondary,
            attributes: %{
              variant: "secondary",
              number: true
            },
            slots: ["8"]
          },
          %Variation{
            id: :number_outline,
            attributes: %{
              variant: "outline",
              number: true
            },
            slots: ["8"]
          },
          %Variation{
            id: :number_destructive,
            attributes: %{
              variant: "destructive",
              number: true
            },
            slots: ["8"]
          },
          %Variation{
            id: :number_success,
            attributes: %{
              variant: "success",
              number: true
            },
            slots: ["8"]
          }
        ]
      }
    ]
  end
end
