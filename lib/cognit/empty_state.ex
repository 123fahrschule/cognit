defmodule Cognit.EmptyState do
  @moduledoc """
  Empty state component for displaying placeholder content when no data is available.

  Provides a centered layout with an illustration, title, and description,
  typically used inside cards or table containers.
  """
  use Cognit, :component

  import Cognit.Icon

  @doc """
  Renders an empty state placeholder.

  ## Examples:

      <.empty_state title="No messages" description="Your inbox is empty." />

      <.empty_state icon="users" title="No users">
        <.button>Add User</.button>
      </.empty_state>
  """

  attr :icon, :string,
    default: nil,
    doc: "Icon name to display instead of the default illustration"

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def empty_state(assigns) do
    ~H"""
    <div
      class={classes(["flex flex-col items-center justify-center py-12 text-center", @class])}
      {@rest}
    >
      <div :if={@icon} class="mb-4 flex size-12 items-center justify-center rounded-full bg-muted">
        <.icon name={@icon} class="size-6 text-muted-foreground" />
      </div>
      <.empty_state_illustration :if={!@icon} />
      <h3 class="text-lg font-semibold text-foreground">{@title}</h3>
      <p :if={@description} class="mt-1 text-sm text-muted-foreground">{@description}</p>
      <div :if={@inner_block != []} class="mt-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp empty_state_illustration(assigns) do
    ~H"""
    <svg
      class="mb-4"
      width="163"
      height="72"
      viewBox="0 0 163 72"
      overflow="visible"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <rect x="28" width="135" height="48" rx="12" class="fill-muted" />
      <rect x="76" y="16" width="39" height="4" rx="2" class="fill-muted-foreground/20" />
      <rect x="76" y="29" width="71" height="4" rx="2" class="fill-muted-foreground/20" />
      <circle cx="52" cy="24" r="16" class="fill-muted-foreground/20" />
      <g filter="url(#empty-state-shadow)">
        <rect y="24" width="135" height="48" rx="12" class="fill-background" />
      </g>
      <rect x="48" y="40" width="39" height="4" rx="2" class="fill-muted-foreground/20" />
      <rect x="48" y="53" width="71" height="4" rx="2" class="fill-muted-foreground/20" />
      <circle cx="24" cy="48" r="16" class="fill-muted-foreground/20" />
      <defs>
        <filter
          id="empty-state-shadow"
          x="-24"
          y="4"
          width="183"
          height="96"
          filterUnits="userSpaceOnUse"
          color-interpolation-filters="sRGB"
        >
          <feFlood flood-opacity="0" result="bg" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="alpha"
          />
          <feOffset dy="4" />
          <feGaussianBlur stdDeviation="12" />
          <feComposite in2="alpha" operator="out" />
          <feColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.1 0"
          />
          <feBlend mode="normal" in2="bg" result="shadow" />
          <feBlend mode="normal" in="SourceGraphic" in2="shadow" result="shape" />
        </filter>
      </defs>
    </svg>
    """
  end
end
