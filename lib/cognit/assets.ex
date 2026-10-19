defmodule Cognit.Assets do
  @moduledoc """
  Renders what Cognit needs in the root layout's `<head>`; `Cognit.Static` in the endpoint
  serves it.

      <head>
        <Cognit.Assets.head />
      </head>

  A layout that renders no Cognit components can load Open Sans alone:

      <Cognit.Assets.head fonts={[:open_sans]} />
  """
  use Cognit, :component

  attr :fonts, :list,
    default: [:open_sans, :material_symbols],
    doc: "any of `:open_sans`, `:material_symbols`; anything else raises on render"

  def head(assigns) do
    ~H"""
    <link
      :for={font <- @fonts}
      rel="stylesheet"
      href={Cognit.Static.stylesheet_path(font)}
    />
    """
  end
end
