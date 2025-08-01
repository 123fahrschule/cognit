defmodule Cognit.Components.FormField do
  use Cognit, :component

  import Cognit.Helpers

  import Cognit.Checkbox
  import Cognit.Form
  import Cognit.Input
  import Cognit.Label
  import Cognit.Switch
  import Cognit.Textarea

  @rest_attributes [
    "accept",
    "autocomplete",
    "capture",
    "cols",
    "form",
    "list",
    "max",
    "maxlength",
    "min",
    "minlength",
    "multiple",
    "pattern",
    "placeholder",
    "readonly",
    "required",
    "rows",
    "size",
    "step"
  ]

  attr(:class, :any, default: nil)
  attr(:id, :string)
  attr(:name, :string)
  attr(:value, :string)
  attr(:type, :string, default: "text")
  attr(:field, Phoenix.HTML.FormField)
  attr(:label, :string, default: nil)
  attr(:options, :list, default: [])
  attr(:multiple, :boolean, default: false)
  attr(:checked, :boolean, default: false)
  attr(:errors, :list, default: [])
  attr(:has_errors, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:form_field, :any, default: nil, doc: "internal assign for use in SaladUI components")
  attr(:rest, :global, include: @rest_attributes)

  def form_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:field, nil)
    |> assign(:form_field, field)
    |> assign_new(:id, fn -> field.id end)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_errors(field)
    |> form_field()
  end

  def form_field(%{type: "hidden"} = assigns) do
    ~H"""
    <input
      type="hidden"
      id={@id}
      name={@name}
      disabled={@disabled}
      value={Phoenix.HTML.Form.normalize_value(@type, @value)}
      {@rest}
    />
    """
  end

  def form_field(%{type: "select"} = assigns) do
    ~H"""
    <.form_item class={@class}>
      <.form_label :if={@label} error={@has_errors}>
        {@label}
      </.form_label>
      <div>
        <select
          id={@id}
          name={@name}
          value={@value}
          multiple={@multiple}
          class={[
            "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1",
            "relative"
          ]}
          {@rest}
        >
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </div>
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message :for={msg <- @errors} >
        {msg}
      </.form_message>
    </.form_item>
    """
  end

  def form_field(%{type: "textarea"} = assigns) do
    ~H"""
    <.form_item class={@class}>
      <.form_label :if={@label} error={@has_errors}>
        {@label}
      </.form_label>
      <.textarea id={@id} name={@name} value={@value} {@rest} />
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message :for={msg <- @errors} >
        {msg}
      </.form_message>
    </.form_item>

    """
  end

  def form_field(%{type: "switch"} = assigns) do
    ~H"""
    <div class={@class}>
      <div class="flex items-center gap-2">
      <.switch field={@form_field} />
      <.label :if={@label} for={@form_field.id <> "-input"}>
        {@label}
      </.label>
      </div>
      <.form_message :for={msg <- @errors} errors={@errors}>
        {msg}
      </.form_message>
    </div>
    """
  end

  def form_field(%{type: "checkbox"} = assigns) do
    ~H"""
    <div class={@class}>
      <div class={["flex items-center gap-2", @class]} >
        <.checkbox id={@id} name={@name} value={@value} {@rest}/>
        <.form_label :if={@label} for={@id} error={@has_errors}>
          {@label}
        </.form_label>
        <.form_message :for={msg <- @errors} >
          {msg}
        </.form_message>
      </div>
    </div>
    """
  end

  def form_field(assigns) do
    ~H"""
    <.form_item>
      <.form_label :if={@label} for={@id} error={@has_errors}>
        {@label}
      </.form_label>
      <.input type={@type} id={@id} name={@name} value={@value} {@rest} />
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message :for={msg <- @errors} errors={@errors}>
        {msg}
      </.form_message>
    </.form_item>
    """
  end

  defp assign_errors(assigns, field) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign(:has_errors, !Enum.empty?(errors))
  end
end
