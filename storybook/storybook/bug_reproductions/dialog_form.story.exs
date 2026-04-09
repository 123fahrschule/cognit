defmodule Storybook.BugReproductions.DialogForm do
  use PhoenixStorybook.Story, :example
  use Cognit

  @roles [
    %{value: "admin", label: "Admin"},
    %{value: "editor", label: "Editor"},
    %{value: "viewer", label: "Viewer"}
  ]

  @departments [
    %{value: "engineering", label: "Engineering"},
    %{value: "design", label: "Design"},
    %{value: "marketing", label: "Marketing"},
    %{value: "sales", label: "Sales"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       roles: @roles,
       departments: @departments,
       form: to_form(%{"name" => "", "email" => "", "role" => "", "department" => ""})
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center p-12">
      <.dialog id="invite-dialog">
        <.dialog_trigger>
          <.button><.icon name="person_add" class="mr-2" /> Invite member</.button>
        </.dialog_trigger>
        <.dialog_content class="sm:max-w-md">
          <.dialog_header>
            <.dialog_title>Invite team member</.dialog_title>
            <.dialog_description>
              Fill in the details to invite a new team member.
            </.dialog_description>
          </.dialog_header>
          <.form for={@form} phx-submit="invite" class="space-y-4 py-4">
            <div class="space-y-2">
              <.label>Role</.label>
              <.select id="invite-role" name="role" on-value-changed="role_changed">
                <.select_trigger class="w-full">
                  <.select_value placeholder="Select a role" />
                </.select_trigger>
                <.select_content>
                  <.select_group>
                    <.select_item :for={role <- @roles} value={role.value}>
                      {role.label}
                    </.select_item>
                  </.select_group>
                </.select_content>
              </.select>
            </div>
            <div class="space-y-2">
              <.label>Department</.label>
              <.select id="invite-department" name="department" on-value-changed="department_changed">
                <.select_trigger class="w-full">
                  <.select_value placeholder="Select a department" />
                </.select_trigger>
                <.select_content>
                  <.select_group>
                    <.select_item :for={dept <- @departments} value={dept.value}>
                      {dept.label}
                    </.select_item>
                  </.select_group>
                </.select_content>
              </.select>
            </div>
            <div class="flex items-center gap-3 pt-2">
              <.dropdown_menu id="invite-actions">
                <.dropdown_menu_trigger>
                  <.button variant="outline" size="sm">
                    <.icon name="more_vert" size="sm" /> Actions
                  </.button>
                </.dropdown_menu_trigger>
                <.dropdown_menu_content>
                  <.dropdown_menu_item>
                    <.icon name="content_copy" class="mr-2" /> Duplicate invite
                  </.dropdown_menu_item>
                  <.dropdown_menu_item>
                    <.icon name="schedule" class="mr-2" /> Schedule for later
                  </.dropdown_menu_item>
                  <.dropdown_menu_separator />
                  <.dropdown_menu_item variant="destructive">
                    <.icon name="delete" class="mr-2" /> Discard
                  </.dropdown_menu_item>
                </.dropdown_menu_content>
              </.dropdown_menu>

              <.popover id="invite-note">
                <.popover_trigger>
                  <.button variant="outline" size="sm">
                    <.icon name="sticky_note_2" size="sm" /> Add note
                  </.button>
                </.popover_trigger>
                <.popover_content class="w-72">
                  <div class="space-y-2">
                    <p class="text-sm font-medium">Note</p>
                    <.input id="invite-note-input" placeholder="Add a note for the invitee..." />
                  </div>
                </.popover_content>
              </.popover>

              <.tooltip>
                <.tooltip_trigger>
                  <.button variant="ghost" size="icon">
                    <.icon name="help" />
                  </.button>
                </.tooltip_trigger>
                <.tooltip_content>
                  Invited members will receive an email with instructions.
                </.tooltip_content>
              </.tooltip>

              <.hover_card id="invite-info">
                <.hover_card_trigger>
                  <span class="text-sm text-muted-foreground underline decoration-dotted cursor-help">
                    Permissions
                  </span>
                </.hover_card_trigger>
                <.hover_card_content class="w-64">
                  <div class="space-y-1">
                    <p class="text-sm font-medium">Role permissions</p>
                    <p class="text-xs text-muted-foreground">
                      Admin: full access. Editor: create and edit. Viewer: read-only.
                    </p>
                  </div>
                </.hover_card_content>
              </.hover_card>
            </div>
            <.dialog_footer>
              <.button type="submit">Send invitation</.button>
            </.dialog_footer>
          </.form>
        </.dialog_content>
      </.dialog>
    </div>
    """
  end

  @impl true
  def handle_event("role_changed", %{"value" => value}, socket) do
    {:noreply, assign(socket, form: to_form(Map.put(socket.assigns.form.params, "role", value)))}
  end

  def handle_event("department_changed", %{"value" => value}, socket) do
    {:noreply,
     assign(socket, form: to_form(Map.put(socket.assigns.form.params, "department", value)))}
  end

  def handle_event("invite", _params, socket) do
    Cognit.LiveView.send_command(socket, "invite-dialog", "close")

    {:noreply,
     assign(socket, form: to_form(%{"name" => "", "email" => "", "role" => "", "department" => ""}))}
  end
end
