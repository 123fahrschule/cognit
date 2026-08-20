defmodule Cognit.Item do
  @moduledoc """
  Item components for a row of leading media, text, and trailing actions.

  An item lays out `item_media/1`, `item_content/1`, and `item_actions/1` on one
  row. `item_header/1` and `item_footer/1` claim a full row of their own above
  and below it. Stack items inside `item_group/1`, divided by
  `separator/1`.

  ## Examples

      <.item variant="outline">
        <.item_media variant="feature"><.icon name="verified_user" /></.item_media>
        <.item_content>
          <.item_title>Security Alert</.item_title>
          <.item_description>New login detected from unknown device.</.item_description>
        </.item_content>
        <.item_actions>
          <.button variant="outline" size="sm">Review</.button>
        </.item_actions>
      </.item>

      <.item_group>
        <.item size="small">...</.item>
        <.separator />
        <.item size="small">...</.item>
      </.item_group>
  """
  use Cognit, :component

  @interactive_class "cursor-pointer hover:bg-input-50 focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"

  @link_attributes [:navigate, :patch, :href]
  @rest_attributes ~w(navigate patch href replace method csrf_token download referrerpolicy rel
                      target disabled form name value type for)

  @doc """
  Renders an item.

  ## Attributes

  * `:as` - Tag to render: `"div"` (default), `"a"`, `"button"`, or `"label"`.
    Interactive tags gain a hover background and a focus ring.
  * `:variant` - Visual style:
      * `"default"` - No visible border
      * `"outline"` - Bordered container
  * `:size` - Density of the row:
      * `"default"` - Roomy padding, suits a media box plus two lines of text
      * `"small"` - Compact padding, suits list rows
  * `:class` - Additional CSS classes.
  * `:rest` - Passing `href`, `navigate`, or `patch` renders the whole item as a link.
  """
  attr :as, :string, default: "div"
  attr :variant, :string, values: ~w(default outline), default: "default"
  attr :size, :string, values: ~w(default small), default: "default"
  attr :class, :any, default: nil
  attr :rest, :global, include: @rest_attributes
  slot :inner_block, required: true

  def item(assigns) do
    linked? = Enum.any?(@link_attributes, &Map.has_key?(assigns.rest, &1))
    assigns = assign(assigns, :linked?, linked?)
    assigns = assign(assigns, :item_class, item_class(assigns))

    ~H"""
    <.link :if={@linked?} class={@item_class} data-size={@size} {@rest}>
      {render_slot(@inner_block)}
    </.link>
    <.dynamic_tag :if={!@linked?} tag_name={@as} class={@item_class} data-size={@size} {@rest}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  defp item_class(assigns) do
    classes([
      "group/item flex flex-wrap items-start overflow-hidden rounded-lg border text-sm transition-colors",
      item_size_class(assigns.size),
      item_variant_class(assigns.variant),
      item_interactive_class(assigns),
      assigns.class
    ])
  end

  defp item_size_class("small"), do: "gap-2.5 p-2"
  defp item_size_class(_default), do: "gap-4 p-4"

  defp item_variant_class("outline"), do: "border-border"
  defp item_variant_class(_default), do: "border-transparent"

  defp item_interactive_class(%{as: as, linked?: linked?}) do
    if linked? or as in ~w(a button label), do: @interactive_class
  end

  @doc """
  Renders the leading media of an item.

  ## Attributes

  * `:variant` - Shape of the media slot:
      * `"default"` - Bare wrapper, for a single avatar
      * `"avatars"` - Row of overlapping avatars, each ringed in the item background
      * `"icon"` - Sized to a single icon, no decoration
      * `"feature"` - Icon on a bordered, muted tile
      * `"image"` - Fixed square that crops its image
  * `:class` - Additional CSS classes.
  """
  attr :variant, :string, values: ~w(default avatars icon feature image), default: "default"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_media(assigns) do
    ~H"""
    <div class={classes(["flex shrink-0", media_variant_class(@variant), @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @icon_sizing "text-foreground [&_.icon]:text-[16px] [&_svg]:size-4"

  defp media_variant_class("avatars"),
    do: "items-center [&>*:not(:last-child)]:-mr-[11px] [&>*]:ring-[1.33px] [&>*]:ring-background"

  defp media_variant_class("icon"), do: "size-4 items-center justify-center #{@icon_sizing}"

  defp media_variant_class("feature"),
    do: "flex-col items-start rounded-md border border-border bg-muted p-2 #{@icon_sizing}"

  defp media_variant_class("image"),
    do: "size-10 overflow-hidden rounded-sm [&_img]:size-full [&_img]:object-cover"

  defp media_variant_class(_default), do: "flex-col items-start"

  @doc """
  Renders the text column of an item, holding `item_title/1` and `item_description/1`.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_content(assigns) do
    ~H"""
    <div
      class={
        classes([
          "flex min-w-0 flex-1 flex-col justify-center gap-1 self-stretch break-words",
          "group-data-[size=small]/item:gap-0.5",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the title line of an item.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_title(assigns) do
    ~H"""
    <div class={classes(["w-full text-sm font-medium leading-5 text-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the description line of an item.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_description(assigns) do
    ~H"""
    <div
      class={classes(["w-full text-sm font-normal leading-5 text-muted-foreground", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the trailing actions of an item.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_actions(assigns) do
    ~H"""
    <div class={classes(["flex shrink-0 items-center gap-2 self-stretch", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a full-width row above the item body, typically a cover image.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_header(assigns) do
    ~H"""
    <div
      class={classes(["flex w-full basis-full items-center justify-between gap-2", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a full-width row below the item body, typically metadata or progress.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_footer(assigns) do
    ~H"""
    <div class={classes(["flex w-full basis-full items-center gap-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a list of items.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item_group(assigns) do
    ~H"""
    <div role="list" class={classes(["flex w-full flex-col", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
