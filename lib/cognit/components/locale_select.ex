defmodule Cognit.Components.LocaleSelect do
  use Cognit, :component

  import Cognit.Button
  import Cognit.DropdownMenu

  import Cognit.Components.Icon

  attr(:rest, :global)

  def locale_select(assigns) do
    assigns =
      assigns
      |> assign(:current_locale, Gettext.get_locale())

    ~H"""
    <div id="locale-select" phx-hook="LocaleSelect" {@rest}>
      <.dropdown_menu id="locale-elect-dropdown-menu">
        <.dropdown_menu_trigger>
          <.button size="icon" variant="secondary" >
            <.icon name="language" class="text-[20px]" />
          </.button>
        </.dropdown_menu_trigger>
        <.dropdown_menu_content align="end">
          <.dropdown_menu_item :for={
              {locale, text} <- [
                {"de", "Deutsch"},
                {"en", "English"}
              ]
            }
            on-select={locale != @current_locale && JS.dispatch("set-locale", to: "#locale-select", detail: %{locale: locale})}
            class={["w-full", locale == @current_locale && "font-semibold"]}
          >
            {text}
          </.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
    </div>
    """
  end
end
