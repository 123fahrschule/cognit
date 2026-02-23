defmodule Cognit.Components.Pagination do
  use Cognit, :component

  import Cognit.Button
  import Cognit.Icon

  alias Cognit.PaginationParams

  @doc """
  Renders a data table pagination component.

  Shows a simple Previous/Next layout on mobile and a detailed layout with
  rows-per-page selector, page indicator, and first/prev/next/last buttons on desktop.

  ## Modes

  **Event mode** — pass `on_change` as a string event name.
  The component pushes `%{page: integer, page_size: integer}` via `JS.push`.
  Use `target` to direct the event to a specific LiveComponent.

      <.pagination pagination={@pagination} on_change="paginate" />
      <.pagination pagination={@pagination} on_change="paginate" target={@myself} />

  **URL mode** — omit `on_change`. The component patches `?page=X&page_size=Y`
  query params into the URL via a JS hook. Handle pagination in `handle_params/3`.

      <.pagination id="pagination" pagination={@pagination} />

  ## Examples

      # With PaginationParams struct (recommended with streams)
      <.pagination pagination={@pagination} on_change="paginate" />

      # With individual attributes
      <.pagination
        page={1}
        total_pages={10}
        total_entries={100}
        on_change="paginate"
      />

      # URL mode — requires id
      <.pagination
        id="pagination"
        page={1}
        total_pages={10}
        total_entries={100}
      />
  """
  attr :id, :string, default: "pagination"
  attr :pagination, PaginationParams, default: nil
  attr :page, :integer, default: 1
  attr :total_pages, :integer, default: 1
  attr :total_entries, :integer, default: 0
  attr :page_size, :integer, default: 10
  attr :page_sizes, :list, default: [10, 20, 30, 40, 50]
  attr :on_change, :string, default: nil
  attr :target, :any, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def pagination(%{pagination: %PaginationParams{} = p} = assigns) do
    assigns
    |> assign(
      page: p.page,
      total_pages: p.total_pages,
      total_entries: p.total_entries,
      page_size: p.page_size,
      pagination: nil
    )
    |> pagination()
  end

  def pagination(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook={!@on_change && "Pagination"}
      class={classes(["flex items-center justify-between pt-4", @class])}
      {@rest}
    >
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
          phx-click={click_js(@on_change, @target, max(1, @page - 1), @page_size)}
        >
          {pgettext("pagination", "Previous")}
        </.button>
        <.button
          variant="outline"
          size="sm"
          class="px-4"
          disabled={@page >= @total_pages}
          phx-click={click_js(@on_change, @target, min(@total_pages, @page + 1), @page_size)}
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
          <form phx-change={form_js(@on_change, @target)}>
            <input type="hidden" name="page" value={1} />
            <select
              name="page_size"
              data-pagination-select
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
            phx-click={click_js(@on_change, @target, 1, @page_size)}
            aria-label={pgettext("pagination", "First page")}
          >
            <.icon name="keyboard_double_arrow_left" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page <= 1}
            phx-click={click_js(@on_change, @target, max(1, @page - 1), @page_size)}
            aria-label={pgettext("pagination", "Previous page")}
          >
            <.icon name="chevron_left" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page >= @total_pages}
            phx-click={click_js(@on_change, @target, min(@total_pages, @page + 1), @page_size)}
            aria-label={pgettext("pagination", "Next page")}
          >
            <.icon name="chevron_right" size="sm" />
          </.button>
          <.button
            variant="outline"
            size="icon"
            class="h-9 w-9"
            disabled={@page >= @total_pages}
            phx-click={click_js(@on_change, @target, @total_pages, @page_size)}
            aria-label={pgettext("pagination", "Last page")}
          >
            <.icon name="keyboard_double_arrow_right" size="sm" />
          </.button>
        </div>
      </div>
    </div>
    """
  end

  defp click_js(nil, _target, page, page_size),
    do: JS.dispatch("pagination:navigate", detail: %{page: page, page_size: page_size})

  defp click_js(event, target, page, page_size),
    do: JS.push(event, value: %{page: page, page_size: page_size}, target: target)

  defp form_js(nil, _target), do: nil
  defp form_js(event, target), do: JS.push(event, target: target)
end
