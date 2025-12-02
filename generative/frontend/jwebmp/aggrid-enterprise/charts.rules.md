# charts.rules.md — AG Grid Enterprise Charts Configuration

**Comprehensive guide for configuring and using the Charts feature in AG Grid Enterprise**

---

## Overview

The **Charts** feature enables data visualization directly from grid data. Users can select grid rows/columns and render charts (line, bar, pie, area, scatter, bubble, etc.) with customizable themes, colors, and styling.

### Key Concepts

- **Enable Charts** — Set `enableCharts()` via fluent API
- **Chart Themes** — Visual presets (ag-default, ag-vivid, ag-material, ag-sheets, polychroma)
- **Theme Overrides** — Custom CSS properties (colors, fonts, backgrounds)
- **Toolbar** — User-accessible chart management tools
- **Tool Panels** — Grid-level configuration panel for chart selection/export

---

## Configuration

### Enable Charts

```java
public class MyGrid extends AgGridEnterprise<MyGrid> {
    public MyGrid() {
        setID("myGrid");
        
        // Enable charts with fluent API
        enableCharts();
        
        // Optional: configure chart options
        ChartOptions charts = new ChartOptions();
        charts.setEnableCharts(true);
        charts.setChartTheme(ChartTheme.AG_VIVID);
        getOptions().setChartOptions(charts);
    }
}
```

### Chart Themes

AG Grid provides 5 built-in themes:

```java
public enum ChartTheme {
    AG_DEFAULT("ag-default"),           // Clean, minimal
    AG_VIVID("ag-vivid"),               // Bright, colorful
    AG_MATERIAL("ag-material"),         // Material Design
    AG_SHEETS("ag-sheets"),             // Google Sheets style
    POLYCHROMA("polychroma");           // High-contrast palette
}
```

#### Selecting a Theme

```java
ChartOptions charts = new ChartOptions();
charts.setChartTheme(ChartTheme.AG_VIVID);
grid.getOptions().setChartOptions(charts);
```

### Theme Overrides

Customize chart appearance with CSS properties:

```java
ChartOptions charts = new ChartOptions();
charts.setChartThemeOverrides(Map.ofEntries(
    Map.entry("backgroundColor", "#f5f5f5"),
    Map.entry("fontSize", "12px"),
    Map.entry("fontFamily", "Arial, sans-serif"),
    Map.entry("palette", "['#1f77b4', '#ff7f0e', '#2ca02c']"),
    Map.entry("lineHeight", "1.5"),
    Map.entry("seriesLineWidth", "2")
));

grid.getOptions().setChartOptions(charts);
```

**Common Override Properties:**

| Property | Type | Example | Purpose |
|----------|------|---------|---------|
| `backgroundColor` | Color | `#f5f5f5` | Chart background color |
| `fontSize` | Size | `12px` | Font size for labels/legend |
| `fontFamily` | Font | `Arial, sans-serif` | Font family |
| `seriesColors` | Array | `['red', 'green', 'blue']` | Series line/bar colors |
| `lineHeight` | Number | `1.5` | Line spacing |
| `seriesLineWidth` | Number | `2` | Line thickness for line charts |
| `seriesMarkerSize` | Number | `6` | Marker (point) size for line charts |

### Toolbar Configuration

The chart toolbar provides buttons for user interactions:

```java
ChartOptions charts = new ChartOptions();

// Configure available toolbar items
// Common items: download, chartPanelToggle, seriesChartType
charts.setToolbarItems(List.of(
    "download",          // Export chart as PNG
    "chartPanelToggle",  // Toggle chart configuration panel
    "seriesChartType"    // Change chart type
));

grid.getOptions().setChartOptions(charts);
```

**Standard Toolbar Items:**

| Item | Action |
|------|--------|
| `download` | Export chart as image (PNG) |
| `chartPanelToggle` | Show/hide chart configuration panel |
| `seriesChartType` | Switch between chart types (line, bar, pie, etc.) |
| `chartRange` | Select data range for chart |
| `chartFormat` | Chart formatting options |

### Tool Panels

Add chart management panel to grid side bar:

```java
SideBarOptions sideBar = new SideBarOptions();

// Add chart panel to side bar
List<SideBarToolPanelDef> toolPanels = List.of(
    new SideBarToolPanelDef()
        .setId("charts")
        .setLabelDefault("Charts"),
    new SideBarToolPanelDef()
        .setId("columns")
        .setLabelDefault("Columns")
);

sideBar.setToolPanels(toolPanels);
grid.getOptions().setSideBarOptions(sideBar);
```

---

## Usage Patterns

### Basic Chart Example

```java
public class SalesChartGrid extends AgGridEnterprise<SalesChartGrid> {
    public SalesChartGrid() {
        setID("salesChartGrid");
        
        // Enable charts
        enableCharts();
        
        // Define columns
        getOptions().setColumnDefs(List.of(
            new AgGridColumnDef<>("region"),
            new AgGridColumnDef<>("sales"),
            new AgGridColumnDef<>("year")
        ));
        
        // Load data
        getOptions().setRowData(loadSalesData());
    }
    
    private List<SalesRow> loadSalesData() {
        return List.of(
            new SalesRow("North", 150000, 2024),
            new SalesRow("South", 120000, 2024),
            new SalesRow("East", 180000, 2024),
            new SalesRow("West", 110000, 2024)
        );
    }
}
```

### Advanced Chart Configuration

```java
ChartOptions charts = new ChartOptions();
charts.setEnableCharts(true);
charts.setChartTheme(ChartTheme.AG_MATERIAL);

// Custom theme with brand colors
charts.setChartThemeOverrides(Map.of(
    "seriesColors", "['#0066cc', '#ff6600', '#00aa00']",
    "backgroundColor", "#ffffff",
    "fontSize", "14px",
    "fontFamily", "Segoe UI, sans-serif"
));

// Toolbar items
charts.setToolbarItems(List.of("download", "seriesChartType"));

grid.getOptions().setChartOptions(charts);
```

### Dynamic Chart Styling

```java
// Apply different theme based on data set
if (isLargeDataSet()) {
    charts.setChartTheme(ChartTheme.AG_SHEETS);  // Minimal theme for performance
} else {
    charts.setChartTheme(ChartTheme.AG_VIVID);   // Rich colors for smaller sets
}
```

---

## Integration with Other Features

### Charts + Row Grouping

When rows are grouped, charts can aggregate data by group:

```java
// Enable both charts and grouping
grid.enableCharts()
    .showRowGroupPanel();

// Define grouping
RowGroupingOptions grouping = new RowGroupingOptions();
grouping.setRowGroupingHierarchy(List.of(
    new RowGroupingHierarchyLevel("year"),
    new RowGroupingHierarchyLevel("quarter")
));

// Charts will aggregate data by group
grid.getOptions().setRowGroupingOptions(grouping);
```

### Charts + Server-Side Model

For large datasets, lazy-load chart data:

```java
grid.enableCharts()
    .useServerSideRowModel();

// Configure caching for chart data
ServerSideRowModelOptions serverSide = new ServerSideRowModelOptions();
serverSide.setCacheBlockSize(100);
serverSide.setMaxBlocksInCache(5);

grid.getOptions().setServerSideOptions(serverSide);
```

### Charts + Range Selection

Users can select ranges and create charts from selection:

```java
grid.enableCharts()
    .enableRangeSelection();

// Users select a range, then click "Create Chart" in toolbar
// Chart renders using selected range data
```

---

## Performance Considerations

### Optimize for Large Datasets

**Small Datasets (< 10K rows):**
```java
charts.setChartTheme(ChartTheme.AG_VIVID);  // Full styling OK
```

**Large Datasets (> 50K rows):**
```java
charts.setChartTheme(ChartTheme.AG_DEFAULT);  // Minimal theme
// or use polychroma for better performance with many series
charts.setChartTheme(ChartTheme.POLYCHROMA);
```

### Data Point Limits

- **Line/Area/Scatter Charts** — Recommend < 5,000 data points per series
- **Bar Charts** — Recommend < 10,000 bars
- **Pie Charts** — Recommend < 50 slices

**For larger datasets:**
1. Aggregate at backend before rendering
2. Lazy-load chart data after grid loads
3. Use server-side model for pagination

### Lazy-Load Charts

```java
// Chart starts disabled; load after grid ready
ChartOptions charts = new ChartOptions();
charts.setEnableCharts(false);  // Start disabled

// After data loaded, enable
setTimeout(() -> {
    charts.setEnableCharts(true);
    grid.refreshOptions();
}, 2000);
```

---

## Accessibility

### Chart Accessibility

- **Keyboard Navigation** — Tab through chart elements; Enter to select
- **Screen Readers** — Chart data accessible via alt-text and ARIA labels
- **Color Contrast** — Ensure theme colors meet WCAG AA standards (4.5:1 ratio)

### Accessible Chart Example

```java
charts.setChartThemeOverrides(Map.of(
    "seriesColors", "['#003366', '#ff6600', '#006600']"  // High contrast
));

// Provide data table alternative
addChartDataTable();  // Accessible alternative to visual chart
```

---

## Security & Compliance

### Data Privacy

- **PII Handling** — Don't export sensitive columns to chart
- **Export Controls** — Disable download for restricted users

```java
// Disable chart export for non-admin users
if (!isAdmin()) {
    charts.setToolbarItems(List.of(
        "chartPanelToggle",      // Allow panel toggle
        "seriesChartType"        // Allow chart type change
        // Exclude "download"
    ));
}
```

### XSS Prevention

AG Grid sanitizes all chart data; no inline HTML in charts.

---

## Browser Compatibility

| Browser | Support | Notes |
|---------|---------|-------|
| Chrome | ✅ Full | Full SVG support |
| Firefox | ✅ Full | Full SVG support |
| Safari | ✅ Full | Full SVG support |
| Edge | ✅ Full | Full SVG support |
| IE 11 | ❌ No | Not supported |

---

## Troubleshooting

### Charts Not Rendering

| Issue | Cause | Solution |
|-------|-------|----------|
| No chart toolbar | `enableCharts()` not called | Verify fluent method called; check getOptions().getChartOptions() |
| Chart blank | No data selected | Ensure grid has data rows; user must select range for chart |
| Wrong colors | Theme overrides conflict | Check override syntax; verify color values are valid hex/rgb |
| Performance lag | Too many data points | Aggregate backend data; limit to < 5K points |
| Export fails | Browser extension blocking | Check console for security errors; disable extensions |

### Theme Not Applying

```java
// Verify theme set correctly
ChartOptions charts = grid.getOptions().getChartOptions();
assertNotNull(charts.getChartTheme());
assertEquals(ChartTheme.AG_VIVID, charts.getChartTheme());
```

---

## Testing

### Unit Test: Chart Options

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

### Integration Test: Chart Rendering

```java
@Test
void chartRendersWithData() {
    SalesChartGrid grid = new SalesChartGrid();
    grid.getOptions().setRowData(List.of(
        new SalesRow("North", 100000, 2024)
    ));
    
    assertNotNull(grid.getOptions().getChartOptions());
    assertTrue(grid.getOptions().getChartOptions().getEnableCharts());
}
```

---

## See Also

- [README.md](./README.md) — Parent index of all enterprise features
- [charts-integration-example.md](./examples/chart-integration-example.md) — Complete working example
- [GLOSSARY.md](./GLOSSARY.md) — Chart terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Code snippets and templates
- [Dynamic Series Coloring](./dynamic-series-coloring.rules.md) — Conditional cell coloring for charts
- [Row Grouping](./row-grouping.rules.md) — Grouping data for chart aggregation

---

**End of charts.rules.md**
