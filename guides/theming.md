# Theming

Colors are HSL triplets in CSS custom properties, declared in `assets/css/theme.css` for `:root` and overridden under `.dark`. The Tailwind preset registers each pair as a color (`bg-primary`, `text-primary-foreground`, `bg-destructive-soft`, and so on) through `assets/tailwind.colors.json`, so components never hard-code hex values.

## Token families

- **Surface and text**: `background`, `foreground`, `card`, `popover`, `muted`, `accent`, `border`, `input`, `ring`
- **Semantic**: `primary`, `secondary`, `destructive`, `success`, `warning`, `info`, each with a `-foreground` and a tinted `-soft` / `-soft-foreground` pair for badges and alerts
- **Shape and depth**: the whole `rounded-xs` … `rounded-xl` scale is derived from `--radius` with fixed offsets, so changing that one variable moves every corner in step; `--shadow-2xs` through `--shadow-2xl` replace Tailwind's stock `shadow-*` scale
- **Type**: `font-sans` is Open Sans, loaded by `Cognit.Assets.head` in the root layout

## Rebranding

Override the variables after importing `styles.css`, once for light and once for dark:

```css
@import "../../deps/cognit/assets/css/styles.css";

:root {
  --primary: 221 83% 53%;
  --primary-foreground: 0 0% 100%;
  --radius: 0.5rem;
}

.dark {
  --primary: 217 91% 60%;
  --primary-foreground: 222 47% 11%;
}
```

## Dark mode

Dark mode is class-based (`darkMode: ["class"]` in the preset). Add `class="dark"` to `<html>` to switch; there is no media-query fallback, so wire the toggle yourself.

## Adding a token

Declare the variable in CSS, then register it under `theme.extend.colors` in your Tailwind config. A variable alone produces no utility class.

```css
:root {
  --brand: 12 76% 61%;
}
```

```javascript
// assets/tailwind.config.js
theme: {
  extend: {
    colors: {
      brand: "hsl(var(--brand))",
    },
  },
},
```
