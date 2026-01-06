defmodule Cognit.Components.Topbar do
  use Cognit, :component

  import Cognit.Sidebar

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def topbar(assigns) do
    ~H"""
    <div
      class={[
        "h-14 sticky top-0 z-[1] bg-background border-b border-border px-14 py-2 flex gap-4 justify-end items-center",
        @class
      ]}
      {@rest}
    >
      <.sidebar_trigger is_mobile class="md:hidden mr-auto" />

      {render_slot(@inner_block)}
    </div>
    """
  end
end
