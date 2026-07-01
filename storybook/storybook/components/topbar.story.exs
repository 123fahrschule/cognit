defmodule Storybook.CognitComponents.Topbar do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.Topbar.topbar/1

  def layout, do: :one_column

  def imports,
    do: [
      {Cognit.Breadcrumb,
       [
         breadcrumb: 1,
         breadcrumb_list: 1,
         breadcrumb_item: 1,
         breadcrumb_link: 1,
         breadcrumb_page: 1,
         breadcrumb_separator: 1
       ]},
      {Cognit.Components.LocaleSelect, [locale_select: 1]},
      {Cognit.Button, [button: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :with_breadcrumb,
        description: "Sidebar toggle, a breadcrumb trail, and a locale select.",
        attributes: %{class: "w-full"},
        slots: [
          """
          <.breadcrumb class="mr-auto">
            <.breadcrumb_list>
              <.breadcrumb_item>
                <.breadcrumb_link>Home</.breadcrumb_link>
              </.breadcrumb_item>
              <.breadcrumb_separator />
              <.breadcrumb_item>
                <.breadcrumb_page>Employees</.breadcrumb_page>
              </.breadcrumb_item>
            </.breadcrumb_list>
          </.breadcrumb>
          <.locale_select />
          """
        ]
      },
      %Variation{
        id: :with_title_and_actions,
        description: "A page title on the left and action buttons on the right.",
        attributes: %{class: "w-full"},
        slots: [
          """
          <span class="mr-auto text-sm font-semibold">Dashboard</span>
          <.button variant="outline" size="sm">
            <.icon name="download" size="sm" class="mr-1" /> Export
          </.button>
          <.button size="sm">
            <.icon name="add" size="sm" class="mr-1" /> New
          </.button>
          """
        ]
      }
    ]
  end
end
