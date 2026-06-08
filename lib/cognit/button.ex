defmodule Cognit.Button do
  @moduledoc """
  Button component for user interactions.

  Provides a versatile button component with various styles, sizes, and states
  to handle user interactions throughout the application.
  """
  use Cognit, :component

  @doc """
  Renders a button with configurable styles and behaviors.

  ## Attributes

  * `:type` - HTML button type attribute (e.g., "button", "submit")
  * `:class` - Additional CSS classes
  * `:variant` - Visual style variant of the button:
      * `"default"` - Primary action button
      * `"secondary"` - Secondary action button
      * `"destructive"` - Buttons for destructive actions
      * `"success"` - Buttons for success actions
      * `"warning"` - Buttons for warning actions
      * `"outline"` - Button with outline style
      * `"ghost"` - Button with minimal styling
      * `"link"` - Button that appears as a link
  * `:size` - Size of the button:
      * `"default"` - Standard size
      * `"sm"` - Small size
      * `"lg"` - Large size
      * `"icon"` - Square button optimized for icons
  * `:rest` - Additional HTML attributes including `disabled`, `form`, `name`, `value`

  ## Examples

      <.button>Send</.button>
      <.button variant="destructive" phx-click="delete">Delete</.button>
      <.button variant="outline" size="sm">Cancel</.button>
      <.button variant="ghost" size="icon">
        <.icon name="close" />
      </.button>
      <.button type="submit" phx-disable-with="Saving...">Save Changes</.button>
  """
  @button_attributes [
    "form",
    "name",
    "value",
    "disabled"
  ]

  @link_attributes [
    "navigate",
    "patch",
    "href",
    "method",
    "download",
    "referrerpolicy",
    "rel",
    "target"
  ]

  @label_attributes [
    "for"
  ]

  @rest_attributes @button_attributes ++ @link_attributes ++ @label_attributes

  attr :as, :any, default: "button"
  attr :type, :string, default: nil
  attr :class, :any, default: nil

  attr :variant, :string,
    values: ~w(default secondary destructive success warning outline ghost link),
    default: "default",
    doc: "the button variant style"

  attr :size, :string, values: ~w(default sm lg icon), default: "default"
  attr :rest, :global, include: @rest_attributes

  slot :inner_block, required: true

  def button(assigns) do
    assigns =
      assigns
      |> assign(:variant_class, button_variant(assigns))
      |> maybe_promote_as_link()

    ~H"""
    <.dynamic
      tag={@as}
      type={@type}
      class={
        classes([
          "phx-submit-loading:opacity-75",
          @variant_class,
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic>
    """
  end

  # When the caller passes a link attr (navigate/patch/href) but leaves `as`
  # at its default, render an `<a>` via `Phoenix.Component.link/1` so the
  # navigation actually takes effect. Without this, the attrs flow through
  # `@rest` onto a `<button>` and are inert.
  defp maybe_promote_as_link(%{as: "button", rest: rest} = assigns) do
    if Map.has_key?(rest, :navigate) or Map.has_key?(rest, :patch) or Map.has_key?(rest, :href) do
      assign(assigns, :as, &Phoenix.Component.link/1)
    else
      assigns
    end
  end

  defp maybe_promote_as_link(assigns), do: assigns
end
