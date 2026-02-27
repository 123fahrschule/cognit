defmodule Storybook.Recipes.Index do
  @moduledoc false
  use PhoenixStorybook.Index

  def folder_name, do: "Recipes"
  def folder_icon, do: {:fa, "toolbox", :light, "psb-mr-1"}
  def folder_open?, do: true
end
