defmodule Storybook.CognitComponents.Form do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Button
  alias Cognit.Form
  alias Cognit.Input

  def function, do: &Form.form_item/1

  def imports,
    do: [
      {Input, [input: 1]},
      {Form, [form_label: 1, form_description: 1, form_message: 1]},
      {Button, [button: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :form,
        template: """
        <.form :let={f} for={%{}} as={:form} class="w-2/3 space-y-6">
          <% f = %{f | data: %{name: ""}} %>
          <.form_item>
            <.form_label error={not Enum.empty?(f[:name].errors)}>Username</.form_label>
            <.input field={f[:name]} type="text" placeholder="saladui" phx-debounce="500" required />
            <.form_description>
              This is your public display name.
            </.form_description>
            <.form_message field={f[:name]} />
          </.form_item>
          <.button type="submit">Submit</.button>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_with_error,
        description: "Field error msgids are translated via Cognit.Gettext (\"errors\" domain) by default.",
        template: """
        <.form for={%{}} as={:form_with_error} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{name: ""}, errors: [name: {"can't be blank", []}]} %>
            <.form_item>
              <.form_label error={not Enum.empty?(f[:name].errors)}>Username</.form_label>
              <.input field={f[:name]} type="text" placeholder="saladui" phx-debounce="500" required />
              <.form_description>
                This is your public display name.
              </.form_description>
              <.form_message field={f[:name]} />
            </.form_item>
           <.button type="submit">Submit</.button>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_with_interpolated_error,
        description: "Errors with %{key} placeholders (e.g. count) are interpolated through Gettext bindings.",
        template: """
        <.form for={%{}} as={:form_interpolated} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{name: ""}, errors: [name: {"should be at least %{count} character(s)", count: 3}]} %>
            <.form_item>
              <.form_label error={not Enum.empty?(f[:name].errors)}>Username</.form_label>
              <.input field={f[:name]} type="text" phx-debounce="500" />
              <.form_message field={f[:name]} />
            </.form_item>
           <.button type="submit">Submit</.button>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_with_german_locale,
        description: "Switch process locale to \"de\" — Cognit.Gettext returns the German translation for the msgid.",
        template: """
        <% Gettext.put_locale(Cognit.Gettext, "de") %>
        <.form for={%{}} as={:form_de} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{name: ""}, errors: [name: {"can't be blank", []}, email: {"should be at least %{count} character(s)", count: 8}]} %>
            <.form_item>
              <.form_label error={true}>Benutzername</.form_label>
              <.input field={f[:name]} type="text" />
              <.form_message field={f[:name]} />
            </.form_item>
            <.form_item>
              <.form_label error={true}>E-Mail</.form_label>
              <.input field={f[:email]} type="email" />
              <.form_message field={f[:email]} />
            </.form_item>
           <.button type="submit">Absenden</.button>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_with_translation_disabled,
        description: "Pass translate={false} to bypass Cognit.Gettext and only interpolate the raw msgid.",
        template: """
        <.form for={%{}} as={:form_no_translate} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{name: ""}, errors: [name: {"should be at least %{count} character(s)", count: 3}]} %>
            <.form_item>
              <.form_label error={not Enum.empty?(f[:name].errors)}>Username</.form_label>
              <.input field={f[:name]} type="text" phx-debounce="500" />
              <.form_message field={f[:name]} translate={false} />
            </.form_item>
           <.button type="submit">Submit</.button>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_message_with_raw_errors,
        description: "Pass raw `{msgid, opts}` tuples directly via `errors=` — they're translated through Cognit.Gettext.",
        template: """
        <.form for={%{}} as={:form_raw_errors} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{name: ""}, errors: [name: {"can't be blank", []}, name: {"should be at least %{count} character(s)", count: 3}]} %>
            <.form_item>
              <.form_label error={true}>Username</.form_label>
              <.input field={f[:name]} type="text" />
              <.form_message errors={f[:name].errors} />
            </.form_item>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_message_with_string_errors,
        description: "Pre-resolved strings can also be passed via `errors=` — they're displayed as-is.",
        template: """
        <.form for={%{}} as={:form_string_errors} :let={f} class="w-2/3 space-y-6">
            <.form_item>
              <.form_label error={true}>Username</.form_label>
              <.input field={f[:name]} type="text" />
              <.form_message errors={["Already taken", "Reserved word"]} />
            </.form_item>
        </.form>
        """,
        attributes: %{}
      },
      %Variation{
        id: :form_with_custom_message,
        description: "Pass children to override the field's error message with custom content.",
        template: """
        <.form for={%{}} as={:form_custom_message} :let={f} class="w-2/3 space-y-6">
            <% f = %{f | data: %{email: ""}, errors: [email: {"is invalid", []}]} %>
            <.form_item>
              <.form_label error={true}>Email</.form_label>
              <.input field={f[:email]} type="email" />
              <.form_message field={f[:email]}>
                Please enter a valid work email address.
              </.form_message>
            </.form_item>
           <.button type="submit">Submit</.button>
        </.form>
        """,
        attributes: %{}
      }
    ]
  end
end
