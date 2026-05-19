defmodule Storybook.CognitComponents.Input do
  @moduledoc false
  use PhoenixStorybook.Story, :component

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
        id: :text_inputs,
        description: "Text-based input types.",
        variations:
          for type <- ~w(text email password number tel url) do
            %Variation{
              id: String.to_atom(type),
              attributes: %{
                type: type,
                placeholder: String.capitalize("#{type} input")
              }
            }
          end
      },
      %VariationGroup{
        id: :date_time_inputs,
        description: "Date and time input types.",
        variations:
          for type <- ~w(date datetime-local time month week) do
            %Variation{
              id: type |> String.replace("-", "_") |> String.to_atom(),
              attributes: %{
                type: type
              }
            }
          end
      },
      %VariationGroup{
        id: :file_input,
        description: "File picker input.",
        variations: [
          %Variation{
            id: :file,
            attributes: %{type: "file"}
          },
          %Variation{
            id: :file_accept_images,
            attributes: %{type: "file", accept: "image/*"}
          }
        ]
      },
      %VariationGroup{
        id: :states,
        description: "Common input states.",
        variations: [
          %Variation{
            id: :with_value,
            attributes: %{value: "Pre-filled value"}
          },
          %Variation{
            id: :disabled,
            attributes: %{disabled: true, placeholder: "Disabled input"}
          },
          %Variation{
            id: :readonly,
            attributes: %{readonly: true, value: "Read-only value"}
          },
          %Variation{
            id: :required,
            attributes: %{required: true, placeholder: "Required input"}
          }
        ]
      }
    ]
  end
end
