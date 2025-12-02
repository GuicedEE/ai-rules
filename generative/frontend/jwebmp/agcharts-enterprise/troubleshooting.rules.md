# Troubleshooting — AgCharts Enterprise Plugin

## General Troubleshooting

Symptoms and fixes
- Build missing dependency `ag-charts-enterprise`
  - Ensure the enterprise module is on the classpath and its Page Configurator is discovered.
  - Verify the generated Angular app `package.json` contains `ag-charts-enterprise`.
  - Check that `@TsDependency(name = "ag-charts-enterprise")` is present in the configurator.
- Enterprise features not available at runtime
  - Confirm license initialization as per AG Charts docs.
  - Clear caches and rebuild the Angular project to ensure the dependency is included.
- Conflicts with community plugin
  - Ensure the community plugin remains present; the enterprise plugin is additive.
  - Review dependency versions via the BOM to avoid mismatches.
- Bundle size concerns
  - Enable production builds and tree-shaking; import only the needed enterprise features when applicable.

Diagnostics
- Use verbose build logs to confirm dependency inclusion steps.
- In host projects, inspect the generated Angular workspace for dependency versions and presence.

## Chart-Grid Integration Troubleshooting (v2.0.0+)

### Charts Not Rendering
**Symptom**: Grid displays normally but linked charts do not appear.

**Diagnosis**:
1. Verify `grid.enableCharts()` is called.
2. Check that chart IDs are registered: `ChartRegistry.getInstance().getChart(chartId)` should not be null.
3. Confirm field mapping keys match grid row data properties:
   ```java
   // Example: if fieldMapping has "region" → "x", verify rows contain "region" key
   row.get("region") != null
   ```

**Solution**:
- Ensure chart registration happens before linking:
  ```java
  // Register first
  ChartRegistry.getInstance().registerChart("myChart", config);
  // Then link
  grid.linkCharts("myChart");
  ```
- Validate field mapping by printing grid data:
  ```java
  System.out.println("Row data: " + rowDataList.get(0)); // Check keys
  System.out.println("Field mapping: " + config.getFieldMapping()); // Check mapping
  ```

### Cross-Filtering Not Working
**Symptom**: Chart interactions don't filter the grid; grid filtering doesn't update charts.

**Diagnosis**:
1. Verify `ChartConfiguration.enableCrossFiltering(true)` is set.
2. Check that field mapping includes an `"id"` key for selection tracking:
   ```java
   Map.of("region", "x", "sales", "y", "regionId", "id")
   ```
3. Confirm grid has a unique identifier set (used internally by registry).

**Solution**:
- Enable cross-filtering explicitly:
  ```java
  grid.registerAndLinkChart(new ChartConfiguration("chart1", "bar")
      .setEnableCrossFiltering(true)
      .setFieldMapping(Map.of("category", "x", "value", "y", "categoryId", "id")))
    .enableChartCrossFiltering();
  ```
- Ensure the `id` field in the field mapping refers to a unique column in grid data.

### Selection Sync Not Working
**Symptom**: Grid row selection doesn't highlight chart data; chart interactions don't highlight grid rows.

**Diagnosis**:
1. Verify `ChartConfiguration.enableSelectionSync(true)` is set.
2. Check that grid selection events are firing (inspect browser dev tools for grid API calls).
3. Confirm `"id"` field mapping exists for data point tracking.

**Solution**:
- Enable selection sync:
  ```java
  grid.registerAndLinkChart(new ChartConfiguration("chart1", "line")
      .setEnableSelectionSync(true)
      .setFieldMapping(Map.of("x", "x", "y", "y", "pointId", "id")))
    .enableChartSelectionSync();
  ```

### Data Not Updating
**Symptom**: Grid data updates but charts display stale data.

**Diagnosis**:
1. Check if `IChartDataBridge.onGridDataChanged()` is being called.
2. Verify the data bridge is registered:
   ```java
   ChartRegistry.getInstance().getDataBridge(bridgeId) != null
   ```
3. Confirm grid and bridge are properly linked via `ChartConfiguration.setDataBridgeId()`.

**Solution**:
- If using a custom data bridge, ensure `onGridDataChanged()` propagates updates to listeners:
  ```java
  @Override
  public void onGridDataChanged(List<T> updatedData) {
      this.gridData = new ArrayList<>(updatedData);
      // Notify listeners that data changed
      listeners.forEach(l -> { /* trigger update */ });
  }
  ```
- For simple cases, use the default bridge or let the framework handle it automatically.

### Registry Lookup Failures
**Symptom**: `NullPointerException` when accessing `ChartRegistry.getInstance().getChart(id)`.

**Diagnosis**:
1. Chart ID may not be registered; check `ChartRegistry.getAllCharts()` to list registered charts.
2. Grid ID collisions in multi-grid scenarios.

**Solution**:
- Debug by printing all registered charts:
  ```java
  ChartRegistry.getInstance().getAllCharts().forEach(c ->
      System.out.println("Chart: " + c.getChartId())
  );
  ```
- Use unique, scoped chart IDs (e.g., "dashboard-1-chart-sales" instead of "chart").
- For multi-grid, explicitly set grid IDs:
  ```java
  AgGridEnterprise<AgGridEnterprise<?>> grid1 = new AgGridEnterprise<>("grid-1");
  AgGridEnterprise<AgGridEnterprise<?>> grid2 = new AgGridEnterprise<>("grid-2");
  ```

### Field Mapping Issues
**Symptom**: Charts display but with empty or misaligned data.

**Diagnosis**:
1. Field mapping keys don't match grid row properties.
2. Null values in mapped fields cause chart errors.

**Solution**:
- Validate field mapping before registration:
  ```java
  // Check a sample row
  Map<String, Object> sampleRow = rowDataList.get(0);
  Map<String, String> mapping = new HashMap<>();
  mapping.forEach((gridField, chartProp) -> {
      if (!sampleRow.containsKey(gridField)) {
          throw new IllegalArgumentException("Missing field: " + gridField);
      }
  });
  ```
- Add null-safe handling in data bridge:
  ```java
  @Override
  public List<Map<String, Object>> getGridRowData() {
      return gridData.stream()
          .filter(row -> row.get("id") != null) // Filter out incomplete rows
          .toList();
  }
  ```

### Performance Issues with Large Datasets
**Symptom**: Charts render slowly or grid becomes unresponsive with 10k+ rows.

**Diagnosis**:
1. Entire dataset is being sent to charts; no server-side aggregation.
2. Data bridge processes all rows on every change.

**Solution**:
- Implement server-side aggregation before charting:
  ```java
  List<Map<String, Object>> aggregatedData = serverService.aggregateSalesData(fullDataset);
  grid.setRowData(fullDataset);
  ChartRegistry.getInstance().registerDataBridge("agg-bridge", 
      new AggregatedDataBridge(aggregatedData));
  ```
- Use windowed/paginated data bridge to limit chart data:
  ```java
  public class WindowedDataBridge implements IChartDataBridge<Map<String, Object>> {
      private static final int WINDOW_SIZE = 1000;
      
      @Override
      public List<Map<String, Object>> getGridRowData() {
          return gridData.stream()
              .limit(WINDOW_SIZE)
              .collect(Collectors.toList());
      }
  }
  ```

## Related Resources

- Integration overview — ./agcharts-enterprise-integration.rules.md
- Grid-Data Binding Rules — ./grid-data-binding.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing — ./licensing-and-activation.rules.md
