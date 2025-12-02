# server-side-row-model.rules.md — AG Grid Enterprise Server-Side Row Model

**Configuration guide for loading and managing large datasets efficiently**

---

## Overview

The **Server-Side Row Model** enables lazy-loading of large datasets from a backend service. Instead of loading all rows at once, the grid requests data in blocks as needed.

### Key Concepts

- **Block Loading** — Fetch rows in chunks (e.g., 50 rows per request)
- **Block Caching** — In-memory cache of recently fetched blocks
- **Lazy-Loading** — Load only visible rows; free memory when scrolled away
- **Backend DataSource** — Service providing row blocks on-demand

---

## Configuration

### Enable Server-Side Row Model

```java
public class MyGrid extends AgGridEnterprise<MyGrid> {
    public MyGrid() {
        setID("myGrid");
        useServerSideRowModel();  // Fluent API
    }
}
```

### Block Size Configuration

```java
ServerSideRowModelOptions serverSide = new ServerSideRowModelOptions();
serverSide.setRowModelType(RowModelType.SERVER_SIDE);
serverSide.setCacheBlockSize(50);      // Rows per request
serverSide.setMaxBlocksInCache(5);     // Max cached blocks
serverSide.setPurgeClosedRowNodes(true);  // Free memory on collapse

grid.getOptions().setServerSideOptions(serverSide);
```

**Configuration Reference:**

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| `rowModelType` | RowModelType | SERVER_SIDE | Data loading strategy |
| `cacheBlockSize` | int | 100 | Rows per request block |
| `maxBlocksInCache` | int | 2 | Max in-memory blocks |
| `purgeClosedRowNodes` | boolean | false | Free memory on collapse |

---

## DataSource Integration

Implement custom DataSource to provide row blocks:

```java
public class MyDataSource implements ServerSideDataSource {
    private MyRepository repo;
    
    @Override
    public GetRowsResponse getRows(GetRowsParams params) {
        // Parse request
        int blockStart = params.getStartRow();
        int blockEnd = params.getEndRow();
        
        // Fetch from backend
        List<MyData> rows = repo.findRows(blockStart, blockEnd);
        int totalCount = repo.countTotal();
        
        // Return response
        GetRowsResponse response = new GetRowsResponse();
        response.setRowData(rows);
        response.setRowCount(totalCount);
        return response;
    }
}
```

### Register DataSource

```java
grid.getOptions().setServerSideDataSource(new MyDataSource());
```

---

## Block Caching Strategy

### Small Datasets (10K – 100K rows)

```java
serverSide.setCacheBlockSize(50);
serverSide.setMaxBlocksInCache(5);   // ~250 rows in cache
```

### Large Datasets (> 1M rows)

```java
serverSide.setCacheBlockSize(100);
serverSide.setMaxBlocksInCache(3);   // ~300 rows in cache
serverSide.setPurgeClosedRowNodes(true);  // Aggressive purging
```

---

## Pagination

Use pagination with server-side model for structured navigation:

```java
ServerSideRowModelOptions serverSide = new ServerSideRowModelOptions();
serverSide.setCacheBlockSize(25);  // Rows per page

grid.getOptions().setPagination(true);
grid.getOptions().setPaginationPageSize(25);
grid.getOptions().setServerSideOptions(serverSide);
```

---

## Sorting & Filtering

Backend must handle sort/filter params:

```java
@Override
public GetRowsResponse getRows(GetRowsParams params) {
    // Parse sort model
    List<SortModel> sorts = params.getSortModel();
    
    // Parse filter model
    Map<String, ColumnFilter> filters = params.getFilterModel();
    
    // Apply to query
    Query query = repo.createQuery();
    for (SortModel sort : sorts) {
        query.orderBy(sort.getColId(), sort.getSort());
    }
    for (String colId : filters.keySet()) {
        query.where(colId, filters.get(colId).getFilter());
    }
    
    // Fetch and return
    List<MyData> rows = query.fetch(
        params.getStartRow(),
        params.getEndRow() - params.getStartRow()
    );
    
    return new GetRowsResponse()
        .setRowData(rows)
        .setRowCount(query.countTotal());
}
```

---

## Integration with Other Features

### Server-Side Model + Row Grouping

Lazy-load group members:

```java
grid.showRowGroupPanel()
    .useServerSideRowModel();

// User expands group → DataSource fetches group members
```

### Server-Side Model + Pivot

Server-side pivot aggregation:

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);

grid.getOptions().setPivotingOptions(pivoting);
grid.useServerSideRowModel();

// Backend performs pivot aggregation
```

---

## Performance Optimization

### Database Indexing

Create indexes for common queries:

```sql
CREATE INDEX idx_region ON sales(region);
CREATE INDEX idx_date ON sales(date);
CREATE INDEX idx_amount ON sales(amount);
```

### Query Optimization

Use database query plans to optimize:

```sql
EXPLAIN SELECT * FROM sales WHERE region = 'North' LIMIT 50;
```

### Caching Strategy

- **Frequently accessed blocks** — Keep in cache (cache size = 5–10 blocks)
- **Infrequently accessed blocks** — Purge quickly
- **Sorted/filtered results** — Cache may be invalidated; clear cache on sort/filter change

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Data not loading | DataSource not registered | Verify `setServerSideDataSource()` called |
| Rows repeating | Cache not purged | Set `purgeClosedRowNodes(true)` |
| Slow performance | Block size too small | Increase `cacheBlockSize` to 50–100 |
| Memory growing | Cache too large | Reduce `maxBlocksInCache` to 3–5 |
| Sorting not working | Backend not applying sort | Verify sort params passed to query |

---

## Testing

### Unit Test: Server-Side Options

```java
@Test
void serverSideOptionsConfigured() {
    ServerSideRowModelOptions opts = new ServerSideRowModelOptions();
    opts.setRowModelType(RowModelType.SERVER_SIDE);
    opts.setCacheBlockSize(50);
    
    String json = mapper.writeValueAsString(opts);
    assertTrue(json.contains("\"rowModelType\":\"serverSide\""));
}
```

### Integration Test: DataSource

```java
@Test
void dataSourceReturnsRows() {
    MyDataSource source = new MyDataSource();
    
    GetRowsParams params = new GetRowsParams();
    params.setStartRow(0);
    params.setEndRow(50);
    
    GetRowsResponse response = source.getRows(params);
    
    assertNotNull(response.getRowData());
    assertTrue(response.getRowData().size() <= 50);
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Server-side model terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Configuration templates
- [Row Grouping](./row-grouping.rules.md) — Grouping with server-side model
- [Advanced Filtering](./advanced-filtering.rules.md) — Filtering at backend

---

**End of server-side-row-model.rules.md**
