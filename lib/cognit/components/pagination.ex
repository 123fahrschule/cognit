defmodule Cognit.Components.Pagination do
  use Cognit, :component

  import Cognit.Pagination

  @doc """
  Renders a button group.

  ## Examples

      <.pagination page={1} total_pages={100} />
  """
  attr :page, :integer, default: 1
  attr :total_pages, :integer
  attr :on_select, :any, default: %JS{}
  attr :rest, :global

  def custom_pagination(assigns) do
    ~H"""
    <.pagination {@rest}>
      <.pagination_content>
        <.pagination_item>
          <.pagination_previous phx-click={@on_select} phx-value-page={max(1, @page - 1)} />
        </.pagination_item>

        <.pagination_item :for={block <- calculate_display_btn(@page, @total_pages)}>
          <%= case block do %>
            <% :ellipsis -> %>
              <.pagination_ellipsis />
            <% _ -> %>
              <.pagination_link
                is-active={block == @page}
                phx-click={@on_select}
                phx-value-page={block}
              >
                {block}
              </.pagination_link>
          <% end %>
        </.pagination_item>

        <.pagination_item>
          <.pagination_next phx-click={@on_select} phx-value-page={min(@total_pages, @page + 1)} />
        </.pagination_item>
      </.pagination_content>
    </.pagination>
    """
  end

  @max_display_block 7
  @doc """

  Returns a list of display buttons for pagination based on the current page, page size, and total entries.

  ## Parameters

  - page - the current page number.
  - page_size - the number of entries per page.
  - total_entries - the total number of entries available.

  ## Description
  Calculates which page numbers to display as buttons in a pagination control.

  """
  def calculate_display_btn(page, total_pages) do
    cond do
      total_pages <= @max_display_block ->
        Enum.map(1..total_pages, & &1)

      page <= 4 ->
        Enum.map(1..5, & &1) ++ [:ellipsis, total_pages]

      total_pages - page <= 3 ->
        start_max_block_4 = total_pages - 4
        [1, :ellipsis] ++ Enum.map(start_max_block_4..total_pages, & &1)

      true ->
        [1, :ellipsis, page - 1, page, page + 1, :ellipsis, total_pages]
    end
  end
end
