defmodule Cognit.Static do
  @moduledoc """
  Serves the bundled Open Sans and Material Symbols fonts, with one stylesheet per font that
  declares its `@font-face` rules.

  Mount it in the endpoint before the router, after the app's own `Plug.Static` so a file the
  app ships at the same path wins:

      plug Cognit.Static

  `Cognit.Assets.head/1` links the stylesheets. A page that can't render it can link
  `/assets/fonts/open_sans.css` and `/assets/fonts/material_symbols.css` directly; those
  unhashed URLs are revalidated by ETag, while the hashed ones the component renders and the font
  URLs inside the stylesheets carry `?vsn=<content hash>` and are cached for a year.

  The prefix is `config :cognit, static_at: "/assets"`, read at compile time. Other options
  except `:at`, `:from`, `:only` and `:only_matching` are passed on to `Plug.Static` for the
  font files, e.g. `headers: %{"access-control-allow-origin" => "*"}` when the stylesheets are
  linked from another origin.
  """

  @behaviour Plug

  import Plug.Conn

  @at Application.compile_env(:cognit, :static_at, "/assets")

  unless match?("/" <> _, @at) do
    raise ArgumentError, "config :cognit, static_at: must start with \"/\", got #{inspect(@at)}"
  end

  @root Path.expand("../../priv/static/fonts", __DIR__)

  @faces %{
    "open_sans.css" =>
      for weight <- [300, 400, 500, 600, 700, 800], style <- ["normal", "italic"] do
        suffix = if style == "italic", do: "italic", else: ""

        %{
          family: "Open Sans",
          style: style,
          weight: weight,
          display: "swap",
          format: "woff2",
          file: "open_sans/open-sans-#{weight}#{suffix}.woff2"
        }
      end,
    "material_symbols.css" => [
      %{
        family: "Material Symbols Outlined",
        style: "normal",
        weight: 400,
        display: "block",
        format: "woff2-variations",
        file: "material_symbols/MaterialSymbolsOutlined.woff2"
      }
    ]
  }

  # Hashes are baked in at compile time; the font files are external resources, so a
  # `mix fonts.update` or `mix icons.update` run recompiles this module.
  @stylesheets Map.new(@faces, fn {name, faces} ->
                 css =
                   for face <- faces, into: "" do
                     path = Path.join(@root, face.file)
                     @external_resource path
                     hash = :crypto.hash(:md5, File.read!(path)) |> Base.encode16(case: :lower)

                     """
                     @font-face{font-family:"#{face.family}";font-style:#{face.style};\
                     font-weight:#{face.weight};font-display:#{face.display};\
                     src:url("#{face.file}?vsn=#{binary_part(hash, 0, 8)}") format("#{face.format}")}
                     """
                   end

                 {name, {css, :crypto.hash(:md5, css) |> Base.encode16(case: :lower)}}
               end)

  @fonts Enum.map(Map.keys(@stylesheets), &String.to_atom(Path.rootname(&1)))

  @doc false
  def stylesheet_path(font) do
    case Map.fetch(@stylesheets, "#{font}.css") do
      {:ok, {_css, hash}} ->
        "#{String.trim_trailing(@at, "/")}/fonts/#{font}.css?vsn=#{binary_part(hash, 0, 8)}"

      :error ->
        raise ArgumentError, "unknown font #{inspect(font)}, expected one of #{inspect(@fonts)}"
    end
  end

  @impl true
  def init(options) do
    if fixed = Enum.find([:at, :from, :only, :only_matching], &Keyword.has_key?(options, &1)) do
      raise ArgumentError,
            "Cognit.Static does not accept #{inspect(fixed)}; set the prefix with " <>
              "`config :cognit, static_at: ...`"
    end

    prefix = Plug.Router.Utils.split(@at) ++ ["fonts"]

    stylesheets =
      Map.new(@stylesheets, fn {name, stylesheet} -> {prefix ++ [name], stylesheet} end)

    static =
      [
        at: @at,
        from: {:cognit, "priv/static"},
        only: ~w(fonts),
        cache_control_for_vsn_requests: "public, max-age=31536000, immutable"
      ]
      |> Keyword.merge(options)
      |> Plug.Static.init()

    {stylesheets, static}
  end

  @impl true
  def call(%Plug.Conn{method: method} = conn, {stylesheets, static})
      when method in ~w(GET HEAD) do
    case Map.fetch(stylesheets, conn.path_info) do
      {:ok, stylesheet} -> send_stylesheet(conn, stylesheet)
      :error -> Plug.Static.call(conn, static)
    end
  end

  def call(conn, {_stylesheets, static}), do: Plug.Static.call(conn, static)

  defp send_stylesheet(conn, {css, hash}) do
    etag = ~s("#{hash}")

    # A stale vsn (rolling deploy) must not be pinned for a year under the new URL. The font
    # files have no such check: Plug.Static pins any `?vsn=` request, and only this stylesheet
    # emits those URLs.
    cache_control =
      if URI.decode_query(conn.query_string)["vsn"] == binary_part(hash, 0, 8),
        do: "public, max-age=31536000, immutable",
        else: "public, no-cache"

    conn =
      conn
      |> put_resp_content_type("text/css")
      |> put_resp_header("cache-control", cache_control)
      |> put_resp_header("etag", etag)

    if etag in request_etags(conn),
      do: conn |> send_resp(304, "") |> halt(),
      else: conn |> send_resp(200, css) |> halt()
  end

  defp request_etags(conn) do
    conn
    |> get_req_header("if-none-match")
    |> Enum.flat_map(&String.split(&1, ","))
    |> Enum.map(&(&1 |> String.trim() |> String.replace_prefix("W/", "")))
  end
end
