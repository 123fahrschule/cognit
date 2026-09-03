defmodule Cognit.Components.Table do
  use Cognit, :component

  import Cognit.Table

  @doc """
  Renders a table wrapped in a bordered, scrollable container.

  The `:footer` slot renders below the container, outside its border.
  """
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block
  slot :footer

  def table_container(assigns) do
    ~H"""
    <div class={classes(["flex flex-col", @class])} {@rest}>
      <div class="rounded-md border overflow-auto">
        {render_slot(@inner_block)}
      </div>
      {render_slot(@footer)}
    </div>
    """
  end

  @doc """
  Renders a placeholder row for a table with no rows.

  The row hides itself via `:not(:only-child)` once the body holds any other
  row, so it needs no `:if` at the call site.

  ## Column span

  The default `colspan` of `100%` is parsed as `colspan=100`, so the table gets
  100 columns rather than the number its header declares. Under the default auto
  table layout the surplus columns hold no content and no width, so they
  collapse and the placeholder spans the row as intended.

  Under `table-fixed` they do not collapse — fixed layout divides the leftover
  width equally across every auto-width column, and the phantoms take a share
  each, shrinking the real columns to almost nothing. Fixed-layout tables pass
  their own column count instead:

      <.table class="table-fixed">
        <.table_header>
          <.table_row>
            <.table_head>Name</.table_head>
            <.table_head class="w-[160px]">Status</.table_head>
            <.table_head class="w-[160px]">Updated</.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_empty colspan={3}>No results</.table_empty>
        </.table_body>
      </.table>

  Passing `nil` omits the attribute entirely, leaving the placeholder in the
  first column.
  """
  attr :colspan, :any, default: "100%", doc: "columns the placeholder spans"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def table_empty(assigns) do
    ~H"""
    <.table_row class={["[&:not(:only-child)]:hidden", @class]} {@rest}>
      <.table_cell colspan={@colspan}>
        {render_slot(@inner_block)}
      </.table_cell>
    </.table_row>
    """
  end
end
