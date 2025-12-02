# pivot-tables-and-aggregation.rules.md — AG Grid Enterprise Pivot Tables and Aggregation

**Configuration guide for pivot mode and data aggregation**

---

## Overview

**Pivot Mode** enables pivot table layout with rows, columns, and values. **Aggregation Functions** summarize grouped values (SUM, COUNT, AVG, MIN, MAX).

### Key Concepts

- **Pivot Mode** — Transform grid into pivot table layout
- **Row Pivot** — Column values become row groups
- **Column Pivot** — Column values become column headers
- **Value Column** — Column whose values are aggregated
- **Aggregation Function** — Operation summarizing values (SUM, COUNT, AVG, MIN, MAX)

---

## Configuration

### Enable Pivot Mode

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

grid.getOptions().setPivotingOptions(pivoting);
```

### Define Pivot Columns

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    // Row pivot: region becomes row groups
    new AgGridColumnDef<>("region")
        .setPivot(true)
        .setPivotIndex(0),
    
    // Column pivot: year becomes column headers
    new AgGridColumnDef<>("year")
        .setPivot(true)
        .setPivotIndex(1),
    
    // Value column: sum sales
    new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM)
        .setValueFormatter("$#,###.##")
);

grid.getOptions().setColumnDefs(columnDefs);
```

### Pivot Totals

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);
pivoting.setPivotRowTotals(true);          // Show row totals
pivoting.setPivotColumnGroupTotals(true);  // Show column totals

grid.getOptions().setPivotingOptions(pivoting);
```

---

## Aggregation Functions

### Available Functions

```java
public enum AggregationFunction {
    SUM("sum"),           // Sum of values
    COUNT("count"),       // Number of items
    AVG("avg"),           // Average value
    MIN("min"),           // Minimum value
    MAX("max"),           // Maximum value
    CUSTOM("custom")      // Custom aggregation
}
```

### Configure Aggregation

```java
new AgGridColumnDef<>("sales")
    .setAggFunc(AggregationFunction.SUM)
    .setValueFormatter("$#,###.00"),

new AgGridColumnDef<>("quantity")
    .setAggFunc(AggregationFunction.COUNT),

new AgGridColumnDef<>("price")
    .setAggFunc(AggregationFunction.AVG)
    .setValueFormatter("$#,###.00")
```

---

## Usage Patterns

### Sales by Region × Year Pivot

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);
pivoting.setPivotRowTotals(true);
pivoting.setPivotColumnGroupTotals(true);

List<AgGridColumnDef<?>> columnDefs = List.of(
    // Row: Region
    new AgGridColumnDef<>("region")
        .setPivot(true)
        .setPivotIndex(0),
    
    // Column: Year
    new AgGridColumnDef<>("year")
        .setPivot(true)
        .setPivotIndex(1),
    
    // Value: Sum of Sales
    new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM)
        .setValueFormatter("$#,###")
);

grid.getOptions().setColumnDefs(columnDefs);
grid.getOptions().setPivotingOptions(pivoting);
```

**Result:**

```
           | 2023    | 2024    | 2025    | Total
-----------|---------|---------|---------|----------
North      | $100K   | $150K   | $200K   | $450K
South      | $80K    | $120K   | $140K   | $340K
East       | $120K   | $180K   | $220K   | $520K
West       | $60K    | $110K   | $130K   | $300K
-----------|---------|---------|---------|----------
Total      | $360K   | $560K   | $690K   | $1.61M
```

### Multi-Level Pivot

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    // Row pivot: Region, then Product
    new AgGridColumnDef<>("region").setPivot(true).setPivotIndex(0),
    new AgGridColumnDef<>("product").setPivot(true).setPivotIndex(1),
    
    // Column pivot: Year
    new AgGridColumnDef<>("year").setPivot(true).setPivotIndex(0),
    
    // Value: Sum of Sales
    new AgGridColumnDef<>("sales").setAggFunc(AggregationFunction.SUM)
);
```

---

## Aggregation Options

### Root Level Aggregation

```java
AggregationOptions agg = new AggregationOptions();
agg.setAlwaysAggregateAtRootLevel(true);  // Aggregate total at root

grid.getOptions().setAggregationOptions(agg);
```

### Column Order Maintenance

```java
AggregationOptions agg = new AggregationOptions();
agg.setMaintainColumnOrder(true);  // Keep column order in pivot

grid.getOptions().setAggregationOptions(agg);
```

---

## Integration with Other Features

### Pivot + Row Grouping

Combine pivot mode with groups:

```java
grid.showRowGroupPanel();

PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

grid.getOptions().setPivotingOptions(pivoting);
```

### Pivot + Charts

Visualize pivot data:

```java
grid.enableCharts();

PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

// User selects chart type; renders pivot summary
```

### Pivot + Server-Side Model

Aggregate at backend:

```java
grid.useServerSideRowModel();

PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

// Backend performs pivot aggregation on large dataset
```

---

## Performance

### Optimization Tips

**Small Datasets (< 100K rows):**
```java
pivoting.setPivotRowTotals(true);
pivoting.setPivotColumnGroupTotals(true);  // All totals OK
```

**Large Datasets (> 1M rows):**
```java
pivoting.setPivotRowTotals(true);
// Skip column group totals for performance
pivoting.setPivotColumnGroupTotals(false);
```

### Memory Management

- **Pivot size** — Limit row × column matrix to < 10K cells
- **Deep pivots** — Avoid > 2 pivot levels
- **Aggregation** — Pre-aggregate at backend for > 100K rows

---

## Testing

### Unit Test: Pivot Options

```java
@Test
void pivotOptionsConfigured() {
    PivotingOptions pivoting = new PivotingOptions();
    pivoting.setPivotMode(true);
    pivoting.setPivotRowTotals(true);
    
    String json = mapper.writeValueAsString(pivoting);
    assertTrue(json.contains("\"pivotMode\":true"));
}
```

### Unit Test: Aggregation

```java
@Test
void aggregationFunctionConfigured() {
    AgGridColumnDef<?> colDef = new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM);
    
    String json = mapper.writeValueAsString(colDef);
    assertTrue(json.contains("\"aggFunc\":\"sum\""));
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Pivot/aggregation terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Code templates
- [Row Grouping](./row-grouping.rules.md) — Group-based aggregation
- [Charts](./charts.rules.md) — Visualizing pivot data

---

**End of pivot-tables-and-aggregation.rules.md**
