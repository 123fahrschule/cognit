defmodule Storybook.CognitComponents.Input do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias SaladStorybookWeb.CognitComponents

  def function, do: &Cognit.Input.input/1

  def template do
    """
    <.form :let={f} for={%{}} as={:story} class="w-full flex flex-col gap-8">
      <.psb-variation-group/>
    </.form>
    """
  end

  def variations do
    [
      %VariationGroup{
        id: :basic_inputs,
        variations:
          for type <- ~w(text number date color)a do
            %Variation{
              id: type,
              attributes: %{
                type: to_string(type),
                label: String.capitalize("#{type} input"),
                placeholder: String.capitalize("#{type} input")
              }
            }
          end
      }
    ]
  end
end
