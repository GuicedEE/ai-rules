# AG Grid ↔ AG Charts Data Binding — Rules

## Overview

This module extends AG Grid Enterprise with bidirectional data binding to AG Charts Enterprise, enabling:

- **Data Synchronization**: Charts consume grid data automatically via field mapping
- **Cross-Filtering**: Chart selections filter grid rows; grid filters update charts
- **Selection Sync**: Grid row selection highlights chart data points
- **Event Coordination**: Registry-based listener pattern for chart lifecycle management

Mirrors the integration philosophy used in combined Grid+Charts dashboards where the grid is the data authority and charts provide visualization/aggregation views.

## Architecture

### Core Components

#### 1. IChartDataBridge<T> Interface
- **Purpose**: Abstraction for grid↔chart data flow and event coordination
- **Generic Type T**: Row data type (typically Map<String, Object> or domain POJO)
- **Responsibilities**:
  - Provide grid row data to charts
  - Handle grid data mutations (add/update/remove events)
  - Coordinate selection state between grid and charts
  - Manage field mappings (grid column → chart property)
  - Support custom cross-filtering logic

#### 2. ChartConfiguration Class
- **Purpose**: Metadata container for chart instances linked to grids
- **Key Properties**:
  - `chartId`: Unique identifier within grid context
  - `chartType`: Chart rendering type (bar, line, pie, scatter, bubble, waterfall, gauge, etc.)
  - `dataBridgeId`: Reference to registered IChartDataBridge instance
  - `linkedGridId`: Grid this chart consumes data from
  - `fieldMapping`: Map of grid field name → chart data property (e.g., "region" → "x", "sales" → "y")
  - `enableCrossFiltering`: Boolean; chart interactions filter the grid
  - `enableSelectionSync`: Boolean; grid selections highlight chart data
  - `themes`: List of chart theme names (e.g., ["ag-default", "ag-material"])
  - `customOptions`: Arbitrary options passed directly to AG Charts

#### 3. ChartRegistry (Singleton)
- **Purpose**: Central registry for managing chart instances and grid-chart relationships
- **Responsibilities**:
  - Chart lifecycle: register/unregister chart configurations
  - Data bridge storage and lookup
  - Grid↔chart relationship mapping (one grid → many charts, one chart ← one grid)
  - Event dispatch to registered listeners for chart registration, linking, and unlinking
  - Thread-safe access (ConcurrentHashMap-backed)

### Data Flow

```
Grid Data (rows)
    ↓
IChartDataBridge
    ├→ Grid changes (add/update/remove) → Chart updates
    ├→ Grid selection → Chart highlight
    └→ Chart interaction → Grid filter
    ↓
ChartConfiguration (field mapping)
    ↓
AG Charts Enterprise
    ├→ Render with grid data
    ├→ Emit user interactions (selection, drill-down)
    └→ Apply theme/customizations
    ↓
ChartRegistry (coordination)
    └→ Notify listeners (e.g., analytics, UI refresh)
```

## Integration Patterns

### Pattern 1: Basic Chart Linking
Pre-register chart configurations, then link by ID.

```java
// Register chart once (e.g., app startup or lazy-load)
ChartRegistry.getInstance().registerChart("region-pie", new ChartConfiguration("region-pie", "pie")
    .setTitle("Sales by Region")
    .setFieldMapping(Map.of("region", "label", "sales", "value", "regionId", "id")));

// Later, when creating grid, link the chart
AgGridEnterprise<AgGridEnterprise<?>> grid = new AgGridEnterprise<>("salesGrid")
    .setRowData(rowDataList)
    .enableCharts()
    .linkCharts("region-pie");
```

### Pattern 2: Inline Registration & Linking
Create chart configuration and register in one step.

```java
grid.enableCharts()
    .registerAndLinkChart(new ChartConfiguration("sales-chart", "bar")
        .setTitle("Sales Trends")
        .setFieldMapping(Map.of(
            "month", "x",
            "sales", "y",
            "productLine", "series",
            "monthId", "id"
        ))
        .setEnableCrossFiltering(true)
        .setEnableSelectionSync(true));
```

### Pattern 3: Cross-Filtering
Enable bidirectional filtering between grid and charts.

```java
grid.enableCharts()
    .registerAndLinkChart(new ChartConfiguration("filter-chart", "column")
        .setFieldMapping(Map.of("category", "x", "count", "y", "categoryId", "id"))
        .setEnableCrossFiltering(true))
    .enableChartCrossFiltering();
    // Now: chart selection → grid filter; grid filter change → chart update
```

### Pattern 4: Selection Synchronization
Highlight grid selections in charts without filtering.

```java
grid.enableCharts()
    .registerAndLinkChart(new ChartConfiguration("detail-chart", "scatter")
        .setFieldMapping(Map.of("xVal", "x", "yVal", "y", "id", "id"))
        .setEnableSelectionSync(true))
    .enableChartSelectionSync();
    // Now: grid row selection → chart point highlight (selection only, no filter)
```

### Pattern 5: Custom Data Bridge
Implement custom logic for data transformation and event coordination.

```java
public class CustomDataBridge implements IChartDataBridge<RowData> {
    private List<RowData> gridData;
    private Map<String, String> fieldMapping;
    private List<ChartInteractionListener> listeners = new ArrayList<>();

    @Override
    public List<RowData> getGridRowData() {
        return new ArrayList<>(gridData);
    }

    @Override
    public void onGridDataChanged(List<RowData> updatedData) {
        this.gridData = new ArrayList<>(updatedData);
        // Notify charts of data changes
    }

    @Override
    public void onChartInteraction(String chartId, List<Map<String, Object>> dataPoints) {
        // Extract IDs from chart selection
        List<String> selectedIds = dataPoints.stream()
            .map(dp -> (String) dp.get("id"))
            .toList();
        
        // Apply filter to grid data
        List<RowData> filtered = gridData.stream()
            .filter(row -> selectedIds.contains(row.getId()))
            .toList();
        
        // Notify listeners (will update grid)
        listeners.forEach(l -> l.onChartInteraction(chartId, dataPoints));
    }

    @Override
    public Map<String, String> getFieldMapping() {
        return fieldMapping;
    }

    @Override
    public void setFieldMapping(Map<String, String> mapping) {
        this.fieldMapping = new HashMap<>(mapping);
    }

    @Override
    public void addChartInteractionListener(ChartInteractionListener listener) {
        listeners.add(listener);
    }

    @Override
    public void removeChartInteractionListener(ChartInteractionListener listener) {
        listeners.remove(listener);
    }
}

// Usage
CustomDataBridge bridge = new CustomDataBridge();
bridge.setFieldMapping(Map.of("region", "x", "sales", "y", "regionId", "id"));
ChartRegistry.getInstance().registerDataBridge("custom-bridge", bridge);
```

## Field Mapping Reference

The `fieldMapping` Map<String, Object> controls which grid columns feed which chart properties.

### Common Mappings by Chart Type

#### Column/Bar Chart
```java
Map.of(
    "category", "x",      // Category axis
    "value", "y",         // Numeric value
    "series", "series"    // Optional: series grouping
)
```

#### Line/Area Chart
```java
Map.of(
    "date", "x",          // X-axis (time or ordinal)
    "value", "y",         // Y-axis (numeric)
    "metric", "series",   // Series grouping
    "metricId", "id"      // Key for cross-filtering
)
```

#### Pie Chart
```java
Map.of(
    "label", "label",     // Slice labels
    "value", "value",     // Slice sizes
    "labelId", "id"       // Key for cross-filtering
)
```

#### Scatter/Bubble Chart
```java
Map.of(
    "xValue", "x",        // X-axis numeric
    "yValue", "y",        // Y-axis numeric
    "size", "size",       // Bubble size (optional)
    "category", "series", // Series grouping (optional)
    "pointId", "id"       // Key for cross-filtering
)
```

#### Waterfall Chart
```java
Map.of(
    "label", "x",         // Category labels
    "value", "y",         // Values
    "type", "type",       // e.g., "total", "increase", "decrease"
    "labelId", "id"
)
```

### Special Field Keys

- **`id`**: Unique key for cross-filtering. Must be present in chart data for reliable selection/filtering.
- **`series`**: Groups data into separate series (line, bar, area charts).
- **`size`**: Bubble/point size (scatter, bubble charts).
- **`color`**: Color mapping (advanced; typically chart theme handles this).

## Helper Methods on AgGridEnterprise

### linkCharts(String... chartIds)
Link pre-registered charts by ID.

```java
grid.linkCharts("chart1", "chart2", "chart3");
```

- **Pre-requisite**: Charts must be registered in ChartRegistry.
- **Effect**: Establishes grid → chart data flow.

### registerAndLinkChart(ChartConfiguration config)
Create a new chart configuration and link in one atomic operation.

```java
grid.registerAndLinkChart(new ChartConfiguration("newChart", "line")
    .setFieldMapping(Map.of("x", "x", "y", "y")));
```

- **Effect**: Registers chart + links to grid + returns `this` for chaining.

### enableChartCrossFiltering()
Activate bidirectional cross-filtering between grid and all linked charts.

```java
grid.enableChartCrossFiltering();
```

- **Effect**: Updates all linked charts' `enableCrossFiltering` flag.

### enableChartSelectionSync()
Activate selection synchronization (grid selection → chart highlight).

```java
grid.enableChartSelectionSync();
```

- **Effect**: Updates all linked charts' `enableSelectionSync` flag.

### getChartRegistry()
Access the singleton ChartRegistry for advanced management.

```java
ChartRegistry registry = AgGridEnterprise.getChartRegistry();
```

## Best Practices

1. **Unique IDs**: Use meaningful, globally-scoped chart IDs (e.g., "dashboard-sales-chart").
2. **Field Mapping**: Define mappings upfront; validate grid column names match mapping keys.
3. **Grid ID**: Set explicit grid IDs for multi-grid scenarios to avoid collisions in registry.
4. **Data Bridge**: Use default bridge for simple cases; implement custom bridge for:
   - Complex data transformations (pivoting, aggregation)
   - Custom cross-filtering logic
   - Event broadcasting to external systems
5. **Listener Patterns**: Register ChartRegistry listeners to track lifecycle and trigger side effects (e.g., analytics, cache invalidation).
6. **Theme Consistency**: Apply the same theme list across related charts for visual cohesion.
7. **Performance**: For large datasets (>10k rows):
   - Consider server-side aggregation before charting
   - Implement lazy loading or pagination on the grid
   - Use windowed data bridges to reduce data sent to charts
8. **Error Handling**: Wrap field mapping validation to fail fast if grid data structure changes.

## Troubleshooting

### Charts Not Rendering
- Verify `enableCharts()` is called on the grid.
- Confirm chart IDs are registered in ChartRegistry.
- Check field mapping keys exist in grid row data.

### Cross-Filtering Not Working
- Ensure `enableCrossFiltering(true)` is set on ChartConfiguration.
- Verify field mapping includes an `id` key for selection tracking.
- Confirm grid selection event listeners are wired correctly.

### Data Not Updating
- Check that `IChartDataBridge.onGridDataChanged()` is invoked when grid data changes.
- Verify bridge is registered and linked to correct grid.

### Selection Sync Fails
- Ensure `enableSelectionSync(true)` is set on ChartConfiguration.
- Confirm grid row selection events propagate to bridge.

## Related Documentation

- **Grid-Charts Integration Guide** (user): `docs/ChartGridIntegration-Guide.md`
- **AG Grid Enterprise** (parent module): `.././../../../../README.md`
- **AG Charts Enterprise** (related): `../README.md`
- **Licensing & Activation**: `./licensing-and-activation.rules.md`
- **AG Grid API**: https://www.ag-grid.com/javascript-data-grid/api/
- **AG Charts API**: https://www.ag-grid.com/javascript-charts/api/

## Policies

- **CRTP Fluent Style**: All helper methods return `(J) this` for method chaining.
- **Thread Safety**: ChartRegistry uses ConcurrentHashMap; safe for multi-threaded access.
- **Forward-Only Changes**: New chart linking features do not modify existing grid options or behavior.
- **Backward Compatibility**: All changes are additive; existing code continues to work unchanged.

## Version History

- **v2.0.0** (2025-12-02): Initial chart-grid data binding implementation
  - IChartDataBridge interface
  - ChartConfiguration and ChartRegistry classes
  - Helper methods on AgGridEnterprise
  - Support for cross-filtering and selection sync

## See Also

- Page Configurator — `./page-configurator.rules.md`
- Licensing & Activation — `./licensing-and-activation.rules.md`
- Usage Examples — `./usage-examples.rules.md`
- Troubleshooting — `./troubleshooting.rules.md`
- JWebMP topic index — `../README.md`
