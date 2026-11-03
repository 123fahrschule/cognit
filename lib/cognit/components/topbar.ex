defmodule Cognit.Components.Topbar do
  use Cognit, :component

  import Cognit.Sidebar

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def topbar(assigns) do
    ~H"""
    <div
      class={
        classes([
          "h-16 shrink-0 sticky top-0 z-[1] bg-background border-b border-border px-6 py-2 flex gap-2 items-center",
          @class
        ])
      }
      {@rest}
    >
      <%!-- Hide the wrapper: `class` reaches only the button, so its tooltip root would still take the gap. `-ml-1.5` puts the resting icon on the px-6 edge. --%>
      <div class="contents md:hidden">
        <.sidebar_trigger is_mobile class="-ml-1.5" />
      </div>
      <div class="hidden md:contents">
        <.sidebar_trigger class="-ml-1.5" />
      </div>

      {render_slot(@inner_block)}
    </div>
    """
  end
end
