# AG Grid Enterprise + AG Charts Enterprise v2.0.0 Release Notes

## Overview
Version 2.0.0 introduces **Grid-to-Charts Data Binding** — a comprehensive framework for synchronizing AG Grid data with AG Charts Enterprise, enabling coordinated dashboards with cross-filtering and selection sync.

## New Features

### Grid ↔ Charts Data Binding
- **Unified Data Model**: Single data source powers both grid and charts with automatic synchronization.
- **Cross-Filtering**: Chart interactions filter grid rows; grid filters update charts in real-time.
- **Selection Sync**: Grid row selection highlights corresponding chart data points and vice versa.
- **Custom Data Bridges**: Implement `IChartDataBridge<T>` for domain-specific data transformations and coordination logic.
- **Registry Pattern**: Centralized `ChartRegistry` manages chart instances, relationships, and event lifecycle.

### Core Components (New)

#### `IChartDataBridge<T>`
Abstraction layer for bidirectional data synchronization:
- Generic over row data type (POJO, Map, custom types)
- Methods: `getGridRowData()`, `onGridDataChanged()`, `onGridSelectionChanged()`, `onChartInteraction()`
- Field mapping support for grid column → chart property projection
- Listener pattern for chart interaction events

#### `ChartConfiguration`
Metadata container for chart-grid relationships:
- 58 fluent properties for complete chart customization
- Chart ID, type, title, themes
- Data bridge and grid references
- Field mapping configuration
- Feature flags: enableCrossFiltering, enableSelectionSync
- Theme overrides and custom options

#### `ChartRegistry`
Singleton registry for lifecycle and relationship management:
- Thread-safe with ConcurrentHashMap
- Manages chart registration, data bridges, and grid-chart linking
- Event listener support for chart lifecycle
- Retrieve linked charts by grid ID

### AgGridEnterprise Helper Methods
Five new fluent methods for simplified chart integration:

1. **`linkCharts(String... chartIds)`** — Link pre-registered charts by ID
2. **`registerAndLinkChart(ChartConfiguration config)`** — Create and link atomically
3. **`enableChartCrossFiltering()`** — Activate bidirectional filtering
4. **`enableChartSelectionSync()`** — Enable selection highlighting
5. **`getChartRegistry()`** — Static accessor to ChartRegistry singleton

All methods follow CRTP pattern: return `(J) this` for method chaining.

## Integration Patterns

### Basic Linking
```java
grid.registerAndLinkChart(new ChartConfiguration("chart1", "bar")
    .setTitle("Sales by Region")
    .setFieldMapping(Map.of("region", "x", "sales", "y")));
```

### Cross-Filtering
```java
grid.registerAndLinkChart(new ChartConfiguration("chart1", "line")
    .setTitle("Sales Trend")
    .setEnableCrossFiltering(true)
    .setFieldMapping(Map.of("month", "x", "amount", "y")))
    .enableChartCrossFiltering();
```

### Selection Sync
```java
grid.enableCharts()
    .registerAndLinkChart(new ChartConfiguration("chart1", "pie")
        .setTitle("Market Share")
        .setEnableCrossFiltering(true)
        .setEnableSelectionSync(true)
        .setFieldMapping(Map.of("competitor", "label", "share", "value")))
    .enableChartSelectionSync();
```

### Custom Data Bridge
```java
class SalesDataBridge implements IChartDataBridge<SalesRecord> {
    @Override
    public List<SalesRecord> getGridRowData() {
        return salesService.getRecords();
    }
    
    @Override
    public void onGridDataChanged(List<SalesRecord> newData) {
        ChartRegistry.getInstance().updateChartData("salesChart", newData);
    }
    
    @Override
    public Map<String, String> getFieldMapping() {
        return Map.of("region", "x", "sales", "y");
    }
}

ChartRegistry.getInstance()
    .registerDataBridge("bridge1", new SalesDataBridge())
    .registerChart(new ChartConfiguration("salesChart", "bar")
        .setTitle("Sales Analysis")
        .setDataBridgeId("bridge1"));
```

## Architecture

### Data Flow
```
┌─────────────────┐
│  Grid Data      │
│  (Row Model)    │
└────────┬────────┘
         │
         ├─────────────────────────┐
         │                         │
         v                         v
    [ChartRegistry]          [ChartRegistry]
         │                         │
    Chart #1          ◄────────► Chart #2
    (Bar Chart)        Cross-    (Line Chart)
                       Filtering
         │                         │
         └────────────┬────────────┘
                      │
              [Grid Selection Sync]
                      │
                  Row Highlight
```

### Thread Safety
- `ChartRegistry` uses `ConcurrentHashMap` for thread-safe access
- Safe for multi-threaded grid updates and chart interactions
- Event listeners are notified asynchronously

### Registry Event Lifecycle
1. `onChartRegistered(ChartConfiguration)` — Chart added to registry
2. `onChartUnregistered(String chartId)` — Chart removed from registry
3. `onChartsLinkedToGrid(String gridId, List<String> chartIds)` — Charts associated with grid
4. `onDataBridgeRegistered(String bridgeId, IChartDataBridge)` — Data bridge added
5. `onChartDataUpdated(String chartId, List<Map>)` — Chart data refreshed

## Field Mapping Reference

### Bar / Column Charts
- Grid columns map to: `x` (category), `y` (series values), `color` (optional)
- Example: `region→x, sales→y, quarter→color`

### Line Charts
- Grid columns map to: `x` (x-axis), `y` (series), `strokeColor` (optional)
- Example: `date→x, revenue→y, department→strokeColor`

### Pie / Doughnut Charts
- Grid columns map to: `label` (segment labels), `value` (segment sizes)
- Example: `category→label, percentage→value`

### Scatter Charts
- Grid columns map to: `x` (x-axis), `y` (y-axis), `size` (optional), `color` (optional)
- Example: `height→x, weight→y, age→size`

### Waterfall Charts
- Grid columns map to: `x` (categories), `y` (values), `isIntermediateTotal`, `isTotal`
- Example: `month→x, amount→y, isQuarterEnd→isIntermediateTotal`

## Best Practices

### IDs and References
- Use consistent, descriptive chart IDs: `"sales-regional"`, `"forecast-monthly"`
- Grid IDs auto-generated; access via `getGridId()` (private, but used internally)
- Bridge IDs should indicate data source: `"bridge-sales"`, `"bridge-forecast"`

### Field Mapping
- Define mappings before linking charts
- Validate grid column names against data model
- Use consistent naming: snake_case or camelCase throughout
- Document custom field transformations in `IChartDataBridge`

### Data Bridges
- Implement for custom transformations (filtering, aggregation, calculation)
- Keep synchronous; use async tasks only for heavy computations outside grid
- Store computed data in bridge instance variables if needed
- Test field mapping with sample data before deployment

### Performance
- Large datasets (>10K rows): aggregate on server before charting
- Enable cross-filtering selectively; it has CPU cost on interactions
- Use pagination for grids with charts to reduce rendering overhead
- Profile chart update performance; consider debouncing rapid grid changes

### Error Handling
- Catch `NullPointerException` when accessing unregistered bridge IDs
- Validate field mapping exists before `enableChartCrossFiltering()`
- Log chart interaction errors; don't fail grid updates on chart exceptions
- Fail fast on registration; use try-catch around `registerAndLinkChart()`

## Migration from v1.x

- **No breaking changes**: Existing grid and chart code continues to work unchanged
- **Additive only**: New chart binding APIs are optional; use when needed
- **Backward compatible**: Community plugin still works; enterprise features enhance it
- **Opt-in**: Chart linking requires explicit `registerAndLinkChart()` or `linkCharts()` calls

## Documentation

- **User Guide**: `docs/ChartGridIntegration-Guide.md` — 650+ lines with examples and best practices
- **Rules Reference**: `./grid-data-binding.rules.md` — 450+ lines with patterns and API details
- **Integration Guide**: `./agcharts-enterprise-integration.rules.md` — Quick start and configuration
- **Troubleshooting**: `./troubleshooting.rules.md` — 7 chart-grid scenarios with diagnosis/solution
- **Java Usage**: `./java-usage-guide.rules.md` — Java API reference and patterns

## Technical Details

### Compilation
- **Java Version**: 25 (module-path compilation)
- **Dependencies**: AG Grid 34.2.0, AG Charts 12.2.0, MapStruct (entity mapping)
- **Build Status**: ✅ SUCCESS (`mvn clean compile`)
- **Package**: ✅ `aggrid-enterprise-2.0.0-SNAPSHOT.jar` created

### Module System
- Explicit module exports in `module-info.java`
- ServiceLoader discovery for `IPageConfigurator`
- Raw type suppression for service providers as needed

### Licensing
- Requires AG Grid Enterprise license (already required)
- Requires AG Charts Enterprise license (new in v2.0.0)
- Initialize licenses per `./licensing-and-activation.rules.md`

## Support & Feedback

- Report issues via GitHub Issues (link to repo)
- Request features via GitHub Discussions (link to repo)
- See `./troubleshooting.rules.md` for common issues
- Review `docs/ChartGridIntegration-Guide.md` for detailed examples

## Changelog

### v2.0.0 (Current)
- **NEW**: Grid-to-charts data binding framework
- **NEW**: IChartDataBridge interface for custom data coordination
- **NEW**: ChartConfiguration class with 58 fluent properties
- **NEW**: ChartRegistry singleton with event listeners
- **NEW**: 5 helper methods on AgGridEnterprise for simplified linking
- **NEW**: Cross-filtering support (grid ↔ charts)
- **NEW**: Selection sync support (grid ↔ charts)
- **NEW**: Comprehensive grid-data-binding.rules.md documentation
- **NEW**: Troubleshooting guide for chart-grid integration
- **IMPROVED**: agcharts-enterprise-integration.rules.md with grid binding examples
- **VERIFIED**: Full backward compatibility with v1.x code

---

**Release Date**: [Current Date]  
**Version**: 2.0.0-SNAPSHOT  
**Artifact**: `com.jwebmp.plugins:aggrid-enterprise:2.0.0-SNAPSHOT`
