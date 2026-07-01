defmodule Storybook.Examples.FormField.Registration.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
    field :bio, :string
    field :plan, :string
    field :country, :string
    field :role, :string
    field :notifications, :boolean, default: true
    field :terms, :boolean, default: false
  end

  def changeset(account \\ %__MODULE__{}, attrs \\ %{}) do
    account
    |> cast(attrs, [:name, :email, :bio, :plan, :country, :role, :notifications, :terms])
    |> validate_required([:name, :email, :plan, :country, :role],
      message: "can't be blank"
    )
    |> validate_length(:name, min: 2)
    |> validate_length(:bio, min: 10, message: "add at least 10 characters")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_acceptance(:terms, message: "you must accept the terms")
  end
end

defmodule Storybook.Examples.FormField.Registration do
  @moduledoc """
  Example: a complete account form driven entirely by `form_field`.

  One `form_field` per row covers every supported type — text, email, textarea,
  select, combobox, native-select, switch, and checkbox — all bound to a single
  Ecto changeset with `phx-change` validation and `phx-submit` handling.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Storybook.Examples.FormField.Registration.Account

  @countries [
    {"Germany", "de"},
    {"France", "fr"},
    {"Spain", "es"},
    {"Italy", "it"},
    {"Netherlands", "nl"},
    {"Poland", "pl"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:countries, @countries)
     |> assign(:submitted, nil)
     |> assign_form(Account.changeset())}
  end

  @impl true
  def handle_event("validate", %{"account" => params}, socket) do
    changeset =
      %Account{}
      |> Account.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"account" => params}, socket) do
    changeset = Account.changeset(%Account{}, params)

    if changeset.valid? do
      account = Ecto.Changeset.apply_changes(changeset)

      {:noreply,
       socket
       |> assign(:submitted, account)
       |> assign_form(Account.changeset())}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg space-y-6 p-8">
      <div>
        <h2 class="text-lg font-semibold">Create account</h2>
        <p class="text-sm text-muted-foreground">
          Every control below is a single <code class="text-xs">form_field</code>.
        </p>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" phx-debounce="300" class="space-y-4">
        <.form_field field={@form[:name]} label="Full name" placeholder="Ada Lovelace" />

        <.form_field field={@form[:email]} type="email" label="Email" placeholder="ada@example.com">
          <:leading><.icon name="mail" size="xs" decorative /></:leading>
        </.form_field>

        <.form_field
          field={@form[:bio]}
          type="textarea"
          label="Bio"
          rows="3"
          description="A short introduction (optional)."
        />

        <div class="grid grid-cols-2 gap-4">
          <.form_field field={@form[:plan]} type="select" label="Plan" placeholder="Choose…">
            <:select_content>
              <.select_item value="free">Free</.select_item>
              <.select_item value="pro">Pro</.select_item>
              <.select_item value="enterprise">Enterprise</.select_item>
            </:select_content>
          </.form_field>

          <.form_field
            field={@form[:role]}
            type="native-select"
            label="Role"
            options={[{"Select…", ""}, {"Developer", "dev"}, {"Designer", "design"}, {"Manager", "manager"}]}
          />
        </div>

        <.form_field field={@form[:country]} type="combobox" label="Country" placeholder="Search…">
          <:select_content>
            <.combobox_item :for={{label, value} <- @countries} value={value}>{label}</.combobox_item>
          </:select_content>
        </.form_field>

        <.separator />

        <.form_field field={@form[:notifications]} type="switch" label="Email notifications" />
        <.form_field field={@form[:terms]} type="checkbox" label="I accept the terms and conditions" />

        <div class="flex justify-end gap-2 pt-2">
          <.button type="submit">Create account</.button>
        </div>
      </.form>

      <div :if={@submitted} class="rounded-md border border-success/40 bg-success-soft/40 p-4 text-sm">
        <p class="font-medium">Account created</p>
        <pre class="mt-2 whitespace-pre-wrap text-xs">{inspect(@submitted, pretty: true)}</pre>
      </div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "account"))
  end
end
