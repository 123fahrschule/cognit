# Changelog

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
