defmodule Storybook.Recipes.AppShell do
  use PhoenixStorybook.Story, :example
  use Cognit

  import Cognit.Components.AppSideNav
  import Cognit.Components.UserSideNav

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :user, %{
       first_name: "Anna",
       last_name: "Müller",
       email: "anna@example.com"
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="h-[600px] rounded-lg border overflow-hidden [&_.h-svh]:h-full"
      style="transform: translateZ(0)"
    >
      <.sidebar_provider>
        <.sidebar id="app-shell-sidebar" is_desktop collapsible="icon">
          <.sidebar_header>
            <.app_side_nav title="Acme Inc" subtitle="Enterprise">
              <.dropdown_menu_item><.icon name="swap_horiz" /> Switch workspace</.dropdown_menu_item>
              <.dropdown_menu_item><.icon name="settings" /> Settings</.dropdown_menu_item>
            </.app_side_nav>
          </.sidebar_header>

          <.sidebar_content>
            <.sidebar_group>
              <.sidebar_group_label>Main</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button is_active href="#">
                      <.icon name="dashboard" /> <span>Dashboard</span>
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>

                  <.sidebar_menu_item>
                    <.collapsible id="nav-employees" open>
                      <.collapsible_trigger>
                        <.sidebar_menu_button as="button">
                          <.icon name="group" />
                          <span>Employees</span>
                          <.icon
                            name="keyboard_arrow_down"
                            size="xs"
                            class="ml-auto transition-transform group-data-[state=open]/collapsible:rotate-180"
                          />
                        </.sidebar_menu_button>
                      </.collapsible_trigger>
                      <.collapsible_content>
                        <.sidebar_menu_sub>
                          <.sidebar_menu_sub_item>
                            <.sidebar_menu_sub_button href="#">
                              <span>All Employees</span>
                            </.sidebar_menu_sub_button>
                          </.sidebar_menu_sub_item>
                          <.sidebar_menu_sub_item>
                            <.sidebar_menu_sub_button href="#">
                              <span>Departments</span>
                            </.sidebar_menu_sub_button>
                          </.sidebar_menu_sub_item>
                          <.sidebar_menu_sub_item>
                            <.sidebar_menu_sub_button href="#">
                              <span>Teams</span>
                            </.sidebar_menu_sub_button>
                          </.sidebar_menu_sub_item>
                        </.sidebar_menu_sub>
                      </.collapsible_content>
                    </.collapsible>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>

            <.sidebar_group>
              <.sidebar_group_label>Settings</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button href="#">
                      <.icon name="settings" /> <span>General</span>
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button href="#">
                      <.icon name="extension" /> <span>Integrations</span>
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>
          </.sidebar_content>

          <.sidebar_footer>
            <.user_side_nav user={@user}>
              <.dropdown_menu_item><.icon name="account_circle" /> Profile</.dropdown_menu_item>
              <.dropdown_menu_item><.icon name="settings" /> Settings</.dropdown_menu_item>
              <.dropdown_menu_separator />
              <.dropdown_menu_item><.icon name="logout" /> Sign out</.dropdown_menu_item>
            </.user_side_nav>
          </.sidebar_footer>
        </.sidebar>

        <.sidebar_inset>
          <.topbar>
            <.breadcrumb class="mr-auto">
              <.breadcrumb_list>
                <.breadcrumb_item>
                  <.breadcrumb_link>Home</.breadcrumb_link>
                </.breadcrumb_item>
                <.breadcrumb_separator />
                <.breadcrumb_item>
                  <.breadcrumb_link>Employees</.breadcrumb_link>
                </.breadcrumb_item>
                <.breadcrumb_separator />
                <.breadcrumb_item>
                  <.breadcrumb_page>All</.breadcrumb_page>
                </.breadcrumb_item>
              </.breadcrumb_list>
            </.breadcrumb>
          </.topbar>

          <.page>
            <.page_header title="Dashboard" />
            <.page_content>
              <p class="text-muted-foreground">Welcome back, Anna.</p>
            </.page_content>
          </.page>
        </.sidebar_inset>
      </.sidebar_provider>
    </div>
    """
  end
end
