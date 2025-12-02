# advanced-filtering.rules.md — AG Grid Enterprise Advanced Filtering Configuration

**Configuration guide for advanced filtering, set filters, and custom predicates**

---

## Overview

**Advanced Filtering** provides multi-criteria filtering UI with set filters, multi-filters, and find filters for complex data queries.

### Key Concepts

- **Set Filter** — Select from predefined values
- **Multi-Filter** — Combine criteria with AND/OR logic
- **Find Filter** — Text search across values
- **Filter Predicate** — Custom boolean logic for row inclusion

---

## Configuration

### Enable Advanced Filtering

```java
AdvancedFilteringOptions advFilters = new AdvancedFilteringOptions();
advFilters.setAllowedCharPattern(".*");      // Allow all characters
advFilters.setCaseSensitive(false);          // Case-insensitive

grid.getOptions().setAdvancedFilteringOptions(advFilters);
```

### Set Filters

Allow users to select from column values:

```java
List<AgGridColumnDef<?>> columnDefs = List.of(
    new AgGridColumnDef<>("region")
        .setFilter("agSetColumnFilter")
        .setFilterParams(new SetFilterParams()
            .setValues(List.of("North", "South", "East", "West"))
        ),
    
    new AgGridColumnDef<>("status")
        .setFilter("agSetColumnFilter")
        .setFilterParams(new SetFilterParams()
            .setValues(List.of("Active", "Inactive", "Pending"))
        )
);

grid.getOptions().setColumnDefs(columnDefs);
```

### Multi-Filters

Combine multiple criteria:

```java
// Filter: (Dept = Sales OR Dept = Marketing) AND Year > 2023
grid.getOptions().setFilterModel(new FilterModel()
    .setDept(new SetColumnFilter()
        .setValues(List.of("Sales", "Marketing"))
    )
    .setYear(new NumberColumnFilter()
        .setType(">")
        .setFilter(2023)
    )
);
```

### Find Filters

Text search across column values:

```java
new AgGridColumnDef<>("customerName")
    .setFilter("agTextColumnFilter")
    .setFilterParams(new TextFilterParams()
        .setDefaultOption("contains")
    )
```

---

## Custom Filter Predicates

Implement custom filtering logic:

```java
new AgGridColumnDef<>("sales")
    .setFilterFunction(params -> {
        double sales = (double) params.getValue();
        // Only show high-value sales
        return sales > 100000;
    })
```

---

## Integration with Other Features

### Filtering + Server-Side Model

Backend applies filters:

```java
grid.useServerSideRowModel();

// Filter params passed to DataSource
// Backend applies WHERE clause to query
```

### Filtering + Row Grouping

Filters apply before grouping:

```java
grid.showRowGroupPanel();

// Filter rows first, then group results
```

---

## Testing

### Unit Test: Advanced Filtering

```java
@Test
void advancedFilteringConfigured() {
    AdvancedFilteringOptions advFilters = new AdvancedFilteringOptions();
    advFilters.setCaseSensitive(false);
    
    String json = mapper.writeValueAsString(advFilters);
    assertTrue(json.contains("\"caseSensitive\":false"));
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Filtering terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Filter examples
- [Server-Side Model](./server-side-row-model.rules.md) — Backend filtering

---

**End of advanced-filtering.rules.md**
