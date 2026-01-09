defmodule Storybook.MyPage do
  # See https://hexdocs.pm/phoenix_storybook/PhoenixStorybook.Story.html for full story
  # documentation.
  @moduledoc false
  use PhoenixStorybook.Story, :page

  # This is a dummy fonction that you should replace with your own HEEx content.
  def render(assigns) do
    ~H"""
    <div class="pt-20 pb-32 max-w-4xl mx-auto px-4">
      <div class="text-center mb-16">
        <h1 class="text-4xl font-bold mb-4">Cognit Component Library</h1>
        <p class="text-lg text-muted-foreground">
          Phoenix LiveView UI components with 40+ accessible, interactive elements
        </p>
      </div>

      <div class="space-y-8">
        <section>
          <h2 class="text-2xl font-semibold mb-3">Features</h2>
          <ul class="list-disc list-inside space-y-2 text-muted-foreground">
            <li>40+ accessible, interactive components</li>
            <li>Built with Phoenix function components and HEEx templates</li>
            <li>Client-side state management with JavaScript state machines</li>
            <li>Tailwind CSS styling with TwMerge for class composition</li>
            <li>Internationalization support with Gettext</li>
          </ul>
        </section>

        <section>
          <h2 class="text-2xl font-semibold mb-3">Icons</h2>
          <p class="text-muted-foreground mb-2">
            This library uses <strong>Material Symbols</strong> for icons.
          </p>
          <p class="text-muted-foreground">
            Search and browse available icons at:
            <a
              href="https://fonts.google.com/icons"
              target="_blank"
              class="text-primary hover:underline font-medium"
            >
              Google Fonts Icons
            </a>
          </p>
        </section>
      </div>
    </div>
    """
  end
end
