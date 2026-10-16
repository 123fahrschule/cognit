# Migrating from another component library

Adopting Cognit into an app that already uses shadcn/ui, SaladUI, PhoenixUiComponents, or another Tailwind-based system risks clashes: duplicate `@tailwind base` rules, conflicting CSS variables, conflicting preset configs.

The safe pattern is a **parallel asset pipeline**:

1. **Separate CSS entrypoint**, e.g. `assets/css/cognit.css` that imports `deps/cognit/assets/css/styles.css` and emits Cognit's Tailwind layers.
2. **Separate Tailwind config**, `assets/tailwind.cognit.config.js` extending Cognit's preset, scoped to Cognit-using templates only.
3. **Separate esbuild profile** that emits `priv/static/assets/cognit.css` and `cognit.js` alongside your existing `app.*` bundle.
4. **Separate root layout** so Cognit-rendered LiveViews use a layout that includes only the Cognit bundle; legacy pages keep their existing layout.

Migrate routes from the legacy layout to the Cognit layout one at a time. Once the last legacy page is gone, collapse the two pipelines back into one.
