defmodule Cognit.Components.Pagination do
  use Cognit, :component

  import Cognit.Button
  import Cognit.Icon

  @doc """
  Renders a data table pagination component.

  Shows a simple Previous/Next layout on mobile and a detailed layout with
  rows-per-page selector, page indicator, and first/prev/next/last buttons on desktop.

  ## Examples

      <.pagination
        page={1}
        total_pages={10}
        total_entries={100}
        on_change="pagination_changed"
      />

      <.pagination
        page={1}
        total_pages={10}
        total_entries={100}
        page_size={10}
        page_sizes={[10, 20, 50, 100]}
        on_change="pagination_changed"
      />
  """
  attr :page, :integer, default: 1
  attr :total_pages, :integer, required: true
  attr :total_entries, :integer, required: true
  attr :page_size, :integer, default: 10
  attr :page_sizes, :list, default: [10, 20, 30, 40, 50]
  attr :on_change, :any, default: %JS{}
  attr :class, :any, default: nil
  attr :rest, :global

  def pagination(assigns) do
    ~H"""
    <div class={classes(["flex items-center justify-between pt-4", @class])} {@rest}>
      <div class="text-sm text-muted-foreground">
        {pgettext("pagination", "%{count} out of %{total} rows",
          count: min(@page_size, @total_entries - (@page - 1) * @page_size),
          total: @total_entries
        )}
      </div>

      <%!-- Mobile: Previous / Next --%>
      <div class="flex items-center gap-2 pl-2 lg:hidden">
        <.button
          variant="outline"
          size="sm"
          class="px-4"
          disabled={@page <= 1}
          phx-click={@on_change}
          phx-value-page={max(1, @page - 1)}
          phx-value-page_size={@page_size}
        >
          {pgettext("pagination", "Previous")}
        </.button>
        <.button
          variant="outline"
          size="sm"
          class="px-4"
          disabled={@page >= @total_pages}
          phx-click={@on_change}
          phx-value-page={min(@total_pages, @page + 1)}
          phx-value-page_size={@page_size}
        >
          {pgettext("pagination", "Next")}
        </.button>
      </div>

      <%!-- Desktop: Rows per page + Page indicator + Navigation buttons --%>
      <div class="hidden lg:flex items-center gap-9 pl-2">
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium">
            {pgettext("pagination", "Rows per page")}
          </span>
          <form phx-change={@on_change}>
            <input type="hidden" name="page" value={1} />
            <select
              name="page_size"
              class="h-9 min-w-16 rounded-md border border-input bg-background px-3 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
            >
              <option :for={size <- @page_sizes} value={size} selected={size == @page_size}>
                {size}
              </option>
            </select>
          </form>
        </div>

        <span class="text-sm">
          {pgettext("pagination", "Page %{page} of %{total}",
            page: @page,
            total: @total_pages
          )}
        </span>

        <div class="flex items-center gap-2">
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page <= 1}
            phx-click={@on_change}
            phx-value-page={1}
            phx-value-page_size={@page_size}
            aria-label={pgettext("pagination", "First page")}
          >
            <.icon name="keyboard_double_arrow_left" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page <= 1}
            phx-click={@on_change}
            phx-value-page={max(1, @page - 1)}
            phx-value-page_size={@page_size}
            aria-label={pgettext("pagination", "Previous page")}
          >
            <.icon name="chevron_left" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page >= @total_pages}
            phx-click={@on_change}
            phx-value-page={min(@total_pages, @page + 1)}
            phx-value-page_size={@page_size}
            aria-label={pgettext("pagination", "Next page")}
          >
            <.icon name="chevron_right" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page >= @total_pages}
            phx-click={@on_change}
            phx-value-page={@total_pages}
            phx-value-page_size={@page_size}
            aria-label={pgettext("pagination", "Last page")}
          >
            <.icon name="keyboard_double_arrow_right" size="sm" />
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
