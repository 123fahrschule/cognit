defmodule Storybook.MyPage do
  # See https://hexdocs.pm/phoenix_storybook/PhoenixStorybook.Story.html for full story
  # documentation.
  @moduledoc false
  use PhoenixStorybook.Story, :page

  # This is a dummy fonction that you should replace with your own HEEx content.
  def render(assigns) do
    ~H"""
    <div class="text-center pt-20 pb-32">
      <h1 class="text-4xl font-bold">Build your LiveView component library</h1>
      <p class="text-lg text-muted-foreground">
        Fully customizable elements to build your own Phoenix LiveView components
      </p>
    </div>
    """
  end
end
