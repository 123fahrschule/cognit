defmodule Storybook.BugReproductions.Index do
  @moduledoc false
  use PhoenixStorybook.Index

  def folder_name, do: "Bug Reproductions"
  def folder_icon, do: {:fa, "bomb"}
  def folder_index, do: 99
end
