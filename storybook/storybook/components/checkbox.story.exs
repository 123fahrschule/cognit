defmodule Storybook.CognitComponents.Checkbox do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Checkbox.checkbox/1
  def imports, do: [{Cognit.Label, [{:label, 1}]}]

  def variations do
    [
      %Variation{
        id: :checkbox_checked,
        template: """
        <div class="flex items-center space-x-2">
        <.checkbox id="checked" value={true}/>
        <.label for="checked">I'm a label</.label>
        </div>
        """,
        attributes: %{
          value: true
        }
      },
      %Variation{
        id: :checkbox,
        template: """
        <div class="flex items-center space-x-2">
        <.checkbox id="unchecked"/>
        <.label for="unchecked">I'm a label</.label>
        </div>
        """
      }
    ]
  end
end
