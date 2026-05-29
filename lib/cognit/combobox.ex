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

  attr :filter, :string,
    values: ~w(client server),
    default: "client",
    doc:
      "Filtering mode. `client` filters rendered items by substring on the client. " <>
        "`server` skips local filtering and only dispatches the `on-search` event."

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

    assigns =
      assigns
      |> assign(:event_map, json(event_map))
      |> assign(
        :options,
        json(%{
          defaultValue: assigns[:"default-value"],
          value: assigns.value,
          name: assigns.name,
          multiple: assigns.multiple,
          filter: assigns.filter,
          usePortal: assigns[:"use-portal"],
          portalContainer: assigns[:"portal-container"],
          animations: get_animation_config()
        })
      )

    ~H"""
    <div
      id={@id}
      class={classes(["relative inline-flex w-full", @class])}
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
          "flex h-9 w-full items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-xs data-[placeholder]:text-muted-foreground focus:outline-none focus:ring-[3px] focus:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1",
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
      <.icon name="search" class="mr-2 h-4 w-4 shrink-0 opacity-50" />
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
  attr :class, :any, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def combobox_item(assigns) do
    ~H"""
    <div
      data-part="item"
      data-value={@value}
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
