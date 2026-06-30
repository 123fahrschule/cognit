defmodule Storybook.Examples.Combobox.InfiniteScroll do
  @moduledoc """
  Example: combobox that paginates its options as you scroll.

  The LiveView owns a large dataset and sends only a page at a time. Phoenix's
  `phx-viewport-bottom` binding on `<.combobox_list>` fires `load-more` when the
  last item scrolls into view, and the LiveView appends the next page. Combined
  with `filter="server"`, typing resets the list to the first page of matches.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  @dataset for i <- 1..500, do: "Item #{String.pad_leading(to_string(i), 3, "0")}"
  @page_size 25

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:value, nil)
     |> assign(:dataset_size, length(@dataset))
     |> assign(:loaded, @page_size)
     |> assign_options()}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:loaded, @page_size)
     |> assign_options()}
  end

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
    matches = filter(socket.assigns.query)

    socket
    |> assign(:total, length(matches))
    |> assign(:options, Enum.take(matches, socket.assigns.loaded))
    |> assign(:end?, socket.assigns.loaded >= length(matches))
  end

  defp filter(""), do: @dataset

  defp filter(query) do
    q = String.downcase(query)
    Enum.filter(@dataset, &String.contains?(String.downcase(&1), q))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <div>
        <h2 class="text-lg font-semibold">Infinite-scroll combobox</h2>
        <p class="text-sm text-muted-foreground">
          {@dataset_size} options total. Open the menu and scroll to the bottom of the
          list to load more, or type to filter on the server.
        </p>
      </div>

      <.combobox
        id="infinite-combobox"
        name="item"
        value={@value}
        filter="server"
        on-search="search"
        on-value-changed="changed"
        debounce={300}
      >
        <.combobox_trigger class="w-full">
          <.combobox_value placeholder="Select an item" />
        </.combobox_trigger>
        <.combobox_content>
          <.combobox_input placeholder="Search items..." />
          <.combobox_empty>No item found.</.combobox_empty>
          <.combobox_list id="infinite-combobox-list" phx-viewport-bottom={!@end? && "load-more"}>
            <.combobox_item :for={item <- @options} value={item}>
              {item}
            </.combobox_item>
          </.combobox_list>
        </.combobox_content>
      </.combobox>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Query:</span> {inspect(@query)}</div>
        <div><span class="font-medium">Selected:</span> {inspect(@value)}</div>
        <div><span class="font-medium">Loaded:</span> {length(@options)} of {@total} matches</div>
        <div><span class="font-medium">End reached:</span> {@end?}</div>
      </div>
    </div>
    """
  end
end
