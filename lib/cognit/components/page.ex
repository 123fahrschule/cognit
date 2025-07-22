defmodule Cognit.Components.Page do
  use Cognit, :component

  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot(:inner_block)

  def page(assigns) do
    ~H"""
    <div class={["", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :any, default: nil)
  attr(:title, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block)
  slot(:actions)

  def page_header(assigns) do
    ~H"""
    <div class={["bg-background border-b px-14 py-4 flex gap-6", @class]} {@rest}>
      <h1 :if={@title} class="text-2xl font-semibold tracking-tight">{@title}</h1>
      <%= render_slot(@inner_block) %>
      <div class="ml-auto flex items-center gap-4">
        <%= render_slot(@actions) %>
      </div>
    </div>
    """
  end

  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot(:inner_block)

  def page_content(assigns) do
    ~H"""
    <div class={["px-16 py-6 flex flex-col gap-6", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot(:inner_block)

  def page_footer(assigns) do
    ~H"""
    <div class={["px-16 py-6", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
