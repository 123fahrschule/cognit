# Changelog

## 0.3.0

### Features

- **Combobox**: New searchable select component
  - Single and multiple selection with keyboard navigation
  - Client- or server-side filtering (`filter="server"` + `on-search`, with an optional `debounce`)
  - Selectable groups — toggle a whole group from its heading
  - Removable chips for selected values (`<.combobox_chips>`), including labels for preselected values not yet loaded (e.g. under server filtering)
  - Rich item content with a plain `label` used for the trigger value and chips
  - Translatable labels
- **FormField**: New `type="combobox"`, reusing the `select_content` slot for the dropdown items

### Storybook

- Add combobox example stories (chips, multi-select, server filtering, form field)

## 0.2.22

### Storybook

- **Copy Button**: Replace the Stripe-style fake API key in the example story with a non-secret placeholder so secret scanners don't flag it

## 0.2.21

### Bug Fixes

- **Select**: Keep an empty-string option value (e.g. an "Any" choice) through a `phx-change` form round-trip — previously selecting it and then another value left two items checked and flashed the trigger back to the placeholder

### Storybook

- Add a bug-reproduction story for the select empty-string value round-trip

## 0.2.20

### Features

- **Forms**: Add `aria-invalid` error state styling to `input`, `checkbox`, `radio_group`, `select`, `switch`, and `textarea` — propagated via `maybe_set_aria_invalid` helper and styled through the Tailwind preset
- **Button**: Auto-promote to a `Phoenix.Component.link/1` when `navigate`, `patch`, or `href` is passed without an explicit `as` — previously these attrs flowed through `@rest` onto a `<button>` and were inert
- **Pagination**: Accept `%Scrivener.Page{}` directly — no need to construct `PaginationParams` manually

### Bug Fixes

- **FormField**: Propagate `checked` through the checkbox branch — switch from a hardcoded `false` default to `Phoenix.HTML.Form.normalize_value/2` so form-bound checkboxes render with the correct state
- **Input**: Align the date/time picker icon to the right edge

### Storybook

- Add error variations for `checkbox`, `input`, `label`, `radio_group`, `select`, `switch`, and `textarea`

### Docs

- **Dialog**: Note that `id` is required by the JS hook

## 0.2.19

### Features

- **Alert**: Add error, success, warning, info, alert, and destructive variants with alert-specific color tokens
- **Flash**: Style flash message kinds through the matching Alert variants
- **Tooltip**: Restyle tooltip with dark background and lighter text

## 0.2.18

### Features

- **`use Cognit`**: Import all shell components (`AppSideNav`, `LoginLayout`, `UserHelpers`, `UserMenu`, `UserSideNav`) so consumers no longer need to import them individually

### Docs

- Document `app_side_nav` and `user_side_nav` rendering modes (dropdown / button / static) and the `:user` map shape via moduledocs
- Document `send_command` (server → client) and `dispatch_command` (client → client) in README
- Document app shell composition in README

## 0.2.17

### Features

- **Badge**: Add `success` variant (green background for confirmation/positive states)
- **Badge**: Add `number` boolean attribute that renders a circular badge sized for count display (`h-5 min-w-5`, centered)

## 0.2.16

### Bug Fixes

- **Sidebar**: Allow multi-line labels in `sidebar_menu_button` and `sidebar_menu_sub_button` — switch fixed `h-*` to `min-h-*` so rows grow with wrapped content, with `!min-h-0` keeping collapsed icon mode at 32×32
- **Sidebar**: Add `pointer-events-none` to `sidebar_group_label` in collapsed (icon) mode — invisible labels were intercepting hover/click on overlapping first menu items

### Storybook

- Add `sidebar_menu_multiline_label` bug reproduction story

## 0.2.15

### Bug Fixes

- **Components**: Pass through LiveView link attributes (`navigate`, `patch`, `replace`, `method`, `csrf_token`, plus standard anchor attrs) on `breadcrumb_link`, `pagination_link`/`pagination_next`/`pagination_previous`, `dropdown_menu_link_item`, `sidebar_menu_button`, `sidebar_menu_sub_button`, and `login_card_action`
- **Components**: Include missing element-specific attrs in `rest` globals — `rowspan` on `table_cell`; `placeholder`, `readonly`, `required`, `minlength`, `maxlength`, `autofocus`, `wrap` on `textarea`; `disabled`, `form`, `required`, `autofocus` on `checkbox`; `form` on `select_trigger`

## 0.2.14

### Refactoring

- **Hooks**: Namespace LiveView hooks with `Cognit.` prefix (`FlashMessage` → `Cognit.FlashMessage`, `LocaleSelect` → `Cognit.LocaleSelect`, `Pagination` → `Cognit.Pagination`, `Sidebar` → `Cognit.Sidebar`, `SidebarMenu` → `Cognit.SidebarMenu`) to avoid collisions with downstream app hooks
- **Components**: Namespace built-in component ids with `cognit-` prefix (`sidebar` → `cognit-sidebar`, `locale-select` → `cognit-locale-select`, `user-menu` → `cognit-user-menu`, `client-error`/`server-error` flash → `cognit-client-error`/`cognit-server-error`)

## 0.2.13

### Bug Fixes

- **Sidebar**: Add tooltips for the sidebar toggle and collapsed sidebar entries so icon-only navigation remains understandable
- **Tooltip**: Generate a DOM id when no tooltip id is passed so SaladUI hooks can mount correctly
- **Tooltip**: Respect zero millisecond open and close delays

## 0.2.12

### Features

- **Table**: Add `sortable_table_head` for LiveView-backed sortable columns with ARIA sort state and visual indicators

## 0.2.11

### Bug Fixes

- **Sidebar**: `SidebarPlug` now assigns `:sidebar_state` on `conn`, so dead-view layouts no longer raise `KeyError` for `@sidebar_state`
- **Locale**: `LocalePlug` now assigns `:locale` on `conn`, and `LocaleHook` assigns `:locale` on the socket (reading from params → session → default) — `@locale` is now available in both dead and live view layouts

## 0.2.10

### Bug Fixes

- **Tooltip**: Cancel pending open timer on `mouseleave`/`blur` so tooltips no longer get stuck open after fast hover-out

### Storybook

- Add `tooltip_stuck_on_fast_hover` bug reproduction story

## 0.2.9

### Bug Fixes

- **Tabs**: Fix content flash when switching controlled tabs — skip optimistic local update so old content stays visible until the server patch arrives

### Storybook

- Add `tabs_dynamic_triggers` bug reproduction story

## 0.2.8

### Bug Fixes

- **Theme**: Define `neutral-100` foundation token used by `success-foreground` and neutral backgrounds
- **Button**: Restore readable foreground color for `success` variant in downstream apps importing Cognit styles

## 0.2.7

### Features

- **Gettext**: Bundled `errors` domain with EN/DE translations for Ecto changeset messages
- **Form**: `form_message` now translates field errors via `Cognit.Gettext` by default

### Bug Fixes

- **User Side Nav**: Drop default that blocked `id` assignment

### Refactoring

- **Form Field**: Drop error state from labels

### Docs

- Document bundled error translations and umbrella setup in README
- Rebrand moduledoc from SaladUI to Cognit

### Storybook

- Reorganize sidebar with `examples` and `bug_reproductions` sections
- Add `form_message` variations for error translation

## 0.2.6

### Bug Fixes

- **Radio Group**: Preserve selection state across LiveView DOM patches

### Storybook

- Add radio group form integration recipe with empty and preset value variants

## 0.2.3

### Bug Fixes

- **Select**: Preserve checkmarks when LiveView patches dynamic options
- **Select**: Allow LiveView to patch options list and disabled state
- **Click Outside**: Use capture phase to detect clicks blocked by `stopPropagation`
- **Positioner**: Re-apply reference size CSS vars on update

### Storybook

- Add multiselect variant to select story
- Add dynamic select recipe with second select instance

## 0.2.2

### Bug Fixes

- **Tabs**: Preserve active tab state across LiveView DOM patches

## 0.2.1

### New Components

- **`empty_state`** — Empty state component with illustration, title, description, and action slot

### Bug Fixes

- **Positioner**: Account for ancestor CSS transforms in fixed positioning
- **Select**: Toggle menu on trigger click instead of always opening

### Storybook

- Restore popover story after portal attr fix; add padding to prevent focus ring clipping
- Add dialog form recipe with nested positioned components

## 0.2.0

### Breaking Changes

- **Requires Phoenix LiveView ~> 1.1** (was ~> 1.0)
- **Pagination rewritten**:
  - Two modes: **URL mode** (default, via query params) and **event mode** (via `phx-click`)
  - New `PaginationParams` struct (`PaginationParams.from/1`) for normalized input
  - Page size picker uses `select` component instead of native `<select>`
  - `PaginationParams` aliased automatically via `use Cognit`
- **Sidebar trigger** no longer has an `icon` slot — uses fixed icon
- **Sidebar header** no longer auto-renders logo and trigger — now purely renders slot content
- **Sidebar** switched from dark to light color scheme
- **Layout** uses fixed viewport height with proper overflow scrolling (affects `sidebar_provider`, `sidebar_inset`, `page`)
- **Topbar** now renders both mobile and desktop sidebar triggers
- **`table_container`** has new structure — `footer` slot renders outside the scrollable area
- **Select item** check indicator moved from left to right side
- **Theme colors** updated — primary, destructive, foreground, sidebar colors all changed
- **`class` attr type** normalized to `:any` across all components (was `:string` in many) — lists and `nil` now accepted everywhere

### Style Alignment

Component styles aligned with Shadcn defaults. Affected components: **button**, **input**, **select**, **switch**, **checkbox**, **table**, **page**, **topbar**, **sidebar**, **dialog**, **sheet**, **progress**.

### New Components

- **`app_side_nav`** — Sidebar header navigation with logo, title, and optional dropdown menu
- **`user_side_nav`** — Sidebar footer user navigation with avatar, name, and optional dropdown menu

### New Features

- **`form_field`**: `layout` attr with `"vertical"` (default) and `"horizontal"` variants
- **`confirmation_dialog`**: `icon`, `confirm_label`, `cancel_label`, `confirm_variant` attrs; centered layout
- **`progress`**: `color` attr for custom indicator color (e.g. `"bg-red-500"`)
- **`locale_select`**: Shows country flag and locale code in trigger
- **`table_container`**: New `footer` slot
- **Dark theme** support via CSS variables

### Bug Fixes

- **JS component state preserved across LiveView DOM patches** — components no longer reset when LiveView patches the DOM
- **Positioned components** (dropdown menu, hover card, popover, tooltip, select): reapply positioning after DOM patch
- **Sheet/Dialog**: Close animation plays on conditional rendering removal
- **Select**: Values normalized to strings to match `data-value` attrs
- **Icons**: Fixed font icon scaling
- **Progress**: Fixed indeterminate animation
