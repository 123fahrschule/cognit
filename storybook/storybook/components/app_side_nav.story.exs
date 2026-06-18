defmodule Storybook.CognitComponents.AppSideNav do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.AppSideNav.app_side_nav/1

  def imports,
    do: [
      {Cognit.Sidebar, [sidebar_provider: 1, sidebar: 1, sidebar_header: 1]},
      {Cognit.DropdownMenu, [dropdown_menu_link_item: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def template do
    """
    <div class="w-full rounded-lg border overflow-hidden [&_.h-svh]:h-auto">
      <.sidebar_provider>
        <.sidebar collapsible="none" class="w-full">
          <.sidebar_header>
            <.psb-variation />
          </.sidebar_header>
        </.sidebar>
      </.sidebar_provider>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :static,
        description: "Non-interactive label — no hover, active, or focus styling.",
        attributes: %{
          title: "Acme Inc",
          subtitle: "Enterprise"
        }
      },
      %Variation{
        id: :link,
        description: "Navigates when clicked. Pass navigate, patch, or href.",
        attributes: %{
          title: "Acme Inc",
          subtitle: "Enterprise",
          href: "#"
        }
      },
      %Variation{
        id: :button,
        description: "Triggers a phx-click handler with no menu.",
        attributes: %{
          title: "Acme Inc",
          subtitle: "Enterprise",
          on_click: "switch_workspace"
        }
      },
      %Variation{
        id: :dropdown,
        description: "Opens a dropdown menu built from the inner block.",
        attributes: %{
          id: "app-side-nav-dropdown",
          title: "Acme Inc",
          subtitle: "Enterprise"
        },
        slots: [
          """
          <.dropdown_menu_link_item href="#">
            <.icon name="swap_horiz" /> Switch workspace
          </.dropdown_menu_link_item>
          <.dropdown_menu_link_item href="#">
            <.icon name="settings" /> Settings
          </.dropdown_menu_link_item>
          """
        ]
      }
    ]
  end
end
