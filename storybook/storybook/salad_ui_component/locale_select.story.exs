defmodule Storybook.CognitComponents.LocaleSelect do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.LocaleSelect.locale_select/1

  def variations do
    [
      %Variation{
        id: :default,
        description: "Locale select with country flags",
        template: """
        <div class="p-24 flex justify-center">
          <.locale_select />
        </div>
        """
      }
    ]
  end
end
