defmodule Cognit.ButtonGroup do
  @moduledoc """
  Joins related buttons into a single segmented control.

  Render `Cognit.Button.button/1` children directly. The group collapses the
  inner corners and merges adjacent borders so the buttons read as one control,
  while each button keeps its own variant, size, and behaviour.

  ## Examples

      <.button_group>
        <.button variant="outline">Left</.button>
        <.button variant="outline">Center</.button>
        <.button variant="outline">Right</.button>
      </.button_group>

      <.button_group orientation="vertical">
        <.button variant="outline">Top</.button>
        <.button variant="outline">Bottom</.button>
      </.button_group>
  """
  use Cognit, :component

  @doc """
  Renders a button group.

  ## Attributes

  * `:orientation` - Layout direction: `"horizontal"` (default) or `"vertical"`.
  * `:class` - Additional CSS classes to apply to the group container.
  """
  attr :orientation, :string, values: ~w(horizontal vertical), default: "horizontal"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def button_group(assigns) do
    ~H"""
    <div
      role="group"
      class={
        classes([
          "inline-flex isolate",
          orientation_classes(@orientation),
          "[&>*:hover]:z-10 [&>*:focus-visible]:z-10",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp orientation_classes("vertical") do
    "flex-col [&>*:not(:first-child)]:-mt-px [&>*:not(:first-child)]:rounded-t-none [&>*:not(:last-child)]:rounded-b-none"
  end

  defp orientation_classes(_horizontal) do
    "[&>*:not(:first-child)]:-ml-px [&>*:not(:first-child)]:rounded-l-none [&>*:not(:last-child)]:rounded-r-none"
  end
end
