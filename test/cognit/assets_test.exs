defmodule Cognit.AssetsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Plug.Test

  defp hrefs(assigns) do
    html =
      ~H"""
      <Cognit.Assets.head {@rest} />
      """
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    ~r/rel="stylesheet" href="([^"]+)"/ |> Regex.scan(html) |> Enum.map(&List.last/1)
  end

  test "links each font stylesheet with a hash the plug serves as immutable" do
    assert [
             "/assets/fonts/open_sans.css?vsn=" <> _ = open_sans,
             "/assets/fonts/material_symbols.css?vsn=" <> _
           ] = hrefs(%{rest: %{}})

    conn = :get |> conn(open_sans) |> Cognit.Static.call(Cognit.Static.init([]))

    assert conn.status == 200

    assert Plug.Conn.get_resp_header(conn, "cache-control") == [
             "public, max-age=31536000, immutable"
           ]
  end

  test "links only the requested fonts" do
    assert ["/assets/fonts/open_sans.css?vsn=" <> _] = hrefs(%{rest: %{fonts: [:open_sans]}})
  end

  test "names the accepted fonts for an unknown one" do
    assert_raise ArgumentError, ~r/:open_san.*:open_sans/, fn ->
      hrefs(%{rest: %{fonts: [:open_san]}})
    end
  end
end
