defmodule Cognit.Badge do
  @moduledoc """
  Implementation of badge component for displaying short labels, statuses, or counts.

  Badges are small UI elements typically used to highlight status, categories, or counts
  in a compact format. They are designed to be visually distinct and draw attention to
  important information.

  ## Examples:

      <.badge>New</.badge>
      <.badge variant="secondary">Beta</.badge>
      <.badge variant="destructive">Error</.badge>
      <.badge variant="outline">Version 1.0</.badge>
      <.badge truncate_on="15">This is a very long badge text that will be truncated</.badge>

      <div class="flex gap-2">
        <.badge>Default</.badge>
        <.badge variant="secondary">Secondary</.badge>
        <.badge variant="destructive">Destructive</.badge>
        <.badge variant="outline">Outline</.badge>
        <.badge truncate_on="10">Long text badge with tooltip</.badge>
      </div>


      # Example with manual tooltip for truncate
      <.badge
        variant="secondary"
        title={if String.length(role) > 30, do: role, else: nil}
        truncate_on={30}
      >
        {role}
      </.badge>

  ## Truncation and Tooltips

  When using `truncate_on`, the badge will visually truncate text with CSS ellipsis ("...")
  and show the full text in a tooltip on hover for better accessibility.
  """
  use Cognit, :component

  @doc """
  Renders a badge component.

  ## Options

  * `:class` - Additional CSS classes to apply to the badge.
  * `:variant` - The visual style of the badge. Available variants:
    * `"default"` - Primary color with white text (default)
    * `"secondary"` - Secondary color with contrasting text
    * `"destructive"` - Typically red, for warning or error states
    * `"outline"` - Bordered style with no background
  * `:truncate_on` - Truncate the badge content after the specified number of characters.
    When set, long text will be truncated with "..." and the full text will be shown
    in a tooltip on hover.

  ## Examples

      <.badge>Badge</.badge>
      <.badge variant="destructive">Warning</.badge>
      <.badge variant="outline" class="text-sm">Custom</.badge>
      <.badge truncate_on="33">This is a very long badge text that will be truncated</.badge>
  """
  attr :class, :string, default: nil

  attr :variant, :string,
    values: ~w(default secondary destructive outline),
    default: "default",
    doc: "the badge variant style"

  attr :truncate_on, :integer, default: nil, doc: "truncate text after specified number of characters"

  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    assigns = assign(assigns, :variant_class, variant(assigns))
    assigns = assign(assigns, :tooltip_content, get_tooltip_content(assigns))

    ~H"""
    <div
      class={
        classes([
          "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
          @variant_class,
          @class
        ])
      }
      {@rest}
    >
      <%= if @truncate_on do %>
        <span
          class="truncate"
          style={"max-width: #{@truncate_on - 4}ch"}
          title={@tooltip_content}
        >
          {render_slot(@inner_block)}
        </span>
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </div>
    """
  end

  @variants %{
    variant: %{
      "default" => "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
      "secondary" =>
        "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
      "destructive" =>
        "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
      "outline" => "text-foreground"
    }
  }

  @default_variants %{
    variant: "default"
  }

  defp variant(props) do
    variants = Map.merge(@default_variants, props)

    Enum.map_join(variants, " ", fn {key, value} -> @variants[key][value] end)
  end

  defp get_tooltip_content(%{truncate_on: nil}), do: nil

  defp get_tooltip_content(%{truncate_on: _limit, inner_block: inner_block}) do
    extract_text_for_tooltip(inner_block)
  end

  defp get_tooltip_content(_), do: nil

  # Extract text content for tooltip from slot definition
  defp extract_text_for_tooltip([%{inner_block: content}]) when is_binary(content) do
    String.trim(content)
  end

  defp extract_text_for_tooltip([%{inner_block: [content]}]) when is_binary(content) do
    String.trim(content)
  end

  defp extract_text_for_tooltip([%{inner_block: content_list}]) when is_list(content_list) do
    content_list
    |> Enum.map(&extract_simple_content/1)
    |> Enum.join("")
    |> String.trim()
  end

  defp extract_text_for_tooltip(_), do: nil

  # Helper to extract simple string content
  defp extract_simple_content(content) when is_binary(content), do: content
  defp extract_simple_content({:safe, content}) when is_binary(content), do: content
  defp extract_simple_content({:safe, content_list}) when is_list(content_list) do
    content_list |> IO.iodata_to_binary()
  end
  defp extract_simple_content(_), do: ""
end

