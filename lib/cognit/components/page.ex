defmodule Cognit.Components.Page do
  use Cognit, :component

  import Cognit.Icon

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page(assigns) do
    ~H"""
    <div class={classes(["flex flex-1 min-h-0 flex-col overflow-auto", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :rest, :global

  slot :badge
  slot :inner_block
  slot :actions
  slot :details
  slot :footer

  def page_header(assigns) do
    ~H"""
    <div
      class={
        classes([
          "bg-background border-b px-6 py-4 flex flex-col gap-6",
          @footer != [] && "pb-0",
          @class
        ])
      }
      {@rest}
    >
      <div class="flex items-center gap-4">
        <div
          :if={@title || @description || @badge != []}
          class="flex flex-col gap-2"
        >
          <div class="flex items-center gap-2">
            <h1 :if={@title} class="text-3xl font-semibold leading-none tracking-tight">
              {@title}
            </h1>
            {render_slot(@badge)}
          </div>
          <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
        </div>
        {render_slot(@inner_block)}
        <div :if={@actions != []} class="ml-auto flex items-center gap-2">
          {render_slot(@actions)}
        </div>
      </div>
      <div :if={@details != []} class="flex flex-wrap gap-x-6 gap-y-4">
        {render_slot(@details)}
      </div>
      <div :if={@footer != []}>
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :label, :string, default: nil
  attr :icon, :string, default: nil
  attr :rest, :global

  slot :inner_block

  def page_header_detail(assigns) do
    ~H"""
    <div class={classes(["flex flex-col gap-1", @class])} {@rest}>
      <span :if={@label} class="text-sm text-muted-foreground">{@label}</span>
      <div class="flex items-center gap-2">
        <.icon :if={@icon} name={@icon} size="sm" />
        <span class="text-base font-medium text-card-foreground">
          {render_slot(@inner_block)}
        </span>
      </div>
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page_content(assigns) do
    ~H"""
    <div class={classes(["p-6 pb-12 flex flex-1 flex-col gap-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def page_footer(assigns) do
    ~H"""
    <div class={classes(["p-6 shrink-0", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
