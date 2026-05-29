defmodule Storybook.CognitComponents.Combobox do
  @moduledoc """
  Storybook documentation for the Cognit Combobox component.

  A searchable select with single and multiple selection modes.
  """
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Combobox.combobox/1

  def imports,
    do: [
      {Cognit.Combobox,
       [
         combobox_trigger: 1,
         combobox_value: 1,
         combobox_content: 1,
         combobox_input: 1,
         combobox_empty: 1,
         combobox_list: 1,
         combobox_group: 1,
         combobox_label: 1,
         combobox_item: 1,
         combobox_separator: 1
       ]}
    ]

  def description do
    """
    The Combobox component combines a trigger, a popover with a search input,
    and a filtered list of items. Supports single and multiple selection,
    form field integration, and client- or server-side filtering.
    """
  end

  def variations do
    [
      %Variation{
        id: :default_combobox,
        description: "Default single-select combobox with client-side filtering",
        attributes: %{
          id: "fruit-combobox",
          name: "fruit",
          "use-portal": false
        },
        slots: [
          """
            <.combobox_trigger class="w-full">
              <.combobox_value placeholder="Select a fruit" />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search fruit..." />
              <.combobox_empty>No fruit found.</.combobox_empty>
              <.combobox_list>
                <.combobox_group>
                  <.combobox_label>Fruits</.combobox_label>
                  <.combobox_item value="apple">Apple</.combobox_item>
                  <.combobox_item value="banana">Banana</.combobox_item>
                  <.combobox_item value="blueberry">Blueberry</.combobox_item>
                  <.combobox_item value="grapes" disabled>Grapes</.combobox_item>
                  <.combobox_item value="orange">Orange</.combobox_item>
                  <.combobox_item value="pineapple">Pineapple</.combobox_item>
                  <.combobox_item value="strawberry">Strawberry</.combobox_item>
                  <.combobox_item value="watermelon">Watermelon</.combobox_item>
                </.combobox_group>
              </.combobox_list>
            </.combobox_content>
          """
        ]
      },
      %Variation{
        id: :with_default_value,
        description: "Combobox with a pre-selected value",
        attributes: %{
          id: "preset-combobox",
          name: "fruit",
          value: "banana",
          "use-portal": false
        },
        slots: [
          """
            <.combobox_trigger class="w-full">
              <.combobox_value />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search..." />
              <.combobox_empty>No results.</.combobox_empty>
              <.combobox_list>
                <.combobox_item value="apple">Apple</.combobox_item>
                <.combobox_item value="banana">Banana</.combobox_item>
                <.combobox_item value="orange">Orange</.combobox_item>
              </.combobox_list>
            </.combobox_content>
          """
        ]
      },
      %Variation{
        id: :multiple_combobox,
        description: "Combobox allowing multiple selections",
        attributes: %{
          id: "multi-combobox",
          name: "fruits[]",
          multiple: true,
          "use-portal": false
        },
        slots: [
          """
            <.combobox_trigger class="w-full">
              <.combobox_value placeholder="Select fruits" />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search fruits..." />
              <.combobox_empty>No fruit found.</.combobox_empty>
              <.combobox_list>
                <.combobox_group>
                  <.combobox_label>Fruits</.combobox_label>
                  <.combobox_item value="apple">Apple</.combobox_item>
                  <.combobox_item value="banana">Banana</.combobox_item>
                  <.combobox_item value="blueberry">Blueberry</.combobox_item>
                  <.combobox_item value="orange">Orange</.combobox_item>
                  <.combobox_item value="pineapple">Pineapple</.combobox_item>
                </.combobox_group>
              </.combobox_list>
            </.combobox_content>
          """
        ]
      },
      %Variation{
        id: :selectable_groups,
        description:
          "Multiple-select with `selectable` groups. Click a group heading to " <>
            "toggle all of its items at once (tri-state checkbox).",
        attributes: %{
          id: "grouped-combobox",
          name: "stack[]",
          multiple: true,
          "use-portal": false
        },
        slots: [
          """
            <.combobox_trigger class="w-full">
              <.combobox_value placeholder="Select your stack" />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search..." />
              <.combobox_empty>No match.</.combobox_empty>
              <.combobox_list>
                <.combobox_group selectable label="Backend">
                  <.combobox_item value="elixir">Elixir</.combobox_item>
                  <.combobox_item value="phoenix">Phoenix</.combobox_item>
                  <.combobox_item value="ecto">Ecto</.combobox_item>
                </.combobox_group>
                <.combobox_separator />
                <.combobox_group selectable label="Frontend">
                  <.combobox_item value="liveview">LiveView</.combobox_item>
                  <.combobox_item value="react">React</.combobox_item>
                  <.combobox_item value="tailwind">Tailwind CSS</.combobox_item>
                </.combobox_group>
              </.combobox_list>
            </.combobox_content>
          """
        ]
      },
      %Variation{
        id: :with_field,
        description:
          "Bound to a form field via `field={@form[:fruit]}`. " <>
            "See the Examples for a full `to_form/1` round-trip with validation.",
        template: """
        <.form :let={f} for={%{"fruit" => "banana"}} as={:profile} class="w-full max-w-sm">
          <.psb-variation field={f[:fruit]} />
        </.form>
        """,
        slots: [
          """
            <.combobox_trigger class="w-full min-w-64">
              <.combobox_value placeholder="Choose a fruit" />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search fruit..." />
              <.combobox_empty>No fruit found.</.combobox_empty>
              <.combobox_list>
                <.combobox_item value="apple">Apple</.combobox_item>
                <.combobox_item value="banana">Banana</.combobox_item>
                <.combobox_item value="blueberry">Blueberry</.combobox_item>
              </.combobox_list>
            </.combobox_content>
          """
        ]
      }
    ]
  end
end
