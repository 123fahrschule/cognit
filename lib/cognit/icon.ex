defmodule Cognit.Icon do
  use Cognit, :component

  @moduledoc """
  Renders Material Symbols icons using variable font.

  Material Symbols is Google's icon system that provides 2,500+ glyphs with support
  for both outlined and filled variants via variable font technology.

  ## Features

  - Outlined icons by default
  - Filled variant via `filled` attribute
  - Customizable size and color via CSS classes
  - Full Material Symbols collection available
  - Accessibility-first with ARIA support

  ## Examples

      # Basic outlined icon (default, 24px)
      <.icon name="home" />

      # Filled icon
      <.icon name="favorite" filled />

      # Different sizes using predefined values
      <.icon name="settings" size="xs" />
      <.icon name="settings" size="sm" />
      <.icon name="settings" size="lg" />
      <.icon name="settings" size="xl" />

      # Custom size with Tailwind class
      <.icon name="search" size="text-4xl" />

      # Size with custom color
      <.icon name="info" size="sm" class="text-primary" />

      # Decorative icon (hidden from screen readers)
      <button>
        <.icon name="home" decorative /> Home
      </button>

      # Standalone icon with accessible label
      <button>
        <.icon name="close" label="Close dialog" />
      </button>

  ## Finding Icons

  Search and browse available icons at: https://fonts.google.com/icons

  ## Sizing

  Use the `size` attribute with predefined values or custom Tailwind classes:
  - `xs` - 16px (for inline text)
  - `sm` - 20px (compact UI)
  - `md` - 24px (default)
  - `lg` - 32px (prominent icons)
  - `xl` - 40px (large icons)
  - Any Tailwind class: `"text-4xl"`, `"text-[28px]"`, etc.

  **Note:** If you provide size classes in both `size` and `class` attributes, the `size`
  attribute takes precedence due to TwMerge's intelligent class merging.

  ## Styling

  Icons inherit the text color from their parent or can be styled directly:
  - Use `class` for colors: `text-primary`, `text-red-500`, etc.
  - Combine with other utilities: `class="opacity-50"`, `class="hover:text-blue-500"`, etc.

  ## Accessibility

  Icons are accessible by default with proper ARIA attributes:

  - **Decorative icons** - Set `decorative={true}` to hide from screen readers when the icon
    is purely visual and adjacent text conveys the meaning
  - **Standalone icons** - Provide a `label` attribute for icons without adjacent text,
    especially in icon-only buttons
  - **With text** - When an icon appears next to text that conveys the same meaning,
    mark it as decorative

  ### Examples

      # Icon next to text - mark as decorative
      <button>
        <.icon name="save" decorative />
        Save Changes
      </button>

      # Icon-only button - provide label
      <button>
        <.icon name="close" label="Close" />
      </button>

      # Interactive icon - provide label
      <button phx-click="delete">
        <.icon name="delete" label="Delete item" />
      </button>

  ## Technical Details

  Icons are rendered using the Material Symbols Outlined variable font with the FILL axis:
  - Outlined: `font-variation-settings: 'FILL' 0` (default)
  - Filled: `font-variation-settings: 'FILL' 1`
  """

  attr :name, :string,
    required: true,
    doc: "Icon name from Material Symbols (e.g., \"home\", \"settings\", \"favorite\")"

  attr :filled, :boolean, default: false, doc: "Use filled variant instead of outlined"

  attr :size, :string,
    default: "md",
    doc: "Icon size: xs (16px), sm (20px), md (24px), lg (32px), xl (40px), or any Tailwind class"

  attr :label, :string,
    default: nil,
    doc:
      "Accessible label for screen readers. Required for standalone icons without adjacent text."

  attr :decorative, :boolean,
    default: false,
    doc:
      "Mark icon as decorative (hidden from screen readers). Use when icon has adjacent text with the same meaning."

  attr :class, :any, default: nil, doc: "Additional CSS classes for color, spacing, etc."
  attr :rest, :global, doc: "Additional HTML attributes passed to the span element"

  def icon(assigns) do
    ~H"""
    <span
      class={
        classes(["icon", "material-symbols-outlined", @filled && "filled", @class, icon_size(@size)])
      }
      role={icon_role(@label, @decorative)}
      aria-label={@label}
      aria-hidden={to_string(@decorative || is_nil(@label))}
      {@rest}
    >
      {@name}
    </span>
    """
  end

  defp icon_role(label, _decorative) when is_binary(label), do: "img"
  defp icon_role(_label, _decorative), do: nil

  defp icon_size("xs"), do: "text-[16px]"
  defp icon_size("sm"), do: "text-[20px]"
  defp icon_size("md"), do: "text-[24px]"
  defp icon_size("lg"), do: "text-[32px]"
  defp icon_size("xl"), do: "text-[40px]"
  defp icon_size(custom), do: custom
end
