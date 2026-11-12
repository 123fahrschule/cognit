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
      <%!-- `-ml-1.5` puts the resting icon on the px-6 edge. --%>
      <.sidebar_trigger class="-ml-1.5" />

      {render_slot(@inner_block)}
    </div>
    """
  end
end
