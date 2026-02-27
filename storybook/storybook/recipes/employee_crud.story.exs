defmodule Storybook.Recipes.EmployeeCrud.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :department, :string
    field :role, :string
    field :salary, :integer
    field :start_date, :string
    field :skills, {:array, :string}, default: []
  end

  def changeset(employee \\ %__MODULE__{}, attrs \\ %{}) do
    employee
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :department,
      :role,
      :salary,
      :start_date,
      :skills
    ])
    |> validate_required([:first_name, :last_name, :email, :department, :role])
    |> validate_length(:first_name, min: 2)
    |> validate_length(:last_name, min: 2)
    |> validate_format(:email, ~r/@/, message: "must be a valid email address")
    |> validate_number(:salary, greater_than: 0)
  end
end

defmodule Storybook.Recipes.EmployeeCrud do
  use PhoenixStorybook.Story, :example
  use Cognit

  alias Phoenix.LiveView.JS
  alias Storybook.Recipes.EmployeeCrud.Employee

  @employees [
    %{
      id: 1,
      first_name: "Anna",
      last_name: "Müller",
      email: "anna.mueller@example.com",
      department: "Engineering",
      role: "senior",
      salary: 85_000,
      start_date: "2022-03-15",
      active: true,
      skills: ["elixir", "javascript", "sql"]
    },
    %{
      id: 2,
      first_name: "Ben",
      last_name: "Schmidt",
      email: "ben.schmidt@example.com",
      department: "Design",
      role: "mid",
      salary: 62_000,
      start_date: "2023-06-01",
      active: true,
      skills: ["figma", "css"]
    },
    %{
      id: 3,
      first_name: "Clara",
      last_name: "Weber",
      email: "clara.weber@example.com",
      department: "Marketing",
      role: "junior",
      salary: 48_000,
      start_date: "2024-01-10",
      active: false,
      skills: ["css", "javascript"]
    },
    %{
      id: 4,
      first_name: "David",
      last_name: "Fischer",
      email: "david.fischer@example.com",
      department: "Engineering",
      role: "lead",
      salary: 95_000,
      start_date: "2020-09-01",
      active: true,
      skills: ["elixir", "javascript", "sql", "docker"]
    },
    %{
      id: 5,
      first_name: "Eva",
      last_name: "Braun",
      email: "eva.braun@example.com",
      department: "HR",
      role: "mid",
      salary: 58_000,
      start_date: "2023-02-15",
      active: true,
      skills: ["excel"]
    },
    %{
      id: 6,
      first_name: "Felix",
      last_name: "Wagner",
      email: "felix.wagner@example.com",
      department: "Engineering",
      role: "junior",
      salary: 52_000,
      start_date: "2024-08-01",
      active: false,
      skills: ["javascript", "css"]
    },
    %{
      id: 7,
      first_name: "Greta",
      last_name: "Hoffmann",
      email: "greta.hoffmann@example.com",
      department: "Design",
      role: "senior",
      salary: 78_000,
      start_date: "2021-04-12",
      active: true,
      skills: ["figma", "css", "javascript"]
    },
    %{
      id: 8,
      first_name: "Hans",
      last_name: "Becker",
      email: "hans.becker@example.com",
      department: "Engineering",
      role: "mid",
      salary: 68_000,
      start_date: "2022-11-01",
      active: true,
      skills: ["elixir", "docker"]
    },
    %{
      id: 9,
      first_name: "Ines",
      last_name: "Koch",
      email: "ines.koch@example.com",
      department: "Marketing",
      role: "lead",
      salary: 82_000,
      start_date: "2019-07-15",
      active: true,
      skills: ["excel", "sql"]
    },
    %{
      id: 10,
      first_name: "Jan",
      last_name: "Richter",
      email: "jan.richter@example.com",
      department: "HR",
      role: "junior",
      salary: 45_000,
      start_date: "2024-09-01",
      active: true,
      skills: ["excel"]
    },
    %{
      id: 11,
      first_name: "Klara",
      last_name: "Schäfer",
      email: "klara.schaefer@example.com",
      department: "Engineering",
      role: "mid",
      salary: 66_000,
      start_date: "2023-03-20",
      active: false,
      skills: ["javascript", "sql"]
    },
    %{
      id: 12,
      first_name: "Leon",
      last_name: "Krause",
      email: "leon.krause@example.com",
      department: "Design",
      role: "junior",
      salary: 47_000,
      start_date: "2024-05-15",
      active: true,
      skills: ["figma"]
    },
    %{
      id: 13,
      first_name: "Mia",
      last_name: "Schulz",
      email: "mia.schulz@example.com",
      department: "Engineering",
      role: "senior",
      salary: 91_000,
      start_date: "2020-01-10",
      active: true,
      skills: ["elixir", "javascript", "docker", "sql"]
    },
    %{
      id: 14,
      first_name: "Noah",
      last_name: "Neumann",
      email: "noah.neumann@example.com",
      department: "Marketing",
      role: "mid",
      salary: 55_000,
      start_date: "2023-08-01",
      active: false,
      skills: ["css", "excel"]
    },
    %{
      id: 15,
      first_name: "Olivia",
      last_name: "Zimmermann",
      email: "olivia.zimmermann@example.com",
      department: "HR",
      role: "senior",
      salary: 76_000,
      start_date: "2021-06-01",
      active: true,
      skills: ["excel", "sql"]
    },
    %{
      id: 16,
      first_name: "Paul",
      last_name: "Maier",
      email: "paul.maier@example.com",
      department: "Engineering",
      role: "junior",
      salary: 50_000,
      start_date: "2024-10-01",
      active: true,
      skills: ["javascript", "css"]
    }
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:all_employees, @employees)
     |> assign(:next_id, length(@employees) + 1)
     |> assign(:filter_form, to_form(%{"search" => ""}, as: :filter))
     |> assign(:status_filter, "all")
     |> assign(:show_details, false)
     |> assign(:search, "")
     |> assign(:dept_filter, nil)
     |> assign(:role_filter, nil)
     |> assign(:page, 1)
     |> assign(:page_size, 10)
     |> assign(:selected_employee, nil)
     |> assign(:editing_id, nil)
     |> assign(:deleting_employee, nil)
     |> assign(:form_sheet_title, "New Employee")
     |> assign_form(Employee.changeset())
     |> apply_filters()}
  end

  def handle_event("filter", %{"filter" => params}, socket) do
    search = Map.get(params, "search", "")

    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:filter_form, to_form(params, as: :filter))
     |> assign(:page, 1)
     |> apply_filters()}
  end

  def handle_event("status_filter", %{"tab" => status}, socket) do
    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> assign(:page, 1)
     |> apply_filters()}
  end

  def handle_event("toggle_details", %{"value" => checked}, socket) do
    {:noreply, assign(socket, :show_details, checked)}
  end

  def handle_event("dept_filter", %{"value" => value}, socket) do
    {:noreply,
     socket
     |> assign(:dept_filter, value)
     |> assign(:page, 1)
     |> apply_filters()}
  end

  def handle_event("role_filter", %{"value" => value}, socket) do
    {:noreply,
     socket
     |> assign(:role_filter, value)
     |> assign(:page, 1)
     |> apply_filters()}
  end

  def handle_event("reset_filters", _, socket) do
    {:noreply,
     socket
     |> assign(:search, "")
     |> assign(:dept_filter, nil)
     |> assign(:role_filter, nil)
     |> assign(:filter_form, to_form(%{"search" => ""}, as: :filter))
     |> assign(:page, 1)
     |> apply_filters()}
  end

  def handle_event("paginate", %{"page" => page, "page_size" => page_size}, socket) do
    {:noreply,
     socket
     |> assign(:page, page)
     |> assign(:page_size, page_size)
     |> apply_filters()}
  end

  def handle_event("new_employee", _, socket) do
    {:noreply,
     socket
     |> assign(:editing_id, nil)
     |> assign(:form_sheet_title, "New Employee")
     |> assign_form(Employee.changeset())
     |> push_command("form-sheet", "open")}
  end

  def handle_event("edit_employee", %{"id" => id}, socket) do
    emp = Enum.find(socket.assigns.all_employees, &(&1.id == id))
    changeset = Employee.changeset(%Employee{}, employee_to_params(emp))

    {:noreply,
     socket
     |> assign(:editing_id, id)
     |> assign(:form_sheet_title, "Edit Employee")
     |> assign_form(changeset)
     |> push_command("form-sheet", "open")}
  end

  def handle_event("show_details", %{"id" => id}, socket) do
    emp = Enum.find(socket.assigns.all_employees, &(&1.id == id))

    {:noreply,
     socket
     |> assign(:selected_employee, emp)
     |> push_command("details-sheet", "open")}
  end

  def handle_event("validate_form", %{"employee" => params}, socket) do
    changeset = Employee.changeset(%Employee{}, params) |> Map.put(:action, :validate)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save_employee", %{"employee" => params}, socket) do
    changeset = Employee.changeset(%Employee{}, params)

    if changeset.valid? do
      {:noreply,
       socket
       |> save_employee(changeset)
       |> apply_filters()
       |> push_command("form-sheet", "close")}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def handle_event("confirm_delete", %{"id" => id}, socket) do
    emp = Enum.find(socket.assigns.all_employees, &(&1.id == id))

    {:noreply,
     socket
     |> assign(:deleting_employee, emp)
     |> push_command("delete-dialog", "open")}
  end

  def handle_event("delete_employee", _, socket) do
    %{all_employees: all, deleting_employee: emp} = socket.assigns

    {:noreply,
     socket
     |> assign(:all_employees, Enum.reject(all, &(&1.id == emp.id)))
     |> assign(:deleting_employee, nil)
     |> apply_filters()
     |> push_command("delete-dialog", "close")}
  end

  def render(assigns) do
    ~H"""
    <.page>
      <.page_header title="Employees">
        <.tabs id="status-tabs" default="all" on-tab-changed="status_filter">
          <.tabs_list>
            <.tabs_trigger value="all">All</.tabs_trigger>
            <.tabs_trigger value="active">Active</.tabs_trigger>
            <.tabs_trigger value="inactive">Inactive</.tabs_trigger>
          </.tabs_list>
        </.tabs>
        <:actions>
          <div class="flex items-center gap-2">
            <.label for="show-details" class="text-sm text-muted-foreground">Show details</.label>
            <.switch id="show-details" checked={@show_details} on-checked-changed="toggle_details" />
          </div>
        </:actions>
        <:actions>
          <.button phx-click="new_employee">
            <.icon name="add" size="sm" class="mr-1" /> New Employee
          </.button>
        </:actions>
      </.page_header>

      <.page_content>
        <div class="flex items-center gap-3">
          <.form for={@filter_form} phx-change="filter">
            <.form_field
              field={@filter_form[:search]}
              placeholder="Search..."
              class="w-48"
              phx-debounce="200"
            />
          </.form>

          <.select
            id="dept-filter"
            placeholder="Department"
            value={@dept_filter}
            on-value-changed="dept_filter"
            class="w-40"
          >
            <.select_trigger>
              <.select_value placeholder="Department" />
            </.select_trigger>
            <.select_content>
              <.select_item value="all">All</.select_item>
              <.select_item value="Engineering">Engineering</.select_item>
              <.select_item value="Design">Design</.select_item>
              <.select_item value="Marketing">Marketing</.select_item>
              <.select_item value="HR">HR</.select_item>
            </.select_content>
          </.select>

          <.select
            id="role-filter"
            placeholder="Role"
            value={@role_filter}
            on-value-changed="role_filter"
            class="w-36"
          >
            <.select_trigger>
              <.select_value placeholder="Role" />
            </.select_trigger>
            <.select_content>
              <.select_item value="all">All</.select_item>
              <.select_item value="junior">Junior</.select_item>
              <.select_item value="mid">Mid</.select_item>
              <.select_item value="senior">Senior</.select_item>
              <.select_item value="lead">Lead</.select_item>
            </.select_content>
          </.select>

          <.button variant="ghost" size="sm" phx-click="reset_filters">
            <.icon name="close" size="sm" class="mr-1" /> Reset
          </.button>
        </div>

        <.separator />

        <.table_container>
          <.table>
            <.table_header>
              <.table_row>
                <.table_head>Employee</.table_head>
                <.table_head>Department</.table_head>
                <.table_head>Status</.table_head>
                <.table_head class="w-12"></.table_head>
              </.table_row>
            </.table_header>
            <.table_body>
              <%= for emp <- @employees do %>
                <.table_row>
                  <.table_cell>
                    <div class="flex items-center gap-3">
                      <.avatar class="h-8 w-8">
                        <.avatar_fallback class="text-xs">
                          {String.first(emp.first_name)}{String.first(emp.last_name)}
                        </.avatar_fallback>
                      </.avatar>
                      <div>
                        <p class="font-medium leading-none">{emp.first_name} {emp.last_name}</p>
                        <p class="text-sm text-muted-foreground">{emp.email}</p>
                      </div>
                    </div>
                  </.table_cell>
                  <.table_cell>{emp.department}</.table_cell>
                  <.table_cell>
                    <.badge variant={if emp.active, do: "default", else: "secondary"}>
                      {if emp.active, do: "Active", else: "Inactive"}
                    </.badge>
                  </.table_cell>
                  <.table_cell>
                    <.table_actions id={"row-actions-#{emp.id}"}>
                      <.dropdown_menu_item on-select={JS.push("edit_employee", value: %{id: emp.id})}>
                        <.icon name="edit" /> Edit
                      </.dropdown_menu_item>
                      <.dropdown_menu_item on-select={JS.push("show_details", value: %{id: emp.id})}>
                        <.icon name="visibility" /> Details
                      </.dropdown_menu_item>
                      <.dropdown_menu_separator />
                      <.dropdown_menu_item
                        variant="destructive"
                        on-select={JS.push("confirm_delete", value: %{id: emp.id})}
                      >
                        <.icon name="delete" /> Delete
                      </.dropdown_menu_item>
                    </.table_actions>
                  </.table_cell>
                </.table_row>
                <.table_row :if={@show_details} class="bg-muted/50 hover:bg-muted/50">
                  <.table_cell colspan="4" class="py-2">
                    <div class="flex gap-6 text-sm pl-11">
                      <span>
                        <span class="text-muted-foreground">Role:</span> {emp.role}
                      </span>
                      <span>
                        <span class="text-muted-foreground">Start:</span> {emp.start_date}
                      </span>
                      <span>
                        <span class="text-muted-foreground">Skills:</span> {Enum.join(
                          emp.skills,
                          ", "
                        )}
                      </span>
                    </div>
                  </.table_cell>
                </.table_row>
              <% end %>
              <.table_empty>No employees found.</.table_empty>
            </.table_body>
          </.table>
          <:footer>
            <.pagination
              id="employees-pagination"
              page={@page}
              total_pages={@total_pages}
              total_entries={@total_entries}
              page_size={@page_size}
              on_change="paginate"
            />
          </:footer>
        </.table_container>
      </.page_content>
    </.page>

    <%!-- Form sheet (new / edit) --%>
    <.sheet id="form-sheet">
      <.sheet_content side="right">
        <.sheet_header>
          <.sheet_title>{@form_sheet_title}</.sheet_title>
          <.sheet_description>Fill in the employee details below.</.sheet_description>
        </.sheet_header>

        <.form
          for={@form}
          phx-change="validate_form"
          phx-submit="save_employee"
          phx-debounce="500"
          class="flex-1 flex flex-col overflow-hidden"
        >
          <div class="flex-1 overflow-y-auto px-1 py-6 space-y-6">
            <section class="space-y-4">
              <h4 class="text-xs font-semibold text-muted-foreground">Personal</h4>

              <.form_field
                field={@form[:first_name]}
                label="First Name"
                layout="horizontal"
                placeholder="Anna"
              />
              <.form_field
                field={@form[:last_name]}
                label="Last Name"
                layout="horizontal"
                placeholder="Müller"
              />
              <.form_field
                field={@form[:email]}
                label="Email"
                layout="horizontal"
                placeholder="anna@example.com"
              />
            </section>

            <.separator />

            <section class="space-y-4">
              <h4 class="text-xs font-semibold text-muted-foreground">Work</h4>

              <.form_field
                field={@form[:department]}
                label="Department"
                layout="horizontal"
                type="select"
                placeholder="Select..."
              >
                <:select_content>
                  <.select_item value="engineering">Engineering</.select_item>
                  <.select_item value="design">Design</.select_item>
                  <.select_item value="marketing">Marketing</.select_item>
                  <.select_item value="hr">HR</.select_item>
                </:select_content>
              </.form_field>
              <.form_field
                field={@form[:role]}
                label="Role"
                layout="horizontal"
                type="native-select"
                options={[
                  {"Select...", ""},
                  {"Junior", "junior"},
                  {"Mid", "mid"},
                  {"Senior", "senior"},
                  {"Lead", "lead"}
                ]}
              />
              <.form_field
                field={@form[:salary]}
                label="Salary"
                layout="horizontal"
                type="number"
                placeholder="50000"
              />
              <.form_field
                field={@form[:start_date]}
                label="Start Date"
                layout="horizontal"
                placeholder="2025-03-01"
              />
              <.form_field
                field={@form[:skills]}
                label="Skills"
                layout="horizontal"
                type="select"
                placeholder="Select skills..."
                multiple
              >
                <:select_content>
                  <.select_item value="elixir">Elixir</.select_item>
                  <.select_item value="javascript">JavaScript</.select_item>
                  <.select_item value="css">CSS</.select_item>
                  <.select_item value="sql">SQL</.select_item>
                  <.select_item value="docker">Docker</.select_item>
                  <.select_item value="figma">Figma</.select_item>
                  <.select_item value="excel">Excel</.select_item>
                </:select_content>
              </.form_field>
            </section>
          </div>

          <.sheet_footer class="gap-2 border-t pt-4">
            <.sheet_close>
              <.button type="button" variant="outline">Cancel</.button>
            </.sheet_close>
            <.button type="submit">Save</.button>
          </.sheet_footer>
        </.form>
      </.sheet_content>
    </.sheet>

    <%!-- Delete confirmation --%>
    <.alert_dialog id="delete-dialog">
      <.alert_dialog_content>
        <.alert_dialog_header>
          <.alert_dialog_title>Delete Employee</.alert_dialog_title>
          <.alert_dialog_description>
            Are you sure you want to delete <span :if={@deleting_employee} class="font-semibold">
              {@deleting_employee.first_name} {@deleting_employee.last_name}
            </span>? This action cannot be undone.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
          <.alert_dialog_action variant="destructive" phx-click="delete_employee">
            Delete
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog_content>
    </.alert_dialog>

    <%!-- Details sheet --%>
    <.sheet id="details-sheet">
      <.sheet_content side="right">
        <%= if @selected_employee do %>
          <.sheet_header>
            <.sheet_title>
              {@selected_employee.first_name} {@selected_employee.last_name}
            </.sheet_title>
            <.sheet_description>Employee details and activity</.sheet_description>
          </.sheet_header>

          <div class="flex-1 overflow-y-auto py-4">
            <.tabs id="details-tabs" default="overview">
              <.tabs_list>
                <.tabs_trigger value="overview">Overview</.tabs_trigger>
                <.tabs_trigger value="details">Details</.tabs_trigger>
                <.tabs_trigger value="activity">Activity</.tabs_trigger>
              </.tabs_list>

              <.tabs_content value="overview">
                <div class="grid grid-cols-2 gap-4 pt-4">
                  <.stat_card label="Vacation Days" value="18 / 30" />
                  <.stat_card label="Sick Days" value="3" />
                  <.stat_card label="Projects" value="4" />
                  <.stat_card label="Tenure" value="2.5 years" />
                </div>
              </.tabs_content>

              <.tabs_content value="details">
                <div class="grid grid-cols-2 gap-x-8 gap-y-4 pt-4">
                  <.detail_field label="First Name" value={@selected_employee.first_name} />
                  <.detail_field label="Last Name" value={@selected_employee.last_name} />
                  <.detail_field label="Email" value={@selected_employee.email} />
                  <.detail_field label="Department" value={@selected_employee.department} />
                  <.detail_field label="Role" value={@selected_employee.role} />
                  <.detail_field label="Start Date" value={@selected_employee.start_date} />
                  <.detail_field label="Salary" value={"€#{@selected_employee.salary}"} />
                  <.detail_field label="Skills" value={Enum.join(@selected_employee.skills, ", ")} />
                </div>
              </.tabs_content>

              <.tabs_content value="activity">
                <div class="space-y-3 pt-4">
                  <.activity_entry date="2025-01-10" text="Vacation approved (Jan 20 – Jan 24)" />
                  <.separator />
                  <.activity_entry date="2025-01-08" text="Added to Project Phoenix" />
                  <.separator />
                  <.activity_entry date="2024-12-15" text="Annual review completed" />
                  <.separator />
                  <.activity_entry date="2024-11-20" text="Promoted to Senior Engineer" />
                </div>
              </.tabs_content>
            </.tabs>
          </div>

          <.sheet_footer class="border-t pt-4">
            <.sheet_close>
              <.button variant="outline">Close</.button>
            </.sheet_close>
          </.sheet_footer>
        <% end %>
      </.sheet_content>
    </.sheet>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <.card>
      <.card_content class="p-4">
        <p class="text-sm text-muted-foreground">{@label}</p>
        <p class="text-2xl font-bold">{@value}</p>
      </.card_content>
    </.card>
    """
  end

  defp detail_field(assigns) do
    ~H"""
    <div>
      <p class="text-sm text-muted-foreground">{@label}</p>
      <p class="font-medium">{@value}</p>
    </div>
    """
  end

  defp activity_entry(assigns) do
    ~H"""
    <div class="flex items-start gap-4">
      <span class="text-sm text-muted-foreground whitespace-nowrap">{@date}</span>
      <p class="text-sm">{@text}</p>
    </div>
    """
  end

  defp apply_filters(socket) do
    %{
      all_employees: all,
      search: search,
      status_filter: status_filter,
      dept_filter: dept_filter,
      role_filter: role_filter,
      page: page,
      page_size: page_size
    } = socket.assigns

    search_down = String.downcase(search)

    filtered =
      Enum.filter(all, fn emp ->
        full_name = "#{emp.first_name} #{emp.last_name}"

        matches_search =
          search == "" or
            String.contains?(String.downcase(full_name), search_down) or
            String.contains?(String.downcase(emp.email), search_down)

        matches_status =
          case status_filter do
            "active" -> emp.active
            "inactive" -> !emp.active
            _ -> true
          end

        matches_dept = dept_filter in [nil, "all"] or emp.department == dept_filter
        matches_role = role_filter in [nil, "all"] or emp.role == role_filter

        matches_search and matches_status and matches_dept and matches_role
      end)

    total_entries = length(filtered)
    total_pages = max(1, ceil(total_entries / page_size))
    page = min(page, total_pages)
    paged = filtered |> Enum.drop((page - 1) * page_size) |> Enum.take(page_size)

    socket
    |> assign(:employees, paged)
    |> assign(:page, page)
    |> assign(:total_entries, total_entries)
    |> assign(:total_pages, total_pages)
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "employee"))
  end

  defp save_employee(socket, changeset) do
    %{all_employees: all, editing_id: editing_id, next_id: next_id} = socket.assigns
    emp = Ecto.Changeset.apply_changes(changeset)

    if editing_id do
      updated =
        Enum.map(all, fn e ->
          if e.id == editing_id do
            %{
              e
              | first_name: emp.first_name,
                last_name: emp.last_name,
                email: emp.email,
                department: capitalize_department(emp.department),
                role: emp.role,
                salary: emp.salary,
                start_date: emp.start_date,
                skills: emp.skills
            }
          else
            e
          end
        end)

      assign(socket, :all_employees, updated)
    else
      new_emp = %{
        id: next_id,
        first_name: emp.first_name,
        last_name: emp.last_name,
        email: emp.email,
        department: capitalize_department(emp.department),
        role: emp.role,
        salary: emp.salary,
        start_date: emp.start_date,
        skills: emp.skills,
        active: true
      }

      socket
      |> assign(:all_employees, all ++ [new_emp])
      |> assign(:next_id, next_id + 1)
    end
  end

  @departments %{
    "engineering" => "Engineering",
    "design" => "Design",
    "marketing" => "Marketing",
    "hr" => "HR"
  }

  defp capitalize_department(dept), do: Map.get(@departments, dept, dept)

  defp push_command(socket, target, command) do
    Cognit.LiveView.send_command(socket, target, command)
  end

  defp employee_to_params(emp) do
    %{
      "first_name" => emp.first_name,
      "last_name" => emp.last_name,
      "email" => emp.email,
      "department" => String.downcase(emp.department),
      "role" => emp.role,
      "salary" => emp.salary,
      "start_date" => emp.start_date,
      "skills" => emp.skills
    }
  end
end
