defmodule Storybook.CognitComponents.Label do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Label.label/1

  def variations do
    [
      %Variation{
        id: :label,
        attributes: %{
          "html-for" => "some_id"
        },
        slots: ["I'm a label"]
      },
      %Variation{
        id: :error,
        description: "Error",
        attributes: %{
          "html-for" => "some_id",
          class: "text-destructive"
        },
        slots: ["I'm a label"]
      }
    ]
  end
end
