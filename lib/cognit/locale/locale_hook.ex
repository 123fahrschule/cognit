defmodule Cognit.LocaleHook do
  import Phoenix.Component

  @default_locale Application.compile_env(:cognit, :default_locale, "de")
  @locales Application.compile_env(:cognit, :locales, ["de", "en"])

  def on_mount(_default, params, session, socket) do
    locale =
      params
      |> get_locale()
      |> case do
        nil -> get_locale(session)
        locale -> locale
      end
      |> normalize_locale()

    Gettext.put_locale(locale)

    {:cont, assign(socket, :locale, locale)}
  end

  defp get_locale(%{"locale" => locale}) when is_binary(locale), do: locale
  defp get_locale(_), do: nil

  defp normalize_locale(locale) when locale in @locales, do: locale
  defp normalize_locale(_), do: @default_locale
end
