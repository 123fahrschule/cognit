defmodule Storybook.CognitComponents.Index do
  @moduledoc false
  use PhoenixStorybook.Index

  def folder_name, do: "Components"
  def folder_icon, do: {:fa, "toolbox"}
  def folder_open?, do: true
  def folder_index, do: 0
end
