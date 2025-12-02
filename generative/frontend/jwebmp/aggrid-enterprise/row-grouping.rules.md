# row-grouping.rules.md — AG Grid Enterprise Row Grouping Configuration

**Comprehensive guide for configuring multi-level row grouping, hierarchies, and group management**

---

## Overview

**Row Grouping** organizes grid rows by column values, creating expandable groups. Multi-level hierarchies enable nested grouping (e.g., Year → Quarter → Month).

### Key Concepts

- **Enable Row Grouping** — Set `rowGroup: true` on columnDef
- **Group Panel** — UI for configuring grouping at runtime
- **Grouping Hierarchy** — Multi-level nesting (3+ levels)
- **Parent Hiding** — Control visibility of parent rows
- **Custom Aggregation** — Aggregate grouped values

---

## Configuration

### Enable Row Grouping

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    new AgGridColumnDef<>("region")
        .setRowGroup(true)
        .setRowGroupIndex(0),
    new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM)
);

grid.getOptions().setColumnDefs(columnDefs);
```

### Multi-Level Grouping Hierarchy

```java
RowGroupingOptions grouping = new RowGroupingOptions();

grouping.setRowGroupingHierarchy(List.of(
    new RowGroupingHierarchyLevel("year"),
    new RowGroupingHierarchyLevel("quarter"),
    new RowGroupingHierarchyLevel("month")
));

grid.getOptions().setRowGroupingOptions(grouping);
```

### Group Panel Configuration

```java
RowGroupingOptions grouping = new RowGroupingOptions();
grouping.setRowGroupPanelShow(PanelShow.ALWAYS);  // Always visible

grid.getOptions().setRowGroupingOptions(grouping);
```

**PanelShow Options:**

| Value | Behavior |
|-------|----------|
| `ALWAYS` | Always visible; user can manage groups |
| `ONLY_WHEN_GROUPING` | Visible only when groups exist |
| `NEVER` | Never visible; grouping read-only |

### Unbalanced Groups

Allow groups with null/missing values:

```java
RowGroupingOptions grouping = new RowGroupingOptions();
grouping.setGroupAllowUnbalanced(true);

grid.getOptions().setRowGroupingOptions(grouping);
```

### Parent Row Hiding

Control when parent rows are hidden (single child hiding):

```java
RowGroupingOptions grouping = new RowGroupingOptions();

// Hide parents with single child (leaf groups only)
grouping.setGroupHideParentOfSingleChild("leafGroupsOnly");

// Or hide all single-child parents
grouping.setGroupHideParentOfSingleChild(true);

grid.getOptions().setRowGroupingOptions(grouping);
```

---

## Advanced Configuration

### Custom Key Creator

Generate custom group keys from row data:

```java
// Group by quarter for date fields
RowGroupingOptions grouping = new RowGroupingOptions();

grouping.setKeyCreator(row -> {
    Date date = (Date) row.get("date");
    int quarter = (date.getMonth() / 3) + 1;
    int year = date.getYear();
    return year + "-Q" + quarter;  // "2024-Q1"
});

grid.getOptions().setRowGroupingOptions(grouping);
```

### Custom Value Formatter

Format group display values:

```java
columnDef.setValueFormatter(params -> {
    String key = (String) params.getValue();
    // Format "2024-Q1" as "Q1 2024"
    return key.replaceAll("(\\d{4})-(Q\\d)", "$2 $1");
});
```

### Aggregation Functions

Aggregate grouped values:

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    new AgGridColumnDef<>("region").setRowGroup(true),
    new AgGridColumnDef<>("sales")
        .setAggFunc(AggregationFunction.SUM),
    new AgGridColumnDef<>("count")
        .setAggFunc(AggregationFunction.COUNT),
    new AgGridColumnDef<>("price")
        .setAggFunc(AggregationFunction.AVG)
);

grid.getOptions().setColumnDefs(columnDefs);
```

**Available Aggregation Functions:**

| Function | Purpose | Example |
|----------|---------|---------|
| `SUM` | Sum of values | Total sales per region |
| `COUNT` | Number of items | Count of transactions |
| `AVG` | Average value | Average order value |
| `MIN` | Minimum value | Lowest price |
| `MAX` | Maximum value | Highest price |

---

## Usage Patterns

### Year → Quarter → Month Hierarchy

```java
public class SalesHierarchyGrid extends AgGridEnterprise<SalesHierarchyGrid> {
    public SalesHierarchyGrid() {
        setID("salesHierarchy");
        
        // Define columns
        getOptions().setColumnDefs(List.of(
            new AgGridColumnDef<>("year")
                .setRowGroup(true)
                .setRowGroupIndex(0),
            new AgGridColumnDef<>("quarter")
                .setRowGroup(true)
                .setRowGroupIndex(1),
            new AgGridColumnDef<>("month")
                .setRowGroup(true)
                .setRowGroupIndex(2),
            new AgGridColumnDef<>("sales")
                .setAggFunc(AggregationFunction.SUM)
        ));
        
        // Configure grouping
        RowGroupingOptions grouping = new RowGroupingOptions();
        grouping.setRowGroupPanelShow(PanelShow.ALWAYS);
        grouping.setGroupAllowUnbalanced(true);
        getOptions().setRowGroupingOptions(grouping);
    }
}
```

### Region → Product Grouping

```java
RowGroupingOptions grouping = new RowGroupingOptions();

grouping.setRowGroupingHierarchy(List.of(
    new RowGroupingHierarchyLevel("region"),
    new RowGroupingHierarchyLevel("product")
));

List<AgGridColumnDef<?>> columnDefs = List.of(
    new AgGridColumnDef<>("region").setRowGroup(true),
    new AgGridColumnDef<>("product").setRowGroup(true),
    new AgGridColumnDef<>("sales").setAggFunc(AggregationFunction.SUM),
    new AgGridColumnDef<>("units").setAggFunc(AggregationFunction.COUNT)
);

grid.getOptions().setColumnDefs(columnDefs);
grid.getOptions().setRowGroupingOptions(grouping);
```

---

## Integration with Other Features

### Row Grouping + Charts

Aggregate by group and render chart:

```java
grid.showRowGroupPanel()
    .enableCharts();

// User groups by region; chart shows sales per region
```

### Row Grouping + Server-Side Model

Lazy-load grouped data:

```java
grid.showRowGroupPanel()
    .useServerSideRowModel();

// Expand group → backend fetches group members on demand
```

### Row Grouping + Pivoting

Create pivot table from groups:

```java
grid.showRowGroupPanel();

PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);
pivoting.setPivotRowTotals(true);

grid.getOptions().setPivotingOptions(pivoting);
```

---

## Performance

### Optimization Tips

**Small Datasets (< 10K rows):**
```java
grouping.setRowGroupPanelShow(PanelShow.ALWAYS);  // Full UI
```

**Large Datasets (> 100K rows):**
```java
grouping.setRowGroupPanelShow(PanelShow.ONLY_WHEN_GROUPING);
grouping.setGroupAllowUnbalanced(false);  // Reduce memory
```

### Deep Hierarchies

Avoid hierarchies > 3 levels:
- ✅ Year → Quarter → Month (3 levels) — OK
- ❌ Year → Quarter → Month → Week → Day (5 levels) — Avoid

---

## Accessibility

- **Keyboard Navigation** — Arrow keys expand/collapse groups
- **Screen Reader Support** — Group nesting announced

---

## Testing

### Unit Test: Row Grouping

```java
@Test
void rowGroupingConfiguredCorrectly() {
    RowGroupingOptions grouping = new RowGroupingOptions();
    grouping.setRowGroupPanelShow(PanelShow.ALWAYS);
    
    String json = mapper.writeValueAsString(grouping);
    assertTrue(json.contains("\"rowGroupPanelShow\":\"always\""));
}
```

### Integration Test: Multi-Level Grouping

```java
@Test
void multiLevelGroupingWorks() {
    SalesHierarchyGrid grid = new SalesHierarchyGrid();
    
    RowGroupingOptions grouping = grid.getOptions().getRowGroupingOptions();
    assertNotNull(grouping.getRowGroupingHierarchy());
    assertEquals(3, grouping.getRowGroupingHierarchy().size());
}
```

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Groups not created | `rowGroup: true` not set | Verify columnDef setting |
| Panel not visible | Wrong PanelShow value | Set to ALWAYS for testing |
| Single-child parents visible | Parent hiding not configured | Set `groupHideParentOfSingleChild` |
| Null values missing | `groupAllowUnbalanced` = false | Set to true to include nulls |

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Row grouping terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Configuration examples
- [Pivot Tables](./pivot-tables-and-aggregation.rules.md) — Pivot mode with grouping
- [Server-Side Model](./server-side-row-model.rules.md) — Large dataset grouping

---

**End of row-grouping.rules.md**
