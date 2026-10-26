defmodule Storybook.BugReproductions.ComboboxGroupSelectWithoutInput do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc do
    """
    Bug reproduction for `selectable` groups in a multiple `<.combobox>` without
    `<.combobox_input />`.

    Each group heading shows its selected count, so every selection re-renders
    the groups. LiveView skips patching a group whose output didn't change, so
    without that the bug stays hidden.

    Steps:
    1. Open the dropdown, click the "Backend" heading.

    Expected: "Backend" stays checked.
    Before the fix: the checkbox flickers back to unchecked after the
    re-render, while the items stay selected.
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_form(socket, %{"stack" => []})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" class="flex max-w-sm flex-col gap-4 p-4">
      <.combobox field={@form[:stack]} multiple>
        <.combobox_trigger class="w-full">
          <.combobox_value placeholder="Select your stack" />
        </.combobox_trigger>
        <.combobox_content>
          <.combobox_list>
            <.combobox_group
              selectable
              label={group_label("Backend", ~w(elixir phoenix ecto), @form[:stack].value)}
            >
              <.combobox_item value="elixir">Elixir</.combobox_item>
              <.combobox_item value="phoenix">Phoenix</.combobox_item>
              <.combobox_item value="ecto">Ecto</.combobox_item>
            </.combobox_group>
            <.combobox_separator />
            <.combobox_group
              selectable
              label={group_label("Frontend", ~w(liveview react tailwind), @form[:stack].value)}
            >
              <.combobox_item value="liveview">LiveView</.combobox_item>
              <.combobox_item value="react">React</.combobox_item>
              <.combobox_item value="tailwind">Tailwind CSS</.combobox_item>
            </.combobox_group>
          </.combobox_list>
        </.combobox_content>
      </.combobox>

      <p class="text-sm text-muted-foreground">Server value: {inspect(@form.params)}</p>
    </.form>
    """
  end

  @impl true
  def handle_event("validate", %{"filter" => params}, socket) do
    {:noreply, assign_form(socket, params)}
  end

  defp group_label(name, values, selected) do
    count = Enum.count(values, &(&1 in List.wrap(selected)))
    "#{name} (#{count}/#{length(values)})"
  end

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params, as: :filter))
  end
end
