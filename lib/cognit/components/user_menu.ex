defmodule Cognit.Components.UserMenu do
  use Cognit, :component

  import Cognit.Avatar
  import Cognit.Button
  import Cognit.DropdownMenu
  import Cognit.Icon

  attr :class, :any, default: nil
  attr :user, :map, required: true
  attr :rest, :global

  slot :inner_block

  def user_menu(assigns) do
    ~H"""
    <div class={["flex items-center", @class]} {@rest}>
      <.avatar class="rounded-lg">
        <.avatar_fallback class="rounded-lg">
          <.icon name="account_circle" />
        </.avatar_fallback>
      </.avatar>
      <.dropdown_menu id="user-menu">
        <.dropdown_menu_trigger>
          <.button variant="ghost" class="px-3">
            {user_display_name(@user)}
            <.icon name="keyboard_arrow_down" size="sm" class="ml-2" />
          </.button>
        </.dropdown_menu_trigger>
        <.dropdown_menu_content>
          {render_slot(@inner_block)}
        </.dropdown_menu_content>
      </.dropdown_menu>
    </div>
    """
  end

  def user_display_name(user) do
    first_name = Map.get(user, :first_name) || Map.get(user, "first_name")
    last_name = Map.get(user, :last_name) || Map.get(user, "last_name")
    email = Map.get(user, :email) || Map.get(user, "email")

    cond do
      first_name && last_name -> "#{first_name} #{last_name}"
      first_name -> first_name
      last_name -> last_name
      email -> email
      true -> pgettext("user menu, fallback username", "Unknown User")
    end
  end
end
