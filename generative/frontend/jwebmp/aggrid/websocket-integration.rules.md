# WebSocket Integration Rules

**Enable real-time updates via WebSocket receivers**

---

## Overview

WebSocket integration allows the server to push real-time grid updates to connected clients. This is essential for monitoring dashboards, collaborative editors, and live data feeds.

---

## WebSocketAbstractCallReceiver

### Base Implementation

```java
public abstract class WebSocketAbstractCallReceiver<T> {
    
    public abstract Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response);
}
```

### Custom Receiver Implementation

```java
@Log4j2
public class GridDataUpdateReceiver extends WebSocketAbstractCallReceiver<AjaxResponse<?>> {
    
    @Inject
    private DataService dataService;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String gridId = (String) call.getParameters().get("gridId");
            String action = (String) call.getParameters().get("action");
            
            switch (action) {
                case "fetchData" -> {
                    var data = dataService.findAll();
                    response.addDataResponse("rowData", data);
                    log.info("Sent data to grid: {}", gridId);
                }
                case "rowUpdated" -> {
                    String rowId = (String) call.getParameters().get("rowId");
                    var updatedRow = dataService.findById(rowId);
                    response.addDataResponse("updatedRow", updatedRow);
                    log.info("Row updated: {}", rowId);
                }
                default -> {
                    response.setStatus(400);
                    log.warn("Unknown action: {}", action);
                }
            }
            
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error in GridDataUpdateReceiver", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

---

## Service Discovery & Registration

### Automatic Registration

WebSocket receivers are auto-discovered via GuicedEE SPI:

```java
// File: META-INF/services/com.guicedee.client.services.config.IGuiceScanModuleInclusions
com.jwebmp.plugins.aggrid.implementations.AgGridWebSocketReceiver
```

### Manual Registration (if needed)

```java
@Log4j2
public class AgGridWebSocketReceiver extends WebSocketAbstractCallReceiver<...> {
    
    static {
        // Register this receiver with GuicedEE
        IGuiceContext.instance()
            .getInstanceOf(WebSocketRegistry.class)
            .register(AgGridWebSocketReceiver.class);
        
        log.info("Registered AgGridWebSocketReceiver");
    }
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        // Implementation
        return Uni.createFrom().item(response);
    }
}
```

---

## Message Routing

### AjaxCall Structure

```java
public class AjaxCall<T> {
    private String messageDirector;  // Routing identifier
    private Class<T> actionClass;    // Grid class to handle
    private Map<String, Object> parameters;  // Request parameters
    
    public String getMessageDirector() { return messageDirector; }
    public Class<T> getActionClass() { return actionClass; }
    public Map<String, Object> getParameters() { return parameters; }
}
```

### AjaxResponse Structure

```java
public class AjaxResponse<?> {
    private int status = 200;
    private Map<String, Object> data = new LinkedHashMap<>();
    
    public void addDataResponse(String key, Object value) {
        this.data.put(key, value);
    }
    
    public void setStatus(int status) {
        this.status = status;
    }
}
```

---

## Common Patterns

### Fetch Data Pattern

```java
@Log4j2
public class FetchDataReceiver extends WebSocketAbstractCallReceiver<...> {
    
    @Inject
    private DataRepository repository;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            // Extract grid parameters
            Integer pageIndex = (Integer) call.getParameters().get("pageIndex");
            Integer pageSize = (Integer) call.getParameters().get("pageSize");
            String sortBy = (String) call.getParameters().get("sortBy");
            String filterText = (String) call.getParameters().get("filterText");
            
            log.debug("Fetching data: page={}, size={}, sort={}, filter={}",
                pageIndex, pageSize, sortBy, filterText);
            
            // Query data (non-blocking)
            var data = repository.search(
                pageIndex * pageSize,
                pageSize,
                sortBy,
                filterText
            );
            
            response.addDataResponse("rowData", data);
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error fetching data", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

### Broadcast Update Pattern

```java
@Log4j2
public class DataChangeListener {
    
    @Inject
    private WebSocketBroadcaster broadcaster;
    
    public void onDataChanged(DataChangeEvent event) {
        log.info("Data changed: {}", event.getId());
        
        // Prepare update message
        var update = new AjaxResponse<>()
            .addDataResponse("updatedRecord", event.getNewValue());
        
        // Broadcast to all connected grid clients
        broadcaster.broadcastToAll("GridUpdateReceiver", update);
    }
}
```

### Error Handling & Retry

```java
@Override
public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
    return dataService.fetchData()
        .onFailure()
        .invoke(error -> log.error("Data fetch failed", error))
        .onFailure(IOException.class)
        .retry()
        .withBackOff(Duration.ofSeconds(1), Duration.ofSeconds(5))
        .times(3)
        .onFailure()
        .recoverWithUni(error -> {
            log.warn("Max retries exceeded, returning cached data");
            response.addDataResponse("rowData", getCachedData());
            return Uni.createFrom().item(response);
        });
}
```

---

## Lifecycle Management

### Connection Lifecycle

```java
@Log4j2
public class GridWebSocketListener implements WebSocketLifecycleListener {
    
    @Override
    public void onConnected(String clientId) {
        log.info("Grid WebSocket connected: {}", clientId);
        // Initialize client state
    }
    
    @Override
    public void onDisconnected(String clientId) {
        log.info("Grid WebSocket disconnected: {}", clientId);
        // Clean up client state
    }
    
    @Override
    public void onError(String clientId, Exception error) {
        log.error("WebSocket error for client: {}", clientId, error);
        // Handle error
    }
}
```

### Grid Component Cleanup

```java
@Override
protected void onDestroy() {
    super.onDestroy();
    
    // Unregister WebSocket listeners
    if (webSocketListener != null) {
        IGuicedWebSocket.get(GridDataUpdateReceiver.class)
            .unsubscribe(webSocketListener);
    }
    
    log.info("Grid destroyed, WebSocket listeners unregistered");
}
```

---

## Performance Optimization

### Message Batching

```java
@Log4j2
public class BatchedUpdateReceiver extends WebSocketAbstractCallReceiver<...> {
    
    private Queue<DataUpdate> updateQueue = new ConcurrentLinkedQueue<>();
    private ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    
    @PostConstruct
    public void init() {
        // Batch updates every 500ms
        scheduler.scheduleAtFixedRate(
            this::flushBatch,
            500,
            500,
            TimeUnit.MILLISECONDS
        );
    }
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        DataUpdate update = parseUpdate(call);
        updateQueue.offer(update);
        return Uni.createFrom().item(response);
    }
    
    private void flushBatch() {
        if (updateQueue.isEmpty()) return;
        
        List<DataUpdate> batch = new ArrayList<>();
        DataUpdate update;
        while ((update = updateQueue.poll()) != null) {
            batch.add(update);
        }
        
        log.info("Broadcasting batched updates: {} items", batch.size());
        broadcaster.broadcastToAll("BatchedUpdates", batch);
    }
}
```

### Throttling

```java
private final Throttle<String> updateThrottle = new Throttle<>(Duration.ofSeconds(1));

@Override
public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
    String gridId = (String) call.getParameters().get("gridId");
    
    if (!updateThrottle.allow(gridId)) {
        log.debug("Update throttled for grid: {}", gridId);
        return Uni.createFrom().item(response);
    }
    
    return fetchAndBroadcast(gridId, response);
}
```

---

## Testing WebSocket Receivers

```java
public class GridDataUpdateReceiverTest {
    
    private GridDataUpdateReceiver receiver;
    private DataService dataServiceMock;
    
    @Before
    public void setUp() {
        receiver = new GridDataUpdateReceiver();
        dataServiceMock = mock(DataService.class);
        // Inject mock
    }
    
    @Test
    public void testFetchDataAction() {
        AjaxCall call = new AjaxCall()
            .setParameters(Map.of("action", "fetchData"));
        
        AjaxResponse response = new AjaxResponse();
        
        Uni<?> result = receiver.action(call, response);
        
        // Assert response contains data
        assertTrue(response.getData().containsKey("rowData"));
    }
    
    @Test
    public void testErrorHandling() {
        AjaxCall call = new AjaxCall()
            .setParameters(Map.of("action", "fetchData"));
        
        when(dataServiceMock.findAll()).thenThrow(new RuntimeException("DB Error"));
        
        AjaxResponse response = new AjaxResponse();
        Uni<?> result = receiver.action(call, response);
        
        assertEquals(500, response.getStatus());
    }
}
```

---

## Best Practices

### ✅ DO

- Make all receiver methods non-blocking (return `Uni<T>`)
- Log all messages with context (client ID, action type)
- Implement error handling with meaningful responses
- Use message throttling to prevent floods
- Clean up resources on WebSocket disconnect

### ❌ DO NOT

- Perform blocking I/O in WebSocket handlers
- Send large uncompressed messages
- Trust client parameters without validation
- Leave listeners registered without cleanup
- Broadcast updates to all clients indiscriminately

---

## Related Documents

- **[Data Binding](./data-binding.rules.md)** — Fetch data patterns
- **[Event Handling](./event-handling.rules.md)** — Client-side event integration
- **[Dependency Injection](./dependency-injection.rules.md)** — Service injection in receivers
- **[Vert.x 5](../../../backend/vertx/README.md)** — Async/WebSocket fundamentals
- **[GuicedEE Client](../../../backend/guicedee/client/README.md)** — WebSocket & IoC integration
