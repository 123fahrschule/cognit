defmodule Cognit.Components.AppSideNav do
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
  attr :rest, :global

  slot :inner_block

  def app_side_nav(%{inner_block: [_ | _]} = assigns) do
    ~H"""
    <.sidebar_menu {@rest}>
      <.sidebar_menu_item>
        <.dropdown_menu id={@id} class="block w-full">
          <.dropdown_menu_trigger>
            <.sidebar_menu_button size="lg" class={@class} as="button">
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

  def app_side_nav(%{on_click: on_click} = assigns) when on_click != nil do
    ~H"""
    <.sidebar_menu {@rest}>
      <.sidebar_menu_item>
        <.sidebar_menu_button size="lg" class={@class} as="button" phx-click={@on_click}>
          <.side_nav_content title={@title} subtitle={@subtitle} />
        </.sidebar_menu_button>
      </.sidebar_menu_item>
    </.sidebar_menu>
    """
  end

  def app_side_nav(assigns) do
    ~H"""
    <.sidebar_menu {@rest}>
      <.sidebar_menu_item>
        <div
          data-sidebar="menu-button"
          data-size="lg"
          class={
            classes([
              "flex w-full items-center gap-2 overflow-hidden rounded-md p-2 text-left text-sm",
              "group-data-[collapsible=icon]:!size-8 group-data-[collapsible=icon]:!p-0",
              @class
            ])
          }
        >
          <.side_nav_content title={@title} subtitle={@subtitle} />
        </div>
      </.sidebar_menu_item>
    </.sidebar_menu>
    """
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
end
