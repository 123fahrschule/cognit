defmodule Cognit.ConfirmationDialog do
  use Cognit, :component

  import Cognit.AlertDialog

  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:title, :string, required: true)
  attr(:description, :string)
  attr(:rest, :global)

  slot(:inner_block)

  def confirmation_dialog(assigns) do
    ~H"""
    <.alert_dialog id={@id}>
      <.alert_dialog_trigger>
        <.button variant="outline">Show Alert Dialog</.button>
      </.alert_dialog_trigger>
      <.alert_dialog_content>
        <.alert_dialog_header>
          <.alert_dialog_title>{@title}</.alert_dialog_title>
          <.alert_dialog_description>
            {@description}
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
          <.alert_dialog_action>Continue</.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog_content>
    </.alert_dialog>
    """
  end
end
