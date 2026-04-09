defmodule Storybook.BugReproductions.TabsDomPatch do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc,
    do: """
    Reproduces a bug where tabs lose active state after a LiveView DOM patch.
    Click a tab, then click "Increment" — the tab visually deselects because
    `onDomUpdate()` resets all `data-state` attributes to "idle".
    """

  def mount(_params, _session, socket) do
    {:ok, assign(socket, counter: 0)}
  end

  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6 max-w-md">
      <p class="text-sm text-muted-foreground">
        Select a tab, then click "Increment". The selected tab should stay highlighted.
      </p>

      <.tabs id="patch-tabs" default="alpha">
        <.tabs_list class="grid w-full grid-cols-3">
          <.tabs_trigger value="alpha">Alpha</.tabs_trigger>
          <.tabs_trigger value="beta">Beta</.tabs_trigger>
          <.tabs_trigger value="gamma">Gamma</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="alpha">
          <div class="p-4 rounded-md bg-muted/50 mt-2">
            Alpha content — counter: {@counter}
          </div>
        </.tabs_content>
        <.tabs_content value="beta">
          <div class="p-4 rounded-md bg-muted/50 mt-2">
            Beta content — counter: {@counter}
          </div>
        </.tabs_content>
        <.tabs_content value="gamma">
          <div class="p-4 rounded-md bg-muted/50 mt-2">
            Gamma content — counter: {@counter}
          </div>
        </.tabs_content>
      </.tabs>

      <.button phx-click="increment">Increment</.button>
    </div>
    """
  end
end
