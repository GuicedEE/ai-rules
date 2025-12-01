# Configuration & Rendering Rules

Purpose
- Shape Ng* metadata into renderable configuration objects and generate TypeScript fragments that downstream Angular builds consume.

Configuration builders
- `ComponentConfiguration` aggregates imports/providers/fields/hooks/interfaces/signals/models; use fluent setters returning `(J) this` (CRTP) and avoid Lombok builders.
- `AbstractNgConfiguration` handles routing, directives, and providers; call `splitComponentReferences()` before rendering to resolve import paths and provider tokens.
- Keep configuration objects immutable to consumers after build; expose only read methods and rendering helpers.

Rendering guidelines
- Use provided render helpers (`renderOnInit`, `renderOnDestroy`, `renderInjects`, `renderInterfaces`, `renderFields`, `renderGlobalFields`, `renderSignals`, `renderModels`) to emit TS strings; do not concatenate ad-hoc fragments.
- Ensure rendered snippets include required Angular imports/interfaces (e.g., `OnInit`, `OnDestroy`) based on used hooks.
- Respect module names and file paths declared in annotations; avoid defaulting to root-level imports which break multi-module Angular apps.
- Treat generated TS as build artifacts only. Do not write files from within helpers; hand responsibility to downstream build pipeline.

Validation & consistency
- Normalize types using `tstypes` primitives to avoid `any`; prefer explicit nullable markers when mapping JSpecify annotations.
- Preserve ordering: annotations → map aggregation → configuration build → reference split → render; bypassing steps leads to missing imports or duplicated providers.
- When extending configuration classes, keep CRTP generic signatures aligned and mark overrides with `@SuppressWarnings("unchecked")` only where necessary.

See also
- Index — `README.md`
- Annotations — `annotations.rules.md`
- Runtime wiring — `scanning-runtime.rules.md`
- Testing — `testing.rules.md`
