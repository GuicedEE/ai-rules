# Page Configurator and Assets — WebAwesome (JWebMP Wrapper)

Use `WebAwesomePageConfigurator` (implements `IPageConfigurator`, `TypescriptIndexPageConfigurator`) to wire assets and theme classes for every page. Do not embed asset tags manually.

Responsibilities
- Inject CSS/JS in priority order: `webawesome.css` then theme CSS (`id="webawesome-theme"`, `sortOrder=Integer.MAX_VALUE-100`) with `RequirementsPriority.First`; JS loader `webawesome.loader.js` as `type="module"` with `RequirementsPriority.Top_Shelf`.
- Apply body classes from static fields when present: `themeClassName`, `themePalletName`, `themeBrandName`.
- Advertise the Angular dependency via `@TsDependency(value="angular-awesome", version="*")` so the TypeScript index picks up the module.
- Carry `data-fa-kit-code` and `data-webawesome` attributes on the CSS reference when `faKitCode` or `basePath` are set.

Configuration guidance
- Keep `basePath` and `themePath` synchronized with deployed static assets; prefer `/webawesome/` style prefixes with trailing slashes for module resolution.
- Use theme overrides by setting `themePath` to a concrete CSS file and updating class names to match (`wa-theme-*`, `wa-pallet-*`, `wa-brand-*`); avoid inlining styles.
- When adding assets, preserve existing priority ordering (CSS first) and avoid non-module scripts.
- Leave `enabled()` returning true unless a host-specific feature flag replaces the configurator; document any replacements in host guides.

Testing expectations
- Add Java Micro Harness tests that render a page with the configurator, asserting CSS/JS URLs, `type="module"`, and body class application.
- Keep BrowserStack optional; defaults should run headless and offline.

See also
- Overview — ./overview.rules.md
- Component rules — ./button.rules.md, ./input.rules.md#number-input, ./cluster.rules.md, ./stack.rules.md
- Testing — ./testing.rules.md
- Base WebAwesome assets — ../../webawesome/page.rules.md
