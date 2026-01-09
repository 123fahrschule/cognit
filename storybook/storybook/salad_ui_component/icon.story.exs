defmodule Storybook.SaladUIComponent.Icon do
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Icon.icon/1

  def description do
    """
    Icon component using Material Symbols font with accessibility support.

    Search and browse available icons at: [Google Fonts Icons](https://fonts.google.com/icons)

    ## Accessibility

    - Use `decorative={true}` for icons next to text
    - Use `label` attribute for standalone icons (especially in icon-only buttons)
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default outlined icon",
        attributes: %{
          name: "home"
        }
      },
      %Variation{
        id: :filled,
        description: "Filled icon variant",
        attributes: %{
          name: "home",
          filled: true
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Icon sizes",
        variations: [
          %Variation{
            id: :size_xs,
            description: "Extra small (16px)",
            attributes: %{name: "star", size: "xs"}
          },
          %Variation{
            id: :size_sm,
            description: "Small (20px)",
            attributes: %{name: "star", size: "sm"}
          },
          %Variation{
            id: :size_md,
            description: "Medium (24px, default)",
            attributes: %{name: "star", size: "md"}
          },
          %Variation{
            id: :size_lg,
            description: "Large (32px)",
            attributes: %{name: "star", size: "lg"}
          },
          %Variation{
            id: :size_xl,
            description: "Extra large (40px)",
            attributes: %{name: "star", size: "xl"}
          },
          %Variation{
            id: :size_custom,
            description: "Custom size (text-4xl)",
            attributes: %{name: "star", size: "text-4xl"}
          }
        ]
      },
      %Variation{
        id: :custom_styling,
        description: "Custom size and color",
        attributes: %{
          name: "favorite",
          filled: true,
          size: "xl",
          class: "text-red-500"
        }
      },
      %VariationGroup{
        id: :accessibility,
        description: "Accessibility examples",
        variations: [
          %Variation{
            id: :decorative,
            description: "Decorative icon (hidden from screen readers)",
            attributes: %{name: "check", decorative: true}
          },
          %Variation{
            id: :with_label,
            description: "Icon with accessible label",
            attributes: %{name: "close", label: "Close dialog"}
          },
          %Variation{
            id: :standalone_delete,
            description: "Icon-only button (with label)",
            attributes: %{name: "delete", label: "Delete item", size: "sm", class: "text-destructive"}
          }
        ]
      },
      %VariationGroup{
        id: :common_icons,
        description: "Common icon examples (outlined)",
        variations: [
          %Variation{
            id: :check,
            attributes: %{name: "check"}
          },
          %Variation{
            id: :close,
            attributes: %{name: "close"}
          },
          %Variation{
            id: :settings,
            attributes: %{name: "settings"}
          },
          %Variation{
            id: :search,
            attributes: %{name: "search"}
          },
          %Variation{
            id: :menu,
            attributes: %{name: "menu"}
          },
          %Variation{
            id: :info,
            attributes: %{name: "info"}
          },
          %Variation{
            id: :warning,
            attributes: %{name: "warning"}
          },
          %Variation{
            id: :error,
            attributes: %{name: "error"}
          }
        ]
      },
      %VariationGroup{
        id: :common_icons_filled,
        description: "Common icon examples (filled)",
        variations: [
          %Variation{
            id: :check_filled,
            attributes: %{name: "check", filled: true}
          },
          %Variation{
            id: :close_filled,
            attributes: %{name: "close", filled: true}
          },
          %Variation{
            id: :settings_filled,
            attributes: %{name: "settings", filled: true}
          },
          %Variation{
            id: :search_filled,
            attributes: %{name: "search", filled: true}
          },
          %Variation{
            id: :menu_filled,
            attributes: %{name: "menu", filled: true}
          },
          %Variation{
            id: :info_filled,
            attributes: %{name: "info", filled: true}
          },
          %Variation{
            id: :warning_filled,
            attributes: %{name: "warning", filled: true}
          },
          %Variation{
            id: :error_filled,
            attributes: %{name: "error", filled: true}
          }
        ]
      }
    ]
  end
end
