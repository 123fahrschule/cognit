defmodule Storybook.CognitComponents.UserSideNav do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.UserSideNav.user_side_nav/1

  def imports,
    do: [
      {Cognit.Sidebar, [sidebar_provider: 1, sidebar: 1, sidebar_footer: 1]},
      {Cognit.DropdownMenu, [dropdown_menu_link_item: 1, dropdown_menu_separator: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  @user %{first_name: "Anna", last_name: "Müller", email: "anna@example.com"}

  def template do
    """
    <div class="w-full max-w-xs rounded-lg border overflow-hidden [&_.h-svh]:h-auto">
      <.sidebar_provider>
        <.sidebar collapsible="none" class="w-full">
          <.sidebar_footer>
            <.psb-variation/>
          </.sidebar_footer>
        </.sidebar>
      </.sidebar_provider>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :static,
        description: "Non-interactive label — pass neither on_click nor an inner block.",
        attributes: %{user: @user}
      },
      %Variation{
        id: :button,
        description: "Clickable button with no menu. Pass on_click (a phx-click value).",
        attributes: %{user: @user, on_click: "open_account"}
      },
      %Variation{
        id: :dropdown,
        description: "Opens a dropdown menu built from the inner block.",
        attributes: %{id: "user-side-nav-dropdown", user: @user},
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
      },
      %Variation{
        id: :email_only,
        description: "Display name falls back to the email when no name is present.",
        attributes: %{user: %{email: "guest@example.com"}}
      }
    ]
  end
end
