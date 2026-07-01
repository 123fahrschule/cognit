defmodule Storybook.CognitComponents.Page do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.Page.page/1

  def layout, do: :one_column

  def imports,
    do: [
      {Cognit.Components.Page,
       [page_header: 1, page_header_detail: 1, page_content: 1, page_footer: 1]},
      {Cognit.Button, [button: 1]},
      {Cognit.Badge, [badge: 1]},
      {Cognit.Card, [card: 1, card_header: 1, card_title: 1, card_content: 1]},
      {Cognit.Stepper, [stepper: 1, step: 1]},
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
        id: :rich_header,
        description: "Title with several badges, description, a details section, and a footer.",
        slots: [
          """
          <.page_header title="Order #10432" description="Placed on Jul 1, 2026 · 4 items">
            <:badge><.badge>Draft</.badge></:badge>
            <:badge><.badge variant="secondary">Priority</.badge></:badge>
            <:actions>
              <.button variant="outline" size="sm">Cancel</.button>
            </:actions>
            <:actions>
              <.button size="sm">Confirm</.button>
            </:actions>
            <:details>
              <.page_header_detail icon="person" label="Customer">Anna Keller</.page_header_detail>
              <.page_header_detail icon="event" label="Due">Jul 5, 2026</.page_header_detail>
              <.page_header_detail icon="payments" label="Total">€1,240.00</.page_header_detail>
            </:details>
            <:footer>
              <p class="text-sm text-muted-foreground">
                Footer content — same padding as the header body.
              </p>
            </:footer>
          </.page_header>
          <.page_content>
            <p class="text-sm text-muted-foreground">Page body goes here.</p>
          </.page_content>
          """
        ]
      },
      %Variation{
        id: :wizard_header,
        description:
          "Header with a stepper in the footer (wizard flow); -mb-px merges the stepper underline with the header border into one line.",
        slots: [
          """
          <.page_header title="New employee" description="Step 2 of 3 · Location & Pricing">
            <:actions>
              <.button variant="outline" size="sm">Back</.button>
            </:actions>
            <:actions>
              <.button size="sm">Continue</.button>
            </:actions>
            <:footer>
              <.stepper class="-mb-px">
                <.step state="completed" number="1">Configuration & Schedule</.step>
                <.step state="current" number="2">Location & Pricing</.step>
                <.step number="3">Capacity & Resources</.step>
              </.stepper>
            </:footer>
          </.page_header>
          <.page_content>
            <p class="text-sm text-muted-foreground">Wizard step body goes here.</p>
          </.page_content>
          """
        ]
      },
      %Variation{
        id: :full_width_footer,
        description: "Footer content bled to the component edges with a -mx-6 wrapper.",
        slots: [
          """
          <.page_header title="New employee" description="Step 2 of 3 · Location & Pricing">
            <:actions>
              <.button variant="outline" size="sm">Back</.button>
            </:actions>
            <:actions>
              <.button size="sm">Continue</.button>
            </:actions>
            <:footer>
              <div class="-mx-6">
                <.stepper>
                  <.step state="completed" number="1">Configuration & Schedule</.step>
                  <.step state="current" number="2">Location & Pricing</.step>
                  <.step number="3">Capacity & Resources</.step>
                </.stepper>
              </div>
            </:footer>
          </.page_header>
          <.page_content>
            <p class="text-sm text-muted-foreground">Wizard step body goes here.</p>
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
