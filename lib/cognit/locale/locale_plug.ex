defmodule Cognit.LocalePlug do
  @moduledoc """
  Resolves the request locale and stores it in the session and `conn.assigns`.

  Lookup order: `locale` query param, `app_locale` cookie, then the default.
  A value outside the accepted list falls back to the default.

  Both settings are read at compile time here and in `Cognit.LocaleHook`, so they belong in `config/config.exs`
  (or a file it imports), never in `runtime.exs`, and a change needs
  `mix deps.compile cognit --force`:

      config :cognit,
        default_locale: "en",      # default "de"
        locales: ["de", "en", "fr"] # default ["de", "en"]

  `:locales` is also the list `Cognit.Components.LocaleSelect` offers.
  Both can be overridden per pipeline with plug options of the same name.
  """

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

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end
end
