defmodule Storybook.CognitComponents.ToggleGroup do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.ToggleGroup.toggle_group/1

  def imports,
    do: [
      {Cognit.ToggleGroup, [toggle_group_item: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :default_toggle_group,
        let: :builder,
        attributes: %{name: "style_group", type: "single", value: "bold"},
        slots: [
          """
          <.toggle_group_item value="bold" builder={builder} aria-label="Toggle bold">
          <.icon name="format_bold" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="italic" builder={builder} aria-label="Toggle italic">
          <.icon name="format_italic" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="underline" builder={builder} aria-label="Toggle underline">
          <.icon name="format_underlined" size="xs" />
          </.toggle_group_item>
          """
        ]
      },
      %Variation{
        id: :toggle_group_multiple,
        let: :builder,
        attributes: %{name: "multiple_group", multiple: true, value: ["bold"]},
        slots: [
          """
          <.toggle_group_item value="bold" builder={builder} aria-label="Toggle bold">
          <.icon name="format_bold" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="italic" builder={builder} aria-label="Toggle italic">
          <.icon name="format_italic" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="underline" builder={builder} aria-label="Toggle underline">
          <.icon name="format_underlined" size="xs" />
          </.toggle_group_item>
          """
        ]
      },
      %Variation{
        id: :toggle_group_outline,
        let: :builder,
        attributes: %{
          name: "multiple_group_outline",
          multiple: true,
          value: ["bold"],
          variant: "outline",
          size: "sm"
        },
        slots: [
          """
          <.toggle_group_item value="bold" builder={builder} aria-label="Toggle bold">
          <.icon name="format_bold" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="italic" builder={builder} aria-label="Toggle italic">
          <.icon name="format_italic" size="xs" />
          </.toggle_group_item>
          <.toggle_group_item value="underline" builder={builder} aria-label="Toggle underline">
          <.icon name="format_underlined" size="xs" />
          </.toggle_group_item>
          """
        ]
      }
    ]
  end
end
