# Dependency Injection Rules

**Access services and manage component dependencies**

---

## Overview

Dependency Injection (via GuicedEE) enables grids and components to access business logic services, repositories, and utilities without tight coupling.

---

## Injecting Services

### Basic Service Injection

```java
public class CrudGrid extends AgGrid<CrudGrid> {
    
    @Inject
    private EmployeeRepository employeeRepository;
    
    @Inject
    private NotificationService notificationService;
    
    public Uni<List<EmployeeRecord>> fetchData() {
        return employeeRepository.findAll();
    }
    
    public void deleteEmployee(String id) {
        employeeRepository.delete(id)
            .subscribe().with(result -> {
                notificationService.success("Employee deleted");
            });
    }
}
```

### Multiple Service Injection

```java
public class OrderGrid extends AgGrid<OrderGrid> {
    
    @Inject
    private OrderRepository orderRepository;
    
    @Inject
    private CustomerService customerService;
    
    @Inject
    private PaymentService paymentService;
    
    @Inject
    private LogisticsService logisticsService;
    
    public Uni<List<OrderRecord>> fetchData() {
        return orderRepository.findAll();
    }
}
```

---

## Qualifier Annotations

### Named Qualifiers

```java
public class MultiDataSourceGrid extends AgGrid<MultiDataSourceGrid> {
    
    @Inject
    @Named("primary")
    private DataRepository primaryRepository;
    
    @Inject
    @Named("cache")
    private DataRepository cacheRepository;
    
    public Uni<List<DataRecord>> fetchData() {
        // Try cache first
        return cacheRepository.findAll()
            .onFailure()
            .recoverWithUni(error -> {
                // Fall back to primary
                return primaryRepository.findAll();
            });
    }
}
```

### Custom Qualifiers

```java
@Qualifier
@Retention(RUNTIME)
public @interface ReadOnly { }

public class ReadOnlyGrid extends AgGrid<ReadOnlyGrid> {
    
    @Inject
    @ReadOnly
    private DataService dataService;
    
    public Uni<List<DataRecord>> fetchData() {
        return dataService.readAll();  // Read-only service
    }
}
```

---

## Service Instance Resolution

### IGuiceContext Access

```java
public class ManualLookupGrid extends AgGrid<ManualLookupGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        // Manually resolve service if @Inject not available
        DataService service = IGuiceContext.get(DataService.class);
        
        service.findAll()
            .subscribe().with(data -> {
                this.rowData = new ArrayList<>(data);
            });
    }
}
```

### Provider Pattern

```java
public class ProviderGrid extends AgGrid<ProviderGrid> {
    
    @Inject
    private javax.inject.Provider<DataService> serviceProvider;
    
    public void lazyLoadData() {
        // Service created only when needed
        DataService service = serviceProvider.get();
        service.findAll()
            .subscribe().asCompletionStage();
    }
}
```

---

## Transactional Service Integration

### Transactional Methods

```java
public class TransactionalGrid extends AgGrid<TransactionalGrid> {
    
    @Inject
    private TransactionService transactionService;
    
    public void updateMultipleRecords(List<RecordUpdate> updates) {
        transactionService.executeInTransaction(() -> {
            // All operations in single transaction
            updates.forEach(update -> 
                repository.update(update.getId(), update.getValue())
            );
        });
    }
}
```

### Async Transaction Handling

```java
public void updateRecordAsync(String id, String newValue) {
    transactionService.executeAsyncTransaction(
        () -> repository.update(id, newValue)
    )
    .subscribe().with(
        result -> notificationService.success("Updated"),
        error -> notificationService.error("Update failed: " + error.getMessage())
    );
}
```

---

## Service Mocking for Testing

### Mock Service Injection

```java
public class CrudGridTest {
    
    private CrudGrid grid;
    private EmployeeRepository mockRepository;
    private NotificationService mockNotificationService;
    
    @Before
    public void setUp() {
        grid = new CrudGrid();
        mockRepository = mock(EmployeeRepository.class);
        mockNotificationService = mock(NotificationService.class);
        
        // Inject mocks
        ReflectionUtils.setField(grid, "employeeRepository", mockRepository);
        ReflectionUtils.setField(grid, "notificationService", mockNotificationService);
    }
    
    @Test
    public void testFetchData() {
        List<EmployeeRecord> employees = List.of(
            new EmployeeRecord("1", "John Doe"),
            new EmployeeRecord("2", "Jane Smith")
        );
        
        when(mockRepository.findAll()).thenReturn(Uni.createFrom().item(employees));
        
        Uni<List<EmployeeRecord>> result = grid.fetchData();

        // Log reactively instead of blocking
        result.invoke(list -> log.info("Fetched {} employees", list.size()));
    }
}
```

---

## Event Handler Service Access

### Service in WebSocket Receiver

```java
@Log4j2
public class ServiceIntegratedReceiver extends WebSocketAbstractCallReceiver<...> {
    
    @Inject
    private DataService dataService;
    
    @Inject
    private AuthService authService;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String userId = (String) call.getParameters().get("userId");
            
            // Check authorization
            if (!authService.hasPermission(userId, "VIEW_GRID")) {
                response.setStatus(403);
                return Uni.createFrom().item(response);
            }
            
            // Access data service
            var data = dataService.findForUser(userId);
            response.addDataResponse("userData", data);
            
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error in service-integrated receiver", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

---

## Service Composition

### Layered Services

```java
public class ComposedGrid extends AgGrid<ComposedGrid> {
    
    @Inject
    private DataRepository repository;
    
    @Inject
    private ValidationService validator;
    
    @Inject
    private CachingService cache;
    
    public Uni<List<DataRecord>> fetchData() {
        // Composed service flow: cache → validation → repository
        return cache.getIfValid()
            .onFailure()
            .recoverWithUni(error -> {
                return repository.findAll()
                    .chain(data -> validator.validate(data))
                    .chain(validData -> cache.store(validData));
            });
    }
}
```

---

## Constructor Injection (Alternative)

### Constructor-Based DI

```java
public class ConstructorInjectGrid extends AgGrid<ConstructorInjectGrid> {
    
    private final DataService dataService;
    private final AuditService auditService;
    
    // Constructor injection (if preferred over field injection)
    @Inject
    public ConstructorInjectGrid(DataService dataService, AuditService auditService) {
        this.dataService = dataService;
        this.auditService = auditService;
    }
    
    @Override
    protected void init() {
        super.init();
        
        auditService.logGridInitialization(getClass().getName());
    }
}
```

---

## Best Practices

### ✅ DO

- Inject services via `@Inject` field annotation
- Use typed injection (concrete classes/interfaces)
- Access services via `IGuiceContext.get()` only when necessary
- Keep service dependencies minimal (avoid circular deps)
- Mock services in tests via reflection or constructors
- Use qualifiers for multiple implementations

### ❌ DO NOT

- Use `new ServiceClass()` directly (breaks IoC)
- Inject too many dependencies (sign of poor design)
- Call `IGuiceContext.get()` in hot loops (cache result)
- Forget to close/cleanup injected resources
- Mix injection strategies (pick field or constructor, not both)

---

## Related Documents

- **[WebSocket Integration](./websocket-integration.rules.md)** — Service access in receivers
- **[Event Handling](./event-handling.rules.md)** — Services in event handlers
- **[Testing Strategy](./testing-strategy.rules.md)** — Mock injection patterns
- **[GuicedEE](../../../backend/guicedee/README.md)** — Dependency injection framework
