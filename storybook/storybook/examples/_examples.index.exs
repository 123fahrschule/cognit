defmodule Storybook.Examples.Index do
  @moduledoc false
  use PhoenixStorybook.Index

  def folder_name, do: "Examples"
  def folder_icon, do: {:fa, "code"}
  def folder_open?, do: true
  def folder_index, do: -1
end
