defmodule Cognit.Components.CopyButton do
  use Cognit, :component

  import Cognit.Icon
  import Cognit.Tooltip

  @moduledoc """
  A reusable copy button component that copies text to clipboard.

  ## Examples

      # Basic usage - copy a direct value
      <.copy_button value="text to copy" />

      # Copy from another element by selector
      <.copy_button target="#element-id" />

      # Custom styling
      <.copy_button value="text" class="p-2" />

      # Show only on parent hover (with parent having 'group' class)
      <div class="group">
        <span>Some text</span>
        <.copy_button value="Some text" class="opacity-0 group-hover:opacity-100" />
      </div>

  ## Styling Behavior

  By default, the button is visible with hover effects. To make it appear only on
  parent hover, add the `opacity-0 group-hover:opacity-100` classes and ensure the
  parent has the `group` class:

      <div class="group">
        <span>Some text</span>
        <.copy_button value="Some text" class="opacity-0 group-hover:opacity-100" />
      </div>

  ## Requirements

  Requires the JavaScript event listener from `assets/js/copy_button.js` to be
  imported in your application's main JS file. This is automatically included
  when you import Cognit's hooks.

  ## Visual Feedback

  When text is successfully copied, a "Copied!" tooltip appears near the button
  for 2 seconds. Requires Cognit's tooltip component.

  ## Notes

  - Uses `cognit:copy` custom event via Phoenix.LiveView's `JS.dispatch/2`
  - Requires either `value` or `target` attribute
  - Uses Material Symbols icon `content_copy`
  - Fully accessible with ARIA labels
  """

  attr :value, :string,
    default: nil,
    doc: "The text to copy to clipboard"

  attr :target, :string,
    default: nil,
    doc: "CSS selector of element to copy text from"

  attr :class, :any,
    default: nil,
    doc:
      "Additional CSS classes. Add 'opacity-0 group-hover:opacity-100' for hover-only visibility"

  attr :icon_class, :any,
    default: nil,
    doc: "CSS classes for the icon element"

  attr :rest, :global, doc: "Additional HTML attributes passed to button element"

  def copy_button(assigns) do
    assigns =
      assigns
      |> assign_new(:tooltip_id, fn -> "copy-tooltip-#{System.unique_integer([:positive])}" end)
      |> assign(:on_click, build_click_event(assigns.value, assigns.target))

    ~H"""
    <.tooltip id={@tooltip_id} class="inline-flex">
      <button
        type="button"
        phx-click={@on_click}
        class={
          classes([
            "inline-flex shrink-0 p-1 rounded transition-colors hover:bg-muted",
            @class
          ])
        }
        title={pgettext("copy button, button title", "Copy to clipboard")}
        data-copy-feedback-target="true"
        {@rest}
      >
        <.icon
          name="content_copy"
          class={classes(["text-[16px] text-muted-foreground", @icon_class])}
        />
      </button>
      <.tooltip_content side="top" align="end">
        {pgettext("copy button, success feedback", "Copied!")}
      </.tooltip_content>
    </.tooltip>
    """
  end

  defp build_click_event(value, _target) when is_binary(value) do
    JS.dispatch("cognit:copy", detail: %{text: value})
  end

  defp build_click_event(_value, target) when is_binary(target) do
    JS.dispatch("cognit:copy", detail: %{target: target})
  end

  defp build_click_event(_value, _target) do
    require Logger
    Logger.warning("copy_button requires either :value or :target attribute")
    nil
  end
end
