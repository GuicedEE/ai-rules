# AgCharts Enterprise Integration — Rules

## Overview
- This module extends the community AgCharts plugin to activate AG Charts Enterprise features in JWebMP applications.
- It mirrors the model used by WebAwesomePro extending WebAwesome and FullCalendarPro extending FullCalendar.
- **New in v2.0.0**: Integrated grid-to-charts data binding for synchronized dashboards with cross-filtering and selection sync.

## Usage patterns

### Basic Usage
- Add Maven dependency: com.jwebmp.plugins:agcharts-enterprise:${version} (version via BOM recommended).
- Keep community plugin dependency present: com.jwebmp.plugins:agcharts.
- Use charts as normal through JWebMP; enterprise features become available on the client when the Page Configurator includes the TypeScript dependency for `ag-charts-enterprise`.
- Reference architecture & sequence diagrams in `docs/architecture/` via `docs/PROMPT_REFERENCE.md` before generating code; they define the required containers and build flow.

### Grid-Charts Integration (v2.0.0+)
- Link AG Grid data to AG Charts Enterprise for coordinated dashboards.
- Enable cross-filtering: chart selections filter grid rows; grid filters update charts.
- Enable selection sync: grid row selection highlights chart data points.
- Use `IChartDataBridge` for custom data transformations and event coordination.
- Manage charts via centralized `ChartRegistry` for lifecycle and relationship tracking.
- See `grid-data-binding.rules.md` for detailed patterns and API reference.

## Minimal example

### Charts Only
- Server-side (Java/JWebMP): continue to construct charts as with the community plugin; no API change required for basic usage.
- Ensure the Page Configurator from this module is on the classpath (auto-discovery via Java ServiceLoader and JWebMP conventions).

### Grid + Charts (v2.0.0+)
```java
// Create grid with data
AgGridEnterprise<AgGridEnterprise<?>> grid = new AgGridEnterprise<>("salesGrid")
    .setRowData(loadSalesData())
    .enableCharts()
    
    // Register and link a chart
    .registerAndLinkChart(new ChartConfiguration("regionChart", "pie")
        .setTitle("Sales by Region")
        .setFieldMapping(Map.of(
            "region", "label",
            "sales", "value",
            "regionId", "id"
        ))
        .setEnableCrossFiltering(true))
    
    // Enable coordination features
    .enableChartCrossFiltering();
```

## Quick start checklist

1. Import the JWebMP BOM plus `com.jwebmp.plugins:agcharts` and this module.
2. Confirm ServiceLoader discovery: `META-INF/services/com.jwebmp.core.services.IPageConfigurator` includes `AgChartsEnterprisePageConfigurator`.
3. **For Grid+Charts**: Use `AgGridEnterprise.registerAndLinkChart()` or `ChartRegistry.getInstance().registerChart()` to establish chart-grid relationships.
4. Annotate charts via CRTP fluent APIs (see ./java-usage-guide.rules.md and ./usage-examples.rules.md for patterns).
5. Run a build (`mvn clean package`); verify generated Angular `package.json` lists `ag-charts-enterprise` and `ag-charts-angular`.
6. Provide AG Charts Enterprise license initialization per ./licensing-and-activation.rules.md if required by your deployment.

## Configuration

### TypeScript dependency
- `ag-charts-enterprise` is pulled in by the Page Configurator using @TsDependency.
- Angular peer dependencies: community plugin typically includes `ag-charts-community` and `ag-charts-angular`; this enterprise plugin complements them.

### Grid-Charts Coordination (v2.0.0+)
- Register charts via `ChartRegistry` or `grid.registerAndLinkChart()`.
- Define field mappings to sync grid columns with chart properties.
- Enable cross-filtering and selection sync on `ChartConfiguration` or via grid helper methods.
- Optionally implement custom `IChartDataBridge` for complex data flows.

## Performance/constraints

- Do not bundle or edit generated TS; rely on the build to include dependencies.
- Enterprise features may increase bundle size; tree-shake when possible.
- Licensing is required per AG Charts Enterprise terms; see licensing-and-activation.rules.md.
- **For large datasets**: Implement server-side aggregation before charting to avoid performance degradation.

## See also

- Page Configurator — ./page-configurator.rules.md
- Grid-Data Binding — ./grid-data-binding.rules.md (new in v2.0.0)
- Licensing — ./licensing-and-activation.rules.md
- Usage examples — ./usage-examples.rules.md
- Troubleshooting — ./troubleshooting.rules.md
- Angular index — ../../../language/angular/README.md

