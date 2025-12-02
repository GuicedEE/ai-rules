# GLOSSARY — AG Grid Enterprise Terminology

**Version:** 2.0.0  
**Scope:** AG Grid Enterprise feature terminology and LLM interpretation guidance  
**Topic-First Composition:** Links to enterprise rules, Fluent API (CRTP), and related topic glossaries

---

## Core Terminology

### Grid & Component

| Term | Definition | Related Concept | Glossary Link |
|------|-----------|---|---|
| **AgGridEnterprise** | Main component class extending AgGrid; enables enterprise features via fluent API | CRTP, Fluent API | [CRTP Pattern](../../backend/fluent-api/crtp.rules.md) |
| **AgGridEnterpriseOptions** | Options POJO extending AgGridOptions; composed of 8 modular feature options | Composition Pattern | [charts.rules.md](./charts.rules.md), [row-grouping.rules.md](./row-grouping.rules.md), etc. |
| **Fluent Setter** | Method returning `this` (self-type) enabling CRTP method chaining | Method Chaining | [CRTP Pattern](../../backend/fluent-api/crtp.rules.md) |
| **Feature Options** | Modular POJO encapsulating one enterprise feature (ChartOptions, RowGroupingOptions, etc.) | @JsonUnwrapped | README.md § Module Structure |

### Feature Modules (Phase 2)

| Module | Class | Properties | Rules File |
|--------|-------|-----------|---|
| **Charts** | ChartOptions | enableCharts, chartTheme, chartThemeOverrides, toolbarItems | [charts.rules.md](./charts.rules.md) |
| **Range Selection** | RangeSelectionOptions | enableRangeSelection | [range-selection.rules.md](./range-selection.rules.md) |
| **Row Grouping** | RowGroupingOptions | rowGroupingHierarchy, groupAllowUnbalanced, keyCreator, valueFormatter | [row-grouping.rules.md](./row-grouping.rules.md) |
| **Server-Side Model** | ServerSideRowModelOptions | serverSideRowModelType, cacheBlockSize, maxBlocksInCache | [server-side-row-model.rules.md](./server-side-row-model.rules.md) |
| **Side Bar & Status Bar** | SideBarOptions, StatusBarOptions | sideBarToolPanelDefs, statusBarDefs | [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md) |
| **Pivot Tables** | PivotingOptions | pivotMode, pivotRowTotals, pivotColumnGroupTotals | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md) |
| **Aggregation** | AggregationOptions | alwaysAggregateAtRootLevel, maintainColumnOrder | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md) |
| **Advanced Filtering** | AdvancedFilteringOptions | allowedCharPattern, caseSensitive | [advanced-filtering.rules.md](./advanced-filtering.rules.md) |

### Charts

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Chart Theme** | Visual styling preset for charts | ag-default, ag-vivid, ag-material, ag-sheets, polychroma | [charts.rules.md](./charts.rules.md) |
| **ChartTheme Enum** | Java enum mapping to AG Grid theme strings | `ChartTheme.AG_VIVID` → `"ag-vivid"` | [charts.rules.md](./charts.rules.md) |
| **Chart Override** | Custom CSS/styling applied over theme | backgroundColor, fontSize, palette colors | [charts.rules.md](./charts.rules.md#theme-overrides) |
| **Toolbar Item** | Configurable chart toolbar button/option | download, chartPanelToggle, seriesChartType | [charts.rules.md](./charts.rules.md#toolbar-configuration) |
| **Tool Panel** | Grid-level panel for chart management | Column aggregation, chart configuration | [charts.rules.md](./charts.rules.md#tool-panels) |

### Range Selection

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Range Selection** | Multi-cell rectangular selection for copy/export | Select A1:C5, copy to clipboard | [range-selection.rules.md](./range-selection.rules.md) |
| **Single-Cell Range** | Flag controlling if single cell is treated as range | When false, single cell uses cellClicked instead | [range-selection.rules.md](./range-selection.rules.md) |
| **Clipboard** | Copy-to-OS-clipboard behavior for selected ranges | Suppress if PII/sensitive data | [range-selection.rules.md](./range-selection.rules.md#clipboard-control) |

### Row Grouping

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Row Grouping** | Organize rows by column value(s); create expandable groups | Group sales by region, year, product | [row-grouping.rules.md](./row-grouping.rules.md) |
| **Grouping Hierarchy** | Multi-level nested grouping (Year > Quarter > Month) | Year (level 1) → Quarter (level 2) → Month (level 3) | [row-grouping.rules.md](./row-grouping.rules.md#multi-level-grouping) |
| **Row Group Panel** | UI panel allowing users to configure grouping | Drag column headers to add/remove grouping | [row-grouping.rules.md](./row-grouping.rules.md#row-group-panel) |
| **Panel Visibility Policy** | Enum controlling when Row Group Panel appears | PanelShow.ALWAYS, ONLY_WHEN_GROUPING, NEVER | [row-grouping.rules.md](./row-grouping.rules.md#panel-visibility) |
| **Unbalanced Groups** | Allow groups with null/missing values | Group by region where some rows have null region | [row-grouping.rules.md](./row-grouping.rules.md#unbalanced-groups) |
| **Group Parent Hiding** | Hide/suppress parent rows with single child | Hide Year if only one Quarter under it | [row-grouping.rules.md](./row-grouping.rules.md#parent-hiding) |
| **Key Creator** | Custom function to generate group keys | Custom date-to-quarter formatter | [row-grouping.rules.md](./row-grouping.rules.md#key-creator) |
| **Value Formatter** | Custom formatting for group value display | Format currency or percentage | [row-grouping.rules.md](./row-grouping.rules.md#value-formatting) |

### Server-Side Row Model

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Server-Side Row Model** | Data loading model where backend provides rows on-demand | Load 1M+ rows in blocks; lazy-load on scroll | [server-side-row-model.rules.md](./server-side-row-model.rules.md) |
| **Block Caching** | In-memory cache of row blocks fetched from server | Cache blocks 0–49 (size 50 each) | [server-side-row-model.rules.md](./server-side-row-model.rules.md#block-caching) |
| **Block Size** | Number of rows per request block | Typical: 50–100 rows per block | [server-side-row-model.rules.md](./server-side-row-model.rules.md#block-size) |
| **Max Cached Blocks** | Maximum blocks held in memory | Typical: 5–10 blocks; frees oldest when exceeded | [server-side-row-model.rules.md](./server-side-row-model.rules.md#cache-limits) |
| **DataSource** | Backend interface providing row blocks on-demand | Implements getRows(request) → List<RowData> | [server-side-row-model.rules.md](./server-side-row-model.rules.md#datasource-integration) |
| **Lazy-Loading** | Load rows incrementally as user scrolls | Fetch block N only when user reaches row N | [server-side-row-model.rules.md](./server-side-row-model.rules.md#lazy-loading) |
| **Purge Behavior** | Release memory when groups closed | Remove cached rows for collapsed group | [server-side-row-model.rules.md](./server-side-row-model.rules.md#purge-on-close) |

### Side Bar & Status Bar

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Side Bar** | Collapsible right/left panel with tool panels (Columns, Filters) | Show/hide columns; manage active filters | [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md) |
| **Tool Panel** | Individual panel within side bar (e.g., Columns, Filters) | User can toggle between Columns and Filters | [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md#tool-panels) |
| **Status Bar** | Bottom bar showing grid metrics (row count, selected count, totals) | "1000 rows • 50 selected • Sum: $125,000" | [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md#status-bar) |
| **Status Bar Panel** | Individual metric/component in status bar | RowCountPanel, SelectionCountPanel, CustomPanel | [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md#status-bar-panels) |

### Pivot Tables & Aggregation

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Pivot Mode** | Enable pivot table layout (rows, columns, values) | Rows: Region; Columns: Year; Values: Sum(Sales) | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md) |
| **Row Pivot** | Column to pivot into rows | Pivot Region into rows → each region is a row group | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#row-pivots) |
| **Column Pivot** | Column to pivot into columns | Pivot Year into columns → each year is a column header | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#column-pivots) |
| **Value Column** | Column whose values are aggregated | Sales column → summed for each row×column intersection | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#value-columns) |
| **Aggregation Function** | Function summarizing values (SUM, COUNT, AVG, MIN, MAX) | SUM(Sales), COUNT(Transactions), AVG(Price) | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#aggregation-functions) |
| **Pivot Totals** | Show/hide row/column totals in pivot | Show bottom row total; show right column total | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#pivot-totals) |
| **Group Total** | Subtotal for a pivot group | Total for North region; total for 2024 | [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#group-totals) |

### Advanced Filtering

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Advanced Filter** | Multi-criterion filter UI (set filter, multi-filter, find filter) | Filter Dept ∈ [Sales, Marketing] AND Status = Active | [advanced-filtering.rules.md](./advanced-filtering.rules.md) |
| **Set Filter** | Filter allowing selection from predefined set of values | Select multiple regions from dropdown checklist | [advanced-filtering.rules.md](./advanced-filtering.rules.md#set-filters) |
| **Multi-Filter** | Combine multiple filter predicates with AND/OR logic | (Dept = Sales OR Dept = Marketing) AND Year > 2023 | [advanced-filtering.rules.md](./advanced-filtering.rules.md#multi-filters) |
| **Find Filter** | Text search filter across column values | Find "Smith" in customer names | [advanced-filtering.rules.md](./advanced-filtering.rules.md#find-filters) |
| **Filter Predicate** | Custom boolean expression to include/exclude rows | row.Sales > 10000 AND row.Region == "North" | [advanced-filtering.rules.md](./advanced-filtering.rules.md#custom-predicates) |

### Dynamic Series Coloring

| Term | Definition | Example | Rules Link |
|------|-----------|---------|---|
| **Dynamic Series Coloring** | Conditional cell coloring based on value or rule | Heatmap: red for low sales, green for high | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md) |
| **SOLID Strategy** | All values same solid color | All cells blue | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#solid) |
| **VALUE_GRADIENT Strategy** | Color gradient from min to max value | Gradient from white (low) → dark green (high) | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#value_gradient) |
| **VALUE_RANGE Strategy** | Color ranges based on value buckets | Red: 0–25%, Yellow: 25–50%, Green: 50–100% | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#value_range) |
| **POSITIVE_NEGATIVE Strategy** | Separate colors for positive/negative values | Green for profit, red for loss | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#positive_negative) |
| **CUSTOM_CALLBACK Strategy** | Custom function to compute color per cell | Call colorizer(row, column) → "#FF0000" | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#custom_callback) |
| **Color Threshold** | Value boundary triggering color change | Threshold 50: < 50 red, ≥ 50 green | [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md#thresholds) |

---

## Enum Types & Constants

### ChartTheme (Enum)

```java
public enum ChartTheme {
    AG_DEFAULT("ag-default"),
    AG_VIVID("ag-vivid"),
    AG_MATERIAL("ag-material"),
    AG_SHEETS("ag-sheets"),
    POLYCHROMA("polychroma");
    
    private final String agGridValue;
}
```

Maps to AG Grid theme option: [charts.rules.md](./charts.rules.md#theme-types)

### PanelShow (Enum)

```java
public enum PanelShow {
    ALWAYS("always"),
    ONLY_WHEN_GROUPING("onlyWhenGrouping"),
    NEVER("never");
}
```

Controls row group panel visibility: [row-grouping.rules.md](./row-grouping.rules.md#panel-visibility)

### RowModelType (Enum)

```java
public enum RowModelType {
    CLIENT_SIDE("clientSide"),
    SERVER_SIDE("serverSide"),
    INFINITE("infinite");
}
```

Specifies data loading strategy: [server-side-row-model.rules.md](./server-side-row-model.rules.md#row-model-types)

### AggregationFunction (Enum)

```java
public enum AggregationFunction {
    SUM("sum"),
    COUNT("count"),
    AVG("avg"),
    MIN("min"),
    MAX("max"),
    CUSTOM("custom");
}
```

Aggregation operation for pivots/grouping: [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md#aggregation-functions)

---

## LLM Interpretation Guidance

### When discussing enterprise features:

- **"Enable feature X"** → Call fluent setter on AgGridEnterprise (e.g., `enableCharts()`)
- **"Configure feature X"** → Modify corresponding Options POJO (e.g., `ChartOptions`)
- **"Add grouping"** → Use `RowGroupingOptions` and `columnDef.setRowGroup(true)`
- **"Large dataset"** → Use ServerSideRowModelOptions with block caching
- **"Show totals"** → Set PivotingOptions.pivotRowTotals, pivotColumnGroupTotals
- **"Color-code cells"** → Use dynamic series coloring with VALUE_GRADIENT or VALUE_RANGE strategy
- **"User can filter"** → Enable AdvancedFilteringOptions; provide set/multi-filter UI

### Java ↔ AG Grid Terminology Mapping

| Concept | Java (JWebMP) | JavaScript (AG Grid) | Mapping |
|---------|---|---|---|
| **Main Component** | `AgGridEnterprise<T>` | ag-grid-enterprise | Parent class |
| **Options** | `AgGridEnterpriseOptions` | gridOptions | Field-based POJO |
| **Chart Theme** | `ChartTheme.AG_VIVID` | `"ag-vivid"` | MapStruct enum mapping |
| **Row Grouping** | `setRowGroup(true)` on columnDef | `rowGroup: true` in colDef | Direct JSON mapping |
| **Data Source** | `ServerSideDataSource` interface | `getRows(params)` callback | Same pattern |
| **Panel Show** | `PanelShow.ONLY_WHEN_GROUPING` | `"onlyWhenGrouping"` | Enum → string mapping |

---

## Related Topic Glossaries

This glossary is **topic-first** and composed from related enterprise topics. For terms defined in these topics, use the topic glossary definitions; do not duplicate:

- **Fluent API (CRTP)** — [../../backend/fluent-api/crtp.rules.md](../../backend/fluent-api/crtp.rules.md) — CRTP pattern, self-type, method chaining
- **MapStruct** — [../../backend/mapstruct/README.md](../../backend/mapstruct/README.md) — Mapper, transformation, DTO
- **JWebMP AgGrid (Community)** — [../aggrid/GLOSSARY.md](../aggrid/GLOSSARY.md) — Column, grid options, cell renderer
- **Logging (Log4j2)** — [../../backend/logging/README.md](../../backend/logging/README.md) — Log level, logger, appender
- **Angular** — [../../language/angular/README.md](../../language/angular/README.md) — Component, module, decorator

---

## Document Control

| Property | Value |
|----------|-------|
| **Version** | 2.0.0 |
| **Last Updated** | 2025-12-02 |
| **Scope** | AG Grid Enterprise plugin terminology |
| **Precedence** | Topic-first; overrides root GLOSSARY.md for enterprise terms |
| **Maintenance** | Updated when new features added; linked from QUICK_REFERENCE.md and README.md |

---

**End of Enterprise Glossary**
