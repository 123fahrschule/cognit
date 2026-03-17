defmodule Storybook.Recipes.SelectDynamic do
  use PhoenixStorybook.Story, :example
  use Cognit

  @fruit_options [
    %{value: "apple", label: "Apple"},
    %{value: "banana", label: "Banana"},
    %{value: "blueberry", label: "Blueberry"},
    %{value: "pineapple", label: "Pineapple"}
  ]

  def doc do
    """
    Bug reproduction for dynamic select updates.

    Test 1 — Dynamic options:
    1. Click "Load options" — select should become enabled with fruit options
    2. Click "Clear options" — select should become disabled with no options

    Test 2 — State preservation during patches:
    1. Load options, open the dropdown
    2. Type in the text input — this triggers a server patch
    3. The dropdown should stay open (not snap closed)
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       options: [],
       disabled: true,
       selected: nil,
       note: ""
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 p-4 max-w-sm">
      <div class="flex gap-2">
        <.button phx-click="load_options">Load options</.button>
        <.button variant="outline" phx-click="clear_options">Clear options</.button>
      </div>

      <p class="text-sm text-muted-foreground">
        Options: {length(@options)} | Disabled: {@disabled} | Selected: {@selected || "none"}
      </p>

      <div>
        <.label>Type here while dropdown is open</.label>
        <.input type="text" value={@note} phx-keyup="note_changed" />
      </div>

      <div class="flex gap-4">
        <.select
          id="dynamic-select"
          name="fruit"
          on-value-changed="value_changed"
          use-portal={false}
        >
          <.select_trigger class="w-[200px]" disabled={@disabled}>
            <.select_value placeholder="Select a fruit" />
          </.select_trigger>
          <.select_content>
            <.select_group>
              <.select_item :for={opt <- @options} value={opt.value}>
                {opt.label}
              </.select_item>
            </.select_group>
          </.select_content>
        </.select>

        <.select id="color-select" name="color" use-portal={false}>
          <.select_trigger class="w-[200px]">
            <.select_value placeholder="Select a color" />
          </.select_trigger>
          <.select_content>
            <.select_group>
              <.select_item value="red">Red</.select_item>
              <.select_item value="green">Green</.select_item>
              <.select_item value="blue">Blue</.select_item>
            </.select_group>
          </.select_content>
        </.select>
      </div>
    </div>
    """
  end

  def handle_event("load_options", _params, socket) do
    {:noreply, assign(socket, options: @fruit_options, disabled: false)}
  end

  def handle_event("clear_options", _params, socket) do
    {:noreply, assign(socket, options: [], disabled: true)}
  end

  def handle_event("value_changed", %{"value" => value}, socket) do
    {:noreply, assign(socket, selected: value)}
  end

  def handle_event("note_changed", %{"value" => value}, socket) do
    {:noreply, assign(socket, note: value)}
  end
end
