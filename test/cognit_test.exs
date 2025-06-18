defmodule CognitTest do
  use ExUnit.Case
  doctest Cognit

  test "greets the world" do
    assert Cognit.hello() == :world
  end
end
