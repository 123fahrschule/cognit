defmodule Storybook.Foundation.Index do
  @moduledoc false
  use PhoenixStorybook.Index

  def folder_name, do: "Foundation"
  def folder_icon, do: {:fa, "palette"}
  def folder_index, do: 1
end
