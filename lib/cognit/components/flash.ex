defmodule Cognit.Components.Flash do
  use Cognit, :component
  use Gettext, backend: CognitWeb.Gettext

  import Cognit.Alert
  import Cognit.Button

  import Cognit.Components.Icon

  attr(:id, :string)
  attr(:title, :string)
  attr(:description, :string, default: nil)
  attr(:kind, :string, default: "info")
  attr(:rest, :global)

  slot(:icon)

  def flash(assigns) do
    ~H"""
    <.alert id={@id} variant={alert_variant(@kind)} {@rest}>
      <%= if @icon != [] do %>
        {render_slot(@icon)}
      <% else %>
        <.icon name={alert_icon(@kind)} class="text-[16px]" />
      <% end %>
      <.alert_title class="pr-7">
        {@title}
      </.alert_title>
      <.alert_description :if={@description}>
        {@description}
      </.alert_description>
      <div class="absolute top-1 right-1 flex !pl-0">
        <.button
          variant="ghost"
          size="icon"
          class="size-6"
          phx-click={JS.exec("phx-remove", to: "##{@id}")}
        >
          <.icon name="close" class="text-[16px]" />
        </.button>
      </div>
    </.alert>
    """
  end

  attr(:flash, :map)

  def flash_group(assigns) do
    ~H"""
    <div class="fixed inset-x-0 top-8 z-[60] px-4 pointer-events-none">
      <div class="mx-auto w-full max-w-[500px] flex flex-col gap-4 *:pointer-events-auto">
        <.client_error_flash />
        <.server_error_flash />
        <.flash
          :for={{kind, message} <- @flash}
          id={"flash_" <> kind}
          kind={kind}
          title={message}
          phx-hook="FlashMessage"
          data-type={kind}
          phx-remove={JS.push("lv:clear-flash", value: %{key: kind}) |> hide("##{"flash_" <> kind}")}
        />
      </div>
    </div>
    """
  end

  defp client_error_flash(assigns) do
    ~H"""
    <.flash
      id="client-error"
      kind="error"
      title={pgettext("flash message, live socket disconnected title", "We can't find the internet")}
      description={
        pgettext(
          "flash message, live socket disconnected description",
          "Attempting to reconnect"
        )
      }
      phx-disconnected={JS.remove_attribute("hidden", to: ".phx-client-error #client-error")}
      phx-connected={JS.set_attribute({"hidden", ""})}
      phx-remove={JS.exec("phx-connected", to: "#client-error")}
      hidden
    >
      <:icon>
        <.icon name="autorenew" class="text-[16px] motion-safe:animate-spin" />
      </:icon>
    </.flash>
    """
  end

  defp server_error_flash(assigns) do
    ~H"""
    <.flash
      id="server-error"
      kind="error"
      title={pgettext("flash message, live view crashed title", "Something went wrong!")}
      description={
        pgettext(
          "flash message, live view crashed description",
          "Hang in there while we get back on track"
        )
      }
      phx-disconnected={JS.remove_attribute("hidden", to: ".phx-server-error #server-error")}
      phx-connected={JS.set_attribute({"hidden", ""})}
      phx-remove={JS.exec("phx-connected", to: "#server-error")}
      hidden
    >
      <:icon>
        <.icon name="autorenew" class="text-[16px] motion-safe:animate-spin" />
      </:icon>
    </.flash>
    """
  end

  defp alert_variant("error"), do: "destructive"
  defp alert_variant(_), do: "default"

  defp alert_icon("error"), do: "error"
  defp alert_icon(_), do: "info"

  defp hide(js, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition: {
        "transition-all ease-in duration-200",
        "opacity-100 translate-y-0 sm:scale-100",
        "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
      }
    )
  end
end
