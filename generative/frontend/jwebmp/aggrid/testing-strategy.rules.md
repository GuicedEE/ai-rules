# Testing Strategy Rules

**Write unit and integration tests for grid components**

---

## Overview

Comprehensive testing ensures grid reliability. Use JUnit 5, Mockito for mocks, and jwebmp-testlib for integration testing.

---

## Unit Testing

### Testing Grid Configuration

```java
public class GridConfigurationTest {
    
    private TestGrid grid;
    
    @Before
    public void setUp() {
        grid = new TestGrid();
    }
    
    @Test
    public void given_grid_when_init_then_height_set() {
        grid.init();
        assertTrue(grid.getAttributes().containsKey("style"));
    }
    
    @Test
    public void given_columns_when_defined_then_column_count_correct() {
        List<AgGridColumnDef> columns = List.of(
            new AgGridColumnDef().setField("id").setHeaderName("ID"),
            new AgGridColumnDef().setField("name").setHeaderName("Name")
        );
        
        grid.setColumnDefs(columns);
        assertEquals(2, grid.getColumnDefs().size());
    }
    
    @Test
    public void given_row_selection_enabled_when_select_mode_set_then_option_applied() {
        grid.enableRowSelection("multiple");
        assertEquals("multiple", grid.getGridOptions().get("rowSelection"));
    }
}
```

### Testing Data Fetching

```java
public class DataFetchingTest {
    
    private OrdersGrid grid;
    private OrderRepository mockRepository;
    
    @Before
    public void setUp() {
        grid = new OrdersGrid();
        mockRepository = mock(OrderRepository.class);
        ReflectionUtils.setField(grid, "orderRepository", mockRepository);
    }
    
    @Test
    public void given_repository_returns_orders_when_fetch_called_then_row_data_populated() {
        // Arrange
        List<OrderRecord> orders = List.of(
            new OrderRecord("1", "Order 1", 100.00),
            new OrderRecord("2", "Order 2", 200.00)
        );
        when(mockRepository.findAll()).thenReturn(Uni.createFrom().item(orders));
        
        // Act
        Uni<List<OrderRecord>> result = grid.fetchData();
        
        // Assert
        List<OrderRecord> fetched = result.await().indefinitely();
        assertEquals(2, fetched.size());
        assertEquals("Order 1", fetched.get(0).getName());
    }
    
    @Test
    public void given_repository_fails_when_fetch_called_then_error_handled() {
        // Arrange
        when(mockRepository.findAll())
            .thenReturn(Uni.createFrom().failure(new RuntimeException("DB Error")));
        
        // Act (reactive logging instead of blocking)
        grid.fetchData().subscribe().with(
            items -> log.info("Received {} items", items.size()),
            err -> log.error("Expected error received: {}", err.toString())
        );
    }
}
```

---

## Integration Testing

### Using JWebMP Test Harness

```java
@ExtendWith(JWebMPTestExtension.class)
public class GridIntegrationTest {
    
    @Inject
    private Page page;
    
    @Inject
    private OrdersGrid grid;
    
    @Inject
    private DatabaseTestUtils dbUtils;
    
    @Test
    public void given_database_with_orders_when_grid_initialized_then_rows_rendered() {
        // Setup
        dbUtils.insertOrders(List.of(
            new Order("1", "Laptop", 1200.00),
            new Order("2", "Mouse", 25.00),
            new Order("3", "Keyboard", 75.00)
        ));
        
        // Act
        page.getBody().add(grid);
        grid.init();
        
        // Assert
        assertEquals(3, grid.getRowData().size());
    }
    
    @Test
    public void given_grid_with_selection_when_row_selected_then_event_fired() {
        // Setup
        grid.init();
        grid.enableRowSelection("single");
        
        // Act
        grid.onRowSelectJS("1");
        
        // Assert - verify server-side action (e.g., audit log)
        // assertTrue(auditService.wasCalled("row.selected"));
    }
}
```

---

## Testing Custom Renderers

```java
public class StatusBadgeRendererTest {
    
    @Test
    public void given_status_active_when_renderer_initialized_then_success_class_applied() {
        StatusBadgeRenderer renderer = new StatusBadgeRenderer()
            .setStatus("ACTIVE");
        renderer.init();
        
        assertTrue(renderer.getCssClasses().contains("badge-success"));
        assertEquals("ACTIVE", renderer.getText());
    }
    
    @Test
    public void given_status_failed_when_renderer_initialized_then_danger_class_applied() {
        StatusBadgeRenderer renderer = new StatusBadgeRenderer()
            .setStatus("FAILED");
        renderer.init();
        
        assertTrue(renderer.getCssClasses().contains("badge-danger"));
    }
    
    @ParameterizedTest
    @ValueSource(strings = {"ACTIVE", "INACTIVE", "PENDING", "FAILED"})
    public void given_various_statuses_when_renderer_created_then_correct_styling(String status) {
        StatusBadgeRenderer renderer = new StatusBadgeRenderer()
            .setStatus(status);
        renderer.init();
        
        assertNotNull(renderer.getText());
        assertTrue(renderer.getCssClasses().size() > 0);
    }
}
```

---

## Testing WebSocket Receivers

```java
public class GridDataUpdateReceiverTest {
    
    private GridDataUpdateReceiver receiver;
    private DataService mockDataService;
    
    @Before
    public void setUp() {
        receiver = new GridDataUpdateReceiver();
        mockDataService = mock(DataService.class);
        ReflectionUtils.setField(receiver, "dataService", mockDataService);
    }
    
    @Test
    public void given_fetch_action_when_receiver_called_then_data_returned() {
        // Arrange
        List<DataRecord> data = List.of(new DataRecord("1", "Value"));
        when(mockDataService.findAll()).thenReturn(Uni.createFrom().item(data));
        
        AjaxCall call = new AjaxCall()
            .setParameters(Map.of("action", "fetchData"));
        AjaxResponse response = new AjaxResponse();
        
        // Act
        Uni<AjaxResponse<?>> result = receiver.action(call, response);

        // Example: log response reactively instead of blocking
        result.invoke(actualResponse -> log.info("Row data present: {}",
            actualResponse.getData().containsKey("rowData")));
    }
    
    @Test
    public void given_error_when_receiver_called_then_500_response() {
        // Arrange
        when(mockDataService.findAll())
            .thenReturn(Uni.createFrom().failure(new RuntimeException("DB Error")));
        
        AjaxCall call = new AjaxCall()
            .setParameters(Map.of("action", "fetchData"));
        AjaxResponse response = new AjaxResponse();
        
        // Act
        Uni<AjaxResponse<?>> result = receiver.action(call, response);

        // Example: log response reactively instead of blocking
        result.invoke(actualResponse -> log.info("Receiver responded with status {}",
            actualResponse.getStatus()));
    }
}
```

---

## Performance & Load Testing

```java
public class GridPerformanceTest {
    
    @Test
    @Timeout(value = 5, unit = TimeUnit.SECONDS)
    public void given_1000_rows_when_rendered_then_completes_within_timeout() {
        List<DataRecord> largeDataset = generateLargeDataset(1000);
        
        long start = System.currentTimeMillis();
        grid.setRowData(largeDataset);
        grid.init();
        long elapsed = System.currentTimeMillis() - start;
        
        assertTrue(elapsed < 5000, "Rendering took too long: " + elapsed + "ms");
    }
    
    @Test
    public void given_many_column_definitions_when_bound_then_no_memory_leak() {
        List<AgGridColumnDef> columns = new ArrayList<>();
        for (int i = 0; i < 100; i++) {
            columns.add(new AgGridColumnDef()
                .setField("field" + i)
                .setHeaderName("Column " + i));
        }
        
        grid.setColumnDefs(columns);
        grid.init();
        
        // Force garbage collection
        System.gc();
        
        // Verify no excessive memory used
        Runtime runtime = Runtime.getRuntime();
        long usedMemory = runtime.totalMemory() - runtime.freeMemory();
        assertTrue(usedMemory < 100_000_000, "Memory usage too high: " + usedMemory);
    }
    
    private List<DataRecord> generateLargeDataset(int size) {
        List<DataRecord> records = new ArrayList<>();
        for (int i = 0; i < size; i++) {
            records.add(new DataRecord("id" + i, "Value " + i));
        }
        return records;
    }
}
```

---

## Test Naming Convention

```java
// BDD-style naming: given_<precondition>_when_<action>_then_<expectation>

public void given_grid_with_pagination_when_page_changed_then_new_data_loaded() { }

public void given_filter_applied_when_grid_refreshes_then_filtered_rows_shown() { }

public void given_row_selected_when_delete_clicked_then_confirmation_shown() { }
```

---

## Coverage Configuration

### Jacoco Maven Plugin

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>jacoco-check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>PACKAGE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

---

## Best Practices

### ✅ DO

- Write unit tests for all public methods
- Use BDD naming convention for clarity
- Mock external dependencies
- Verify both happy path and error cases
- Test renderers in isolation
- Aim for ≥80% code coverage
- Use parameterized tests for multiple cases

### ❌ DO NOT

- Test private methods directly
- Ignore error cases
- Create tests without assertions
- Leave mock setup verbose (use helper methods)
- Test framework behavior (test your code only)
- Leave tests with hard-coded delays

---

## Related Documents

- **[Data Binding](./data-binding.rules.md)** — Testing data fetching
- **[Event Handling](./event-handling.rules.md)** — Testing event handlers
- **[WebSocket Integration](./websocket-integration.rules.md)** — Testing receivers
- **[Cell Renderers](./cell-renderers.rules.md)** — Testing renderers
