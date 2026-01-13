defmodule Cognit.LocalePlug do
  import Plug.Conn

  @default_locale Application.compile_env(:cognit, :default_locale, "de")
  @locales Application.compile_env(:cognit, :locales, ["de", "en"])

  def init(options), do: options

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, options) do
    set_locale(conn, normalize_locale(locale, options))
  end

  def call(%Plug.Conn{cookies: %{"app_locale" => locale}} = conn, options) do
    set_locale(conn, normalize_locale(locale, options))
  end

  def call(conn, options) do
    set_locale(conn, Keyword.get(options, :default_locale, @default_locale))
  end

  defp normalize_locale(locale, options) do
    if locale in Keyword.get(options, :locales, @locales),
      do: locale,
      else: Keyword.get(options, :default_locale, @default_locale)
  end

  defp set_locale(conn, locale) do
    Gettext.put_locale(locale)

    put_session(conn, :locale, locale)
  end
end
