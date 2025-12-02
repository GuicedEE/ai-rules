# QUICK_REFERENCE — AG Grid Enterprise Code Templates & Checklists

**A practical guide with code snippets, configuration templates, and troubleshooting checklists for the JWebMP AG Grid Enterprise plugin**

---

## Table of Contents

1. [Configuration Templates](#configuration-templates)
2. [Code Snippets](#code-snippets)
3. [Feature Checklist](#feature-checklist)
4. [Performance Checklist](#performance-checklist)
5. [Testing Templates](#testing-templates)
6. [Troubleshooting Guide](#troubleshooting-guide)

---

## Configuration Templates

### 1. Basic Enterprise Grid Setup

```java
public class BasicEnterpriseGrid extends AgGridEnterprise<BasicEnterpriseGrid> {
    public BasicEnterpriseGrid() {
        setID("basicGrid");
        
        // Enable core enterprise features
        enableCharts()
            .enableRangeSelection()
            .sideBarFiltersAndColumns()
            .showRowGroupPanel();
        
        // Configure grid options
        getOptions().setPagination(true);
        getOptions().setPaginationPageSize(25);
        getOptions().setRowSelection(RowSelection.MULTIPLE);
    }
}
```

### 2. Charts Configuration

```java
ChartOptions charts = new ChartOptions();
charts.setEnableCharts(true);
charts.setChartTheme(ChartTheme.AG_VIVID);
charts.setChartThemeOverrides(Map.of(
    "backgroundColor", "#f5f5f5",
    "fontSize", "12px",
    "seriesColors", List.of("#1f77b4", "#ff7f0e", "#2ca02c")
));

grid.getOptions().setChartOptions(charts);
```

### 3. Row Grouping Configuration

```java
RowGroupingOptions grouping = new RowGroupingOptions();

// Define multi-level hierarchy
grouping.setRowGroupingHierarchy(List.of(
    new RowGroupingHierarchyLevel("year"),
    new RowGroupingHierarchyLevel("quarter"),
    new RowGroupingHierarchyLevel("month")
));

// Control panel visibility
grouping.setRowGroupPanelShow(PanelShow.ALWAYS);

// Allow unbalanced groups
grouping.setGroupAllowUnbalanced(true);

// Hide single-child parents
grouping.setGroupHideParentOfSingleChild("leafGroupsOnly");

grid.getOptions().setRowGroupingOptions(grouping);
```

### 4. Server-Side Row Model Configuration

```java
ServerSideRowModelOptions serverSide = new ServerSideRowModelOptions();
serverSide.setRowModelType(RowModelType.SERVER_SIDE);
serverSide.setCacheBlockSize(50);
serverSide.setMaxBlocksInCache(5);
serverSide.setPurgeClosedRowNodes(true);

grid.getOptions().setServerSideOptions(serverSide);
```

### 5. Side Bar & Status Bar Configuration

```java
// Side Bar Panels
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

// Status Bar Panels
List<StatusBarPanelDef> statusPanels = List.of(
    new StatusBarPanelDef().setKey("totalAndFiltered"),
    new StatusBarPanelDef().setKey("selectedCount")
);

StatusBarOptions statusBar = new StatusBarOptions();
statusBar.setStatusPanels(statusPanels);

grid.getOptions().setSideBarOptions(sideBar);
grid.getOptions().setStatusBarOptions(statusBar);
```

### 6. Pivot Table Configuration

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

// Define pivots
pivoting.setPivotRowTotals(true);
pivoting.setPivotColumnGroupTotals(true);

// Define aggregation
AggregationOptions aggregation = new AggregationOptions();
aggregation.setAlwaysAggregateAtRootLevel(true);
aggregation.setMaintainColumnOrder(true);

grid.getOptions().setPivotingOptions(pivoting);
grid.getOptions().setAggregationOptions(aggregation);
```

### 7. Advanced Filtering Configuration

```java
AdvancedFilteringOptions advFilters = new AdvancedFilteringOptions();
advFilters.setAllowedCharPattern(".*");  // Allow all chars in filter
advFilters.setCaseSensitive(false);      // Case-insensitive search
advFilters.setIncludeHiddenColumns(false);  // Skip hidden columns

grid.getOptions().setAdvancedFilteringOptions(advFilters);
```

---

## Code Snippets

### Adding Column Definitions with Enterprise Options

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    new AgGridColumnDef<>("region")
        .setRowGroup(true)
        .setRowGroupIndex(0)
        .setComparator(customComparator)
        .setValueFormatter("${region}"),
    
    new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM)
        .setValueFormatter("$#,###.##"),
        
    new AgGridColumnDef<>("date")
        .setRowGroup(true)
        .setRowGroupIndex(1)
        .setKeyCreator(dateToQuarterKeyCreator()),
    
    new AgGridColumnDef<>("status")
        .setFilter("agSetColumnFilter")
);

grid.getOptions().setColumnDefs(columnDefs);
```

### Custom Group Value Formatter

```java
class QuarterValueFormatter implements ValueFormatter {
    @Override
    public String getValue(ValueFormatterParams params) {
        String key = (String) params.getValue();
        // Format "2024-Q1" as "Q1 2024"
        return key.replaceAll("(\\d{4})-(Q\\d)", "$2 $1");
    }
}

columnDef.setValueFormatter(new QuarterValueFormatter());
```

### Fluent API Chaining Example

```java
SalesGrid grid = new SalesGrid()
    .enableCharts()
    .enableRangeSelection()
    .sideBarFiltersAndColumns()
    .showRowGroupPanel()
    .useServerSideRowModel();

// Grid is fully configured; ready to add to page
```

### Server-Side Data Source Integration

```java
public class SalesDataSource implements ServerSideDataSource {
    private SalesRepository repo;
    
    @Override
    public GetRowsResponse getRows(GetRowsParams params) {
        // Parse sort/filter from params
        int blockStart = params.getStartRow();
        int blockEnd = params.getEndRow();
        
        // Fetch from backend
        List<SalesData> rows = repo.fetchRows(blockStart, blockEnd);
        int totalRows = repo.countTotal();
        
        GetRowsResponse response = new GetRowsResponse();
        response.setRowData(rows);
        response.setRowCount(totalRows);
        return response;
    }
}
```

### Dynamic Series Coloring Example

```java
// VALUE_GRADIENT Strategy: gradient from white → green
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_GRADIENT);
coloring.setColorRange(new ColorRange()
    .setMin("#ffffff")
    .setMax("#00aa00")
    .setThreshold(0, 100));

grid.getOptions().setDynamicSeriesColoring(coloring);
```

---

## Feature Checklist

### When Adding a New Enterprise Feature

- [ ] Create typed Options POJO (e.g., `MyNewOptions`)
  - [ ] Annotate `@JsonAutoDetect(fieldVisibility = Visibility.ANY)`
  - [ ] Annotate `@JsonUnwrapped` in parent (AgGridEnterpriseOptions)
  - [ ] Add to module-info.java exports
  
- [ ] Add fluent setter on `AgGridEnterprise<T>`
  ```java
  public T enableMyFeature() {
      getOptions().setMyNewOptions(new MyNewOptions());
      return this;
  }
  ```
  - [ ] Return `this` for CRTP chaining
  - [ ] Annotate `@SuppressWarnings("unchecked")` if needed
  
- [ ] Create MapStruct mapper (if enum transformations needed)
  ```java
  @Mapper
  public interface MyFeatureMapper {
      MyNewOptions toOptions(MyFeatureDTO dto);
  }
  ```
  - [ ] Add to annotation processor path in pom.xml
  
- [ ] Create unit test
  ```java
  @Test
  void myFeatureSerializesCorrectly() throws JsonProcessingException {
      MyNewOptions opts = new MyNewOptions();
      opts.setSetting("value");
      String json = mapper.writeValueAsString(opts);
      assertTrue(json.contains("\"setting\":\"value\""));
  }
  ```
  
- [ ] Create rule file: `my-feature.rules.md`
  - [ ] Overview & purpose section
  - [ ] Configuration examples
  - [ ] Usage patterns
  - [ ] See-also links to README.md
  
- [ ] Update GLOSSARY.md with new terms
  
- [ ] Update QUICK_REFERENCE.md with code example
  
- [ ] Update README.md features index
  
- [ ] Link from main project GUIDES.md
  
- [ ] Run build: `mvn clean install`

---

## Performance Checklist

### Before Deploying to Production

**Small Datasets (< 10K rows):**
- [ ] All enterprise features enabled (Charts, Range, Groups, etc.)
- [ ] Grid initializes in < 500ms
- [ ] Client-side row model sufficient
- [ ] Run with BrowserStack or equivalent

**Medium Datasets (10K – 100K rows):**
- [ ] Enable server-side row model
- [ ] Set `cacheBlockSize = 50`
- [ ] Set `maxBlocksInCache = 5`
- [ ] Set `purgeClosedRowNodes = true`
- [ ] Grid initialization: < 1 second
- [ ] Scroll response: < 200ms per block
- [ ] Charts render in < 500ms after data load

**Large Datasets (> 100K rows):**
- [ ] Server-side row model **required**
- [ ] Set `cacheBlockSize = 50–100`
- [ ] Set `maxBlocksInCache = 3–5`
- [ ] Enable lazy-loading (purge=true)
- [ ] Use pagination or virtual scrolling
- [ ] Lazy-load charts (don't render on init)
- [ ] Run load test: 1000+ concurrent users

**Memory & Network:**
- [ ] Monitor heap usage (target < 500MB for 100K rows)
- [ ] Network payload < 2MB per request
- [ ] Compression enabled (gzip)
- [ ] Block requests throttled (max 10/sec)

**Charts Performance:**
- [ ] Avoid rendering > 5K data points per chart
- [ ] Use appropriate theme (polychroma for large legends)
- [ ] Cache chart SVG (don't regenerate on sort)
- [ ] Lazy-load if dataset > 50K rows

---

## Testing Templates

### Unit Test: Charts Options

```java
@Test
void chartOptionsSerializesCorrectly() throws JsonProcessingException {
    ChartOptions opts = new ChartOptions();
    opts.setEnableCharts(true);
    opts.setChartTheme(ChartTheme.AG_VIVID);
    opts.setChartThemeOverrides(Map.of("backgroundColor", "#f5f5f5"));
    
    String json = mapper.writeValueAsString(opts);
    
    JsonNode node = mapper.readTree(json);
    assertTrue(node.get("enableCharts").asBoolean());
    assertEquals("ag-vivid", node.get("chartTheme").asText());
}
```

### Unit Test: Fluent API Chaining

```java
@Test
void fluentApiReturnsCorrectType() {
    SalesGrid grid = new SalesGrid()
        .enableCharts()
        .enableRangeSelection()
        .sideBarFiltersAndColumns();
    
    assertNotNull(grid);
    assertNotNull(grid.getOptions().getChartOptions());
    assertNotNull(grid.getOptions().getRangeSelectionOptions());
}
```

### Integration Test: Server-Side Model

```java
@Test
void serverSideRowModelFetchesRows() {
    // Mock data source
    ServerSideDataSource mockSource = new ServerSideDataSource() {
        @Override
        public GetRowsResponse getRows(GetRowsParams params) {
            return new GetRowsResponse()
                .setRowData(List.of(new SalesRow("North", 100000)))
                .setRowCount(1);
        }
    };
    
    // Create grid with server-side model
    SalesGrid grid = new SalesGrid()
        .useServerSideRowModel();
    
    // Verify configuration
    assertEquals(RowModelType.SERVER_SIDE, 
        grid.getOptions().getServerSideOptions().getRowModelType());
}
```

### UI Test: Charts Rendering

```java
@Test
@DisplayName("Charts render with correct theme")
void chartsRenderWithTheme() {
    // Setup grid with chart theme
    SalesGrid grid = new SalesGrid()
        .enableCharts();
    
    ChartOptions charts = grid.getOptions().getChartOptions();
    charts.setChartTheme(ChartTheme.AG_MATERIAL);
    
    // Render in browser (Selenium/Cypress)
    // Assert chart toolbar present
    // Assert AG Material theme applied
    // Assert data series colored correctly
}
```

---

## Troubleshooting Guide

### Issue: Charts Not Rendering

| Symptom | Cause | Solution |
|---------|-------|----------|
| No chart toolbar | `enableCharts()` not called | Verify `grid.getOptions().getChartOptions().getEnableCharts() == true` |
| Charts blank | AllEnterpriseModule not registered | Check page source for `AllEnterpriseModule`; verify Page Configurator runs |
| Chart JS error | ag-grid-enterprise npm not installed | Run `npm list ag-grid-enterprise`; install if missing |
| Data not in chart | Chart data source not configured | Verify grid has data; check browser console for JS errors |
| Wrong colors | Theme not applied | Verify `setChartTheme()` called; check theme overrides |

### Issue: Server-Side Model Not Working

| Symptom | Cause | Solution |
|---------|-------|----------|
| Data not loading | DataSource not registered | Verify `ServerSideDataSource` returned from grid API |
| Rows repeating | Block cache not purging | Set `purgeClosedRowNodes(true)` |
| Slow scrolling | Block size too small | Increase `cacheBlockSize` to 50–100 |
| Memory growing | Cache never cleared | Set `maxBlocksInCache` to reasonable value (5–10) |
| Sorting not working | Backend not handling sort params | Verify `GetRowsParams.getSortModel()` and apply to query |

### Issue: Row Grouping Errors

| Symptom | Cause | Solution |
|---------|-------|----------|
| Groups not created | `rowGroup: true` not set on column | Verify `columnDef.setRowGroup(true)` |
| Panel not visible | `setRowGroupPanelShow()` not called | Set to `PanelShow.ALWAYS` |
| Single-child parent visible | Parent hiding not configured | Set `setGroupHideParentOfSingleChild("leafGroupsOnly")` |
| Null values missing | `groupAllowUnbalanced` not set | Set `setGroupAllowUnbalanced(true)` |
| Custom grouping not working | KeyCreator not implemented | Provide custom `setKeyCreator()` function |

### Issue: Performance Problems

| Symptom | Cause | Solution |
|---------|-------|----------|
| Grid slow with 100K rows | Using client-side model | Switch to server-side model |
| Charts take 10+ seconds | Rendering too much data | Limit chart to < 5K points; use lazy-load |
| Memory bloat | Cache never releases | Enable `purgeClosedRowNodes`; reduce `maxBlocksInCache` |
| Filtering slow | No backend indexing | Create database indexes on filter columns |
| Sorting slow | Sorting happens client-side | Implement sort in backend; use server-side model |

### Issue: Serialization/JSON Errors

| Symptom | Cause | Solution |
|---------|-------|----------|
| Unknown JSON field | Field not in Options POJO | Check pom.xml for MapStruct; verify processor order |
| Enum serializes wrong | MapStruct mapper not applied | Verify `@Mapper` interface and processor path |
| Null fields in JSON | `@JsonInclude` not set | Add `@JsonInclude(Include.NON_NULL)` to POJO |
| Field not visible | Jackson visibility not set | Add `@JsonAutoDetect(fieldVisibility = Visibility.ANY)` |

---

## Deployment Checklist

### Before Go-Live

**Code Quality:**
- [ ] All tests passing: `mvn test`
- [ ] Coverage > 80%: `mvn jacoco:report`
- [ ] No compiler warnings
- [ ] All docs links valid

**Build & Packaging:**
- [ ] Maven build succeeds: `mvn clean install`
- [ ] Artifact published to Maven Central
- [ ] Javadoc generated and reviewed
- [ ] CHANGELOG updated

**Documentation:**
- [ ] README.md up-to-date
- [ ] PACT.md reflects current architecture
- [ ] GUIDES.md has examples for all features
- [ ] IMPLEMENTATION.md matches code structure
- [ ] GLOSSARY.md complete and linked

**Testing:**
- [ ] Unit tests cover all feature modules
- [ ] Integration tests pass with real data
- [ ] Performance benchmarks < targets
- [ ] Browser testing (Chrome, Firefox, Safari, Edge)
- [ ] Mobile testing (iOS Safari, Android Chrome)

**Deployment:**
- [ ] Release tag created: `v2.0.0`
- [ ] Artifact staged in Maven Central
- [ ] GitHub release with changelog
- [ ] Website/docs updated with new version

---

## Quick Links

- **Parent Rules Index**: [README.md](./README.md)
- **Enterprise Glossary**: [GLOSSARY.md](./GLOSSARY.md)
- **Charts Feature**: [charts.rules.md](./charts.rules.md)
- **Row Grouping Feature**: [row-grouping.rules.md](./row-grouping.rules.md)
- **Server-Side Model**: [server-side-row-model.rules.md](./server-side-row-model.rules.md)
- **Host Project GUIDES**: [../../../../../../GUIDES.md](../../../../../../GUIDES.md)
- **Host Project IMPLEMENTATION**: [../../../../../../IMPLEMENTATION.md](../../../../../../IMPLEMENTATION.md)

---

**End of QUICK_REFERENCE**
