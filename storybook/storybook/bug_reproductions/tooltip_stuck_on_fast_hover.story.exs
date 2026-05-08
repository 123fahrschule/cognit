defmodule Storybook.BugReproductions.TooltipStuckOnFastHover do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc do
    """
    Bug reproduction for tooltips getting stuck open after fast hover.

    Steps:
    1. Move the cursor quickly across the grid of buttons below, sweeping over many in succession.
    2. Stop somewhere outside the grid.
    3. Observe: one or more tooltips remain visible even though no button is hovered.

    Why it happens:
    - Hovering a trigger schedules an open via `setTimeout` (default 150ms `open-delay`).
    - If the cursor leaves before that timer fires, the component is still in the
      `closed` state, and the `mouseleave` handler is only registered for the
      `open` state — so the pending open is never cancelled.
    - The timer fires later, the tooltip opens, but `mouseleave` already happened
      and won't fire again. Tooltip stays open until the user re-enters and leaves.
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 40)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 space-y-4">
      <p class="text-sm text-muted-foreground">
        Sweep the cursor quickly across the grid, then stop outside it.
      </p>

      <div class="grid grid-cols-10 gap-2 max-w-3xl">
        <.tooltip :for={i <- 1..@count} id={"stuck-tooltip-#{i}"}>
          <.tooltip_trigger>
            <.button variant="outline" size="sm">{i}</.button>
          </.tooltip_trigger>
          <.tooltip_content>
            <p>Tooltip #{i}</p>
          </.tooltip_content>
        </.tooltip>
      </div>

      <div class="h-32 border border-dashed rounded-md flex items-center justify-center text-sm text-muted-foreground">
        Park the cursor here after sweeping the grid.
      </div>
    </div>
    """
  end
end
