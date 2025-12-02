# Performance Optimization Rules

**Achieve <500ms grid init, <200ms WebSocket latency, 50+ updates/sec**

---

## Overview

AG Grid performance targets (from PACT.md NRRs):
- **Grid initialization**: <500ms
- **WebSocket latency**: <200ms per update
- **Update throughput**: 50+ updates/sec
- **Virtual scrolling**: Support 10,000+ rows without lag

---

## Virtual Scrolling & Pagination

### Server-Side Pagination

```java
@RestController
@RequestMapping("/api/grid/{gridId}")
public class GridController {
  
  @GetMapping("/data")
  public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> getGridData(
    @PathVariable String gridId,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "50") int pageSize,
    @RequestParam(required = false) String sort,
    @RequestParam(required = false) String filter
  ) {
    // Parse sort model: "colId:asc,colId2:desc"
    List<Sort.Order> orders = parseSortModel(sort);
    
    // Parse filter model: "colId:eq:value,colId2:gte:100"
    Specification<OrderRow> spec = parseFilterModel(filter);
    
    // Paginated query
    Pageable pageable = PageRequest.of(page, pageSize, Sort.by(orders));
    Page<OrderRow> result = orderRepository.findAll(spec, pageable);
    
    return ResponseEntity.ok(new AjaxResponse<>(
      new PagedResponse<>(
        result.getContent(),
        result.getNumber(),
        result.getSize(),
        result.getTotalElements(),
        result.getTotalPages(),
        result.hasNext()
      )
    ));
  }
  
  private List<Sort.Order> parseSortModel(String sort) {
    if (sort == null || sort.isEmpty()) return List.of();
    return Arrays.stream(sort.split(","))
      .map(s -> {
        String[] parts = s.split(":");
        return new Sort.Order(
          "desc".equals(parts[1]) ? Sort.Direction.DESC : Sort.Direction.ASC,
          parts[0]
        );
      })
      .toList();
  }
  
  private Specification<OrderRow> parseFilterModel(String filter) {
    if (filter == null || filter.isEmpty()) 
      return Specification.where(null);
    
    // Example: "status:eq:PENDING,amount:gte:100"
    String[] conditions = filter.split(",");
    Specification<OrderRow> spec = Specification.where(null);
    
    for (String condition : conditions) {
      String[] parts = condition.split(":");
      String field = parts[0];
      String operator = parts[1];
      String value = parts[2];
      
      spec = spec.and((root, query, cb) -> {
        switch (operator) {
          case "eq" -> {
            if ("true".equals(value) || "false".equals(value)) {
              return cb.equal(root.get(field), Boolean.parseBoolean(value));
            } else if (value.matches("\\d+")) {
              return cb.equal(root.get(field), Long.parseLong(value));
            }
            return cb.equal(root.get(field), value);
          }
          case "gte" -> {
            if (value.matches("\\d+(\\.\\d+)?")) {
              return cb.ge(root.get(field), Double.parseDouble(value));
            }
            return cb.greaterThanOrEqualTo(root.get(field), value);
          }
          case "lte" -> {
            if (value.matches("\\d+(\\.\\d+)?")) {
              return cb.le(root.get(field), Double.parseDouble(value));
            }
            return cb.lessThanOrEqualTo(root.get(field), value);
          }
          case "like" -> {
            return cb.like(root.get(field), "%" + value + "%");
          }
          default -> throw new IllegalArgumentException("Unknown operator: " + operator);
        }
      });
    }
    
    return spec;
  }
}

// Response model
@Data
@AllArgsConstructor
public class PagedResponse<T> {
  private List<T> content;
  private int page;
  private int pageSize;
  private long totalElements;
  private int totalPages;
  private boolean hasMore;
}
```

### TypeScript Datasource Configuration

```typescript
import { IServerSideDatasource, IGetRowsParams, IGetRowsResult } from 'ag-grid-community';
import { GridDataService } from './grid-data.service';

export class ServerSideDatasource implements IServerSideDatasource {
  constructor(private gridService: GridDataService) {}
  
  getRows(params: IGetRowsParams): Promise<IGetRowsResult> {
    const page = Math.floor(params.startRow / params.endRow);
    const pageSize = params.endRow - params.startRow;
    
    // Serialize sort model: "colId:asc,colId2:desc"
    const sortString = params.sortModel
      .map(m => `${m.colId}:${m.sort}`)
      .join(',');
    
    // Serialize filter model
    const filterString = Object.entries(params.filterModel || {})
      .map(([colId, condition]) => `${colId}:eq:${condition.filter}`)
      .join(',');
    
    return this.gridService.fetchGridData(page, pageSize, sortString, filterString)
      .toPromise()
      .then(response => ({
        rowData: response.response.content,
        rowCount: response.response.totalElements,
        lastRow: !response.response.hasMore ? response.response.totalElements : -1
      }))
      .catch(error => {
        console.error('Failed to fetch grid data:', error);
        return { rowData: [], rowCount: 0 };
      });
  }
}

// Grid configuration
gridOptions = {
  rowModelType: 'serverSide',
  cacheBlockSize: 50, // Fetch 50 rows at a time
  paginationPageSize: 50,
  datasource: new ServerSideDatasource(this.gridService),
  onGridReady: (params) => {
    params.api.setSuppressRowTransformOnNextSort();
  }
};
```

---

## WebSocket Batch Updates

### Server-Side Batch Emission

```java
@Component
public class GridUpdateBatcher {
  
  private static final int BATCH_SIZE = 100;
  private static final long BATCH_INTERVAL_MS = 100; // Emit every 100ms
  
  private final BlockingQueue<GridUpdate<?>> updateQueue = 
    new LinkedBlockingQueue<>();
  private final SimpMessagingTemplate messagingTemplate;
  
  @PostConstruct
  public void start() {
    new Thread(this::batchProcessor, "GridUpdateBatcher").start();
  }
  
  public void queueUpdate(String gridId, GridUpdate<?> update) {
    updateQueue.offer(update);
  }
  
  private void batchProcessor() {
    List<GridUpdate<?>> batch = new ArrayList<>();
    long lastEmit = System.currentTimeMillis();
    
    while (true) {
      try {
        // Collect updates for BATCH_INTERVAL_MS or until batch is full
        GridUpdate<?> update = updateQueue.poll(BATCH_INTERVAL_MS, TimeUnit.MILLISECONDS);
        
        if (update != null) {
          batch.add(update);
        }
        
        long elapsed = System.currentTimeMillis() - lastEmit;
        
        // Emit if batch is full or interval elapsed
        if (batch.size() >= BATCH_SIZE || (elapsed >= BATCH_INTERVAL_MS && !batch.isEmpty())) {
          emitBatch(batch);
          batch.clear();
          lastEmit = System.currentTimeMillis();
        }
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        break;
      }
    }
  }
  
  private void emitBatch(List<GridUpdate<?>> batch) {
    // Group updates by gridId
    Map<String, List<GridUpdate<?>>> byGrid = batch.stream()
      .collect(Collectors.groupingBy(GridUpdate::getGridId));
    
    for (Map.Entry<String, List<GridUpdate<?>>> entry : byGrid.entrySet()) {
      String gridId = entry.getKey();
      List<GridUpdate<?>> updates = entry.getValue();
      
      messagingTemplate.convertAndSend(
        "/topic/grid/" + gridId,
        new BatchUpdateMessage(updates)
      );
    }
  }
}

@Data
@AllArgsConstructor
public class BatchUpdateMessage {
  private List<GridUpdate<?>> updates;
  private long timestamp = System.currentTimeMillis();
}
```

### Client-Side Batch Processing

```typescript
export class GridUpdateProcessor {
  private updateBuffer: IGridUpdate<any>[] = [];
  private flushTimer: any;
  private readonly FLUSH_INTERVAL_MS = 50;
  
  constructor(private gridApi: GridApi) {}
  
  processUpdate(update: IGridUpdate<any>): void {
    this.updateBuffer.push(update);
    
    // Reset flush timer
    if (this.flushTimer) clearTimeout(this.flushTimer);
    
    // Flush if buffer full
    if (this.updateBuffer.length >= 100) {
      this.flushBuffer();
    } else {
      // Schedule flush
      this.flushTimer = setTimeout(() => this.flushBuffer(), this.FLUSH_INTERVAL_MS);
    }
  }
  
  private flushBuffer(): void {
    if (this.updateBuffer.length === 0) return;
    
    // Batch grid updates for performance
    this.gridApi.batchUpdateStart();
    
    for (const update of this.updateBuffer) {
      switch (update.type) {
        case 'ADD':
          this.gridApi.applyTransaction({ add: update.rows });
          break;
        case 'UPDATE':
          this.gridApi.applyTransaction({ update: update.rows });
          break;
        case 'REMOVE':
          this.gridApi.applyTransaction({ remove: update.rows });
          break;
        case 'REFRESH':
          this.gridApi.redrawRows({ rowNodes: this.gridApi.getRenderedNodes() });
          break;
      }
    }
    
    this.gridApi.batchUpdateStop();
    
    // Clear buffer
    this.updateBuffer = [];
    if (this.flushTimer) clearTimeout(this.flushTimer);
  }
}
```

---

## Memory Management

### Prevent Memory Leaks

```typescript
// Bad: Memory leak
export class GridComponent implements AfterViewInit {
  private subscription: Subscription;
  
  ngAfterViewInit(): void {
    // Subscribes forever, never unsubscribed
    this.gridService.gridUpdates$.subscribe(update => {
      this.gridApi.applyTransaction({ update: [update.row] });
    });
  }
}

// Good: Proper cleanup
export class GridComponent implements AfterViewInit, OnDestroy {
  private subscription: Subscription;
  private destroy$ = new Subject<void>();
  
  ngAfterViewInit(): void {
    this.subscription = this.gridService.gridUpdates$
      .pipe(takeUntil(this.destroy$))
      .subscribe(update => {
        this.gridApi.applyTransaction({ update: [update.row] });
      });
  }
  
  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
    this.destroy$.next();
    this.destroy$.complete();
    this.gridApi?.destroy();
  }
}
```

### Limit DOM Elements

```java
// Server-side: Always paginate, never fetch all rows
@GetMapping("/data")
public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> getGridData(
  @RequestParam(defaultValue = "0") int page,
  @RequestParam(defaultValue = "50") int pageSize
) {
  // Enforce maximum page size
  if (pageSize > 1000) {
    pageSize = 1000;
  }
  
  // Never return unbounded results
  Page<OrderRow> result = orderRepository.findAll(
    PageRequest.of(page, pageSize)
  );
  
  return ResponseEntity.ok(new AjaxResponse<>(
    new PagedResponse<>(
      result.getContent(),
      page,
      pageSize,
      result.getTotalElements(),
      result.getTotalPages(),
      result.hasNext()
    )
  ));
}
```

---

## Grid Initialization Performance

### Lazy Load Grid Definition

```typescript
export class GridInitializer {
  
  async initializeGrid(gridId: string): Promise<void> {
    // Step 1: Create empty grid (fast)
    const gridApi = await this.createEmptyGrid(gridId);
    
    // Step 2: Fetch column definitions (async)
    const columnDefs = await this.loadColumnDefs(gridId);
    
    // Step 3: Set columns
    gridApi.setColumnDefs(columnDefs);
    
    // Step 4: Fetch initial data
    const datasource = new ServerSideDatasource(this.gridService);
    gridApi.setGridOption('datasource', datasource);
    
    // Total: <500ms
  }
  
  private async createEmptyGrid(gridId: string): Promise<GridApi> {
    return new Promise(resolve => {
      const gridOptions: GridOptions = {
        rowModelType: 'serverSide',
        onGridReady: (params) => resolve(params.api)
      };
      
      const gridDiv = document.getElementById(gridId);
      new Grid(gridDiv, gridOptions);
    });
  }
  
  private async loadColumnDefs(gridId: string): Promise<ColDef[]> {
    const response = await this.http.get<IColumnDef[]>(`/api/grid/${gridId}/columns`).toPromise();
    return response || [];
  }
}
```

---

## Monitoring & Metrics

### Performance Metrics Collection

```typescript
export class GridPerformanceMonitor {
  
  private metrics = {
    initTime: 0,
    firstRenderTime: 0,
    dataFetchTimes: [] as number[],
    updateLatencies: [] as number[],
    wsLatencies: [] as number[]
  };
  
  monitorGridInit(gridApi: GridApi): void {
    const startTime = performance.now();
    
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.name.includes('grid')) {
          const duration = entry.duration;
          
          if (entry.name.includes('render')) {
            this.metrics.firstRenderTime = duration;
          }
        }
      }
    });
    
    observer.observe({ entryTypes: ['measure'] });
    
    gridApi.onFirstDataRendered(() => {
      const elapsed = performance.now() - startTime;
      this.metrics.initTime = elapsed;
      console.log(`Grid initialized in ${elapsed}ms`);
    });
  }
  
  monitorDataFetch(startTime: number): void {
    const elapsed = performance.now() - startTime;
    this.metrics.dataFetchTimes.push(elapsed);
    
    if (elapsed > 200) {
      console.warn(`Slow data fetch: ${elapsed}ms`);
    }
  }
  
  monitorWebSocketLatency(sentTime: number): void {
    const latency = performance.now() - sentTime;
    this.metrics.wsLatencies.push(latency);
    
    if (latency > 200) {
      console.warn(`High WebSocket latency: ${latency}ms`);
    }
  }
  
  getMetrics() {
    return {
      ...this.metrics,
      avgDataFetchTime: this.metrics.dataFetchTimes.reduce((a, b) => a + b, 0) / this.metrics.dataFetchTimes.length,
      avgUpdateLatency: this.metrics.updateLatencies.reduce((a, b) => a + b, 0) / this.metrics.updateLatencies.length,
      avgWsLatency: this.metrics.wsLatencies.reduce((a, b) => a + b, 0) / this.metrics.wsLatencies.length
    };
  }
}
```

---

## Best Practices

### ✅ DO

- Use server-side pagination for large datasets
- Batch WebSocket updates (100 rows every 100ms)
- Implement virtual scrolling (built into AG Grid)
- Lazy load grid definitions and column metadata
- Unsubscribe from observables (takeUntil pattern)
- Monitor performance metrics continuously
- Set maximum page size limits (1000 rows)
- Clean up grid instances on component destroy

### ❌ DO NOT

- Fetch all rows at once from server
- Emit WebSocket updates one-by-one
- Render more than 50 rows without pagination
- Keep DOM references without cleanup
- Create circular subscriptions
- Ignore browser memory usage
- Send uncompressed WebSocket messages

---

## Related Documents

- **[WebSocket Integration](./websocket-integration.rules.md)** — Real-time updates
- **[Data Binding](./data-binding.rules.md)** — Server communication
- **[Code Quality](./code-quality.rules.md)** — Monitoring integration
