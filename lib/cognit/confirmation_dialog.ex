defmodule Cognit.ConfirmationDialog do
  use Cognit, :component

  import Cognit.AlertDialog

  @doc """
  Renders a confirmation dialog component with customizable behavior and content.

  ## Attributes
  - `id`: A unique identifier for the alert dialog (required)
  - `open`: Controls whether the dialog is initially open (default: false)
  - `on_open`: Optional handler for the dialog open event
  - `on_close`: Optional handler for the dialog close event
  - `title`: The title of the confirmation dialog (required)
  - `description`: Optional description text for the dialog
  - `on_confirm`: Optional handler for the confirm action
  - `on_cancel`: Optional handler for the cancel action

  ## Slots
  - `trigger`: Optional slot to render a custom dialog trigger
  - `inner_block`: Optional slot for additional content inside the dialog

  ## Example
      <.confirmation_dialog
        id="delete-confirmation"
        title="Confirm Deletion"
        description="Are you sure you want to delete this item?"
        on_confirm={JS.push("confirm_delete")}
        on_cancel={JS.push("cancel_delete")}
      />
  """

  attr :id, :string, required: true, doc: "Unique identifier for the alert dialog"
  attr :open, :boolean, default: false, doc: "Whether the alert dialog is initially open"
  attr :on_open, :any, default: nil, doc: "Handler for alert dialog open event"
  attr :on_close, :any, default: nil, doc: "Handler for alert dialog close event"
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :on_confirm, :any, default: nil
  attr :on_cancel, :any, default: nil
  attr :rest, :global

  slot :inner_block
  slot :trigger

  def confirmation_dialog(assigns) do
    ~H"""
    <.alert_dialog id={@id} open={@open} on-open={@on_open} on-close={@on_close} {@rest}>
      <.alert_dialog_trigger :if={@trigger != []}>
        {render_slot(@trigger)}
      </.alert_dialog_trigger>

      <.alert_dialog_content>
        <.alert_dialog_header>
          <.alert_dialog_title>
            {@title}
          </.alert_dialog_title>
          <.alert_dialog_description :if={@description}>
            {@description}
          </.alert_dialog_description>
        </.alert_dialog_header>

        {render_slot(@inner_block)}

        <.alert_dialog_footer>
          <.alert_dialog_cancel variant="destructive" phx-click={@on_cancel}>
            {pgettext("confirmation dialog action", "No")}
          </.alert_dialog_cancel>
          <.alert_dialog_action variant="secondary" phx-click={@on_confirm}>
            {pgettext("confirmation dialog action", "Yes")}
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog_content>
    </.alert_dialog>
    """
  end
end
