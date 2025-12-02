# chart-integration-example.md — Complete Example: AG Grid Enterprise Charts

**A complete, working example showing how to enable and configure charts in a JWebMP grid**

---

## Setup

### 1. Create Grid Component

```java
public class SalesAnalysisGrid extends AgGridEnterprise<SalesAnalysisGrid> {
    public SalesAnalysisGrid() {
        setID("salesAnalysisGrid");
        
        // Enable enterprise features
        enableCharts()
            .enableRangeSelection()
            .sideBarFiltersAndColumns()
            .showRowGroupPanel();
        
        // Configure grid options
        getOptions().setPagination(true);
        getOptions().setPaginationPageSize(25);
        getOptions().setRowSelection(RowSelection.MULTIPLE);
        
        // Configure columns
        setupColumns();
        
        // Load sample data
        loadSampleData();
        
        // Configure charts
        configureCharts();
    }
    
    private void setupColumns() {
        List<AgGridColumnDef<?>> columnDefs = List.of(
            new AgGridColumnDef<>("id")
                .setHeaderName("ID")
                .setWidth(80),
            
            new AgGridColumnDef<>("region")
                .setHeaderName("Region")
                .setRowGroup(true)
                .setRowGroupIndex(0)
                .setFilter("agSetColumnFilter"),
            
            new AgGridColumnDef<>("product")
                .setHeaderName("Product")
                .setFilter("agSetColumnFilter"),
            
            new AgGridColumnDef<>("sales")
                .setHeaderName("Sales")
                .setAggFunc(AggregationFunction.SUM)
                .setValueFormatter("$#,###.##")
                .setWidth(120),
            
            new AgGridColumnDef<>("units")
                .setHeaderName("Units Sold")
                .setAggFunc(AggregationFunction.COUNT)
                .setWidth(120),
            
            new AgGridColumnDef<>("year")
                .setHeaderName("Year")
                .setRowGroup(true)
                .setRowGroupIndex(1),
            
            new AgGridColumnDef<>("quarter")
                .setHeaderName("Quarter")
                .setFilter("agSetColumnFilter")
        );
        
        getOptions().setColumnDefs(columnDefs);
    }
    
    private void loadSampleData() {
        List<SalesData> data = List.of(
            new SalesData(1, "North", "Product A", 150000, 120, 2024, "Q1"),
            new SalesData(2, "North", "Product B", 120000, 100, 2024, "Q1"),
            new SalesData(3, "South", "Product A", 100000, 80, 2024, "Q1"),
            new SalesData(4, "South", "Product C", 95000, 75, 2024, "Q1"),
            new SalesData(5, "East", "Product B", 180000, 150, 2024, "Q1"),
            new SalesData(6, "East", "Product C", 160000, 130, 2024, "Q1"),
            new SalesData(7, "West", "Product A", 110000, 90, 2024, "Q1"),
            new SalesData(8, "West", "Product B", 95000, 75, 2024, "Q1"),
            
            new SalesData(9, "North", "Product A", 160000, 130, 2024, "Q2"),
            new SalesData(10, "South", "Product B", 125000, 105, 2024, "Q2"),
            new SalesData(11, "East", "Product A", 190000, 160, 2024, "Q2"),
            new SalesData(12, "West", "Product C", 120000, 100, 2024, "Q2")
        );
        
        getOptions().setRowData(data);
    }
    
    private void configureCharts() {
        ChartOptions charts = new ChartOptions();
        charts.setEnableCharts(true);
        charts.setChartTheme(ChartTheme.AG_VIVID);
        
        // Custom theme overrides
        charts.setChartThemeOverrides(Map.of(
            "backgroundColor", "#f9f9f9",
            "fontSize", "12px",
            "fontFamily", "Segoe UI, sans-serif"
        ));
        
        // Toolbar items
        charts.setToolbarItems(List.of(
            "download",         // Export as PNG
            "seriesChartType",  // Change chart type
            "chartPanelToggle"  // Show chart settings
        ));
        
        getOptions().setChartOptions(charts);
        
        // Configure side bar with chart panel
        configureSideBar();
        
        // Configure row grouping for chart aggregation
        configureRowGrouping();
    }
    
    private void configureSideBar() {
        List<SideBarToolPanelDef> toolPanels = List.of(
            new SideBarToolPanelDef()
                .setId("columns")
                .setLabelDefault("Columns"),
            
            new SideBarToolPanelDef()
                .setId("filters")
                .setLabelDefault("Filters")
        );
        
        SideBarOptions sideBar = new SideBarOptions();
        sideBar.setToolPanels(toolPanels);
        sideBar.setPosition("right");
        
        getOptions().setSideBarOptions(sideBar);
    }
    
    private void configureRowGrouping() {
        RowGroupingOptions grouping = new RowGroupingOptions();
        grouping.setRowGroupPanelShow(PanelShow.ALWAYS);
        grouping.setGroupAllowUnbalanced(true);
        
        getOptions().setRowGroupingOptions(grouping);
    }
}
```

### 2. Data Model

```java
public class SalesData {
    public int id;
    public String region;
    public String product;
    public double sales;
    public int units;
    public int year;
    public String quarter;
    
    public SalesData(int id, String region, String product, 
                     double sales, int units, int year, String quarter) {
        this.id = id;
        this.region = region;
        this.product = product;
        this.sales = sales;
        this.units = units;
        this.year = year;
        this.quarter = quarter;
    }
}
```

---

## Usage Workflow

### Step 1: Create Grid

```java
SalesAnalysisGrid grid = new SalesAnalysisGrid();
page.add(grid);  // Add to JWebMP page
```

### Step 2: User Interactions

1. **View Data** — Grid displays sales data grouped by region and year
2. **Configure Groups** — Drag columns to Row Group Panel to reorder/remove grouping
3. **Apply Filters** — Click Filters in side bar; select values to filter
4. **Select Range** — Click and drag to select cell range; Ctrl+C copies
5. **Create Chart** — Click "Chart" button in toolbar (or use menu)
6. **Configure Chart** — Toggle chart settings; change theme; switch chart type

### Step 3: Chart Output

User selects Sales column range → Creates chart showing:
- Line chart: Sales by region over time
- Bar chart: Sales comparison by region
- Pie chart: Sales distribution by region

---

## Testing

### Unit Test

```java
@Test
void chartsEnabledOnGrid() {
    SalesAnalysisGrid grid = new SalesAnalysisGrid();
    
    assertNotNull(grid.getOptions().getChartOptions());
    assertTrue(grid.getOptions().getChartOptions().getEnableCharts());
    assertEquals(ChartTheme.AG_VIVID, 
        grid.getOptions().getChartOptions().getChartTheme());
}
```

### Integration Test

```java
@Test
void gridLoadsDataAndEnablesCharts() {
    SalesAnalysisGrid grid = new SalesAnalysisGrid();
    
    List<?> rowData = grid.getOptions().getRowData();
    assertNotNull(rowData);
    assertEquals(12, rowData.size());
    
    assertTrue(grid.getOptions().getChartOptions().getEnableCharts());
    assertNotNull(grid.getOptions().getSideBarOptions());
}
```

---

## See Also

- [charts.rules.md](../charts.rules.md) — Detailed chart configuration guide
- [README.md](../README.md) — Parent enterprise features index
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) — Code templates and snippets

---

**End of chart-integration-example.md**
