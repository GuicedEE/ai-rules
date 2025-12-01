# Chart Components and CRTP Patterns — AgCharts (JWebMP)

Purpose
- Define how to create and extend chart components built on `AgChart<J>` with CRTP chaining and Angular 20 client bindings.

Base contract
- `AgChart<J>` registers websocket listeners for options/data and generates Angular signals; do not mark chart subclasses `final`.
- Required override: `getInitialOptions(): Uni<AgChartOptions<?>>` returning the initial options object.
- Optional override: `getInitialData(): Uni<Object>` when data is fetched separately; return null/empty `Uni` to skip.
- Listener names derive from the component id: `<id>Options` and `<id>Data`.

Concrete wrappers (provided)
- Bar/Line/Area/Pie/Donut/Bubble/Combination/Scatter charts preconfigure `AgChartOptions` defaults. Treat these defaults as opinionated starters; host apps may replace options.
- Keep CRTP setter returns `(J) this` and avoid Lombok builders; align with `rules/generative/backend/fluent-api/GLOSSARY.md`.

Extending/adding charts
- Subclass `AgChart<J>`; add typed setters for new options objects and ensure CRTP return types.
- When adding new series types, mirror AG Charts type fields in `options/series/*`; update ERD (`../../../../../docs/architecture/erd-chart-model.md`) and rules links if relationships change.
- Keep constructor defaults minimal; avoid tight coupling to data sources or app-specific services.

Interaction with JWebMP components
- Express markup using JWebMP components (Div/Span/etc.); avoid inline HTML strings.
- Ensure chart ids are stable so listener names remain deterministic across rerenders.
- If lifecycle hooks change (e.g., additional websocket listeners), update sequence diagrams and `./data-and-events.rules.md`.

See also
- Topic index — ./README.md
- Options and styling — ./options-and-styling.rules.md
- Data and events — ./data-and-events.rules.md
- Architecture component view — ../../../../../docs/architecture/c4-component-agcharts.md
