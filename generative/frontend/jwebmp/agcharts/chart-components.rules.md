# Chart Components and CRTP Patterns — AgCharts (JWebMP)

Purpose
- Define how to create and extend chart components built on `AgChart<J>` with CRTP chaining, all 38 AG Charts 12.2.0 options, and Angular 20 client bindings.

Base contract
- `AgChart<J>` registers websocket listeners for options/data and generates Angular signals; do not mark chart subclasses `final`.
- Required override: `getInitialOptions(): Uni<AgChartOptions<?>>` returning the full `AgChartOptions` (includes all 19 core + 19 interaction options).
- Optional override: `getInitialData(): Uni<Object>` when data is fetched separately; return null/empty `Uni` to skip.
- Listener names derive from component id: `<id>Options` (initial options payload) and `<id>Data` (data updates merged into series or options.data).

CRTP fluent pattern
- All option classes extend `JavaScriptPart<J>` and implement CRTP `public J setX(...)` returning `(J) this`.
- Example chain:
  ```java
  new AgChartOptions()
      .setHighlight(new AgChartHighlightOptions()
          .setHighlightedItem(new AgChartHighlightStyleOptions().setFill("red").setOpacity(1.0)))
      .setAnimation(new AgChartAnimationOptions().setEnabled(true).setDuration(500))
      .setZoom(new AgChartZoomOptions().setEnabled(true).setWheelBehaviour("zoom"))
  ```
- **Do NOT use Lombok `@Builder` or other builder patterns**; CRTP is the only fluent style for this module.
- Jackson annotations ensure NON_NULL fields are omitted from JSON; use `@JsonInclude(JsonInclude.Include.NON_NULL)` on all option classes.

Concrete wrappers (provided)
- Bar/Line/Area/Pie/Donut/Bubble/Combination/Scatter charts preconfigure `AgChartOptions` defaults (e.g., appropriate axis types, series types).
- Treat defaults as opinionated starters; host apps may replace entire options via `setOptions(new AgChartOptions()...)` or chain option setters.
- Each wrapper's `getInitialOptions()` may include default highlight, animation, zoom settings; document in JavaDoc.

Extending/adding charts
- Subclass `AgChart<J>`; add typed setters for chart-specific options and ensure CRTP return type `J`.
- When adding new series types:
  1. Create `AgXyzSeriesOptions` extending `AgSeriesBaseOptions` with series-specific fields.
  2. Update `options/series/` package and add to module-info exports/opens.
  3. Update ERD (`../../../../../docs/architecture/erd-chart-model.md`) to show new series relationships.
  4. Add test coverage in `./testing.rules.md` if new interactions apply.
- Keep constructor defaults minimal; avoid tight coupling to data sources or app-specific services.

New interaction options (December 2025)
- `highlight`: per-item and per-series styling (highlighted/unhighlighted states); enabled by default in interactive charts.
- `animation`: smooth transitions; duration/easing/enabled control; consider disabling for performance-critical charts.
- `zoom`: zoom and pan with wheelBehaviour control; coordinate with legend/tooltip positioning.
- `ranges`: preset range UI for time-series filtering; use with TimeAxis and data-driven ranges.
- `sync`: multi-chart synchronization modes (tooltip/highlight/selection); ensure all synced charts share the same sync mode.
- `listeners`: onClick/onHighlight/onSelection callbacks as raw JavaScript; pass as string via `@JsonRawValue`.
- `formatter`: modern formatter for number/time/category display; replaces deprecated global formatter.
- Other toggles: `keyboard`, `touch`, `contextMenu`, `dataSource`, `container`, `data`, `annotations`, `initialState`, `misc`.

Interaction with JWebMP components
- Express markup using JWebMP components (Div/Span/etc.); avoid inline HTML strings.
- Ensure chart ids are stable so listener names remain deterministic across rerenders.
- If lifecycle hooks change (e.g., additional websocket listeners), update sequence diagrams and `./data-and-events.rules.md`.
- Listener payload handling: `InitialOptionsReceiver` deserializes `AgChartOptions` and pushes via `AjaxResponse`; `DataReceiver` handles data channel payloads.

Enterprise features (if using ag-charts-enterprise)
- `navigator`: mini chart range selector; requires `ag-charts-enterprise@^12.2.0`.
- `gradientLegend`: continuous gradient legend; requires `ag-charts-enterprise@^12.2.0`.
- Certain `sync` modes may require enterprise; document in release notes and host GUIDES.md.
- Ensure hosting app licenses and activates enterprise package; AgCharts rules do not enforce licensing.

See also
- Topic index — ./README.md
- Options and styling — ./options-and-styling.rules.md
- Data and events — ./data-and-events.rules.md
- Architecture component view — ../../../../../docs/architecture/c4-component-agcharts.md
