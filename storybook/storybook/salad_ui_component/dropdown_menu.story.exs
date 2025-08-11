defmodule Storybook.CognitComponents.DropdownMenu do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.DropdownMenu

  def function, do: &DropdownMenu.dropdown_menu/1

  def imports,
    do: [
      {DropdownMenu,
       [
         dropdown_menu_trigger: 1,
         dropdown_menu_content: 1,
         dropdown_menu_label: 1,
         dropdown_menu_separator: 1,
         dropdown_menu_item: 1,
         dropdown_menu_shortcut: 1,
         dropdown_menu_group: 1,
         dropdown_menu_checkbox_item: 1,
         dropdown_menu_radio_group: 1,
         dropdown_menu_radio_item: 1,
         dropdown_menu_sub: 1,
         dropdown_menu_sub_trigger: 1,
         dropdown_menu_sub_content: 1
       ]},
      {Cognit.Button, [button: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default dropdown menu with various options",
        template: """
        <div class="p-24 flex justify-center">
          <.dropdown_menu id="dropdown-default">
            <.dropdown_menu_trigger>
              <.button variant="outline">Open Menu</.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content class="w-56">
              <.dropdown_menu_label>Account</.dropdown_menu_label>
              <.dropdown_menu_separator />
              <.dropdown_menu_group>
                <.dropdown_menu_item on-select="on_command" value="profile">
                  <.icon name="person" class="mr-2 text-[16px]" />
                  <span>Profile</span>
                  <.dropdown_menu_shortcut>⌘P</.dropdown_menu_shortcut>
                </.dropdown_menu_item>
                <.dropdown_menu_item on-select="on_command">
                  <.icon name="settings" class="mr-2 text-[16px]" />
                  <span>Settings</span>
                  <.dropdown_menu_shortcut>⌘S</.dropdown_menu_shortcut>
                </.dropdown_menu_item>
                <.dropdown_menu_item on-select="on_command">
                  <.icon name="payments" class="mr-2 text-[16px]" />
                  <span>Billing</span>
                  <.dropdown_menu_shortcut>⌘B</.dropdown_menu_shortcut>
                </.dropdown_menu_item>
              </.dropdown_menu_group>
              <.dropdown_menu_separator />
              <.dropdown_menu_group>
                <.dropdown_menu_item on-select="on_command">
                  <.icon name="group" class="mr-2 text-[16px]" />
                  <span>Team</span>
                </.dropdown_menu_item>
                <.dropdown_menu_item disabled>
                  <.icon name="add" class="mr-2 text-[16px]" />
                  <span>New Team</span>
                  <.dropdown_menu_shortcut>⌘T</.dropdown_menu_shortcut>
                </.dropdown_menu_item>
              </.dropdown_menu_group>
              <.dropdown_menu_separator />
              <.dropdown_menu_item on-select="on_command">
                <.icon name="logout" class="mr-2 text-[16px]" />
                <span>Log out</span>
              </.dropdown_menu_item>
            </.dropdown_menu_content>
          </.dropdown_menu>
        </div>
        """
      },
      %Variation{
        id: :checkbox_item,
        description: "Dropdown with checkbox",
        template: """
        <.dropdown_menu id="text-formatting">
        <.dropdown_menu_trigger>
        <.button variant="outline">Format</.button>
        </.dropdown_menu_trigger>
        <.dropdown_menu_content>
        <.dropdown_menu_checkbox_item
        checked
        on-checked-change="toggle_bold"
        >
        <span class="font-bold">Bold</span>
        </.dropdown_menu_checkbox_item>
        <.dropdown_menu_checkbox_item
        on-checked-change={JS.push("toggle_italic")}
        >
        <span class="italic">Italic</span>
        </.dropdown_menu_checkbox_item>
        <.dropdown_menu_checkbox_item
        on-select="format_underline"
        on-checked-change={JS.push("toggle_underline")}
        >
        <span class="underline">Underline</span>
        </.dropdown_menu_checkbox_item>
        </.dropdown_menu_content>
        </.dropdown_menu>
        """
      }
    ]
  end
end
