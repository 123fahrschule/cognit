defmodule Cognit.Application do
  def start(_type, _args) do
    children = [TwMerge.Cache]
    children
  end
end
