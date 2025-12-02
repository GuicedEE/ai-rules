# server-side-row-model-example.md — Complete Example: Server-Side Row Model with 1M+ Rows

**A complete, working example showing lazy-loaded large dataset with server-side row model**

---

## Setup

### 1. Backend DataSource Implementation

```java
@Service
public class LargeDatasetDataSource implements ServerSideDataSource {
    private SalesRepository repo;
    private static final Logger logger = LoggerFactory.getLogger(
        LargeDatasetDataSource.class);
    
    @Override
    public GetRowsResponse getRows(GetRowsParams params) {
        try {
            int startRow = params.getStartRow();
            int endRow = params.getEndRow();
            int pageSize = endRow - startRow;
            
            // Parse sort model
            List<SortModel> sorts = params.getSortModel();
            Map<String, SortDirection> sortMap = new HashMap<>();
            for (SortModel sort : sorts) {
                sortMap.put(sort.getColId(), 
                    "asc".equals(sort.getSort()) 
                        ? SortDirection.ASC 
                        : SortDirection.DESC
                );
            }
            
            // Parse filter model
            Map<String, ColumnFilter> filters = params.getFilterModel();
            Map<String, String> filterMap = new HashMap<>();
            if (filters != null) {
                for (String colId : filters.keySet()) {
                    filterMap.put(colId, filters.get(colId).getFilter());
                }
            }
            
            logger.debug("Fetching rows {} to {} with filters: {}", 
                startRow, endRow, filterMap);
            
            // Fetch from database with pagination
            long startTime = System.currentTimeMillis();
            List<SalesRow> rows = repo.findRows(
                startRow, 
                pageSize, 
                sortMap, 
                filterMap
            );
            long elapsed = System.currentTimeMillis() - startTime;
            
            logger.debug("Fetched {} rows in {}ms", rows.size(), elapsed);
            
            // Get total count (cached if possible)
            int totalCount = repo.countTotal(filterMap);
            
            // Return response
            GetRowsResponse response = new GetRowsResponse();
            response.setRowData(rows);
            response.setRowCount(totalCount);
            return response;
            
        } catch (Exception e) {
            logger.error("Error fetching rows", e);
            return new GetRowsResponse()
                .setRowData(List.of())
                .setRowCount(0);
        }
    }
}
```

### 2. Repository Implementation

```java
@Repository
public class SalesRepository {
    private EntityManager em;
    
    public List<SalesRow> findRows(int offset, int limit,
            Map<String, SortDirection> sorts,
            Map<String, String> filters) {
        
        StringBuilder jpql = new StringBuilder(
            "SELECT s FROM SalesRow s WHERE 1=1");
        Map<String, Object> params = new HashMap<>();
        
        // Add filters
        if (filters.containsKey("region")) {
            jpql.append(" AND s.region = :region");
            params.put("region", filters.get("region"));
        }
        if (filters.containsKey("year")) {
            jpql.append(" AND s.year >= :year");
            params.put("year", Integer.parseInt(filters.get("year")));
        }
        
        // Add sorting
        jpql.append(" ORDER BY");
        boolean first = true;
        for (Map.Entry<String, SortDirection> sort : sorts.entrySet()) {
            if (!first) jpql.append(",");
            jpql.append(" s.")
                .append(sort.getKey())
                .append(" ").append(sort.getValue());
            first = false;
        }
        
        // Execute with pagination
        TypedQuery<SalesRow> query = em.createQuery(jpql.toString(), 
            SalesRow.class);
        
        for (Map.Entry<String, Object> param : params.entrySet()) {
            query.setParameter(param.getKey(), param.getValue());
        }
        
        return query
            .setFirstResult(offset)
            .setMaxResults(limit)
            .getResultList();
    }
    
    public int countTotal(Map<String, String> filters) {
        StringBuilder jpql = new StringBuilder(
            "SELECT COUNT(s) FROM SalesRow s WHERE 1=1");
        Map<String, Object> params = new HashMap<>();
        
        // Add filters (same as findRows)
        if (filters.containsKey("region")) {
            jpql.append(" AND s.region = :region");
            params.put("region", filters.get("region"));
        }
        
        TypedQuery<Long> query = em.createQuery(jpql.toString(), 
            Long.class);
        
        for (Map.Entry<String, Object> param : params.entrySet()) {
            query.setParameter(param.getKey(), param.getValue());
        }
        
        return query.getSingleResult().intValue();
    }
}
```

### 3. Grid Component

```java
public class LargeDatasetGrid extends AgGridEnterprise<LargeDatasetGrid> {
    public LargeDatasetGrid() {
        setID("largeDatasetGrid");
        
        // Enable server-side row model for 1M+ rows
        useServerSideRowModel()
            .sideBarFiltersAndColumns()
            .enableRangeSelection();
        
        // Configure grid options
        setupColumns();
        configureServerSideModel();
        configureStatusBar();
    }
    
    private void setupColumns() {
        List<AgGridColumnDef<?>> columnDefs = List.of(
            new AgGridColumnDef<>("id")
                .setHeaderName("ID")
                .setWidth(80),
            
            new AgGridColumnDef<>("region")
                .setHeaderName("Region")
                .setFilter("agSetColumnFilter")
                .setWidth(100),
            
            new AgGridColumnDef<>("product")
                .setHeaderName("Product")
                .setFilter("agTextColumnFilter")
                .setWidth(120),
            
            new AgGridColumnDef<>("sales")
                .setHeaderName("Sales")
                .setValueFormatter("$#,###.##")
                .setWidth(120),
            
            new AgGridColumnDef<>("year")
                .setHeaderName("Year")
                .setFilter("agNumberColumnFilter")
                .setWidth(80)
        );
        
        getOptions().setColumnDefs(columnDefs);
    }
    
    private void configureServerSideModel() {
        ServerSideRowModelOptions serverSide = new ServerSideRowModelOptions();
        serverSide.setRowModelType(RowModelType.SERVER_SIDE);
        serverSide.setCacheBlockSize(50);      // 50 rows per block
        serverSide.setMaxBlocksInCache(5);     // 5 blocks max (~250 rows)
        serverSide.setPurgeClosedRowNodes(true);  // Free memory on close
        
        getOptions().setServerSideOptions(serverSide);
        
        // Pagination
        getOptions().setPagination(true);
        getOptions().setPaginationPageSize(50);
    }
    
    private void configureStatusBar() {
        List<StatusBarPanelDef> statusPanels = List.of(
            new StatusBarPanelDef().setKey("totalAndFiltered"),
            new StatusBarPanelDef().setKey("selectedCount")
        );
        
        StatusBarOptions statusBar = new StatusBarOptions();
        statusBar.setStatusPanels(statusPanels);
        
        getOptions().setStatusBarOptions(statusBar);
    }
}
```

### 4. Data Model

```java
@Entity
@Table(name = "sales")
public class SalesRow {
    @Id
    private Long id;
    
    @Column(name = "region")
    private String region;
    
    @Column(name = "product")
    private String product;
    
    @Column(name = "sales")
    private BigDecimal sales;
    
    @Column(name = "year")
    private Integer year;
    
    // Getters/Setters (or use Lombok @Data)
}
```

---

## Usage Workflow

### Step 1: Create Grid

```java
LargeDatasetGrid grid = new LargeDatasetGrid();
page.add(grid);
```

### Step 2: Data Loading

1. Grid initializes with empty viewport
2. User scrolls → Grid requests block from backend
3. Backend queries database (pagination + filter/sort)
4. Rows rendered as they arrive
5. Old blocks purged from cache to free memory

### Step 3: User Interactions

- **Filter** — Click Filters in side bar; backend re-queries with WHERE clause
- **Sort** — Click column header; backend applies ORDER BY
- **Scroll** — Grid lazy-loads next block on demand
- **Select Range** — Copy to clipboard (visible rows only)

---

## Performance Metrics

### Configuration for 1M+ Rows

| Parameter | Value | Impact |
|-----------|-------|--------|
| Block Size | 50 | 50 rows per request |
| Max Cache | 5 | ~250 rows in memory |
| Pagination | true | Page-based navigation |
| Purge on Close | true | Memory freed when scrolled away |

**Result:**
- Grid init: < 500ms (empty)
- First block load: 200–500ms
- Scroll response: 100–200ms per block
- Memory usage: ~10MB (50 rows × 8 cache) + overhead

### Database Optimization

Create indexes for common filters:

```sql
CREATE INDEX idx_region ON sales(region);
CREATE INDEX idx_year ON sales(year);
CREATE INDEX idx_product ON sales(product);
```

### Query Performance

Sample query:
```sql
SELECT * FROM sales 
WHERE region = 'North' 
ORDER BY year DESC 
LIMIT 50 OFFSET 0;
-- Expected: < 100ms with index
```

---

## Testing

### Unit Test

```java
@Test
void serverSideModelConfigured() {
    LargeDatasetGrid grid = new LargeDatasetGrid();
    
    ServerSideRowModelOptions serverSide = 
        grid.getOptions().getServerSideOptions();
    
    assertNotNull(serverSide);
    assertEquals(RowModelType.SERVER_SIDE, 
        serverSide.getRowModelType());
    assertEquals(50, serverSide.getCacheBlockSize());
}
```

### Integration Test

```java
@Test
void dataSourceReturnsRows() {
    LargeDatasetDataSource source = new LargeDatasetDataSource();
    
    GetRowsParams params = new GetRowsParams();
    params.setStartRow(0);
    params.setEndRow(50);
    
    GetRowsResponse response = source.getRows(params);
    
    assertNotNull(response.getRowData());
    assertEquals(50, response.getRowData().size());
    assertTrue(response.getRowCount() > 0);
}
```

---

## Troubleshooting

### Issue: Rows not loading

**Symptom:** Grid shows no data  
**Cause:** DataSource not registered  
**Solution:** Verify `setServerSideDataSource()` called in page configurator

### Issue: Slow scrolling

**Symptom:** Lag when scrolling  
**Cause:** Block size too small or database slow  
**Solution:** 
- Increase `cacheBlockSize` to 100
- Create database indexes on filter columns
- Profile query: `EXPLAIN SELECT ...`

### Issue: Memory growing

**Symptom:** Browser memory usage increasing  
**Cause:** Cache not purging  
**Solution:** Set `purgeClosedRowNodes(true)`

---

## See Also

- [server-side-row-model.rules.md](../server-side-row-model.rules.md) — Full config guide
- [README.md](../README.md) — Parent enterprise features index
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) — Performance checklist

---

**End of server-side-row-model-example.md**
