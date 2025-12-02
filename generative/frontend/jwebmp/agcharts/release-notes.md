# Release and Migration Notes — AgCharts (JWebMP Rules)

Forward-only stance
- This ruleset replaces any previous AgCharts guidance; do not retain legacy anchors or monolithic docs.
- Angular 20 + JWebMP client + TypeScript + Java 25 are locked for this topic; mixing versions requires explicit override and new rules.
- **AG Charts 12.2.0 is the locked version**; no backwards compatibility with earlier versions.

December 2025 Update — AG Charts 12.2.0 Full Implementation (38/38 Options)
- **Completion**: All 38 official AG Charts 12.2.0 chart-level options now fully implemented as CRTP Java classes (127 total classes, 27 packages).
- **New interaction options (19)**: Highlight, animation, zoom, ranges, sync, contextMenu, dataSource, keyboard, touch, listeners, formatter, container, data, annotations, initialState, misc.
- **Removed deprecated options**: `highlightStyle`, `formatterFunction`/`formatterFunctions`/`formatterFormats`, `seriesId` (use `id`).
- **Java package structure**: All 27 new/updated packages exported and opened for reflection (Guice, Jackson, JWebMP).
- **Jackson JSON serialization**: All classes decorated with `@JsonInclude(NON_NULL)` and `@JsonAutoDetect`; listeners use `@JsonRawValue` for raw JavaScript.
- **Module exports/opens**: Updated `module-info.java` to export all 27 packages; reflection access granted to com.google.guice, com.fasterxml.jackson.databind, com.jwebmp.core.

Breaking changes
- Introduced modular AgCharts topic under `rules/generative/frontend/jwebmp/agcharts` with index, glossary, and per-topic rules.
- Added explicit listener naming guidance (`<id>Options`, `<id>Data`) and merge behavior references to architecture sequences.
- Topic-first glossary now authoritative for chart terms; host projects must link to this glossary rather than duplicate.
- **Listener options now use `AgChartListenersOptions`** (chart-level) and series-level listeners; raw JavaScript functions passed as strings via `@JsonRawValue`.

Migration guidance
- Update prompts and host project docs to reference `rules/generative/frontend/jwebmp/agcharts/README.md` for AgCharts usage.
- Remove references to deprecated `highlightStyle` in series; use series-level `highlight` or chart-level `highlight` instead.
- If using `formatterFunction` or global formatter options, migrate to `AgChartFormatterOptions` using the new modern formatter configuration.
- When enabling enterprise features (navigator, gradientLegend, sync modes), also load `rules/generative/frontend/jwebmp/agcharts-enterprise/README.md` and ensure licensing is documented in the host app.
- Listener callbacks: define as raw JavaScript strings and pass via `AgChartListenersOptions.setOnClick()`, `setOnHighlight()`, `setOnSelection()`.

New architecture resources
- ERD (options relationships) — `../../../../../docs/architecture/erd-chart-model.md` (shows all 38 options and nested class relationships).
- Updated: C4 component diagram, sequence diagrams for initial load/data update (listener channel naming).

See also
- Topic index — ./README.md
- Glossary — ./GLOSSARY.md
- JWebMP topic index — ../README.md
