defmodule Storybook.CognitComponents.Button do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  # def function, do: &SaladStorybookWeb.CognitComponents.button/1
  def function, do: &Cognit.Button.button/1

  def imports, do: [{Cognit.Icon, [icon: 1]}]

  def variations do
    [
      %VariationGroup{
        id: :colors,
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
            id: :color_outline,
            attributes: %{
              variant: "outline"
            },
            slots: ["Outline"]
          },
          %Variation{
            id: :color_ghost,
            attributes: %{
              variant: "ghost"
            },
            slots: ["Ghost"]
          },
          %Variation{
            id: :color_link,
            attributes: %{
              variant: "link"
            },
            slots: ["Link"]
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Text size variations with `size` attribute.",
        variations: [
          %Variation{
            id: :size_default,
            slots: ["Default"]
          },
          %Variation{
            id: :size_sm,
            attributes: %{size: "sm"},
            slots: ["Small"]
          },
          %Variation{
            id: :size_lg,
            attributes: %{size: "lg"},
            slots: ["Large"]
          }
        ]
      },
      %Variation{
        id: :size_icon,
        template: """
        <.button size="icon">
          <.icon name="settings" size="xs" />
        </.button>
        """
      },
      %Variation{
        id: :size_icon_sm,
        template: """
        <.button size="icon-sm">
          <.icon name="settings" size="xs" />
        </.button>
        """
      },
      %Variation{
        id: :size_icon_lg,
        template: """
        <.button size="icon-lg">
          <.icon name="settings" size="xs" />
        </.button>
        """
      },
      %Variation{
        id: :custom_class,
        attributes: %{
          class: "rounded-full",
          variant: "destructive",
          size: "lg"
        },
        slots: ["Disabled"]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          disabled: true
        },
        slots: ["Disabled"]
      }
    ]
  end
end
