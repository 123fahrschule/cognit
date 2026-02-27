defmodule Storybook.CognitComponents.CopyButton do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  def function, do: &Cognit.Components.CopyButton.copy_button/1

  def imports do
    [
      {Cognit.Card, [card: 1, card_content: 1, card_header: 1, card_title: 1]}
    ]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default copy button - always visible with hover effect",
        attributes: %{
          value: "Hello, World!"
        }
      },
      %Variation{
        id: :with_text,
        description: "Copy button next to text content",
        template: """
        <div class="flex items-center gap-2">
          <code class="px-2 py-1 bg-muted rounded text-sm">mix phx.server</code>
          <.copy_button value="mix phx.server" />
        </div>
        """
      },
      %Variation{
        id: :hover_reveal,
        description: "Visible only on parent hover using group classes",
        template: """
        <div class="group inline-flex items-center gap-2 p-4 bg-muted rounded">
          <span class="text-sm">Hover to reveal copy button</span>
          <.copy_button value="Hidden until hover" class="opacity-0 group-hover:opacity-100" />
        </div>
        """
      },
      %Variation{
        id: :api_key_card,
        description: "Copy button in a card with API key",
        template: """
        <.card class="w-full max-w-md">
          <.card_header>
            <.card_title>API Key</.card_title>
          </.card_header>
          <.card_content>
            <div class="flex items-center justify-between gap-4 p-3 bg-muted rounded-lg">
              <code class="text-sm font-mono flex-1 truncate">sk_live_51234567890abcdef</code>
              <.copy_button value="sk_live_51234567890abcdef" />
            </div>
            <p class="text-sm text-muted-foreground mt-2">
              Keep your API key secure. Click to copy.
            </p>
          </.card_content>
        </.card>
        """
      },
      %Variation{
        id: :list_items,
        description: "Copy buttons in a list with hover reveal",
        template: """
        <div class="space-y-2 max-w-md">
          <div class="group flex items-center justify-between p-3 bg-muted rounded-lg hover:bg-muted/80">
            <div class="flex-1">
              <div class="font-medium">Production URL</div>
              <code class="text-sm text-muted-foreground">https://api.example.com</code>
            </div>
            <.copy_button
              value="https://api.example.com"
              class="opacity-0 group-hover:opacity-100"
            />
          </div>
          <div class="group flex items-center justify-between p-3 bg-muted rounded-lg hover:bg-muted/80">
            <div class="flex-1">
              <div class="font-medium">Staging URL</div>
              <code class="text-sm text-muted-foreground">https://staging-api.example.com</code>
            </div>
            <.copy_button
              value="https://staging-api.example.com"
              class="opacity-0 group-hover:opacity-100"
            />
          </div>
          <div class="group flex items-center justify-between p-3 bg-muted rounded-lg hover:bg-muted/80">
            <div class="flex-1">
              <div class="font-medium">Development URL</div>
              <code class="text-sm text-muted-foreground">http://localhost:4000</code>
            </div>
            <.copy_button
              value="http://localhost:4000"
              class="opacity-0 group-hover:opacity-100"
            />
          </div>
        </div>
        """
      },
      %Variation{
        id: :with_target,
        description: "Copy button using target attribute to copy from another element",
        template: """
        <div class="flex items-center gap-2">
          <input
            id="copy-target-input"
            type="text"
            value="Text from input element"
            class="px-3 py-2 border rounded text-sm"
            readonly
          />
          <.copy_button target="#copy-target-input" />
        </div>
        """
      },
      %Variation{
        id: :custom_padding,
        description: "Custom padding",
        attributes: %{
          value: "Custom padding",
          class: "p-2"
        }
      },
      %Variation{
        id: :custom_icon_color,
        description: "Custom icon color",
        attributes: %{
          value: "Custom icon color",
          icon_class: "text-blue-500"
        }
      },
      %Variation{
        id: :larger_button,
        description: "Larger button with custom styling",
        attributes: %{
          value: "Larger button",
          class: "p-2 hover:bg-blue-100",
          icon_class: "text-[20px]"
        }
      }
    ]
  end
end
