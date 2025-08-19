defmodule Storybook.CognitComponents.ConfirmationDialog do
  @moduledoc """
  Storybook for Confirmation Dialog component
  """
  use PhoenixStorybook.Story, :component

  alias Cognit.ConfirmationDialog

  def function, do: &ConfirmationDialog.confirmation_dialog/1

  def imports,
    do: [
      {Cognit.Button, button: 1},
      {Cognit.Icon, icon: 1}
    ]

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic Confirmation Dialog",
        attributes: %{
          id: "default-confirmation-dialog",
          title: "Confirm Action",
          description: "Are you sure you want to proceed with this action?"
        },
        template: """
        <button phx-click={Cognit.JS.dispatch_command(%JS{}, "open", to: "#:variation_id")}>
          Open Confirmation Dialog
        </button>
        <.psb-variation />
        """
      },
      %Variation{
        id: :with_custom_trigger,
        description: "Custom Trigger Slot",
        attributes: %{
          id: "custom-trigger-dialog",
          title: "Custom Trigger Confirmation",
          description: "Dialog with a custom trigger element"
        },
        template: """
        <.psb-variation />
        """,
        slots: [
          """
          <:trigger>
            <.button variant="destructive">
              <.icon name="delete" class="text-[20px] mr-2" />
              Custom Trigger
            </.button>
          </:trigger>
          """
        ]
      },
      %Variation{
        id: :with_additional_content,
        description: "Dialog with Additional Content",
        attributes: %{
          id: "content-confirmation-dialog",
          title: "Confirm Details",
          description: "Please review the following details before confirming."
        },
        template: """
        <button phx-click={Cognit.JS.dispatch_command(%JS{}, "open", to: "#:variation_id")}>
          Open Dialog with Content
        </button>
        <.psb-variation/>
        """,
        slots: [
          """
          <div class="p-4 bg-muted rounded">
            <p class="text-sm text-muted-foreground">
              Additional details or warning message can be placed here.
            </p>
          </div>
          """
        ]
      }
    ]
  end
end
