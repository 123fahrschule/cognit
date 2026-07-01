defmodule Storybook.CognitComponents.UserMenu do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.UserMenu.user_menu/1

  def imports,
    do: [
      {Cognit.DropdownMenu, [dropdown_menu_link_item: 1, dropdown_menu_separator: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def template do
    """
    <div class="flex justify-end rounded-lg border bg-background p-3">
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description:
          "Avatar plus a display-name trigger. The inner block becomes the dropdown content.",
        attributes: %{
          user: %{first_name: "Anna", last_name: "Müller", email: "anna@example.com"}
        },
        slots: [
          """
          <.dropdown_menu_link_item href="#">
            <.icon name="account_circle" /> Profile
          </.dropdown_menu_link_item>
          <.dropdown_menu_link_item href="#">
            <.icon name="settings" /> Settings
          </.dropdown_menu_link_item>
          <.dropdown_menu_separator />
          <.dropdown_menu_link_item href="#" method="delete">
            <.icon name="logout" /> Sign out
          </.dropdown_menu_link_item>
          """
        ]
      }
    ]
  end
end
