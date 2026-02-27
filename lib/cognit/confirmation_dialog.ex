defmodule Cognit.ConfirmationDialog do
  use Cognit, :component

  import Cognit.AlertDialog
  import Cognit.Icon

  attr :id, :string, required: true, doc: "Unique identifier for the alert dialog"
  attr :open, :boolean, default: false, doc: "Whether the alert dialog is initially open"
  attr :on_open, :any, default: nil, doc: "Handler for alert dialog open event"
  attr :on_close, :any, default: nil, doc: "Handler for alert dialog close event"
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :icon, :string, default: "warning", doc: "Icon name displayed above the title"
  attr :confirm_label, :string, default: nil
  attr :cancel_label, :string, default: nil

  attr :confirm_variant, :string,
    default: "destructive",
    values: ~w(default secondary destructive outline ghost link)

  attr :on_confirm, :any, default: nil
  attr :on_cancel, :any, default: nil
  attr :rest, :global

  slot :inner_block
  slot :trigger

  def confirmation_dialog(assigns) do
    assigns =
      assigns
      |> assign_new(:resolved_confirm_label, fn ->
        assigns[:confirm_label] || pgettext("confirmation dialog action", "Confirm")
      end)
      |> assign_new(:resolved_cancel_label, fn ->
        assigns[:cancel_label] || pgettext("confirmation dialog action", "Cancel")
      end)

    ~H"""
    <.alert_dialog id={@id} open={@open} on-open={@on_open} on-close={@on_close} {@rest}>
      <.alert_dialog_trigger :if={@trigger != []}>
        {render_slot(@trigger)}
      </.alert_dialog_trigger>

      <.alert_dialog_content>
        <.alert_dialog_header class="text-center sm:text-center">
          <div
            :if={@icon}
            class="mx-auto mb-2 flex size-12 items-center justify-center rounded-full bg-destructive/10"
          >
            <.icon name={@icon} class="size-6 text-destructive" />
          </div>
          <.alert_dialog_title>
            {@title}
          </.alert_dialog_title>
          <.alert_dialog_description :if={@description}>
            {@description}
          </.alert_dialog_description>
        </.alert_dialog_header>

        {render_slot(@inner_block)}

        <.alert_dialog_footer class="sm:justify-center">
          <.alert_dialog_cancel phx-click={@on_cancel}>
            {@resolved_cancel_label}
          </.alert_dialog_cancel>
          <.alert_dialog_action variant={@confirm_variant} phx-click={@on_confirm}>
            {@resolved_confirm_label}
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog_content>
    </.alert_dialog>
    """
  end
end
