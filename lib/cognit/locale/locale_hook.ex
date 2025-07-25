defmodule Cognit.LocaleHook do
  def on_mount(_default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(locale)

    {:cont, socket}
  end

  def on_mount(_default, _params, _session, socket) do
    {:cont, socket}
  end
end
