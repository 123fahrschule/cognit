defmodule Cognit.Helpers do
  @moduledoc false
  use Phoenix.Component

  import Phoenix.Component

  @doc """
  Prepare input assigns for use in a form. Extract required attribute from the Form.Field struct and update current assigns.
  """
  def prepare_assign(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns[:id] || field.id)
    |> assign(:errors, field_errors(field))
    |> assign(
      :name,
      assigns[:name] || if(assigns[:multiple], do: field.name <> "[]", else: field.name)
    )
    |> assign(:value, assigns[:value] || field.value)
    |> prepare_assign()
  end

  # use default value if value is not provided or empty
  def prepare_assign(assigns) do
    value =
      if assigns[:value] in [nil, []] do
        assigns[:"default-value"]
      else
        assigns[:value]
      end

    assign(assigns, value: value)
  end

  @doc """
  Set `aria-invalid="true"` on a `:global` rest map when the given errors list is non-empty.
  Respects an explicit caller-supplied `aria-invalid`.
  """
  def maybe_set_aria_invalid(rest, [_ | _]),
    do: Map.put_new(rest, :"aria-invalid", "true")

  def maybe_set_aria_invalid(rest, _), do: rest

  @doc """
  Return the list of error messages from a form field.

  Returns `[]` for fields the user has not interacted with yet
  (`Phoenix.Component.used_input?/1`), so validation errors only surface once a
  field is touched or the form is submitted.

  ## Options

    * `:translate` (boolean, default `true`) — when `false`, skips
      `translate_error/1` and only interpolates `%{key}` placeholders in the
      raw msgid. Useful when the caller has already translated errors
      upstream or wants to bypass Cognit's default translation entirely.
  """
  def field_errors(field, opts \\ [])

  def field_errors(%Phoenix.HTML.FormField{} = field, opts) do
    cond do
      not Phoenix.Component.used_input?(field) ->
        []

      Keyword.get(opts, :translate, true) ->
        Enum.map(field.errors, &translate_error/1)

      true ->
        Enum.map(field.errors, fn {msg, o} -> interpolate(msg, o) end)
    end
  end

  def field_errors(_, _), do: []

  @doc """
  Return `true` when a touched field (`Phoenix.Component.used_input?/1`) has errors.
  """
  def has_error?(%Phoenix.HTML.FormField{} = field) do
    Phoenix.Component.used_input?(field) and not Enum.empty?(field.errors)
  end

  def has_error?(_field), do: false

  # Helper function to add event mappings
  def add_event_mapping(map \\ %{}, assigns, event, key) do
    if assigns[key] do
      Map.put(map, event, assigns[key])
    else
      map
    end
  end

  # Helper to encode data to JSON
  def json(data) do
    Phoenix.json_library().encode!(data)
  end

  # normalize_integer
  def normalize_integer(value) when is_integer(value), do: value

  def normalize_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, _} -> integer
      _ -> nil
    end
  end

  def normalize_integer(_), do: nil

  def normalize_boolean(value) do
    case value do
      "true" -> true
      "false" -> false
      true -> true
      false -> false
      _ -> false
    end
  end

  @doc """
  Normalize id to be used in HTML id attribute
  It will replace all non-alphanumeric characters with `-` and downcase the string
  """
  def id(id) do
    id
    |> String.replace(~r/[^a-zA-Z0-9]/, "-")
    |> String.downcase()
  end

  @variants %{
    variant: %{
      "default" => "bg-primary text-primary-foreground shadow-2xs hover:bg-primary/90",
      "destructive" =>
        "bg-destructive text-destructive-foreground shadow-2xs hover:bg-destructive/90",
      "success" => "bg-success text-success-foreground shadow-2xs hover:bg-success/90",
      "warning" => "bg-warning text-warning-foreground shadow-2xs hover:bg-warning/90",
      "outline" => "border border-input bg-input-30 text-foreground shadow-2xs hover:bg-input-50",
      "secondary" => "bg-secondary text-secondary-foreground shadow-2xs hover:bg-secondary/80",
      "ghost" => "text-foreground hover:bg-accent hover:text-accent-foreground",
      "link" => "text-primary underline-offset-4 hover:underline"
    },
    size: %{
      "default" => "h-9 px-4 py-2",
      "sm" => "h-8 px-3 text-xs",
      "lg" => "h-10 px-6",
      "icon" => "h-9 w-9",
      "icon-sm" => "h-8 w-8",
      "icon-lg" => "h-10 w-10"
    }
  }

  @default_variants %{
    variant: "default",
    size: "default"
  }

  @doc """
  Reuseable button variant helper. Support 2 variant
  - size: `default|sm|lg|icon|icon-sm|icon-lg`
  - variant: `default|destructive|success|warning|outline|secondary|ghost|link`
  """
  def button_variant(props \\ %{}) do
    variants = Map.take(props, ~w(variant size)a)
    variants = Map.merge(@default_variants, variants)

    variation_classes = Enum.map_join(variants, " ", fn {key, value} -> @variants[key][value] end)

    shared_classes =
      "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 active:opacity-60 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 [&_.icon]:pointer-events-none [&_.icon]:text-[16px] [&_.icon]:leading-none [&_.icon]:shrink-0"

    "#{shared_classes} #{variation_classes}"
  end

  @doc """
  Common function for building variant

  ## Examples

  ```elixir
  config =
  %{
    variants: %{
      variant: %{
        default: "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
        outline:
          "bg-background shadow-[0_0_0_1px_hsl(var(--sidebar-border))] hover:bg-sidebar-accent hover:text-sidebar-accent-foreground hover:shadow-[0_0_0_1px_hsl(var(--sidebar-accent))]",
      },
      size: %{
        default: "h-8 text-sm",
        sm: "h-7 text-xs",
        lg: "h-12 text-sm group-data-[collapsible=icon]:!p-0",
      },
    },
    default_variants: %{
      variant: "default",
      size: "default",
    },
  }

  class_input = %{variant: "outline", size: "lg"}
  variant_class(config, class_input)
  ```

  """
  def variant_class(config, class_input) do
    variants = Map.get(config, :variants, %{})
    default_variants = Map.get(config, :default_variants, %{})

    variants
    |> Map.keys()
    |> Enum.map(fn variant_key ->
      # Get the variant value from input or use default
      variant_value =
        Map.get(class_input, variant_key) ||
          Map.get(default_variants, variant_key)

      # Get the variant options map
      variant_options = Map.get(variants, variant_key, %{})

      # Get the CSS classes for this variant value
      Map.get(variant_options, String.to_existing_atom(variant_value))
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  This function build css style string from map of css style

  ## Examples

  ```elixir
  css_style = %{
    "background-color": "red",
    "color": "white",
    "font-size": "16px",
  }

  style(css_style)

  # => "background-color: red; color: white; font-size: 16px;"
  ```
  """
  def style(items) when is_list(items) do
    {acc_map, acc_list} =
      Enum.reduce(items, {%{}, []}, fn item, {acc_map, acc_list} ->
        cond do
          is_map(item) ->
            {Map.merge(acc_map, item), acc_list}

          is_binary(item) ->
            {acc_map, [item | acc_list]}

          true ->
            {acc_map, [item | acc_list]}
        end
      end)

    style = Enum.map_join(acc_map, "; ", fn {k, v} -> "#{k}: #{v}" end) <> ";"
    Enum.join([style | acc_list], "; ")
  end

  @doc """
  This function build js script to invoke JS stored in given attribute.
  Similar to JS.exec/2 but this function target the nearest ancestor element.

  ## Examples

  ```heex
  <button click={exec_closest("phx-hide-sheet", ".ancestor_class")}>
    Close
  </button>
  ```
  """
  def exec_closest(attribute, ancestor_selector) do
    """
    var el = this.closest("#{ancestor_selector}"); liveSocket.execJS(el, el.getAttribute("#{attribute}"));
    """
  end

  @doc """
  This component is used to render dynamic tag based on the `tag` attribute. `tag` attribute can be a string or a function component.

  This is just a wrapper around `dynamic_tag` function from Phoenix LiveView which only support string tag.

  ## Examples

  ```heex
  <.dynamic tag={@tag} class="bg-primary text-primary-foreground">
     Hello World
  </.dynamic>
  ```
  """
  def dynamic(%{tag: name} = assigns) when is_function(name, 1) do
    assigns = Map.delete(assigns, :tag)
    name.(assigns)
  end

  def dynamic(assigns) do
    name = assigns[:tag] || "div"

    assigns =
      assigns
      |> Map.delete(:tag)
      |> assign(:tag_name, name)
      |> assign(:name, name)

    dynamic_tag(assigns)
  end

  @doc """
  This component mimic behavior of `asChild` attribute from shadcn/ui.
  It works by passing all attribute from `as_child` tag to `tag` function component, add pass `child` attribute to the `as` attribute of the `tag` function component.

  The `tag` function component should accept `as_tag` attribute to render the child component.

  ## Examples

  ```heex
  <.as_child tag={&dropdown_menu_trigger/1} child={&sidebar_menu_button/1} class="bg-primary text-primary-foreground">
     Hello World
  </.as_child>
  ```

  Normally this can be archieved by using `dropdown_menu_trigger` component directly but this will fire copile warning.

  ```heex
  <.dropdown_menu_trigger as={&sidebar_menu_button/1} class="bg-primary text-primary-foreground">
     Hello World
  </.dropdown_menu_trigger>
  """
  def as_child(%{tag: tag, child: child_tag} = assigns) when is_function(tag, 1) do
    assigns
    |> Map.drop([:tag, :child])
    |> assign(:as, child_tag)
    |> tag.()
  end

  @doc """
  Translate a changeset error tuple into a localized string.

  Lookup order:

    1. `Cognit.Gettext` "errors" domain — ships translations for the common
       Ecto changeset errors out of the box. Can be disabled with:

           config :cognit, :use_default_error_translator, false

    2. Consumer-configured translator (when the Cognit backend has no
       translation for the given msgid, or when the default lookup is
       disabled). Configure with:

           config :cognit, :error_translator_function, {MyAppWeb.CoreComponents, :translate_error}

    3. Manual `%{key}` interpolation of the original msgid as a last resort.
  """
  def translate_error({msg, opts}) do
    result =
      if use_default_translator?() do
        cognit_translate({msg, opts})
      else
        :missing
      end

    case result do
      {:ok, translated} ->
        translated

      :missing ->
        case get_translator_from_config() do
          nil -> interpolate(msg, opts)
          translator -> translator.({msg, opts})
        end
    end
  end

  defp use_default_translator? do
    Application.get_env(:cognit, :use_default_error_translator, true)
  end

  defp cognit_translate({msg, opts}) do
    locale = Gettext.get_locale(Cognit.Gettext)
    bindings = Map.new(opts)

    result =
      if count = opts[:count] do
        Cognit.Gettext.lngettext(locale, "errors", nil, msg, msg, count, bindings)
      else
        Cognit.Gettext.lgettext(locale, "errors", nil, msg, bindings)
      end

    case result do
      {:ok, translated} -> {:ok, translated}
      {:default, _} -> :missing
    end
  end

  @doc """
  Interpolate `%{key}` placeholders in `msg` using values from `opts`.

  Used as the no-translation fallback path for raw error msgids.
  """
  def interpolate(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp get_translator_from_config do
    case Application.get_env(:cognit, :error_translator_function) do
      {module, function} -> &apply(module, function, [&1])
      nil -> nil
    end
  end
end
