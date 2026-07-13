defmodule Storybook.CognitComponents.ButtonGroup do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.ButtonGroup.button_group/1

  def imports, do: [{Cognit.Button, [button: 1]}, {Cognit.Icon, [icon: 1]}]

  def variations do
    [
      %Variation{
        id: :outline,
        template: """
        <.button_group>
          <.button variant="outline">Left</.button>
          <.button variant="outline">Center</.button>
          <.button variant="outline">Right</.button>
        </.button_group>
        """
      },
      %Variation{
        id: :default,
        template: """
        <.button_group>
          <.button>Left</.button>
          <.button>Center</.button>
          <.button>Right</.button>
        </.button_group>
        """
      },
      %Variation{
        id: :secondary,
        template: """
        <.button_group>
          <.button variant="secondary">Left</.button>
          <.button variant="secondary">Center</.button>
          <.button variant="secondary">Right</.button>
        </.button_group>
        """
      },
      %Variation{
        id: :sizes,
        template: """
        <div class="flex flex-col items-start gap-4">
          <.button_group>
            <.button variant="outline" size="sm">One</.button>
            <.button variant="outline" size="sm">Two</.button>
            <.button variant="outline" size="sm">Three</.button>
          </.button_group>
          <.button_group>
            <.button variant="outline">One</.button>
            <.button variant="outline">Two</.button>
            <.button variant="outline">Three</.button>
          </.button_group>
          <.button_group>
            <.button variant="outline" size="lg">One</.button>
            <.button variant="outline" size="lg">Two</.button>
            <.button variant="outline" size="lg">Three</.button>
          </.button_group>
        </div>
        """
      },
      %Variation{
        id: :with_icons,
        template: """
        <.button_group>
          <.button variant="outline" size="icon"><.icon name="chevron_left" label="Previous" /></.button>
          <.button variant="outline">Today</.button>
          <.button variant="outline" size="icon"><.icon name="chevron_right" label="Next" /></.button>
        </.button_group>
        """
      },
      %Variation{
        id: :vertical,
        template: """
        <.button_group orientation="vertical">
          <.button variant="outline">Top</.button>
          <.button variant="outline">Middle</.button>
          <.button variant="outline">Bottom</.button>
        </.button_group>
        """
      }
    ]
  end
end
