defmodule Cognit do
  @moduledoc """
  Cognit - A Phoenix LiveView UI component library providing 40+ accessible,
  interactive components built with function components, JavaScript state machines,
  and LiveView hooks.

  Fork of [SaladUI](https://github.com/bluzky/salad_ui).

  ## Quick Start

  See `README.md` for full installation instructions. Once configured, import all
  components in your web module:

      # lib/my_app_web.ex
      defp html_helpers do
        quote do
          # ...
          use Cognit
        end
      end

  Then use components in your templates:

      <.button variant="outline" size="lg">
        Save Changes
      </.button>

  ## Components

  Every component below is imported by `use Cognit` and has a story under
  `storybook/storybook/components/`. Attributes and slots are documented in
  the owning module.

  ### Forms and input

  - `button`, `button_group` (`Cognit.Button`, `Cognit.ButtonGroup`) - actions
    in several variants and sizes; the group joins buttons into one segmented control
  - `input`, `textarea`, `label` (`Cognit.Input`, `Cognit.Textarea`, `Cognit.Label`) -
    text entry bound to a form `field` or plain `name`/`value`
  - `checkbox`, `switch`, `radio_group`, `slider` (`Cognit.Checkbox`, `Cognit.Switch`,
    `Cognit.RadioGroup`, `Cognit.Slider`) - boolean and range controls
  - `select`, `combobox` (`Cognit.Select`, `Cognit.Combobox`) - dropdown choice;
    combobox adds search, multiple selection and server-side filtering
  - `calendar`, `date_picker`, `time_picker` (`Cognit.Calendar`, `Cognit.DatePicker`,
    `Cognit.TimePicker`) - date, date range and 24-hour time entry
  - `toggle`, `toggle_group` (`Cognit.Toggle`, `Cognit.ToggleGroup`) - pressed-state
    buttons, single or multiple
  - `form`, `form_item`, `form_label`, `form_control`, `form_message` (`Cognit.Form`) -
    low-level form structure and error display
  - `form_field` (`Cognit.Components.FormField`) - one-liner wrapper: label,
    control of any `type`, description and errors

  ### Overlays

  - `dialog`, `alert_dialog`, `confirmation_dialog` (`Cognit.Dialog`, `Cognit.AlertDialog`,
    `Cognit.ConfirmationDialog`) - modal dialogs; the confirmation variant is a
    ready-made yes/no with destructive styling
  - `sheet` (`Cognit.Sheet`) - panel sliding in from a screen edge
  - `popover`, `hover_card`, `tooltip` (`Cognit.Popover`, `Cognit.HoverCard`,
    `Cognit.Tooltip`) - anchored floating content on click, hover with delay, and hover
  - `dropdown_menu`, `menu` (`Cognit.DropdownMenu`, `Cognit.Menu`) - action menus
    with items, link items, separators and shortcuts
  - `command`, `command_dialog` (`Cognit.Command`) - command palette with filtering
  - `toaster`, `send_toast/3` (`Cognit.Toast`) - toast notifications pushed from any LiveView

  ### Navigation and layout

  - `sidebar_*` (`Cognit.Sidebar`) - collapsible app sidebar with groups, menus,
    sub-menus, rail and inset
  - `app_side_nav`, `user_side_nav` (`Cognit.Components.AppSideNav`,
    `Cognit.Components.UserSideNav`) - branding entry at the top and signed-in
    user entry at the bottom of the sidebar
  - `topbar`, `page`, `page_header`, `page_content`, `page_footer`
    (`Cognit.Components.Topbar`, `Cognit.Components.Page`) - content column
    structure inside the sidebar inset
  - `login_layout`, `logo` (`Cognit.Components.LoginLayout`, `Cognit.Components.Logo`) -
    centered auth page frame and the brand mark
  - `tabs`, `breadcrumb`, `stepper` (`Cognit.Tabs`, `Cognit.Breadcrumb`, `Cognit.Stepper`) -
    tabbed content, location trail, multi-step progress
  - `pagination` with `Cognit.PaginationParams` (`Cognit.Components.Pagination`) -
    page controls driven by a normalized params struct (Scrivener pages, maps or keyword lists)
  - `locale_select`, `user_menu` (`Cognit.Components.LocaleSelect`,
    `Cognit.Components.UserMenu`) - topbar widgets for switching locale and
    showing the current user
  - `accordion`, `collapsible`, `scroll_area`, `separator` (`Cognit.Accordion`,
    `Cognit.Collapsible`, `Cognit.ScrollArea`, `Cognit.Separator`) - expand and
    collapse, custom scrollbars, dividers

  ### Data display and feedback

  - `table`, `table_container`, `table_empty` (`Cognit.Table`, `Cognit.Components.Table`) -
    data tables with a scroll container and an empty-row placeholder
  - `card`, `item`, `item_group`, `list` (`Cognit.Card`, `Cognit.Item`,
    `Cognit.CoreComponents`) - content containers, media-title-actions rows,
    title/value lists
  - `avatar`, `badge`, `icon`, `copy_button` (`Cognit.Avatar`, `Cognit.Badge`,
    `Cognit.Icon`, `Cognit.Components.CopyButton`) - profile images with fallback,
    status labels, Material Symbols, copy-to-clipboard
  - `alert`, `flash`, `flash_group`, `empty_state`, `progress`, `skeleton`
    (`Cognit.Alert`, `Cognit.Components.Flash`, `Cognit.EmptyState`, `Cognit.Progress`,
    `Cognit.Skeleton`) - status messages, LiveView flash, no-data placeholder,
    progress bars, loading placeholders
  - `chart` (`Cognit.Chart`) - Chart.js wrapper fed by data and config attrs

  ## Usage Patterns

  ### Basic Component Usage

      <.button variant="outline" size="lg">
        Large Outline Button
      </.button>

  ### Form Integration

      <.form for={@form} phx-change="validate" phx-submit="save">
        <.form_item>
          <.form_label>Email</.form_label>
          <.form_control>
            <.input field={@form[:email]} type="email" />
          </.form_control>
          <.form_message field={@form[:email]} />
        </.form_item>
      </.form>

  ### Interactive Components with Events

      <.dialog id="user-dialog" on-open={JS.push("dialog_opened")}>
        <.dialog_trigger>
          <.button>Edit Profile</.button>
        </.dialog_trigger>
        <.dialog_content>
          <!-- Dialog content -->
        </.dialog_content>
      </.dialog>

  ### Server-Client Communication

      # Send commands to components from LiveView
      def handle_event("open_dialog", _params, socket) do
        socket = Cognit.LiveView.send_command(socket, "user-dialog", "open")
        {:noreply, socket}
      end

  See `Cognit.LiveView` and `Cognit.JS` for driving components from the
  server and the client.
  """

  def component do
    quote do
      use Phoenix.Component
      use Gettext, backend: Cognit.Gettext

      import Cognit.Helpers

      alias Phoenix.LiveView.JS

      defp classes(input) do
        TwMerge.merge(List.flatten(input))
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate macro.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      import Cognit.Accordion
      import Cognit.Alert
      import Cognit.AlertDialog
      import Cognit.Avatar
      import Cognit.Badge
      import Cognit.Breadcrumb
      import Cognit.Button
      import Cognit.ButtonGroup
      import Cognit.Calendar
      import Cognit.Card
      import Cognit.Chart
      import Cognit.Checkbox
      import Cognit.Collapsible
      import Cognit.Combobox
      import Cognit.ConfirmationDialog
      import Cognit.DatePicker
      import Cognit.Dialog
      import Cognit.DropdownMenu
      import Cognit.EmptyState
      import Cognit.Form
      import Cognit.Helpers
      import Cognit.HoverCard
      import Cognit.Icon
      import Cognit.Input
      import Cognit.Item
      import Cognit.Label
      import Cognit.Menu
      import Cognit.Popover
      import Cognit.Progress
      import Cognit.RadioGroup
      import Cognit.ScrollArea
      import Cognit.Select
      import Cognit.Separator
      import Cognit.Sheet
      import Cognit.Sidebar
      import Cognit.Skeleton
      import Cognit.Slider
      import Cognit.Stepper
      import Cognit.Switch
      import Cognit.Table
      import Cognit.Tabs
      import Cognit.Textarea
      import Cognit.TimePicker
      import Cognit.Toast
      import Cognit.Toggle
      import Cognit.ToggleGroup
      import Cognit.Tooltip

      import Cognit.CoreComponents

      import Cognit.Components.AppSideNav
      import Cognit.Components.CopyButton
      import Cognit.Components.Flash
      import Cognit.Components.FormField
      import Cognit.Components.LocaleSelect
      import Cognit.Components.LoginLayout
      import Cognit.Components.Logo
      import Cognit.Components.Page
      import Cognit.Components.Pagination
      import Cognit.Components.Table
      import Cognit.Components.Topbar
      import Cognit.Components.UserHelpers
      import Cognit.Components.UserMenu
      import Cognit.Components.UserSideNav

      alias Cognit.PaginationParams
    end
  end
end
