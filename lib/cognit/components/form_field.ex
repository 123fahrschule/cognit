defmodule Cognit.Components.FormField do
  use Cognit, :component

  import Cognit.Checkbox
  import Cognit.Combobox
  import Cognit.Form
  import Cognit.Input
  import Cognit.Label
  import Cognit.Switch
  import Cognit.Textarea
  import Cognit.Select

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

  attr :class, :any, default: nil
  attr :id, :string
  attr :name, :string
  attr :value, :string
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField
  attr :label, :string, default: nil
  attr :layout, :string, default: "vertical", values: ~w(vertical horizontal)
  attr :disabled, :boolean, default: false
  attr :options, :list, default: []
  attr :multiple, :boolean, default: false
  attr :checked, :boolean
  attr :errors, :list
  attr :has_errors, :boolean, default: false
  attr :description, :string, default: nil
  attr :form_field, :any, default: nil, doc: "internal assign for use in SaladUI components"
  attr :rest, :global, include: @rest_attributes

  slot :select_content do
    attr :id, :string, doc: "id of the options list (required for `phx-update`/viewport hooks)"
    attr :"phx-update", :string, doc: "e.g. `\"stream\"` for streamed options"

    attr :"phx-viewport-top", :any, doc: "event for loading earlier options on scroll"
    attr :"phx-viewport-bottom", :any, doc: "event for loading more options on scroll"
  end

  slot :leading,
    doc: "optional leading icon rendered inside the input (select, combobox, text input)"

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
    assigns = assign(assigns, :list_attrs, content_attrs(assigns.select_content))

    ~H"""
    <.field_wrapper layout={@layout} label={@label} class={@class}>
      <.select field={@form_field} multiple={@multiple}>
        <.select_trigger disabled={@disabled}>
          <:leading :if={@leading != []}>{render_slot(@leading)}</:leading>
          <.select_value placeholder={@rest[:placeholder] || pgettext("select placeholder", "Select")} />
        </.select_trigger>
        <.select_content {@list_attrs}>
          {render_slot(@select_content)}
        </.select_content>
      </.select>
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message errors={@errors} />
    </.field_wrapper>
    """
  end

  def form_field(%{type: "combobox"} = assigns) do
    assigns = assign(assigns, :list_attrs, content_attrs(assigns.select_content))

    ~H"""
    <.field_wrapper layout={@layout} label={@label} class={@class}>
      <.combobox field={@form_field} multiple={@multiple}>
        <.combobox_trigger disabled={@disabled}>
          <:leading :if={@leading != []}>{render_slot(@leading)}</:leading>
          <.combobox_value placeholder={
            @rest[:placeholder] || pgettext("select placeholder", "Select")
          } />
        </.combobox_trigger>
        <.combobox_content>
          <.combobox_input placeholder={pgettext("combobox", "Search...")} />
          <.combobox_empty>{pgettext("combobox", "No results found.")}</.combobox_empty>
          <.combobox_list {@list_attrs}>
            {render_slot(@select_content)}
          </.combobox_list>
        </.combobox_content>
      </.combobox>
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message errors={@errors} />
    </.field_wrapper>
    """
  end

  def form_field(%{type: "native-select"} = assigns) do
    ~H"""
    <.field_wrapper layout={@layout} label={@label} class={@class}>
      <div>
        <select
          id={@id}
          name={@name}
          value={@value}
          multiple={@multiple}
          aria-invalid={@has_errors && "true"}
          class={[
            "flex h-9 w-full items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm data-[placeholder]:text-muted-foreground focus:outline-none focus:border-ring focus:ring-[3px] focus:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-[3px] aria-invalid:ring-destructive/40 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1",
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
      <.form_message errors={@errors} />
    </.field_wrapper>
    """
  end

  def form_field(%{type: "textarea"} = assigns) do
    ~H"""
    <.field_wrapper layout={@layout} label={@label} class={@class}>
      <.textarea id={@id} name={@name} value={@value} aria-invalid={@has_errors && "true"} {@rest} />
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message errors={@errors} />
    </.field_wrapper>
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
      <.form_message errors={@errors} />
    </div>
    """
  end

  def form_field(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={@class}>
      <div class="flex items-center gap-2">
        <.checkbox
          id={@id}
          name={@name}
          value={@checked}
          aria-invalid={@has_errors && "true"}
          {@rest}
        />
        <.form_label :if={@label} for={@id}>
          {@label}
        </.form_label>
        <.form_message errors={@errors} />
      </div>
    </div>
    """
  end

  def form_field(assigns) do
    ~H"""
    <.field_wrapper layout={@layout} label={@label} for={@id} class={@class}>
      <.input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        disabled={@disabled}
        aria-invalid={@has_errors && "true"}
        {@rest}
      >
        <:leading :if={@leading != []}>{render_slot(@leading)}</:leading>
      </.input>
      <.form_description :if={@description}>
        {@description}
      </.form_description>
      <.form_message errors={@errors} />
    </.field_wrapper>
    """
  end

  defp field_wrapper(%{layout: "horizontal"} = assigns) do
    ~H"""
    <div class={classes(["grid grid-cols-2 items-start gap-3", @class])}>
      <.form_label :if={@label} for={assigns[:for]} class="h-9 flex items-center">
        {@label}
      </.form_label>
      <div class="flex flex-col gap-2">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp field_wrapper(assigns) do
    ~H"""
    <.form_item class={@class}>
      <.form_label :if={@label} for={assigns[:for]}>
        {@label}
      </.form_label>
      {render_slot(@inner_block)}
    </.form_item>
    """
  end

  # Attributes set on the `:select_content` slot (id, phx-update, viewport
  # bindings, ...) are forwarded onto the internal options list, so consumers can
  # stream options or wire up infinite scrolling.
  defp content_attrs([entry | _]), do: Map.drop(entry, [:__slot__, :inner_block])
  defp content_attrs(_), do: %{}

  defp assign_errors(assigns, field) do
    errors =
      cond do
        assigns[:errors] -> assigns.errors
        Phoenix.Component.used_input?(field) -> field.errors
        true -> []
      end

    assigns
    |> assign(:errors, errors)
    |> assign(:has_errors, errors != [])
  end
end
