defmodule Storybook.CognitComponents.Textarea do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Textarea.textarea/1

  def variations do
    [
      %Variation{
        id: :textarea,
        attributes: %{
          name: "my-textarea",
          placeholder: "Type your message here"
        }
      },
      %Variation{
        id: :textarea_disabled,
        attributes: %{
          name: "my-textarea",
          disabled: true,
          placeholder: "I'm disabled"
        }
      },
      %Variation{
        id: :error,
        description: "Error",
        template: """
          <.form for={%{}} as={:story} :let={f} class="w-full">
            <% f = %{f | params: %{"field" => ""}, errors: [field: {"can't be blank", []}]} %>
            <.psb-variation field={f[:field]} placeholder="Placeholder" />
          </.form>
        """
      }
    ]
  end
end
