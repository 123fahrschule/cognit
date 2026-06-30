defmodule Storybook.Examples.Select.InfiniteScroll do
  @moduledoc """
  Example: select that paginates its options as you scroll.

  The LiveView owns a large dataset and renders only a page at a time. Phoenix's
  `phx-viewport-bottom` binding on `<.select_content>` fires `load-more` when the
  bottom of the list scrolls into view, and the LiveView appends the next page.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  @dataset for i <- 1..500, do: "Item #{String.pad_leading(to_string(i), 3, "0")}"
  @page_size 25

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:value, nil)
     |> assign(:dataset_size, length(@dataset))
     |> assign(:loaded, @page_size)
     |> assign_options()}
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    {:noreply,
     socket
     |> assign(:loaded, socket.assigns.loaded + @page_size)
     |> assign_options()}
  end

  def handle_event("changed", %{"value" => value}, socket) do
    {:noreply, assign(socket, :value, value)}
  end

  defp assign_options(socket) do
    socket
    |> assign(:options, Enum.take(@dataset, socket.assigns.loaded))
    |> assign(:end?, socket.assigns.loaded >= length(@dataset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <div>
        <h2 class="text-lg font-semibold">Infinite-scroll select</h2>
        <p class="text-sm text-muted-foreground">
          {@dataset_size} options total. Open the menu and scroll to the bottom of the
          list to load the next page.
        </p>
      </div>

      <.select id="infinite-select" name="item" value={@value} on-value-changed="changed">
        <.select_trigger class="w-full">
          <.select_value placeholder="Select an item" />
        </.select_trigger>
        <.select_content id="infinite-select-list" phx-viewport-bottom={!@end? && "load-more"}>
          <.select_item :for={item <- @options} value={item}>
            {item}
          </.select_item>
        </.select_content>
      </.select>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Selected:</span> {inspect(@value)}</div>
        <div>
          <span class="font-medium">Loaded:</span> {length(@options)} of {@dataset_size}
        </div>
        <div><span class="font-medium">End reached:</span> {@end?}</div>
      </div>
    </div>
    """
  end
end
