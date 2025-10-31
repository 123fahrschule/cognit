defmodule Storybook.Foundation.Colors do
  use PhoenixStorybook.Story, :page
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <main class="space-y-8">
      <.section title="Color System">
        <p class="text-body text-neutral-600 mb-6">
          All colors are defined as CSS variables in HSL format, making them themeable and maintainable.
          Colors support both shade palettes (50-600) and semantic usage for UI components.
        </p>
        <div class="p-6 bg-neutral-200 rounded-lg space-y-3">
          <p class="text-body-sm font-semibold text-neutral-800">Usage Guidelines:</p>
          <ul class="text-body-sm text-neutral-700 space-y-1 list-disc list-inside">
            <li>
              <strong>Brand Colors:</strong> Use primary/secondary for brand identity, main actions, and emphasis
            </li>
            <li><strong>Neutral:</strong> Use for text, borders, backgrounds, and subtle UI elements</li>
            <li>
              <strong>Semantic:</strong> Use warning/success/error/info to communicate status and feedback
            </li>
            <li>
              <strong>Domain:</strong> Use driving/theory colors for domain-specific categorization
            </li>
          </ul>
        </div>
      </.section>

      <.section title="Brand Colors">
        <div class="space-y-8">
          <div>
            <h3 class="text-h5 mb-3 text-neutral-800">Primary</h3>
            <p class="text-body-sm text-neutral-600 mb-4">
              Main brand color. Use for primary buttons, links, and key UI elements.
            </p>
            <.color_palette
              colors={[
                {"primary-50", "bg-primary-50"},
                {"primary-100", "bg-primary-100"},
                {"primary-200", "bg-primary-200"},
                {"primary-300", "bg-primary-300"},
                {"primary-400", "bg-primary-400"},
                {"primary-500", "bg-primary-500"},
                {"primary-600", "bg-primary-600"}
              ]}
            />
          </div>

          <div>
            <h3 class="text-h5 mb-3 text-neutral-800">Secondary</h3>
            <p class="text-body-sm text-neutral-600 mb-4">
              Accent brand color. Use for highlights, badges, and visual interest.
            </p>
            <.color_palette
              colors={[
                {"secondary-50", "bg-secondary-50"},
                {"secondary-100", "bg-secondary-100"},
                {"secondary-200", "bg-secondary-200"},
                {"secondary-300", "bg-secondary-300"},
                {"secondary-400", "bg-secondary-400"},
                {"secondary-500", "bg-secondary-500"},
                {"secondary-600", "bg-secondary-600"}
              ]}
            />
          </div>
        </div>
      </.section>

      <.section title="Neutral Colors">
        <p class="text-body-sm text-neutral-600 mb-4">
          Grayscale palette for text, borders, backgrounds, and general UI elements.
        </p>
        <.color_palette
          colors={[
            {"neutral-100", "bg-neutral-100"},
            {"neutral-200", "bg-neutral-200"},
            {"neutral-300", "bg-neutral-300"},
            {"neutral-400", "bg-neutral-400"},
            {"neutral-500", "bg-neutral-500"},
            {"neutral-600", "bg-neutral-600"},
            {"neutral-700", "bg-neutral-700"},
            {"neutral-800", "bg-neutral-800"},
            {"neutral-900", "bg-neutral-900"}
          ]}
        />
      </.section>

      <.section title="Semantic Colors">
        <p class="text-body-sm text-neutral-600 mb-6">
          Use these colors to communicate status, feedback, and important information.
        </p>
        <div class="space-y-8">
          <div>
            <h3 class="text-h5 mb-3 flex items-center gap-2">
              <span class="w-4 h-4 bg-warning-400 rounded-full"></span>
              <span class="text-neutral-800">Warning</span>
            </h3>
            <.color_palette
              colors={[
                {"warning-50", "bg-warning-50"},
                {"warning-100", "bg-warning-100"},
                {"warning-200", "bg-warning-200"},
                {"warning-300", "bg-warning-300"},
                {"warning-400", "bg-warning-400"},
                {"warning-500", "bg-warning-500"}
              ]}
            />
          </div>

          <div>
            <h3 class="text-h5 mb-3 flex items-center gap-2">
              <span class="w-4 h-4 bg-success-400 rounded-full"></span>
              <span class="text-neutral-800">Success</span>
            </h3>
            <.color_palette
              colors={[
                {"success-50", "bg-success-50"},
                {"success-100", "bg-success-100"},
                {"success-200", "bg-success-200"},
                {"success-300", "bg-success-300"},
                {"success-400", "bg-success-400"},
                {"success-500", "bg-success-500"}
              ]}
            />
          </div>

          <div>
            <h3 class="text-h5 mb-3 flex items-center gap-2">
              <span class="w-4 h-4 bg-error-400 rounded-full"></span>
              <span class="text-neutral-800">Error</span>
            </h3>
            <.color_palette
              colors={[
                {"error-50", "bg-error-50"},
                {"error-100", "bg-error-100"},
                {"error-200", "bg-error-200"},
                {"error-300", "bg-error-300"},
                {"error-400", "bg-error-400"},
                {"error-500", "bg-error-500"}
              ]}
            />
          </div>

          <div>
            <h3 class="text-h5 mb-3 flex items-center gap-2">
              <span class="w-4 h-4 bg-info-400 rounded-full"></span>
              <span class="text-neutral-800">Info</span>
            </h3>
            <.color_palette
              colors={[
                {"info-50", "bg-info-50"},
                {"info-100", "bg-info-100"},
                {"info-200", "bg-info-200"},
                {"info-300", "bg-info-300"},
                {"info-400", "bg-info-400"},
                {"info-500", "bg-info-500"}
              ]}
            />
          </div>
        </div>
      </.section>

      <.section title="Domain Colors">
        <p class="text-body-sm text-neutral-600 mb-6">
          Domain-specific color palettes for categorizing content and features.
        </p>
        <div class="space-y-8">
          <div>
            <h3 class="text-h5 mb-3 text-neutral-800">Driving</h3>
            <.color_palette
              colors={[
                {"driving-50", "bg-driving-50"},
                {"driving-100", "bg-driving-100"},
                {"driving-200", "bg-driving-200"},
                {"driving-300", "bg-driving-300"},
                {"driving-400", "bg-driving-400"},
                {"driving-500", "bg-driving-500"}
              ]}
            />
          </div>

          <div>
            <h3 class="text-h5 mb-3 text-neutral-800">Theory</h3>
            <.color_palette
              colors={[
                {"theory-50", "bg-theory-50"},
                {"theory-100", "bg-theory-100"},
                {"theory-200", "bg-theory-200"},
                {"theory-300", "bg-theory-300"},
                {"theory-400", "bg-theory-400"},
                {"theory-500", "bg-theory-500"}
              ]}
            />
          </div>
        </div>
      </.section>

      <.section title="UI Semantic Colors">
        <p class="text-body-sm text-neutral-600 mb-4">
          These colors are used by SaladUI components and map to CSS variables that can be themed.
        </p>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.semantic_color_card
            name="Background"
            class="bg-background text-foreground"
            var_name="--background / --foreground"
          />
          <.semantic_color_card name="Card" class="bg-card text-card-foreground" var_name="--card" />
          <.semantic_color_card
            name="Popover"
            class="bg-popover text-popover-foreground"
            var_name="--popover"
          />
          <.semantic_color_card
            name="Primary"
            class="bg-primary text-primary-foreground"
            var_name="--primary"
          />
          <.semantic_color_card
            name="Secondary"
            class="bg-secondary text-secondary-foreground"
            var_name="--secondary"
          />
          <.semantic_color_card
            name="Muted"
            class="bg-muted text-muted-foreground"
            var_name="--muted"
          />
          <.semantic_color_card
            name="Accent"
            class="bg-accent text-accent-foreground"
            var_name="--accent"
          />
          <.semantic_color_card
            name="Destructive"
            class="bg-destructive text-destructive-foreground"
            var_name="--destructive"
          />
        </div>
      </.section>
    </main>
    """
  end

  attr :title, :string, required: true
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section>
      <h2 class="border-b-2 border-neutral-300 text-h3 mb-6 pb-2">
        {@title}
      </h2>
      <div>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  attr :colors, :list, required: true

  defp color_palette(assigns) do
    ~H"""
    <div class="flex gap-2 flex-wrap">
      <div :for={{name, class} <- @colors} class="flex-1 min-w-24">
        <div class={["h-20 rounded-t-lg border border-neutral-300", class]}></div>
        <div class="bg-white border border-t-0 border-neutral-300 rounded-b-lg p-2">
          <p class="text-body-xs text-neutral-700 text-center font-mono">{name}</p>
        </div>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, required: true
  attr :var_name, :string, required: true

  defp semantic_color_card(assigns) do
    ~H"""
    <div class={["p-4 rounded-lg border", @class]}>
      <p class="text-body-sm font-semibold">{@name}</p>
      <p class="text-body-xs font-mono opacity-80">{@var_name}</p>
    </div>
    """
  end
end
