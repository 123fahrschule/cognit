defmodule Cognit.Components.AppSideNav do
  @moduledoc """
  App branding entry at the top of a sidebar. Renders an avatar, title, and optional subtitle.

  Four rendering modes, selected automatically by the assigns you pass:

  * **Dropdown** — provide an `inner_block`. Renders as a `dropdown_menu` trigger; the
    inner block becomes the menu content.
  * **Link** — provide a navigation attr (`navigate`, `patch`, or `href`). Renders as an
    `<a>` that performs the navigation.
  * **Button** — provide `on_click` (a `phx-click` value, e.g. a `JS` command). Renders
    as a clickable button with no menu.
  * **Static** — provide none of the above. Renders as a non-interactive label with no
    hover/active/focus styling.
  """

  use Cognit, :component

  import Cognit.Avatar
  import Cognit.Components.Logo
  import Cognit.DropdownMenu
  import Cognit.Icon
  import Cognit.Sidebar

  attr :id, :string, default: "app-side-nav"
  attr :class, :any, default: nil
  attr :title, :string, required: true
  attr :subtitle, :string, default: "123Fahrschule"
  attr :on_click, :any, default: nil

  attr :rest, :global,
    include:
      ~w(download href hreflang ping referrerpolicy rel target navigate patch replace method csrf_token)

  slot :inner_block

  def app_side_nav(%{inner_block: [_ | _]} = assigns) do
    ~H"""
    <.sidebar_menu {@rest}>
      <.sidebar_menu_item>
        <.dropdown_menu id={@id} class="block w-full">
          <.dropdown_menu_trigger>
            <.sidebar_menu_button
              size="lg"
              class={@class}
              as="button"
              tooltip={side_nav_tooltip(@title, @subtitle)}
            >
              <.side_nav_content title={@title} subtitle={@subtitle} />
              <.icon name="unfold_more" size="sm" class="ml-auto" />
            </.sidebar_menu_button>
          </.dropdown_menu_trigger>
          <.dropdown_menu_content side="right" align="start" class="min-w-56 rounded-lg">
            {render_slot(@inner_block)}
          </.dropdown_menu_content>
        </.dropdown_menu>
      </.sidebar_menu_item>
    </.sidebar_menu>
    """
  end

  def app_side_nav(assigns) do
    link? = link_nav?(assigns.rest)
    interactive? = link? or assigns.on_click != nil

    as =
      cond do
        link? -> &link/1
        assigns.on_click != nil -> "button"
        true -> "div"
      end

    assigns = assign(assigns, as: as, interactive?: interactive?)

    ~H"""
    <.sidebar_menu>
      <.sidebar_menu_item>
        <.sidebar_menu_button
          size="lg"
          as={@as}
          phx-click={@on_click}
          class={classes([!@interactive? && "pointer-events-none", @class])}
          tooltip={side_nav_tooltip(@title, @subtitle)}
          {@rest}
        >
          <.side_nav_content title={@title} subtitle={@subtitle} />
        </.sidebar_menu_button>
      </.sidebar_menu_item>
    </.sidebar_menu>
    """
  end

  defp link_nav?(rest) do
    Map.has_key?(rest, :navigate) or Map.has_key?(rest, :patch) or Map.has_key?(rest, :href)
  end

  defp side_nav_content(assigns) do
    ~H"""
    <.avatar class="h-8 w-8 rounded-lg">
      <.avatar_fallback class="rounded-lg">
        <.brand_logo class="size-4" />
      </.avatar_fallback>
    </.avatar>
    <div class="grid flex-1 text-left text-sm leading-tight">
      <span class="truncate font-semibold">{@title}</span>
      <span :if={@subtitle} class="truncate text-xs">{@subtitle}</span>
    </div>
    """
  end

  defp side_nav_tooltip(title, nil), do: title
  defp side_nav_tooltip(title, ""), do: title
  defp side_nav_tooltip(title, subtitle), do: "#{title} · #{subtitle}"
end
