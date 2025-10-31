defmodule Storybook.Foundation.Typography do
  use PhoenixStorybook.Story, :page
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <main class="space-y-8">
      <.section title="Typography System">
        <p class="text-body text-neutral-600 mb-8">
          Typography utility classes for consistent text styling across the application.
          All classes use the <code class="px-2 py-1 bg-neutral-100 rounded text-sm font-mono">
          .text-*</code> prefix.
        </p>
      </.section>

      <.section title="Headings">
        <div class="space-y-8">
          <.type_specimen
            class="text-h1"
            label=".text-h1"
            properties="48px / 60px · Bold · 0.24px"
            sample="The quick brown fox jumps over the lazy dog"
          />
          <.type_specimen
            class="text-h2"
            label=".text-h2"
            properties="32px / 48px · Bold · 0.16px"
            sample="The quick brown fox jumps over the lazy dog"
          />
          <.type_specimen
            class="text-h3"
            label=".text-h3"
            properties="24px / 32px · Bold"
            sample="The quick brown fox jumps over the lazy dog"
          />
          <.type_specimen
            class="text-h4"
            label=".text-h4"
            properties="20px / 28px · Bold"
            sample="The quick brown fox jumps over the lazy dog"
          />
          <.type_specimen
            class="text-h5"
            label=".text-h5"
            properties="16px / 20px · Bold"
            sample="The quick brown fox jumps over the lazy dog"
          />
          <.type_specimen
            class="text-h6"
            label=".text-h6"
            properties="12px / 16px · Bold · 0.48px · Uppercase"
            sample="The quick brown fox jumps over the lazy dog"
          />
        </div>
      </.section>

      <.section title="Body Text">
        <div class="space-y-8">
          <.type_specimen
            class="text-body"
            label=".text-body"
            properties="16px / 24px"
            sample="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
          />
          <.type_specimen
            class="text-body-sm"
            label=".text-body-sm"
            properties="14px / 20px"
            sample="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
          />
          <.type_specimen
            class="text-body-xs"
            label=".text-body-xs"
            properties="12px / 16px"
            sample="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
          />
        </div>
      </.section>

      <.section title="Button Text">
        <div class="space-y-8">
          <.type_specimen
            class="text-button-lg"
            label=".text-button-lg"
            properties="16px / 24px · Bold"
            sample="Click Here"
          />
          <.type_specimen
            class="text-button"
            label=".text-button"
            properties="14px / 20px · Bold"
            sample="Click Here"
          />
          <.type_specimen
            class="text-button-sm"
            label=".text-button-sm"
            properties="12px / 16px · Bold"
            sample="Click Here"
          />
        </div>

        <div class="mt-8 p-6 bg-neutral-50 rounded-lg">
          <p class="text-body-sm text-neutral-600 mb-4">Example usage with button components:</p>
          <div class="flex gap-3 items-center">
            <button class="text-button-lg px-6 py-3 bg-primary text-white rounded-lg">
              Large Button
            </button>
            <button class="text-button px-4 py-2 bg-primary text-white rounded-lg">
              Default Button
            </button>
            <button class="text-button-sm px-3 py-1.5 bg-primary text-white rounded-lg">
              Small Button
            </button>
          </div>
        </div>
      </.section>

      <.section title="Helper Text">
        <div class="space-y-8">
          <.type_specimen
            class="text-helper"
            label=".text-helper"
            properties="11px / 12px"
            sample="Helper text for small labels, captions, and metadata"
          />
        </div>

        <div class="mt-8 p-6 bg-neutral-50 rounded-lg">
          <p class="text-body-sm text-neutral-600 mb-4">Example usage in form context:</p>
          <div class="space-y-2">
            <label class="text-body-sm font-medium">Email address</label>
            <input
              type="email"
              class="w-full px-3 py-2 border rounded-lg"
              placeholder="you@example.com"
            />
            <p class="text-helper text-neutral-500">
              We'll never share your email with anyone else.
            </p>
          </div>
        </div>
      </.section>

      <.section title="Font Weights">
        <p class="text-body-sm text-neutral-600 mb-6">
          Combine typography classes with Tailwind font weight utilities for additional variations.
        </p>
        <div class="space-y-4">
          <div :for={
            {class, label} <- [
              {"font-thin", "Thin (100)"},
              {"font-extralight", "Extra Light (200)"},
              {"font-light", "Light (300)"},
              {"font-normal", "Normal (400)"},
              {"font-medium", "Medium (500)"},
              {"font-semibold", "Semi Bold (600)"},
              {"font-bold", "Bold (700)"},
              {"font-extrabold", "Extra Bold (800)"},
              {"font-black", "Black (900)"}
            ]
          }>
            <div class="flex items-baseline gap-4 pb-3 border-b border-neutral-200">
              <code class="text-body-sm font-mono text-neutral-500 w-48">{class}</code>
              <span class="text-body-sm text-neutral-600 w-32">{label}</span>
              <p class={["text-body flex-1", class]}>
                The quick brown fox jumps over the lazy dog
              </p>
            </div>
          </div>
        </div>
      </.section>
    </main>
    """
  end

  attr :title, :string
  slot :inner_block

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

  attr :class, :string, required: true
  attr :label, :string, required: true
  attr :properties, :string, required: true
  attr :sample, :string, required: true

  def type_specimen(assigns) do
    ~H"""
    <div class="group">
      <div class="flex items-baseline gap-3 mb-2">
        <code class="text-body-sm font-mono font-semibold text-neutral-700">{@label}</code>
        <span class="text-body-sm text-neutral-500">{@properties}</span>
      </div>
      <div class={["p-4 border border-neutral-200 rounded-lg bg-white", @class]}>
        {@sample}
      </div>
    </div>
    """
  end
end
