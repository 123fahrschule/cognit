defmodule Storybook.CognitComponents.Alert do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  # alias SaladStorybookWeb.CoreComponents
  alias Cognit.Alert

  def function, do: &Alert.alert/1

  def imports,
    do: [
      {Alert, [alert_title: 1, alert_description: 1]},
      {Cognit.Icon, [icon: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :default_alert,
        template: """
        <.alert>
          <.icon name="terminal" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :info_alias,
        template: """
        <.alert variant="info">
          <.icon name="info" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :error,
        template: """
        <.alert variant="error">
          <.icon name="error" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :alert_alias,
        template: """
        <.alert variant="alert">
          <.icon name="warning" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :destructive_alias,
        template: """
        <.alert variant="destructive">
          <.icon name="warning" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :success,
        template: """
        <.alert variant="success">
          <.icon name="check_circle" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      },
      %Variation{
        id: :warning,
        template: """
        <.alert variant="warning">
          <.icon name="warning" size="xs" />
          <.alert_title>Heads up!</.alert_title>
          <.alert_description>
            You can add components to your app using the cli
          </.alert_description>
        </.alert>
        """,
        attributes: %{}
      }
    ]
  end
end
