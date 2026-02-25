defmodule Cognit.Components.Page do
  use Cognit, :component

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page(assigns) do
    ~H"""
    <div class={["flex flex-1 min-h-0 flex-col overflow-auto", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :title, :string, default: nil
  attr :rest, :global

  slot :inner_block
  slot :actions

  def page_header(assigns) do
    ~H"""
    <div class={["bg-background px-6 py-4 flex items-center gap-4", @class]} {@rest}>
      <h1 :if={@title} class="text-3xl font-semibold leading-none tracking-tight">{@title}</h1>
      {render_slot(@inner_block)}
      <div class="ml-auto flex items-center gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page_content(assigns) do
    ~H"""
    <div class={["p-6 pb-12 flex flex-1 flex-col gap-6", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page_footer(assigns) do
    ~H"""
    <div class={["p-6 shrink-0", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
