# Data Binding Rules

**Fetch, update, and bind data to the grid**

---

## Overview

Data binding in AgGrid connects server-side data sources to the grid via the `fetchData()` pattern and real-time updates via WebSocket.

---

## fetchData Pattern

### Core Concept

The `fetchData()` method is called by the grid or via WebSocket to retrieve row data. It must be non-blocking (return `Uni<List<T>>` or `CompletableFuture<List<T>>`).

### Implementation

```java
public class OrdersGrid extends AgGrid<OrdersGrid> {
    
    @Inject
    private OrderService orderService;
    
    public Uni<List<OrderRecord>> fetchData() {
        // Reactive data fetch
        return orderService.findAllOrders();
    }
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("600px")
            .enablePagination(20)
            .bindRowData("orders");
    }
}
```

### With Pagination

```java
public class OrdersGrid extends AgGrid<OrdersGrid> {
    
    @Inject
    private OrderService orderService;
    
    private int pageIndex = 0;
    private int pageSize = 20;
    
    public Uni<List<OrderRecord>> fetchData() {
        int offset = pageIndex * pageSize;
        return orderService.findOrders(offset, pageSize);
    }
    
    public Uni<Integer> getTotalCount() {
        return orderService.countAllOrders();
    }
    
    public void setPageIndex(int index) {
        this.pageIndex = index;
    }
}
```

### With Filtering & Sorting

```java
public class EmployeesGrid extends AgGrid<EmployeesGrid> {
    
    @Inject
    private EmployeeRepository employeeRepository;
    
    private String filterDepartment;
    private String sortBy = "name";
    private boolean sortAscending = true;
    
    public Uni<List<EmployeeRecord>> fetchData() {
        var spec = new EmployeeSearchSpec()
            .setDepartmentFilter(filterDepartment)
            .setSortBy(sortBy)
            .setSortDirection(sortAscending ? "ASC" : "DESC");
        
        return employeeRepository.search(spec);
    }
    
    public void setFilterDepartment(String dept) {
        this.filterDepartment = dept;
    }
    
    public void setSortBy(String column) {
        this.sortBy = column;
    }
}
```

---

## WebSocket Integration

### Real-Time Updates

When server-side data changes, push updates to all connected grids via WebSocket.

```java
@Log4j2
public class OrdersGrid extends AgGrid<OrdersGrid> {
    
    @Inject
    private OrderService orderService;
    
    public Uni<List<OrderRecord>> fetchData() {
        return orderService.findAllOrders();
    }
    
    @Override
    protected void init() {
        super.init();
        
        // Register WebSocket listener for order updates
        this.setHeight("600px")
            .enablePagination(20)
            .bindRowData("orders");
        
        // Listen for 'OrderUpdated' events from server
        IGuicedWebSocket.get(OrderUpdateReceiver.class)
            .subscribe(message -> {
                // Refresh grid data when order changes
                Uni.createFrom().item(fetchData())
                    .subscribe().asCompletionStage();
            });
        
        log.info("Registered OrdersGrid WebSocket listeners");
    }
}
```

### WebSocket Receiver

```java
@Log4j2
public class OrderUpdateReceiver extends WebSocketAbstractCallReceiver<OrdersGrid> {
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String orderId = (String) call.getParameters().get("orderId");
            String action = (String) call.getParameters().get("action");
            
            log.info("Order {} : {}", orderId, action);
            
            // Fetch updated data
            OrdersGrid grid = IGuiceContext.get(OrdersGrid.class);
            var updatedOrders = grid.fetchData();
            
            // Broadcast to all connected clients
            response.addDataResponse("ordersUpdated", updatedOrders);
            
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error processing order update", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

---

## Pagination

### Client-Side Pagination

Grid handles pagination internally; server provides all rows.

```java
grid.enablePagination(25)  // 25 rows per page
    .bindRowData("allRows");
```

### Server-Side Pagination

Server provides only the requested page; more efficient for large datasets.

```java
public class LargeDatasetGrid extends AgGrid<LargeDatasetGrid> {
    
    @Inject
    private DataRepository repository;
    
    private int currentPage = 1;
    private final int PAGE_SIZE = 50;
    
    public Uni<PagedResult<DataRecord>> fetchData() {
        return repository.findPage(currentPage, PAGE_SIZE);
    }
    
    public void nextPage() {
        currentPage++;
        Uni.createFrom().item(fetchData())
            .subscribe().asCompletionStage();
    }
    
    public void previousPage() {
        if (currentPage > 1) {
            currentPage--;
            Uni.createFrom().item(fetchData())
                .subscribe().asCompletionStage();
        }
    }
}
```

---

## Virtual Scrolling

For extremely large datasets (100K+ rows), use virtual scrolling with lazy loading.

```java
public class VirtualScrollGrid extends AgGrid<VirtualScrollGrid> {
    
    @Inject
    private LargeDatasetRepository repository;
    
    private final int LAZY_LOAD_SIZE = 50;
    private int lastRequestedIndex = 0;
    
    public Uni<List<Record>> fetchData(int startRow, int endRow) {
        return repository.findBetween(startRow, endRow, LAZY_LOAD_SIZE);
    }
    
    @Override
    protected void init() {
        super.init();
        
        // Enable virtual scrolling
        this.gridOptions.put("rowBuffer", 10);
        this.gridOptions.put("enableCellTextSelection", false);
        
        this.setHeight("800px")
            .bindRowData("lazyLoadedRows");
    }
}
```

---

## Filtering & Sorting Sync

### Client-Side Filtering/Sorting

Grid handles filter/sort internally; refresh data when needed.

```java
public class SmartGrid extends AgGrid<SmartGrid> {
    
    @Inject
    private DataService dataService;
    
    private String currentFilter = "";
    private String currentSort = "name";
    
    public void onFilterChanged(String filterText) {
        this.currentFilter = filterText;
        refreshData();
    }
    
    public void onSortChanged(String column) {
        this.currentSort = column;
        refreshData();
    }
    
    private void refreshData() {
        dataService.search(currentFilter, currentSort)
            .subscribe().asCompletionStage();
    }
}
```

### Server-Side Filtering/Sorting

Server performs filtering and sorting for better performance on large datasets.

```java
public class ServerFilteredGrid extends AgGrid<ServerFilteredGrid> {
    
    @Inject
    private QueryService queryService;
    
    public Uni<List<Record>> fetchData(String filterCriteria, String sortColumn) {
        var query = new QuerySpec()
            .setFilter(filterCriteria)
            .setOrderBy(sortColumn)
            .setLimit(100);
        
        return queryService.execute(query);
    }
    
    @Override
    protected void init() {
        super.init();
        
        this.enableServerSideFiltering = true;
        this.enableServerSideSorting = true;
    }
}
```

---

## Data Refresh Patterns

### Manual Refresh

```java
public void refreshGrid() {
    Uni.createFrom().item(fetchData())
        .subscribe().asCompletionStage();
}
```

### Scheduled Refresh

```java
@Log4j2
public class AutoRefreshGrid extends AgGrid<AutoRefreshGrid> {
    
    @Inject
    private DataService dataService;
    
    private ScheduledExecutorService scheduler;
    
    @Override
    protected void init() {
        super.init();
        
        scheduler = Executors.newScheduledThreadPool(1);
        
        // Refresh every 30 seconds
        scheduler.scheduleAtFixedRate(
            () -> {
                try {
                    Uni.createFrom().item(fetchData())
                        .subscribe().asCompletionStage();
                } catch (Exception e) {
                    log.error("Grid refresh error", e);
                }
            },
            0,
            30,
            TimeUnit.SECONDS
        );
        
        log.info("Scheduled auto-refresh every 30 seconds");
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (scheduler != null) {
            scheduler.shutdown();
        }
    }
}
```

---

## Error Handling

```java
public Uni<List<OrderRecord>> fetchData() {
    return orderService.findAllOrders()
        .onFailure().invoke(error -> {
            log.error("Failed to fetch orders: {}", error.getMessage());
            // Notify UI of error
        })
        .onFailure().recoverWithUni(error -> {
            log.warn("Retrying order fetch...");
            return orderService.findAllOrders();
        });
}
```

---

## Best Practices

### ✅ DO

- Make `fetchData()` non-blocking (return `Uni<T>`)
- Use pagination for datasets > 1000 rows
- Implement proper error handling and logging
- Cache data when appropriate
- Clean up resources (schedulers, listeners) in `onDestroy()`

### ❌ DO NOT

- Make blocking database calls in `fetchData()`
- Fetch more data than necessary
- Update grid rows synchronously
- Ignore pagination/sorting parameters
- Leave listeners/schedulers without cleanup

---

## Related Documents

- **[Grid Configuration](./grid-configuration.rules.md)** — Pagination options
- **[WebSocket Integration](./websocket-integration.rules.md)** — Real-time updates
- **[Event Handling](./event-handling.rules.md)** — Listen to grid events
- **[Vert.x 5](../../../backend/vertx/README.md)** — Async/reactive patterns
