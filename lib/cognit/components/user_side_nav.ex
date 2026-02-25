defmodule Cognit.Components.UserSideNav do
  use Cognit, :component

  import Cognit.Avatar
  import Cognit.Components.UserHelpers
  import Cognit.DropdownMenu
  import Cognit.Icon
  import Cognit.Sidebar

  attr :id, :string, default: "user-side-nav"
  attr :class, :any, default: nil
  attr :user, :map, required: true
  attr :is_mobile, :boolean, default: false
  attr :state, :string, default: "expanded"
  attr :rest, :global

  slot :inner_block

  def user_side_nav(assigns) do
    ~H"""
    <.sidebar_menu {@rest}>
      <.sidebar_menu_item>
        <.dropdown_menu id={@id} class="block w-full">
          <.dropdown_menu_trigger>
            <.sidebar_menu_button
              size="lg"
              class={@class}
              is_mobile={@is_mobile}
              state={@state}
              as="button"
            >
              <.avatar class="h-8 w-8 rounded-lg">
                <.avatar_fallback class="rounded-lg">
                  <.icon name="account_circle" />
                </.avatar_fallback>
              </.avatar>
              <div class="grid flex-1 text-left text-sm leading-tight">
                <span class="truncate font-semibold">{user_display_name(@user)}</span>
                <span class="truncate text-xs">{user_email(@user)}</span>
              </div>
              <.icon name="unfold_more" size="sm" class="ml-auto" />
            </.sidebar_menu_button>
          </.dropdown_menu_trigger>
          <.dropdown_menu_content
            side="right"
            align="end"
            class="min-w-56 rounded-lg"
          >
            {render_slot(@inner_block)}
          </.dropdown_menu_content>
        </.dropdown_menu>
      </.sidebar_menu_item>
    </.sidebar_menu>
    """
  end
end
