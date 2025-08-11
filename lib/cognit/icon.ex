defmodule Cognit.Icon do
  use Cognit, :component

  attr(:class, :any, default: nil)
  attr(:name, :any, required: true)
  attr(:outlined, :boolean, default: false)
  attr(:rest, :global)

  def icon(assigns) do
    ~H"""
    <span class={["icon", get_material_icon_class(@outlined), @class]} {@rest}>
      {@name}
    </span>
    """
  end

  defp get_material_icon_class(true), do: "material-symbols-outlined"
  defp get_material_icon_class(_), do: "material-symbols"
end
