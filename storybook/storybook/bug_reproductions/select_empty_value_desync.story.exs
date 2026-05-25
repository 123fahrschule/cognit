defmodule Storybook.BugReproductions.SelectEmptyValueDesync do
  use PhoenixStorybook.Story, :example
  use Cognit

  def doc do
    """
    Bug reproduction for `<.select>` desync when an empty-string option is in play.

    The select declares an option with `value=""` ("Any") and is bound to a
    `phx-change` form. Selecting that empty option and then another value used to
    leave two items visibly checked and flash the trigger back to the placeholder.

    Steps:
    1. Open the dropdown, click "A".
    2. Open the dropdown, click "Any" (value="").
    3. Open the dropdown, click "B".

    Expected: only "B" is checked, trigger reads "B".
    Before the fix: "A" (or "Any") and "B" both showed as checked.

    The current server value is shown below the select so the round-trip of the
    empty-string value is observable.
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign_form(socket, %{"education_short_code" => ""})}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 p-4 max-w-sm">
      <.form for={@form} as={:filter} phx-change="search">
        <.form_field field={@form[:education_short_code]} type="select" label="Education">
          <:select_content>
            <.select_group>
              <.select_item value="">Any</.select_item>
              <.select_item value="A">A</.select_item>
              <.select_item value="B">B</.select_item>
            </.select_group>
          </:select_content>
        </.form_field>
      </.form>

      <p class="text-sm text-muted-foreground">
        Server value: {inspect(@form.params["education_short_code"])}
      </p>
    </div>
    """
  end

  def handle_event("search", %{"filter" => params}, socket) do
    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params, as: :filter))
  end
end
