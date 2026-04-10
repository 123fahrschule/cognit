defmodule Storybook.BugReproductions.TabsDynamicTriggers do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc,
    do: """
    Reproduces a bug where tab content disappears after the tab triggers list
    is re-rendered due to an assign change that the triggers depend on.

    Select a tab, then click "Increment conflicts". The list of triggers
    re-renders (badge counts change, a new trigger may appear/disappear),
    and the selected tab content should remain visible.
    """

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(active_tab: "participants")
     |> assign(number_of_conflicts: 0)}
  end

  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :number_of_conflicts, &(&1 + 1))}
  end

  def handle_event("tab-changed", %{"value" => value}, socket) do
    {:noreply, assign(socket, :active_tab, value)}
  end

  defp course_tabs(number_of_conflicts) do
    [
      %{value: "participants", label: "Participants", count: 12},
      %{value: "vehicles", label: "Vehicles", count: 5},
      %{value: "instructors", label: "Instructors", count: 3},
      %{value: "conflicts", label: "Conflicts", count: number_of_conflicts}
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6 max-w-2xl">
      <p class="text-sm text-muted-foreground">
        Select any tab, then click "Increment conflicts". The tab content should stay visible.
      </p>

      <.tabs
        id="course-details-tabs"
        value={@active_tab}
        on-tab-changed="tab-changed"
      >
        <.tabs_list>
          <%= for tab <- course_tabs(@number_of_conflicts) do %>
            <.tabs_trigger id={"course-details-tabs-trigger-#{tab.value}"} value={tab.value}>
              <div class="flex gap-2 items-center">
                {tab.label}
                <.badge>{tab.count}</.badge>
              </div>
            </.tabs_trigger>
          <% end %>
        </.tabs_list>
        <%= case @active_tab do %>
          <% "participants" -> %>
            <.tabs_content id="course-details-tabs-content-participants" value="participants">
              <div class="p-4 rounded-md bg-muted/50 mt-2">
                Participants tab content
              </div>
            </.tabs_content>
          <% "vehicles" -> %>
            <.tabs_content id="course-details-tabs-content-vehicles" value="vehicles">
              <div class="p-4 rounded-md bg-muted/50 mt-2">
                Vehicles tab content
              </div>
            </.tabs_content>
          <% "instructors" -> %>
            <.tabs_content id="course-details-tabs-content-instructors" value="instructors">
              <div class="p-4 rounded-md bg-muted/50 mt-2">
                Instructors tab content
              </div>
            </.tabs_content>
          <% "conflicts" -> %>
            <.tabs_content id="course-details-tabs-content-conflicts" value="conflicts">
              <div class="p-4 rounded-md bg-muted/50 mt-2">
                Conflicts tab content ({@number_of_conflicts})
              </div>
            </.tabs_content>
        <% end %>
      </.tabs>

      <.button phx-click="increment">Increment conflicts</.button>
    </div>
    """
  end
end
