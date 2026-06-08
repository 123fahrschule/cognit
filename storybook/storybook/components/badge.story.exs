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
          },
          %Variation{
            id: :color_warning,
            attributes: %{
              variant: "warning"
            },
            slots: ["Warning"]
          },
          %Variation{
            id: :color_info,
            attributes: %{
              variant: "info"
            },
            slots: ["Info"]
          }
        ]
      },
      %VariationGroup{
        id: :badge_soft_variants,
        description: "Soft tones: tinted background with solid color text.",
        variations: [
          %Variation{
            id: :soft_primary,
            attributes: %{variant: "primary-soft"},
            slots: ["Primary"]
          },
          %Variation{
            id: :soft_secondary,
            attributes: %{variant: "secondary-soft"},
            slots: ["Secondary"]
          },
          %Variation{
            id: :soft_destructive,
            attributes: %{variant: "destructive-soft"},
            slots: ["Destructive"]
          },
          %Variation{
            id: :soft_success,
            attributes: %{variant: "success-soft"},
            slots: ["Success"]
          },
          %Variation{
            id: :soft_warning,
            attributes: %{variant: "warning-soft"},
            slots: ["Warning"]
          },
          %Variation{
            id: :soft_info,
            attributes: %{variant: "info-soft"},
            slots: ["Info"]
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
          },
          %Variation{
            id: :number_warning,
            attributes: %{
              variant: "warning",
              number: true
            },
            slots: ["8"]
          }
        ]
      }
    ]
  end
end
