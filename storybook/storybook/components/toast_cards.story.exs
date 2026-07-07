defmodule Storybook.CognitComponents.ToastCards do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Toast

  def function, do: &Toast.toast/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{title: "Event has been created"}
      },
      %Variation{
        id: :default_with_description,
        attributes: %{
          title: "Event has been created",
          description: "Monday, January 3rd at 6:00pm"
        }
      },
      %Variation{
        id: :success,
        attributes: %{
          kind: :success,
          title: "Course created",
          description: "Express course is now available."
        }
      },
      %Variation{
        id: :error,
        attributes: %{
          kind: :error,
          title: "Something went wrong",
          description: "The course could not be saved."
        }
      },
      %Variation{
        id: :warning,
        attributes: %{
          kind: :warning,
          title: "Heads up",
          description: "This configuration is close to the daily driving limit."
        }
      },
      %Variation{
        id: :info,
        attributes: %{
          kind: :info,
          title: "Update available",
          description: "A new version of the schedule was published."
        }
      },
      %Variation{
        id: :with_action,
        attributes: %{
          kind: :info,
          title: "Update available",
          description: "A new version of the schedule was published.",
          action: {:eval, ~s|%{label: "Undo", command: Phoenix.LiveView.JS.push("toast-undo")}|}
        }
      }
    ]
  end
end
