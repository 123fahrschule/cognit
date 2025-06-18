defmodule Cognit do
  @moduledoc """
  Documentation for `Cognit`.
  """

  defmacro __using__(_) do
    quote do
      use CognitWeb.Components.MishkaComponents
    end
  end
end
