defmodule Storybook.BugReproductions.SidebarMenuMultilineLabel do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc do
    """
    Bug reproduction for sidebar menu buttons clipping multi-line labels.

    Before the fix:
    - The button row was locked to a fixed height (`h-8` / `h-7` / `h-12`) with
      `overflow-hidden` and `items-center`.
    - When a label wrapped to multiple lines (e.g. the label `<span>` was not the
      last child, so `[&>span:last-child]:truncate` did not apply), the wrapped
      lines were clipped vertically:
        * 1 line — fully visible
        * 2 lines — bottom line cut off
        * 3 lines — only the middle line visible, top and bottom clipped

    After the fix:
    - Fixed heights were replaced with `min-h-*`, so the row grows to fit
      multi-line content while single-line labels still render at the same
      default height.
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="h-[600px] rounded-lg border overflow-hidden [&_.h-svh]:h-full"
      style="transform: translateZ(0)"
    >
      <.sidebar_provider>
        <.sidebar>
          <.sidebar_content>
            <.sidebar_group>
              <.sidebar_group_label>Single line (baseline)</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button href="#">
                      <.icon name="dashboard" /> <span>Dashboard</span>
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>

            <.sidebar_group>
              <.sidebar_group_label>Multi-line (span not last child)</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button href="#">
                      <.icon name="group" />
                      <span>Two line label that wraps to a second line</span>
                      <.icon name="keyboard_arrow_down" size="xs" class="ml-auto" />
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>

                  <.sidebar_menu_item>
                    <.sidebar_menu_button href="#">
                      <.icon name="settings" />
                      <span>
                        Three line label that wraps across three lines inside the sidebar menu button
                      </span>
                      <.icon name="keyboard_arrow_down" size="xs" class="ml-auto" />
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>

            <.sidebar_group>
              <.sidebar_group_label>Multi-line sub-button</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_sub>
                      <.sidebar_menu_sub_item>
                        <.sidebar_menu_sub_button href="#">
                          <span>Sub-button label that also wraps to multiple lines</span>
                          <.icon name="open_in_new" size="xs" class="ml-auto" />
                        </.sidebar_menu_sub_button>
                      </.sidebar_menu_sub_item>
                    </.sidebar_menu_sub>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>

            <.sidebar_group>
              <.sidebar_group_label>Size variants</.sidebar_group_label>
              <.sidebar_group_content>
                <.sidebar_menu>
                  <.sidebar_menu_item>
                    <.sidebar_menu_button size="sm" href="#">
                      <.icon name="bolt" />
                      <span>Small size with a long wrapping label</span>
                      <.icon name="keyboard_arrow_down" size="xs" class="ml-auto" />
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>

                  <.sidebar_menu_item>
                    <.sidebar_menu_button size="lg" href="#">
                      <.avatar class="h-8 w-8 rounded-lg">
                        <.avatar_fallback class="rounded-lg">
                          <.icon name="account_circle" />
                        </.avatar_fallback>
                      </.avatar>
                      <div class="grid flex-1 text-left text-sm leading-tight">
                        <span class="truncate font-semibold">
                          Large size with a long wrapping label that spans multiple lines
                        </span>
                        <span class="truncate text-xs">user@example.com</span>
                      </div>
                      <.icon name="unfold_more" size="sm" class="ml-auto" />
                    </.sidebar_menu_button>
                  </.sidebar_menu_item>
                </.sidebar_menu>
              </.sidebar_group_content>
            </.sidebar_group>
          </.sidebar_content>
        </.sidebar>

        <.sidebar_inset>
          <.topbar />
        </.sidebar_inset>
      </.sidebar_provider>
    </div>
    """
  end
end
