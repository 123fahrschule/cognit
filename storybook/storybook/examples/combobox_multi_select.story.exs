defmodule Storybook.Examples.ComboboxMultiSelect.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :skills, {:array, :string}, default: []
  end

  def changeset(profile \\ %__MODULE__{}, attrs \\ %{}) do
    profile
    |> cast(attrs, [:skills])
    |> update_change(:skills, fn skills -> Enum.reject(skills, &(&1 == "")) end)
    |> validate_length(:skills, min: 1, message: "select at least one skill")
  end
end

defmodule Storybook.Examples.ComboboxMultiSelect do
  @moduledoc """
  Example: multi-select combobox bound to a form.

  The combobox is wired to an Ecto `embedded_schema` through `to_form/1` and
  `field={@form[:skills]}`. Selected values round-trip through the form as
  `profile[skills][]`, validate on change, and are applied on submit.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.ComboboxMultiSelect.Profile

  @skills [
    "Elixir",
    "Phoenix",
    "LiveView",
    "Ecto",
    "JavaScript",
    "TypeScript",
    "React",
    "Vue",
    "Svelte",
    "Tailwind CSS",
    "PostgreSQL",
    "MySQL",
    "Redis",
    "Docker",
    "Kubernetes",
    "AWS",
    "GraphQL",
    "REST",
    "Git",
    "Python",
    "Rust",
    "Go"
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:skills, @skills)
     |> assign(:submitted, nil)
     |> assign_form(Profile.changeset(%Profile{}, %{"skills" => ["Elixir", "Phoenix"]}))}
  end

  def handle_event("validate", %{"profile" => params}, socket) do
    changeset =
      %Profile{}
      |> Profile.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"profile" => params}, socket) do
    changeset = Profile.changeset(%Profile{}, params)

    if changeset.valid? do
      profile = Ecto.Changeset.apply_changes(changeset)

      {:noreply,
       socket
       |> assign(:submitted, profile.skills)
       |> assign_form(Profile.changeset(%Profile{}, params))}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md space-y-4 p-8">
      <div>
        <h2 class="text-lg font-semibold">Multi-select combobox in a form</h2>
        <p class="text-sm text-muted-foreground">
          Bound to an Ecto <code>embedded_schema</code>
          via <code>to_form/1</code>
          and a <code>field</code>
          assign. The values round-trip through the form
          as <code>profile[skills][]</code>, validate on change, and apply on submit.
        </p>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <div class="space-y-1.5">
          <.combobox field={@form[:skills]} multiple>
            <.combobox_trigger class="w-full">
              <.combobox_value placeholder="Select skills..." />
            </.combobox_trigger>
            <.combobox_content>
              <.combobox_input placeholder="Search skills..." />
              <.combobox_empty>No skill found.</.combobox_empty>
              <.combobox_list>
                <.combobox_item :for={skill <- @skills} value={skill}>
                  {skill}
                </.combobox_item>
              </.combobox_list>
            </.combobox_content>
          </.combobox>
          <.form_message field={@form[:skills]} />
        </div>

        <.button type="submit">Save</.button>
      </.form>

      <div class="rounded-md border bg-muted/40 p-3 text-sm">
        <div><span class="font-medium">Current value:</span> {inspect(@form[:skills].value)}</div>
        <div><span class="font-medium">Last submitted:</span> {inspect(@submitted)}</div>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "profile"))
  end
end
