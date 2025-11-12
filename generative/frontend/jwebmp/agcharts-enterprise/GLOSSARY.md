# Glossary — AgCharts Enterprise (JWebMP Plugin)

Purpose
- Minimal authoritative glossary for this plugin. Host projects should copy only enforced aligned names and link back to this glossary.

Terms
- AgCharts Community: The free/community edition of AG Charts used by the base JWebMP AgCharts plugin.
- AgCharts Enterprise: The paid edition providing additional chart types and features; enabled via this plugin.
- Page Configurator: An auto-discovered JWebMP component that contributes frontend dependencies and settings, including TypeScript libs via annotations.
- @TsDependency: Annotation used to declare a TypeScript/NPM dependency (e.g., name = "ag-charts-enterprise").
- CRTP (Curiously Recurring Template Pattern): Fluent API pattern used across JWebMP/GuicedEE where setters return (J)this.

AG Charts terms
- Series: A collection of data points of the same visual type (e.g., line, bar/column, area, pie, treemap, waterfall).
- Axis: Chart axis definition (category, number, time).
- Tooltip: On-hover detail display for data points; can be customized.
- Legend: Component listing series and their markers/labels; can be toggled.
- Navigator: Enterprise timeline/navigator control for zoom/pan in time series.
- Cross-filtering: Enterprise feature where interactions in one chart filter data in other charts.
- Pivoting (Charts): Aggregating data by dimensions (e.g., groupBy: region) to generate series or categories dynamically.
- Theme: Visual presets for charts (colors, fonts, backgrounds).

AG Grid terms (for combined Grid + Charts dashboards)
- Column: Grid column definition describing field, header name, renderers, etc.
- Row Data: Array of row objects rendered by the grid; often the source for charts.
- Data Source: Abstraction for providing data to the grid (client-side or server-side row model).
- Transaction: Batch updates applied to the grid’s data (add, update, remove rows).
- Filter/Sort/Group: Grid state operations that can be mirrored to charts for synchronized views.
- Enterprise Features (Grid): Pivoting, row grouping, advanced filtering, server-side row model, charts integration.
- Events: Grid events (rowSelected, selectionChanged, filterChanged) useful for bridging to chart updates.

JWebMP integration concepts
- Component: Server-side Java object representing a UI element (e.g., Div, Tabs, AgChartComponent).
- Page: A top-level server-rendered container that collects components and resources for a route/view.
- ServiceLoader Discovery: Mechanism used for auto-discovering configurators and services on the classpath.
- Forward-Only Policy: Documentation and rules must be updated forward; do not mutate generated client artifacts directly.
- Secrets Provider: Application-specific abstraction to retrieve secrets (e.g., license keys) at runtime.

LLM guidance
- Do not propose edits to generated artifacts (TS/HTML/site bundles); treat them as read-only.
- Prefer JWebMP components over inline HTML strings.
- Respect Forward-Only change policy.

Links
- Plugin rules index — ./README.md
- Angular language rules index — ../../../language/angular/README.md
