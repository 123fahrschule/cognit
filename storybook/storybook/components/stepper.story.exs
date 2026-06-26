defmodule Storybook.CognitComponents.Stepper do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Stepper

  def function, do: &Stepper.stepper/1

  def layout, do: :one_column

  def imports, do: [{Stepper, [step: 1]}]

  def variations do
    [
      %Variation{
        id: :default,
        description: "Three steps: completed, current, and upcoming",
        template: """
        <.stepper>
          <.step state="completed" number="1">Configuration & Schedule</.step>
          <.step state="current" number="2">Location & Pricing</.step>
          <.step number="3">Capacity & Resources</.step>
        </.stepper>
        """,
        attributes: %{}
      },
      %Variation{
        id: :default_state,
        description: "Default (upcoming) step",
        template: """
        <.stepper>
          <.step number="1">Default</.step>
        </.stepper>
        """,
        attributes: %{}
      },
      %Variation{
        id: :current_state,
        description: "Current (active) step",
        template: """
        <.stepper>
          <.step state="current" number="2">Current</.step>
        </.stepper>
        """,
        attributes: %{}
      },
      %Variation{
        id: :completed_state,
        description: "Completed step",
        template: """
        <.stepper>
          <.step state="completed" number="3">Completed</.step>
        </.stepper>
        """,
        attributes: %{}
      },
      %Variation{
        id: :clickable,
        description: "Interactive steps show hover styling (only when a click callback is set)",
        template: """
        <.stepper>
          <.step state="completed" number="1" on_click={JS.push("step")}>Configuration & Schedule</.step>
          <.step state="current" number="2" on_click={JS.push("step")}>Location & Pricing</.step>
          <.step number="3" on_click={JS.push("step")}>Capacity & Resources</.step>
        </.stepper>
        """,
        attributes: %{}
      }
    ]
  end
end
