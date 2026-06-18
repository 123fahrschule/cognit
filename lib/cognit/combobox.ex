defmodule Cognit.Combobox do
  @moduledoc """
  Searchable select (combobox) component.

  Wraps a trigger, a popover-style content panel with a search input, and a
  filtered list of items. Supports single and multiple selection, form field
  integration, and both client-side (default) and server-side filtering.

  ## Examples

      <.combobox id="fruit" name="fruit" placeholder="Select a fruit">
        <.combobox_trigger class="w-[220px]">
          <.combobox_value placeholder="Select a fruit" />
        </.combobox_trigger>
        <.combobox_content>
          <.combobox_input placeholder="Search fruit..." />
          <.combobox_empty>No fruit found.</.combobox_empty>
          <.combobox_group>
            <.combobox_item value="apple">Apple</.combobox_item>
            <.combobox_item value="banana">Banana</.combobox_item>
            <.combobox_item value="blueberry">Blueberry</.combobox_item>
          </.combobox_group>
        </.combobox_content>
      </.combobox>

  For server-side filtering, set `filter="server"` and handle the
  `on-search` event in the LiveView to update the item list.
  """
  use Cognit, :component

  import Cognit.Icon

  attr :id, :string, default: nil
  attr :name, :any, default: nil
  attr :value, :any, default: nil, doc: "The value of the combobox"
  attr :"default-value", :any, default: nil, doc: "The default value of the combobox"
  attr :multiple, :boolean, default: false, doc: "Allow multiple selection"

  attr :selected, :list,
    default: [],
    doc:
      "Labels for selected values, as a list of `%{value:, label:}` maps. Lets `<.combobox_chips>` " <>
        "show a label for values whose option isn't in the currently rendered list (e.g. server " <>
        "filtering with preselected values not yet loaded)."

  attr :filter, :string,
    values: ~w(client server),
    default: "client",
    doc:
      "Filtering mode. `client` filters rendered items by substring on the client. " <>
        "`server` skips local filtering and only dispatches the `on-search` event."

  attr :debounce, :integer,
    default: 0,
    doc:
      "Milliseconds to debounce the search query before dispatching `on-search`. " <>
        "0 (default) dispatches on every keystroke. Only applies to `server` filtering."

  attr :"use-portal", :boolean, default: false, doc: "Whether to render the content in a portal"
  attr :"portal-container", :string, default: nil, doc: "CSS selector for the portal container"
  attr :"on-value-changed", :any, default: nil, doc: "Handler for value changed event"
  attr :"on-open", :any, default: nil, doc: "Handler for open event"
  attr :"on-close", :any, default: nil, doc: "Handler for close event"
  attr :"on-search", :any, default: nil, doc: "Handler for search query event"

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:fruit]"

  attr :placeholder, :string,
    default: nil,
    doc: "The placeholder text when no value is selected."

  attr :"selected-label", :string,
    default: nil,
    doc:
      "Trigger text when multiple items are selected. `%{count}` is replaced with the " <>
        "number selected. Defaults to a translated \"%{count} items selected\"."

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox(assigns) do
    assigns = prepare_assign(assigns)

    event_map =
      %{}
      |> add_event_mapping(assigns, "value-changed", :"on-value-changed")
      |> add_event_mapping(assigns, "opened", :"on-open")
      |> add_event_mapping(assigns, "closed", :"on-close")
      |> add_event_mapping(assigns, "search", :"on-search")

    rest = maybe_set_aria_invalid(assigns.rest, assigns[:errors])

    assigns =
      assigns
      |> assign(:rest, rest)
      |> assign(:event_map, json(event_map))
      |> assign(
        :options,
        json(%{
          defaultValue: assigns[:"default-value"],
          value: assigns.value,
          name: assigns.name,
          multiple: assigns.multiple,
          selected: assigns.selected,
          filter: assigns.filter,
          debounce: assigns.debounce,
          usePortal: assigns[:"use-portal"],
          portalContainer: assigns[:"portal-container"],
          selectedLabel:
            assigns[:"selected-label"] ||
              pgettext("combobox", "%{count} items selected", count: "%{count}"),
          animations: get_animation_config()
        })
      )

    ~H"""
    <div
      id={@id}
      class={classes(["group/field relative inline-flex w-full flex-wrap", @class])}
      data-part="root"
      data-component="combobox"
      data-state="closed"
      data-options={@options}
      data-event-mappings={@event_map}
      phx-hook="SaladUI"
      phx-mounted={JS.ignore_attributes(["data-state"])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <input name={@name} value="" data-input class="hidden" />
      <div hidden id={@id <> "_inputs_container"} data-inputs-container phx-update="ignore"></div>
    </div>
    """
  end

  @doc """
  Renders selected items as removable chips outside the trigger (multiple-select).

  Place it inside `<.combobox>`, next to the trigger; it stays empty until items
  are selected and the trigger keeps its compact count summary. Chips for values
  not in the rendered list (e.g. server filtering) show the label supplied via
  the combobox `selected` attr, falling back to the raw value.
  """
  attr :class, :any, default: nil
  attr :rest, :global

  def combobox_chips(assigns) do
    ~H"""
    <div
      data-part="chips"
      class={classes(["flex w-full flex-wrap gap-1 empty:hidden", @class])}
      {@rest}
    >
    </div>
    <template data-part="chip-template">
      <span
        data-part="chip"
        class="inline-flex max-w-full items-center gap-1 rounded bg-secondary py-0.5 pl-2 pr-1 text-xs font-medium text-secondary-foreground"
      >
        <span data-part="chip-label" class="truncate"></span>
        <button
          type="button"
          data-part="chip-remove"
          aria-label={pgettext("combobox", "Remove")}
          class="flex size-4 shrink-0 cursor-pointer items-center justify-center rounded-sm opacity-70 hover:bg-secondary-foreground/10 hover:opacity-100"
        >
          <.icon name="close" size="xs" decorative />
        </button>
      </span>
    </template>
    """
  end

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global, include: ["disabled"]

  def combobox_trigger(assigns) do
    ~H"""
    <button
      type="button"
      data-part="trigger"
      class={
        classes([
          "flex h-9 w-full items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm data-[placeholder]:text-muted-foreground focus:outline-none focus:border-ring focus:ring-[3px] focus:ring-ring/50 group-aria-invalid/field:border-destructive group-aria-invalid/field:ring-[3px] group-aria-invalid/field:ring-destructive/40 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
      <span class="h-4 w-4 opacity-50">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="lucide lucide-chevron-down h-4 w-4"
        >
          <path d="M6 9l6 6 6-6"></path>
        </svg>
      </span>
    </button>
    """
  end

  attr :placeholder, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def combobox_value(assigns) do
    ~H"""
    <span
      data-part="value"
      class={classes(["combobox-value pointer-events-none text-start", @class])}
      data-placeholder={@placeholder}
      {@rest}
    >
    </span>
    """
  end

  attr :class, :any, default: nil
  attr :side, :string, values: ~w(top bottom), default: "bottom"
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_content(assigns) do
    position_class =
      case assigns.side do
        "top" -> "bottom-full mb-1"
        "bottom" -> "top-full mt-1"
      end

    assigns = assign(assigns, :position_class, position_class)

    ~H"""
    <div
      data-part="content"
      data-side={@side}
      style="min-width: var(--salad-reference-width)"
      hidden
      class={
        classes([
          "absolute min-w-full",
          "z-50 max-h-96 min-w-[8rem] overflow-hidden rounded-md border bg-popover text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          @position_class,
          @class
        ])
      }
      {@rest}
    >
      <div class="flex max-h-96 flex-col">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :placeholder, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def combobox_input(assigns) do
    ~H"""
    <div data-part="input-wrapper" class="flex shrink-0 items-center border-b px-3">
      <.icon name="search" size="xs" class="mr-2 shrink-0 opacity-50" />
      <input
        type="text"
        data-part="input"
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        spellcheck="false"
        placeholder={@placeholder}
        class={
          classes([
            "flex h-10 w-full rounded-md border-none bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground focus:ring-transparent disabled:cursor-not-allowed disabled:opacity-50",
            @class
          ])
        }
        {@rest}
      />
    </div>
    """
  end

  attr :class, :any, default: nil
  slot :inner_block, required: true

  def combobox_empty(assigns) do
    ~H"""
    <div
      data-part="empty"
      data-visible="false"
      class={
        classes([
          "py-6 text-center text-sm text-muted-foreground data-[visible=false]:hidden",
          @class
        ])
      }
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_list(assigns) do
    ~H"""
    <div
      data-part="list"
      class={classes(["overflow-y-auto overflow-x-hidden p-1", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :selectable, :boolean,
    default: false,
    doc:
      "When true (multiple-select only), renders the `label` as a clickable row " <>
        "that toggles all visible items in the group. Single-select ignores it."

  attr :label, :string,
    default: nil,
    doc: "Group heading. Required to render the select-all row when `selectable` is set."

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_group(assigns) do
    ~H"""
    <div
      data-part="group"
      data-selectable={@selectable}
      class={classes(["data-[visible=false]:hidden", @class])}
      {@rest}
    >
      <div
        :if={@selectable and @label}
        data-part="group-trigger"
        role="button"
        tabindex="0"
        class="relative flex w-full cursor-pointer select-none items-center gap-2 rounded-sm px-2 py-1.5 text-xs font-medium text-muted-foreground outline-none hover:bg-accent hover:text-accent-foreground"
      >
        <span
          data-part="group-indicator"
          data-group-state="unchecked"
          class="flex h-4 w-4 shrink-0 items-center justify-center rounded border border-input text-primary-foreground data-[group-state=checked]:border-primary data-[group-state=checked]:bg-primary data-[group-state=indeterminate]:border-primary data-[group-state=indeterminate]:bg-primary"
        >
          <svg
            data-part="group-check"
            hidden
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="3"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-3 w-3"
          >
            <path d="M20 6 9 17l-5-5"></path>
          </svg>
          <svg
            data-part="group-minus"
            hidden
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="3"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-3 w-3"
          >
            <path d="M5 12h14"></path>
          </svg>
        </span>
        {@label}
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_label(assigns) do
    ~H"""
    <div
      data-part="label"
      class={classes(["px-2 py-1.5 text-xs text-muted-foreground", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :value, :string, required: true
  attr :disabled, :boolean, default: false

  attr :label, :string,
    default: nil,
    doc:
      "Plain-text label used for the trigger value and chips. Defaults to the item's text " <>
        "content; set it when the item renders rich/custom content."

  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_item(assigns) do
    ~H"""
    <div
      data-part="item"
      data-value={@value}
      data-label={@label}
      data-disabled={@disabled}
      class={
        classes([
          "relative flex w-full cursor-default select-none items-center rounded-sm py-1.5 pl-2 pr-8 text-sm outline-none data-[visible=false]:hidden data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
          @class
        ])
      }
      tabindex={(@disabled && "-1") || "0"}
      {@rest}
    >
      <span class="absolute right-2 flex h-3.5 w-3.5 items-center justify-center">
        <span data-part="item-indicator" hidden>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-4 w-4"
          >
            <path d="M20 6 9 17l-5-5"></path>
          </svg>
        </span>
      </span>

      <span data-part="item-text">{render_slot(@inner_block)}</span>
    </div>
    """
  end

  def combobox_separator(assigns) do
    ~H"""
    <div data-part="separator" class={classes(["-mx-1 my-1 h-px bg-muted"])}></div>
    """
  end

  defp get_animation_config do
    %{
      "open_to_closed" => %{
        duration: 130,
        target_part: "content"
      }
    }
  end
end
