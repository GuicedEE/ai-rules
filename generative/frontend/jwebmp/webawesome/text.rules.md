# WaText — WebAwesome (JWebMP Wrapper)

Directive-style wrapper for applying WebAwesome typography utilities (`waText`, body/heading/caption, links, lists). No base rules exist in the shared WebAwesome set; this file documents wrapper usage.

Usage
- `WaText` defaults to a `<div>` but can target any tag via `setTag()` (e.g., `p`, `h1`..`h6`, `a`).
- Enable directive with `waText` (default true). Size helpers: `waBody`, `waHeading`, `waCaption`, `waLongform` (string or boolean flag variants). Link styles via `waLink` (boolean or string like `plain`).
- Utility flags: `waListPlain`, `waFormControlText` (label/value/placeholder/hint), `waFontSize`, `waFontWeight`, `waColorText`, `waTextTruncate`.
- Add to clusters/stacks; apply grid utilities to the parent cluster when needed.

Patterns
- Keep CRTP chaining; avoid builders and inline HTML.
- Prefer semantic tags (p/h1-h6/a/ul/li) and meaningful text for accessibility.
- When using links, set href on the component after switching the tag to `a`.
