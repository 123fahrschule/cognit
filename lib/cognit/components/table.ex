defmodule Cognit.Components.Table do
  use Cognit, :component

  import Cognit.Table

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block
  slot :footer

  def table_container(assigns) do
    ~H"""
    <div class={classes(["flex flex-col", @class])} {@rest}>
      <div class="rounded-lg border overflow-auto">
        {render_slot(@inner_block)}
      </div>
      {render_slot(@footer)}
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def table_empty(assigns) do
    ~H"""
    <.table_row class={["[&:not(:only-child)]:hidden", @class]} {@rest}>
      <.table_cell colspan="100%">
        {render_slot(@inner_block)}
      </.table_cell>
    </.table_row>
    """
  end
end
