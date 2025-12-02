# Glossary — AgCharts (JWebMP Wrapper)

Precedence and usage
- Topic-first: load this glossary after base Angular 20, TypeScript, and JWebMP client glossaries. Do not duplicate definitions in host projects; link here.
- Prompt language alignment: refer to chart listener channels as `<componentId>Options` / `<componentId>Data`; use CRTP setters returning `(J) this`; avoid builders and inline string HTML.

Terms

**AG Charts 12.2.0 Compliance (38 options, 127 Java classes)**
- Version lock: AG Charts 12.2.0 is minimum and only supported; no backwards compatibility.
- Options coverage: All 38 official chart-level options fully implemented as CRTP Java classes.

**Core Chart Elements (19 options)**
- `axes`: List of chart axes (Number, Time, Category, Log, OrdinalTime, UnitTime, GroupedCategory).
- `series`: List of series (Bar, Line, Area, Pie, Donut, Bubble, Scatter, Combination).
- `legend`: Chart legend with pagination, listeners, styling.
- `tooltip`: Chart-level tooltip with position, interaction, anchoring.
- `theme`: Theme name (string) or object with palette customization.
- `locale`: Localization options for labels, number/time formats.
- `background`: Chart background fill color/image.
- `seriesArea`: Series area appearance (fill, stroke).
- `overlays`: Decorative overlays (lines, bands).
- `navigator`: Mini chart for range selection (requires enterprise).
- `gradientLegend`: Continuous gradient legend (requires enterprise).
- `width`, `height`, `minWidth`, `minHeight`: Chart sizing (pixels).
- `padding`: Chart padding (integer or object with top/right/bottom/left).
- `title`, `subtitle`, `footnote`: Chart captions with styling.

**Interaction & Feature Options (19 options) — Added December 2025**
- `highlight`: Chart-level highlighting with styles for highlighted/unhighlighted items and series.
- `animation`: Duration, easing, enabled toggle for smooth transitions.
- `zoom`: Zoom and pan control with wheel behavior (zoom vs pan).
- `ranges`: Preset range buttons and selection UI for time-series filtering.
- `sync`: Multi-chart synchronization modes (tooltip, highlight, selection).
- `contextMenu`: Right-click context menu enable/disable.
- `dataSource`: Data source adapter configuration.
- `keyboard`: Keyboard input enable/disable for accessibility.
- `touch`: Touch gesture control (panning, pinching).
- `listeners`: Chart-level event callbacks (onClick, onHighlight, onSelection) as raw JavaScript.
- `formatter`: Modern FormatterConfiguration for custom number/time/category formatting.
- `container`: Chart container element ID, className, or styling.
- `data`: Chart-level data binding.
- `annotations`: Annotations (lines, labels, shapes).
- `initialState`: Initial zoom/pan state for replay.
- `misc`: Miscellaneous (CSP nonce, field notation, Google Fonts loading).

**AgChart base component**
- JWebMP component that generates Angular signals and websocket listeners for options/data (`AgChart#initializeOptionsListener`, `AgChart#initializeDataListener`, `AgChart#fetchOptions`, `AgChart#fetchDataChannel`).
- Provides `getInitialOptions()` / `getInitialData()` as Mutiny `Uni` for server-side reactive data fetching.
- Concrete wrappers: `AgBarChart`, `AgLineChart`, `AgAreaChart`, `AgPieChart`, `AgDonutChart`, `AgBubbleChart`, `AgScatterChart`, `AgCombinationChart`.

**Listener channels**
- Options channel: EventBus websocket listener suffixed with `Options`; returns `AgChartOptions` payloads (see `../../../../../docs/architecture/sequence-initial-load.md`).
- Data channel: EventBus websocket listener suffixed with `Data`; streams data payloads merged into series or options data (see `../../../../../docs/architecture/sequence-data-update.md`).

**Options model hierarchy**
- `AgChartOptions`: Root aggregates all 38 chart-level properties (core + interaction/feature).
- `AgSeriesBaseOptions`: Base series with axes, label, marker, tooltip, highlight, fill types.
- Concrete series: `AgBarSeriesOptions`, `AgLineSeriesOptions`, `AgAreaSeriesOptions`, `AgPieSeriesOptions`, `AgDonutSeriesOptions`, `AgBubbleSeriesOptions`, `AgScatterSeriesOptions`.
- Nested options: `AgAxisBaseOptions` (+ subtypes), `AgChartLegendOptions`, `AgChartTooltipOptions`, `AgLocaleOptions`, `AgChartTheme`, `AgChartHighlightOptions`, `AgChartAnimationOptions`, `AgChartZoomOptions`, `AgChartRangesOptions`, `AgChartSyncOptions`, `AgChartFormatterOptions`, etc.

**Deprecation (12.2.0 alignment)**
- Removed: `formatterFunction`, `formatterFunctions`, `formatterFormats` (replaced by `AgChartFormatterOptions`).
- Removed: `highlightStyle` in series (use series-level `highlight` or chart-level `highlight`).
- Removed: `seriesId` field (use `id` only).
- Keep for compatibility: deprecated formatter classes under `options/formatters/` (not serialized by default).

**Page configurator and npm deps**
- `AgChartsPageConfigurator` registering npm deps for Angular builds:
  - `ag-charts-community@^12.2.0` (mandatory)
  - `ag-charts-enterprise@^12.2.0` (optional, for navigator/gradientLegend/sync modes)
  - `ag-charts-angular@^12.2.0` (mandatory for Angular wrapper)
  - `ag-charts-locale@^12.2.0` (optional for localization)

See also
- Topic index — ./README.md
- JWebMP client glossary — ../client/GLOSSARY.md
- TypeScript glossary — ../../../language/typescript/GLOSSARY.md
- Angular glossary and version override — ../../../language/angular/GLOSSARY.md, ../../../language/angular/angular-20.rules.md
