defmodule Storybook.CognitComponents.Page do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.Page.page/1

  def imports,
    do: [
      {Cognit.Components.Page, [page_header: 1, page_content: 1, page_footer: 1]},
      {Cognit.Button, [button: 1]},
      {Cognit.Badge, [badge: 1]},
      {Cognit.Card, [card: 1, card_header: 1, card_title: 1, card_content: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def template do
    """
    <div class="h-[480px] w-full rounded-lg border overflow-hidden flex flex-col bg-muted/30">
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :full,
        description: "Header with title and actions, scrollable content, sticky footer.",
        slots: [
          """
          <.page_header title="Projects">
            <:actions>
              <.button variant="outline" size="sm">
                <.icon name="filter_list" size="sm" class="mr-1" /> Filter
              </.button>
            </:actions>
            <:actions>
              <.button size="sm">
                <.icon name="add" size="sm" class="mr-1" /> New project
              </.button>
            </:actions>
          </.page_header>
          <.page_content>
            <.card>
              <.card_header>
                <.card_title>Overview</.card_title>
              </.card_header>
              <.card_content>
                <p class="text-sm text-muted-foreground">
                  The page wraps header, content, and footer in a scrollable column.
                </p>
              </.card_content>
            </.card>
          </.page_content>
          <.page_footer>
            <p class="text-sm text-muted-foreground">12 projects · last updated today</p>
          </.page_footer>
          """
        ]
      },
      %Variation{
        id: :header_only,
        description: "Just a header with a title and a status badge in the inner block.",
        slots: [
          """
          <.page_header title="Billing">
            <.badge variant="success">Active</.badge>
          </.page_header>
          <.page_content>
            <p class="text-sm text-muted-foreground">Page body goes here.</p>
          </.page_content>
          """
        ]
      },
      %Variation{
        id: :scrolling_content,
        description: "Long content scrolls within the page while the header stays in place.",
        slots: [
          """
          <.page_header title="Activity" />
          <.page_content>
            <div :for={i <- 1..20} class="rounded-md border bg-background p-4 text-sm">
              Activity item {i}
            </div>
          </.page_content>
          """
        ]
      }
    ]
  end
end
