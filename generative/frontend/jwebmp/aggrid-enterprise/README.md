# JWebMP AgGrid Enterprise Plugin Rules & Guides

**A comprehensive, modular rules repository for the JWebMP AG Grid Enterprise Plugin** — v2.0.0

---

## Overview

The **JWebMP AgGrid Enterprise Plugin** extends the community AgGrid plugin to expose **AG Grid Enterprise** features (Charts, Range Selection, Row Grouping, Server-Side Row Models, Pivot Tables, Advanced Filtering, Side Bar, Status Bar, Dynamic Series Coloring) in a type-safe, fluent Java API.

This rules directory maintains the authoritative guidance for using, configuring, and extending the enterprise features within JWebMP projects.

### Key Resources

- **Product & Architecture Contract**: [../../../../../../PACT.md](../../../../../../PACT.md) *(host project)*
- **Technology Rules**: [../../../../../../RULES.md](../../../../../../RULES.md) *(host project)*
- **How-To Guides**: [../../../../../../GUIDES.md](../../../../../../GUIDES.md) *(host project)*
- **Code Layout & Implementation**: [../../../../../../IMPLEMENTATION.md](../../../../../../IMPLEMENTATION.md) *(host project)*
- **Glossary (Topic-First)**: [./GLOSSARY.md](./GLOSSARY.md) — *canonical for AG Grid Enterprise terminology*
- **Quick Reference**: [./QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — *checklists, code templates, troubleshooting*

---

## Enterprise Features Index

### Core Features

1. **[charts.rules.md](./charts.rules.md)**
   - Enable/configure Charts (ChartOptions)
   - Chart themes (ag-default, ag-vivid, ag-material, ag-sheets, polychroma)
   - Custom theme overrides
   - Toolbar items and tool panels
   - Example: Creating an embedded chart from grid data

2. **[range-selection.rules.md](./range-selection.rules.md)**
   - Enable range selection (RangeSelectionOptions)
   - Cell range selection and copy-to-clipboard
   - Single-cell range behavior
   - Integration with grid keyboard shortcuts
   - Example: Multi-cell range selection workflow

3. **[row-grouping.rules.md](./row-grouping.rules.md)**
   - Configure row grouping (RowGroupingOptions, columnDef.rowGroup)
   - Group hierarchy configuration (hierarchy levels, custom sorting)
   - Expandable groups and lazy-loading
   - Group panels and visibility control (PanelShow enum)
   - Multi-level grouping and aggregation
   - Example: Year → Quarter → Month grouping

4. **[server-side-row-model.rules.md](./server-side-row-model.rules.md)**
   - Configure server-side row model (ServerSideRowModelOptions)
   - Full vs. partial data loading strategies
   - Block caching and memory management
   - Lazy-loading large datasets
   - Backend DataSource integration
   - Example: Loading 1M+ rows with pagination

5. **[side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md)**
   - Configure side bar panels (SideBarOptions)
   - Columns and Filters panels
   - Position and visibility control
   - Status bar configuration (row count, selection metrics)
   - Custom status bar components
   - Example: Adding user-selectable panels

6. **[pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md)**
   - Configure pivot mode and aggregation (PivotingOptions, AggregationOptions)
   - Row/column pivot definitions
   - Aggregation functions (sum, count, avg, min, max)
   - Custom aggregation functions
   - Multi-level pivots
   - Example: Sales by Region × Year with sum aggregation

7. **[advanced-filtering.rules.md](./advanced-filtering.rules.md)**
   - Advanced filter configuration (AdvancedFilteringOptions)
   - Set filters, multi-filters, find filters
   - Custom filter predicates
   - Filter state management
   - Performance optimization for large datasets
   - Example: Multi-criteria filtering on 100K rows

8. **[dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md)**
   - Configure dynamic series coloring strategies
   - 5 coloring strategies: SOLID, VALUE_GRADIENT, VALUE_RANGE, POSITIVE_NEGATIVE, CUSTOM_CALLBACK
   - Color scales and thresholds
   - Conditional styling based on cell values
   - Integration with charts and range selection
   - Example: Heatmap-style conditional coloring

---

## Quick Start

### Enable Enterprise Features (Fluent API)

```java
public class SalesGrid extends AgGridEnterprise<SalesGrid> {
    public SalesGrid() {
        setID("salesGrid");
        
        // Enable enterprise features via fluent setters
        enableCharts()
            .enableRangeSelection()
            .sideBarFiltersAndColumns()
            .showRowGroupPanel()
            .useServerSideRowModel()
            .enableAdvancedFilters();
        
        // Configure columns
        getOptions().setColumnDefs(List.of(
            new AgGridColumnDef<>("region")
                .setRowGroup(true)
                .setValueFormatter("${region}"),
            new AgGridColumnDef<>("sales")
                .setAggFunc(AggregationFunction.SUM),
            new AgGridColumnDef<>("year")
                .setRowGroup(true)
        ));
    }
}
```

### Configure Charts

```java
ChartOptions charts = new ChartOptions();
charts.setEnableCharts(true);
charts.setChartTheme(ChartTheme.AG_VIVID);
charts.setChartThemeOverrides(Map.of(
    "backgroundColor", "#f5f5f5",
    "fontSize", "12px"
));
grid.getOptions().setChartOptions(charts);
```

### Enable Row Grouping with Hierarchy

```java
RowGroupingOptions grouping = new RowGroupingOptions();
grouping.setRowGroupingHierarchy(List.of(
    new RowGroupingHierarchyLevel("year"),
    new RowGroupingHierarchyLevel("quarter"),
    new RowGroupingHierarchyLevel("month")
));
grouping.setRowGroupPanelShow(PanelShow.ALWAYS);
grid.getOptions().setRowGroupingOptions(grouping);
```

---

## Integration with Community AgGrid

This plugin **extends** the community AgGrid plugin without breaking changes:

- **Base Class** — `AgGridEnterprise<T>` extends `AgGrid<T>`
- **Options Composition** — `AgGridEnterpriseOptions` extends `AgGridOptions`; enterprise features composed as fields
- **JSON Compatibility** — `@JsonUnwrapped` ensures identical JSON serialization; no API breaking changes
- **Module Registration** — Page Configurator auto-registers `AllEnterpriseModule` with Angular's ModuleRegistry

See [../../../../../../GUIDES.md](../../../../../../GUIDES.md#integrating-enterprise-features) for integration patterns.

---

## Module Structure (Phase 2)

The enterprise plugin uses **modular composition** via `@JsonUnwrapped` pattern:

| Module | Field | Properties | Examples |
|--------|-------|-----------|----------|
| ChartOptions | `chartOptions` | 10 | enableCharts, chartTheme, chartThemeOverrides |
| RangeSelectionOptions | `rangeSelectionOptions` | 1 | enableRangeSelection |
| SideBarAndStatusBarOptions | `sideBarOptions`, `statusBarOptions` | 3 | sideBarFiltersAndColumns, statusBarDefs |
| RowGroupingOptions | `rowGroupingOptions` | 22 | rowGroupingHierarchy, groupAllowUnbalanced, keyCreator |
| ServerSideRowModelOptions | `serverSideOptions` | 17 | serverSideRowModelType, cacheBlockSize, maxBlocksInCache |
| PivotingOptions | `pivotingOptions` | 11 | pivotMode, pivotRowTotals, pivotColumnGroupTotals |
| AggregationOptions | `aggregationOptions` | 7 | alwaysAggregateAtRootLevel, maintainColumnOrder |
| AdvancedFilteringOptions | `advancedFilteringOptions` | 6 | allowedCharPattern, caseSensitive |

---

## Fluent API & CRTP Pattern

All enterprise options use the **CRTP (Curiously Recurring Template Pattern)** for type-safe method chaining:

```java
AgGridEnterprise<MyGrid> grid = new MyGrid()
    .enableCharts()                      // Returns MyGrid
    .enableRangeSelection()              // Returns MyGrid
    .sideBarFiltersAndColumns()          // Returns MyGrid
    .useServerSideRowModel();            // Returns MyGrid
```

Each method returns `this` (the concrete type), enabling compile-time safe chaining without casting.

---

## Configuration Reference

For complete parameter reference, see [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) and individual feature rule files.

### Enterprise Options Enum Types

| Enum | Values | Purpose |
|------|--------|---------|
| `ChartTheme` | ag-default, ag-vivid, ag-material, ag-sheets, polychroma | Chart visual theme |
| `PanelShow` | ALWAYS, ONLY_WHEN_GROUPING, NEVER | Panel visibility policy |
| `RowModelType` | CLIENT_SIDE, SERVER_SIDE, INFINITE | Data loading strategy |
| `AggregationFunction` | SUM, COUNT, AVG, MIN, MAX, CUSTOM | Aggregation operation |

---

## Extending Enterprise Features

To add a new enterprise feature:

1. **Create a new Options POJO** (e.g., `MyNewOptions`)
   - Annotate with Jackson: `@JsonAutoDetect(fieldVisibility = Visibility.ANY)`
   - Decorate with `@JsonUnwrapped` in parent
2. **Add fluent setter** on `AgGridEnterprise<T>`
   - Return `this` for CRTP chaining
3. **Add MapStruct mapper** for enum/DTO transformations
4. **Update module-info.java** exports
5. **Create a new .rules.md file** in this directory
6. **Update GLOSSARY.md** with new terms
7. **Add unit test** in test suite
8. **Update QUICK_REFERENCE.md** with example

See [../../../../../../GUIDES.md#adding-new-enterprise-features](../../../../../../GUIDES.md#adding-new-enterprise-features) for detailed instructions.

---

## Performance & Best Practices

### Recommended Configurations

**For Small Datasets (< 10K rows):**
- Use client-side row model with built-in sorting/filtering
- Enable all features without performance concern
- Example: [examples/chart-integration-example.md](./examples/chart-integration-example.md)

**For Medium Datasets (10K – 100K rows):**
- Use server-side row model with block caching
- Enable range selection and status bar
- Lazy-load row groups on expand
- Example: See [server-side-row-model.rules.md](./server-side-row-model.rules.md#medium-datasets)

**For Large Datasets (> 100K rows):**
- Use server-side row model with partial caching
- Enable lazy-loaded charts
- Paginate or virtual scroll
- Example: [examples/server-side-row-model-example.md](./examples/server-side-row-model-example.md)

### Optimization Checklist

- [ ] **Charts** — Load data incrementally; use appropriate theme (polychroma for large legends)
- [ ] **Row Grouping** — Use lazy-loading; avoid deep hierarchies (>3 levels)
- [ ] **Filtering** — Index backend queries; use partial matching
- [ ] **Server-Side Model** — Set `cacheBlockSize` to 50–100; `maxBlocksInCache` to 5–10
- [ ] **Pivot Tables** — Pre-aggregate at backend; avoid real-time pivoting on >1M rows

See [../../../../../../GUIDES.md#performance-tuning](../../../../../../GUIDES.md#performance-tuning) for details.

---

## Testing Enterprise Features

### Unit Testing

Test feature options serialization:

```java
@Test
void chartOptionsSerializeCorrectly() throws JsonProcessingException {
    ChartOptions opts = new ChartOptions();
    opts.setEnableCharts(true);
    opts.setChartTheme(ChartTheme.AG_VIVID);
    
    String json = mapper.writeValueAsString(opts);
    assertTrue(json.contains("\"enableCharts\":true"));
    assertTrue(json.contains("\"chartTheme\":\"ag-vivid\""));
}
```

### Integration Testing

Test fluent API chaining:

```java
@Test
void fluentApiChainingWorks() {
    SalesGrid grid = new SalesGrid()
        .enableCharts()
        .enableRangeSelection()
        .sideBarFiltersAndColumns();
    
    assertNotNull(grid.getOptions().getChartOptions());
    assertNotNull(grid.getOptions().getRangeSelectionOptions());
    assertNotNull(grid.getOptions().getSideBarOptions());
}
```

See [../../../../../../GUIDES.md#testing-enterprise-features](../../../../../../GUIDES.md#testing-enterprise-features) for comprehensive test patterns.

---

## Troubleshooting

### Charts Not Rendering

**Symptom:** Grid shows no chart toolbar.  
**Causes & Solutions:**
- Verify `enableCharts()` called: `grid.getOptions().getChartOptions().getEnableCharts() == true`
- Ensure AllEnterpriseModule registered in TS: Check page source for `AllEnterpriseModule`
- Verify `ag-grid-enterprise` npm installed: `npm list ag-grid-enterprise`
- Check browser console for JS errors (missing data, invalid theme)

See [QUICK_REFERENCE.md#troubleshooting](./QUICK_REFERENCE.md#troubleshooting).

---

## Security & Compliance

- **XSS Prevention** — All chart data sanitized by AG Grid; no inline HTML rendering
- **CSRF Protection** — Server-side filters/sorting validated on backend; parameterized queries used
- **Data Sensitivity** — Sensitive columns marked with `cellClass` for styling; no export to untrusted clients
- **Access Control** — Implement authorization checks at backend service level (not grid-level)

See [../../../../../../GUIDES.md#security-in-enterprise-grids](../../../../../../GUIDES.md#security-in-enterprise-grids).

---

## Related Rules Topics (Enterprise Repository)

Link to authoritative topic rules for applicable technologies:

- **JWebMP AgGrid (Community)** — [../aggrid/README.md](../aggrid/README.md)
- **JWebMP Core** — [../core/README.md](../core/README.md)
- **JWebMP Client** — [../client/README.md](../client/README.md)
- **JWebMP TypeScript** — [../typescript/README.md](../typescript/README.md)
- **Angular** — [../../language/angular/README.md](../../language/angular/README.md)
- **Fluent API (CRTP)** — [../../backend/fluent-api/crtp.rules.md](../../backend/fluent-api/crtp.rules.md)
- **MapStruct** — [../../backend/mapstruct/README.md](../../backend/mapstruct/README.md)
- **Logging (Log4j2)** — [../../backend/logging/README.md](../../backend/logging/README.md)
- **JSpecify** — [../../backend/jspecify/README.md](../../backend/jspecify/README.md)
- **Architecture (SDD, TDD)** — [../../architecture/README.md](../../architecture/README.md)

---

## Document Index

| Document | Purpose |
|----------|---------|
| [GLOSSARY.md](./GLOSSARY.md) | Enterprise terminology (topic-first composition) |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | Code templates, checklists, quick troubleshooting |
| [charts.rules.md](./charts.rules.md) | Charts feature configuration guide |
| [range-selection.rules.md](./range-selection.rules.md) | Range selection feature guide |
| [row-grouping.rules.md](./row-grouping.rules.md) | Row grouping and multi-level hierarchies |
| [server-side-row-model.rules.md](./server-side-row-model.rules.md) | Server-side data loading strategies |
| [side-bar-and-status-bar.rules.md](./side-bar-and-status-bar.rules.md) | Side bar and status bar configuration |
| [pivot-tables-and-aggregation.rules.md](./pivot-tables-and-aggregation.rules.md) | Pivot tables and aggregation functions |
| [advanced-filtering.rules.md](./advanced-filtering.rules.md) | Advanced filtering configurations |
| [dynamic-series-coloring.rules.md](./dynamic-series-coloring.rules.md) | Dynamic coloring strategies (5 strategies) |

---

## Version Management

| Version | Release Date | Notes |
|---------|---|---|
| 2.0.0 | 2025-12-02 | Phase 2 modular restructuring complete; rules submodule created |
| 1.0.0 | 2025-11-30 | Initial enterprise plugin release |

---

## Contributing

When extending enterprise features:

1. **Update relevant .rules.md file** (or create new if feature not documented)
2. **Update GLOSSARY.md** with new terms
3. **Add QUICK_REFERENCE.md** code example
4. **Link to parent [README.md](./README.md)** and main project GUIDES.md
5. **Update [examples/](./examples/)** with complete working example if significant feature

See [../../../../../../GUIDES.md#contributing](../../../../../../GUIDES.md#contributing) for full contribution guidelines.

---

**End of Enterprise Rules Index**
