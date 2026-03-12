defmodule Storybook.CognitComponents.EmptyState do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.EmptyState

  def function, do: &EmptyState.empty_state/1

  def imports,
    do: [
      {Cognit.Button, [button: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          title: "No results",
          description: "Try adjusting your search or filters."
        }
      },
      %Variation{
        id: :with_icon,
        attributes: %{
          icon: "users",
          title: "No users",
          description: "Add users to get started."
        }
      },
      %Variation{
        id: :with_action,
        template: """
        <.empty_state title="No projects" description="Get started by creating a new project.">
          <.button>Create Project</.button>
        </.empty_state>
        """
      },
      %Variation{
        id: :with_icon_and_action,
        template: """
        <.empty_state icon="inbox" title="No messages" description="Your inbox is empty.">
          <.button variant="outline">Refresh</.button>
        </.empty_state>
        """
      }
    ]
  end
end
