defmodule Cognit.Components.LocaleSelect do
  use Cognit, :component

  import Cognit.Button
  import Cognit.DropdownMenu

  @locales [
    {"de", "Deutsch"},
    {"en", "English"}
  ]

  attr :rest, :global

  def locale_select(assigns) do
    assigns =
      assigns
      |> assign(:current_locale, Gettext.get_locale())
      |> assign(:locales, @locales)

    ~H"""
    <div id="locale-select" phx-hook="LocaleSelect" {@rest}>
      <.dropdown_menu id="locale-select-dropdown-menu">
        <.dropdown_menu_trigger>
          <.button variant="secondary">
            <.flag locale={@current_locale} />
            {String.upcase(@current_locale)}
          </.button>
        </.dropdown_menu_trigger>
        <.dropdown_menu_content align="end">
          <.dropdown_menu_item
            :for={{locale, text} <- @locales}
            on-select={
              locale != @current_locale &&
                JS.dispatch("set-locale", to: "#locale-select", detail: %{locale: locale})
            }
            class={["w-full gap-2", locale == @current_locale && "font-semibold"]}
          >
            <.flag locale={locale} />
            {text}
          </.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
    </div>
    """
  end

  attr :locale, :string, required: true

  defp flag(%{locale: "de"} = assigns) do
    ~H"""
    <svg class="size-4 shrink-0" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="16" height="5.33" fill="#151515" />
      <rect y="5.33" width="16" height="5.34" fill="#F93939" />
      <rect y="10.67" width="16" height="5.33" fill="#FFDA2C" />
    </svg>
    """
  end

  defp flag(%{locale: "en"} = assigns) do
    ~H"""
    <svg class="size-4 shrink-0" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="16" height="16" fill="#1A47B8" />
      <path d="M0 0L16 16M16 0L0 16" stroke="white" stroke-width="2" />
      <path d="M0 0L16 16M16 0L0 16" stroke="#F93939" stroke-width="1" />
      <rect x="6" width="4" height="16" fill="white" />
      <rect y="6" width="16" height="4" fill="white" />
      <rect x="6.5" width="3" height="16" fill="#F93939" />
      <rect y="6.5" width="16" height="3" fill="#F93939" />
    </svg>
    """
  end
end
