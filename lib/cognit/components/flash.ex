defmodule Cognit.Components.Flash do
  use Cognit, :component

  import Cognit.Alert
  import Cognit.Button

  import Cognit.Icon

  attr :id, :string
  attr :title, :string
  attr :description, :string, default: nil
  attr :kind, :string, default: "info"
  attr :rest, :global

  slot :icon

  def flash(assigns) do
    assigns = update(assigns, :kind, &to_string/1)

    ~H"""
    <.alert id={@id} variant={alert_variant(@kind)} {@rest}>
      <%= if @icon != [] do %>
        {render_slot(@icon)}
      <% else %>
        <.icon name={alert_icon(@kind)} size="xs" />
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
          <.icon name="close" size="xs" />
        </.button>
      </div>
    </.alert>
    """
  end

  attr :flash, :map

  def flash_group(assigns) do
    ~H"""
    <div class="fixed inset-x-0 top-8 z-[60] px-4 pointer-events-none">
      <div class="mx-auto w-full max-w-[500px] flex flex-col gap-4 *:pointer-events-auto">
        <.client_error_flash />
        <.server_error_flash />
        <.flash
          :for={{kind, message} <- @flash}
          id={"flash_" <> to_string(kind)}
          kind={to_string(kind)}
          title={message}
          phx-hook="Cognit.FlashMessage"
          data-type={to_string(kind)}
          phx-remove={
            JS.push("lv:clear-flash", value: %{key: kind})
            |> hide("##{"flash_" <> to_string(kind)}")
          }
        />
      </div>
    </div>
    """
  end

  defp client_error_flash(assigns) do
    ~H"""
    <.flash
      id="cognit-client-error"
      kind="error"
      title={pgettext("flash message, live socket disconnected title", "We can't find the internet")}
      description={
        pgettext(
          "flash message, live socket disconnected description",
          "Attempting to reconnect"
        )
      }
      phx-disconnected={JS.remove_attribute("hidden", to: ".phx-client-error #cognit-client-error")}
      phx-connected={JS.set_attribute({"hidden", ""})}
      phx-remove={JS.exec("phx-connected", to: "#cognit-client-error")}
      hidden
    >
      <:icon>
        <.icon name="autorenew" size="xs" class="motion-safe:animate-spin" />
      </:icon>
    </.flash>
    """
  end

  defp server_error_flash(assigns) do
    ~H"""
    <.flash
      id="cognit-server-error"
      kind="error"
      title={pgettext("flash message, live view crashed title", "Something went wrong!")}
      description={
        pgettext(
          "flash message, live view crashed description",
          "Hang in there while we get back on track"
        )
      }
      phx-disconnected={JS.remove_attribute("hidden", to: ".phx-server-error #cognit-server-error")}
      phx-connected={JS.set_attribute({"hidden", ""})}
      phx-remove={JS.exec("phx-connected", to: "#cognit-server-error")}
      hidden
    >
      <:icon>
        <.icon name="autorenew" size="xs" class="motion-safe:animate-spin" />
      </:icon>
    </.flash>
    """
  end

  defp alert_variant("error"), do: "error"
  defp alert_variant("alert"), do: "alert"
  defp alert_variant("destructive"), do: "destructive"
  defp alert_variant("success"), do: "success"
  defp alert_variant("warning"), do: "warning"
  defp alert_variant(_kind), do: "info"

  defp alert_icon("alert"), do: "error"
  defp alert_icon("destructive"), do: "error"
  defp alert_icon("error"), do: "error"
  defp alert_icon("success"), do: "check_circle"
  defp alert_icon("warning"), do: "warning"
  defp alert_icon(_kind), do: "info"

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
