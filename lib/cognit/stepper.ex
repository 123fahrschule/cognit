defmodule Cognit.Stepper do
  @moduledoc """
  Horizontal stepper for multi-step flows such as wizards and forms.

  A `stepper/1` lays out a row of `step/1` items, each showing a numbered badge and a
  label. Steps reflect progress through three states:

  * `"default"` — an upcoming step (muted badge, neutral underline)
  * `"current"` — the active step (filled badge, primary underline)
  * `"completed"` — a finished step (filled badge with a check, primary underline)

  Steps are static by default. Pass a navigation attr (`navigate`, `patch`, or `href`)
  or `on_click` to make a step interactive — only interactive steps get hover styling.

  ## Examples

      <.stepper>
        <.step state="completed" number="1">Configuration & Schedule</.step>
        <.step state="current" number="2">Location & Pricing</.step>
        <.step number="3">Capacity & Resources</.step>
      </.stepper>

      <.stepper>
        <.step state="completed" number="1" on_click={JS.push("go", value: %{step: 1})}>
          Configuration & Schedule
        </.step>
        <.step state="current" number="2">Location & Pricing</.step>
        <.step number="3" navigate={~p"/wizard/3"}>Capacity & Resources</.step>
      </.stepper>
  """

  use Cognit, :component

  import Cognit.Icon

  @doc """
  Renders a stepper container that distributes its `step/1` children evenly.

  ## Attributes

  * `:class` - Additional CSS classes to apply to the container
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def stepper(assigns) do
    ~H"""
    <div class={classes(["flex w-full items-start", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a single step within a `stepper/1`.

  Renders as a link when a navigation attr (`navigate`, `patch`, `href`) is given, as a
  button when `on_click` is given, otherwise as a non-interactive element. Hover styling
  is applied only to interactive steps.

  ## Attributes

  * `:state` - Progress state: `"default"`, `"current"`, or `"completed"`
  * `:number` - The step number shown in the badge (replaced by a check when completed)
  * `:on_click` - A `phx-click` value (e.g. a `JS` command) that makes the step a button
  * `:class` - Additional CSS classes to apply to the step
  """
  attr :state, :string, values: ~w(default current completed), default: "default"
  attr :number, :any, default: nil
  attr :on_click, :any, default: nil
  attr :class, :any, default: nil

  attr :rest, :global,
    include:
      ~w(download href hreflang ping referrerpolicy rel target navigate patch replace method csrf_token)

  slot :inner_block, required: true

  def step(assigns) do
    link? = link_nav?(assigns.rest)
    interactive? = link? or assigns.on_click != nil

    as =
      cond do
        link? -> &link/1
        assigns.on_click != nil -> "button"
        true -> "div"
      end

    assigns = assign(assigns, as: as, interactive?: interactive?)

    ~H"""
    <.dynamic
      tag={@as}
      type={(@as == "button" && "button") || nil}
      phx-click={@on_click}
      aria-current={(@state == "current" && "step") || nil}
      class={
        classes([
          "flex min-w-0 flex-1 items-center justify-center gap-2 border-b border-solid py-2.5",
          step_border(@state),
          @interactive? && "cursor-pointer transition-colors hover:bg-info-soft",
          @class
        ])
      }
      {@rest}
    >
      <span class={
        classes([
          "inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full text-xs font-medium leading-4",
          badge_class(@state)
        ])
      }>
        <.icon :if={@state == "completed"} name="check" size="text-[12px]" decorative />
        <span :if={@state != "completed"}>{@number}</span>
      </span>
      <span class="truncate text-sm text-secondary-foreground">
        {render_slot(@inner_block)}
      </span>
    </.dynamic>
    """
  end

  defp link_nav?(rest) do
    Map.has_key?(rest, :navigate) or Map.has_key?(rest, :patch) or Map.has_key?(rest, :href)
  end

  defp step_border("default"), do: "border-border"
  defp step_border(_), do: "border-primary"

  defp badge_class("completed"), do: "size-5 bg-primary text-primary-foreground"
  defp badge_class("current"), do: "h-5 min-w-5 px-1 bg-primary text-primary-foreground"
  defp badge_class(_), do: "h-5 min-w-5 px-1 bg-secondary text-secondary-foreground"
end
