defmodule Storybook.CognitComponents.FormField do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.FormField.form_field/1

  def imports,
    do: [
      {Cognit.Select, [select_item: 1]},
      {Cognit.Combobox, [combobox_item: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  # Each variation wraps the field in a `<.form :let={f}>` so it binds through a
  # real FormField (clean `field={f[:x]}` in the code panel, errors handled for us).
  def variations do
    [
      %Variation{
        id: :text,
        description: "Label plus a text input — the default field type.",
        template: """
        <.form :let={f} for={%{"name" => "Ada Lovelace"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:name]} label="Full name" placeholder="Jane Doe" />
        </.form>
        """
      },
      %Variation{
        id: :with_description,
        description: "Helper text rendered below the input.",
        template: """
        <.form :let={f} for={%{"email" => ""}} as={:demo} class="w-full max-w-sm">
          <.psb-variation
            field={f[:email]}
            type="email"
            label="Email"
            placeholder="jane@example.com"
            description="We'll never share your email."
          />
        </.form>
        """
      },
      %Variation{
        id: :with_errors,
        description: "Validation message shown when the field has errors.",
        template: """
        <.form :let={f} for={%{}} as={:demo} class="w-full max-w-sm">
          <% f = %{f | params: %{"email" => "not-an-email"}, errors: [email: {"must be a valid email address", []}]} %>
          <.psb-variation field={f[:email]} type="email" label="Email" />
        </.form>
        """
      },
      %Variation{
        id: :disabled,
        description: "Non-editable field.",
        template: """
        <.form :let={f} for={%{"name" => "Read only"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:name]} label="Full name" disabled />
        </.form>
        """
      },
      %Variation{
        id: :horizontal,
        description: "Label and control side by side via layout=\"horizontal\".",
        template: """
        <.form :let={f} for={%{"name" => ""}} as={:demo} class="w-full max-w-md">
          <.psb-variation field={f[:name]} label="Full name" layout="horizontal" placeholder="Jane Doe" />
        </.form>
        """
      },
      %Variation{
        id: :leading_icon,
        description: "Icon rendered inside the input via the leading slot.",
        attributes: %{label: "Search", placeholder: "Search…"},
        slots: ["<:leading><.icon name=\"search\" size=\"xs\" decorative /></:leading>"],
        template: """
        <.form :let={f} for={%{"query" => ""}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:query]} />
        </.form>
        """
      },
      %Variation{
        id: :textarea,
        description: "Multi-line text via type=\"textarea\".",
        template: """
        <.form :let={f} for={%{"bio" => ""}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:bio]} type="textarea" label="Bio" placeholder="Tell us about yourself" rows="4" />
        </.form>
        """
      },
      %Variation{
        id: :native_select,
        description: "Plain HTML select via type=\"native-select\" and options.",
        attributes: %{
          type: "native-select",
          label: "Role",
          options: [{"Select…", ""}, {"Junior", "junior"}, {"Senior", "senior"}, {"Lead", "lead"}]
        },
        template: """
        <.form :let={f} for={%{"role" => "senior"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:role]} />
        </.form>
        """
      },
      %Variation{
        id: :select,
        description: "Styled select via type=\"select\"; items passed through the select_content slot.",
        attributes: %{type: "select", label: "Plan"},
        slots: [
          """
          <:select_content>
            <.select_item value="free">Free</.select_item>
            <.select_item value="pro">Pro</.select_item>
            <.select_item value="enterprise">Enterprise</.select_item>
          </:select_content>
          """
        ],
        template: """
        <.form :let={f} for={%{"plan" => "pro"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:plan]} />
        </.form>
        """
      },
      %Variation{
        id: :combobox,
        description: "Searchable select via type=\"combobox\".",
        attributes: %{type: "combobox", label: "Country"},
        slots: [
          """
          <:select_content>
            <.combobox_item value="de">Germany</.combobox_item>
            <.combobox_item value="fr">France</.combobox_item>
            <.combobox_item value="es">Spain</.combobox_item>
            <.combobox_item value="it">Italy</.combobox_item>
          </:select_content>
          """
        ],
        template: """
        <.form :let={f} for={%{"country" => "de"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:country]} />
        </.form>
        """
      },
      %Variation{
        id: :switch,
        description: "Boolean toggle via type=\"switch\" with an inline label.",
        attributes: %{type: "switch", label: "Enable notifications"},
        template: """
        <.form :let={f} for={%{"notify" => "true"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:notify]} />
        </.form>
        """
      },
      %Variation{
        id: :checkbox,
        description: "Boolean checkbox via type=\"checkbox\" with an inline label.",
        attributes: %{type: "checkbox", label: "I accept the terms"},
        template: """
        <.form :let={f} for={%{"terms" => "true"}} as={:demo} class="w-full max-w-sm">
          <.psb-variation field={f[:terms]} />
        </.form>
        """
      }
    ]
  end
end
