defmodule Cognit.StaticTest do
  use ExUnit.Case, async: true

  import Plug.Test

  defp request(path, headers \\ []) do
    conn =
      Enum.reduce(headers, conn(:get, path), fn {key, value}, conn ->
        Plug.Conn.put_req_header(conn, key, value)
      end)

    Cognit.Static.call(conn, Cognit.Static.init([]))
  end

  test "serves a stylesheet per font whose hashed URLs resolve to immutable files" do
    conn = request("/assets/fonts/open_sans.css")

    assert conn.status == 200
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/css; charset=utf-8"]
    assert Plug.Conn.get_resp_header(conn, "cache-control") == ["public, no-cache"]
    assert conn.resp_body =~ ~s|font-family:"Open Sans";font-style:italic;font-weight:800|
    refute conn.resp_body =~ "Material Symbols"

    [_, url] =
      Regex.run(~r/url\("(open_sans\/open-sans-400\.woff2\?vsn=[0-9a-f]{8})"\)/, conn.resp_body)

    font = request("/assets/fonts/" <> url)

    assert font.status == 200

    assert Plug.Conn.get_resp_header(font, "cache-control") == [
             "public, max-age=31536000, immutable"
           ]
  end

  test "doesn't pin a stylesheet requested with another hash" do
    conn = request("/assets/fonts/open_sans.css?vsn=00000000")

    assert conn.status == 200
    assert Plug.Conn.get_resp_header(conn, "cache-control") == ["public, no-cache"]
  end

  test "answers a matching ETag with 304" do
    [etag] = Plug.Conn.get_resp_header(request("/assets/fonts/material_symbols.css"), "etag")
    conn = request("/assets/fonts/material_symbols.css", [{"if-none-match", etag}])

    assert conn.status == 304
    assert conn.resp_body == ""

    weak = request("/assets/fonts/material_symbols.css", [{"if-none-match", ~s("x", W/#{etag})}])
    assert weak.status == 304
  end

  test "rejects a mount path that would split stylesheets from their fonts" do
    assert_raise ArgumentError, ~r/static_at/, fn -> Cognit.Static.init(at: "/cognit") end
    assert_raise ArgumentError, ~r/static_at/, fn -> Cognit.Static.init(only_matching: ~w(f)) end
  end

  test "passes through paths it doesn't serve" do
    refute request("/assets/fonts/missing.woff2").halted
    refute request("/assets/fonts/missing.css").halted
    refute request("/assets/app.css").halted
  end
end
