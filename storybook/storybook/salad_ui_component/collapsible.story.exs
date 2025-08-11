defmodule Storybook.CognitComponents.Collapsible do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Collapsible

  def function, do: &Collapsible.collapsible/1

  def imports,
    do: [
      {Cognit.Collapsible, [collapsible_trigger: 1, collapsible_content: 1]},
      {Cognit.Button, [button: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{open: false, class: "w-[350px] space-y-2"},
        slots: [
          """
          <div class="flex items-center justify-between space-x-4 px-4">
            <h4 class="text-sm font-semibold">
              @peduarte starred 3 repositories
            </h4>
            <.collapsible_trigger>
              <.button variant="ghost" size="sm" class="w-9 p-0">
                <.icon name="expand_all" class="text-[16px]" />
                <span class="sr-only">
                  Toggle
                </span>
              </.button>
            </.collapsible_trigger>
          </div>
          <div class="rounded-md border px-4 py-3 font-mono text-sm">
            @radix-ui/primitives
          </div>
          <.collapsible_content class="space-y-2">
            <div class="rounded-md border px-4 py-3 font-mono text-sm">
              @radix-ui/colors
            </div>
            <div class="rounded-md border px-4 py-3 font-mono text-sm">
              @stitches/react
            </div>
          </.collapsible_content>
          """
        ]
      }
    ]
  end
end
