defmodule Storybook.Foundation.Effects do
  use PhoenixStorybook.Story, :page
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <main class="space-y-8">
      <.section title="Border Radius">
        <p class="text-body-sm text-neutral-600 mb-4">
          Corner radius scale. <span class="font-mono">rounded-sm</span>/<span class="font-mono">md</span>/<span class="font-mono">lg</span> are driven by the
          <span class="font-mono">--radius</span>
          variable and their pixel values don't
          line up with the design system's step of the same name (e.g. Cognit's
          <span class="font-mono">rounded-sm</span>
          is 8px, not the design system's 6px "sm" step) — go by
          the pixel value shown, not the class name, when comparing to Figma.
        </p>
        <.radius_palette items={[
          {"none", "rounded-none", "0px"},
          {"xs", "rounded-xs", "2px"},
          {"sm", "rounded-sm", "8px"},
          {"md", "rounded-md", "10px"},
          {"lg", "rounded-lg", "12px"},
          {"xl", "rounded-xl", "12px"},
          {"2xl", "rounded-2xl", "16px"},
          {"full", "rounded-full", "9999px"}
        ]} />
      </.section>

      <.section title="Box Shadow">
        <p class="text-body-sm text-neutral-600 mb-4">
          Elevation scale exposed as theme-aware CSS variables
          (<span class="font-mono">--shadow-2xs</span> … <span class="font-mono">--shadow-2xl</span>).
          Not wired to Tailwind's <span class="font-mono">shadow-*</span>
          utility classes (those keep
          their existing values, already used across components) — apply via an arbitrary value, e.g. <span class="font-mono">shadow-[var(--shadow-md)]</span>.
          <span class="font-mono">2xl</span>
          is a design-system outlier (much higher alpha than the rest of the scale on otherwise-identical
          geometry to <span class="font-mono">xs</span>) — kept 1:1 with the source values rather than adjusted.
        </p>
        <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
          <.shadow_swatch name="2xs" var="--shadow-2xs" />
          <.shadow_swatch name="xs" var="--shadow-xs" />
          <.shadow_swatch name="sm" var="--shadow-sm" />
          <.shadow_swatch name="md" var="--shadow-md" />
          <.shadow_swatch name="lg" var="--shadow-lg" />
          <.shadow_swatch name="xl" var="--shadow-xl" />
          <.shadow_swatch name="2xl" var="--shadow-2xl" />
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

  attr :items, :list, required: true

  defp radius_palette(assigns) do
    ~H"""
    <div class="flex gap-6 flex-wrap">
      <div :for={{name, class, px} <- @items} class="text-center">
        <div class={["h-16 w-16 bg-primary/10 border-2 border-primary", class]}></div>
        <p class="text-body-xs font-mono text-neutral-700 mt-2">{name}</p>
        <p class="text-body-xs text-neutral-500">{px}</p>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :var, :string, required: true

  defp shadow_swatch(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-2 py-4">
      <div class="h-16 w-16 rounded-md bg-card" style={"box-shadow: var(#{@var})"}></div>
      <p class="text-body-xs font-mono text-neutral-700">shadow-{@name}</p>
    </div>
    """
  end
end
