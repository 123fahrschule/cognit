defmodule Storybook.CognitComponents.Switch do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Switch.switch/1

  def variations do
    [
      %VariationGroup{
        id: :basic,
        variations: [
          %Variation{
            id: :default,
            attributes: %{
              id: "switch-default"
            }
          },
          %Variation{
            id: :checked,
            attributes: %{
              id: "switch-checked",
              checked: true
            }
          },
          %Variation{
            id: :disabled,
            attributes: %{
              id: "switch-disabled",
              disabled: true
            }
          },
          %Variation{
            id: :checked_disabled,
            attributes: %{
              id: "switch-checked-disabled",
              checked: true,
              disabled: true
            }
          }
        ]
      },
      %Variation{
        id: :with_label,
        template: """
        <div class="flex items-center space-x-2">
          <.psb-variation />
          <label for="switch-with-label">Click me</label>
        </div>
        """,
        attributes: %{
          id: "switch-with-label",
          checked: true,
          "on-checked-changed": "on_checked"
        }
      },
      %Variation{
        id: :error,
        description: "Error",
        template: """
          <.form for={%{}} as={:story} :let={f} class="w-full">
            <% f = %{f | params: %{"field" => ""}, errors: [field: {"must be enabled", []}]} %>
            <.psb-variation id="switch-error" field={f[:field]} />
          </.form>
        """
      }
    ]
  end
end
