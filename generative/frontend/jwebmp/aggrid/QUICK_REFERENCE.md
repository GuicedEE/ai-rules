# QUICK_REFERENCE.md

**AgGrid Development Checklist & Quick Reference** 

---

## Getting Started with AgGrid

### New Grid Setup Checklist

```markdown
## Starting a new AgGrid grid:

- [ ] Create Java class extending `AgGrid<YourGrid>`
- [ ] Implement `fetchData()` method (return List<T>)
- [ ] Implement `getRowIdFieldName()` (unique field)
- [ ] Set grid ID: `setID("myGrid")`
- [ ] Set height/width: `setHeight("500px")`
- [ ] Set theme: `setTheme("ag-theme-alpine")`
- [ ] Add columns with `addColumnDef()`
- [ ] Add grid to page/component
- [ ] Run tests (unit + integration)
- [ ] Verify coverage ≥80%
- [ ] Deploy to staging

See: [grid-configuration.rules.md](./rules/generative/frontend/jwebmp/aggrid/grid-configuration.rules.md)
```

---

## Column Setup Quick Reference

| Feature | Code | Documentation |
|---------|------|-----------------|
| **Basic Column** | `new AgGridColumnDef<>("field", "Header")` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |
| **Sortable** | `.setSortable(true)` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |
| **Filterable** | `.setFilterable(true)` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |
| **Width** | `.setWidth(200)` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |
| **Custom Renderer** | `.setCellRenderer(new MyRenderer())` | [cell-renderers.rules.md](./rules/generative/frontend/jwebmp/aggrid/cell-renderers.rules.md) |
| **Custom Header** | `.setHeaderComponent(new MyHeader())` | [headers.rules.md](./rules/generative/frontend/jwebmp/aggrid/headers.rules.md) |
| **Resizable** | `.setResizable(true)` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |
| **Hidden** | `.setHide(true)` | [column-definitions.rules.md](./rules/generative/frontend/jwebmp/aggrid/column-definitions.rules.md) |

---

## Custom Cell Renderer Template

```java
// Location: src/main/java/com/example/renderers/MyRenderer.java

import com.jwebmp.plugins.aggrid.cellrenderers.ICellRenderer;
import com.jwebmp.plugins.aggrid.cellrenderers.DefaultCellRenderer;

public class MyRenderer extends DefaultCellRenderer<MyRenderer> 
    implements ICellRenderer<MyRenderer> {
  
  @Override
  public String render(CellRendererParams params) {
    Object value = params.getValue();
    // Return HTML or component reference
    return "<span class='badge'>" + value + "</span>";
  }
}

// Usage:
AgGridColumnDef<MyData> col = new AgGridColumnDef<>("status", "Status")
  .setCellRenderer(new MyRenderer());
```

**See**: [cell-renderers.rules.md](./rules/generative/frontend/jwebmp/aggrid/cell-renderers.rules.md)

---

## Row Selection

```java
// Enable single-row selection:
grid.enableRowSelection("single");

// Enable multi-row selection:
grid.enableRowSelection("multiple");

// Handle row selection event:
grid.onRowSelectJS = (rowData) -> {
  System.out.println("Selected: " + rowData);
  // Send to server via WebSocket or API call
};
```

**See**: [event-handling.rules.md](./rules/generative/frontend/jwebmp/aggrid/event-handling.rules.md)

---

## Real-Time Updates (WebSocket)

```java
// Server-side: Create WebSocket receiver
@Component
public class GridUpdateReceiver extends WebSocketAbstractCallReceiver<GridUpdateMessage, AjaxResponse<GridUpdateMessage>> {
  
  @Override
  public Uni<AjaxResponse<GridUpdateMessage>> onCall(GridUpdateMessage message) {
    return Uni.createFromItem(message)
      .onItem().invoke(m -> handleUpdate(m))
      .onItem().transform(m -> new AjaxResponse<>(m));
  }
}

// Client-side: Listen for updates
gridService.subscribeToUpdates('myGrid')
  .subscribe(update => {
    gridApi.applyTransaction({ update: [update.row] });
  });
```

**See**: [websocket-integration.rules.md](./rules/generative/frontend/jwebmp/aggrid/websocket-integration.rules.md) + [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md)

---

## Testing Template

```java
// Location: src/test/java/com/example/GridTest.java

@SpringBootTest
public class MyGridTest {
  
  @Test
  public void shouldCreateGrid() {
    MyGrid grid = new MyGrid();
    assertThat(grid).isNotNull();
    assertThat(grid.getID()).isEqualTo("myGrid");
  }
  
  @Test
  public void shouldFetchData() {
    MyGrid grid = new MyGrid();
    List<MyData> data = grid.fetchData();
    assertThat(data).isNotEmpty();
  }
}
```

**See**: [testing-strategy.rules.md](./rules/generative/frontend/jwebmp/aggrid/testing-strategy.rules.md)

---

## Validation Checklist

### Server-Side Validation

```markdown
### REQUIRED Validation Checks:

- [ ] Validate sort parameters (only allowed columns)
- [ ] Validate filter parameters (type checking, range bounds)
- [ ] Validate pagination (page ≥ 0, pageSize ≤ 1000)
- [ ] Validate user authorization (can access this grid?)
- [ ] Validate rowId exists in data
- [ ] Sanitize string inputs (prevent SQL injection)
- [ ] Check for null values (use @NonNull annotations)

See: [validation.rules.md](./rules/generative/frontend/jwebmp/aggrid/validation.rules.md) + [security.rules.md](./rules/generative/frontend/jwebmp/aggrid/security.rules.md)
```

---

## Performance Optimization Quick Wins

| Problem | Solution | Documentation |
|---------|----------|-----------------|
| Grid initialization > 500ms | Lazy load column definitions | [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md) |
| WebSocket latency > 200ms | Batch updates (100 per 100ms) | [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md) |
| Memory leaks | Unsubscribe on destroy (`takeUntil`) | [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md) |
| 10K+ rows rendering slow | Enable virtual scrolling + pagination | [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md) |
| DOM too heavy | Server-side pagination (max 50 rows) | [performance.rules.md](./rules/generative/frontend/jwebmp/aggrid/performance.rules.md) |

---

## Security Checklist

```markdown
### SECURITY REQUIREMENTS:

- [ ] Implement CSRF protection (Spring Security)
- [ ] Escape HTML output (use textContent, not innerHTML)
- [ ] Validate all server-side input
- [ ] Use parameterized SQL queries (JPA)
- [ ] Implement access control (user roles)
- [ ] Log security events (audit trail)
- [ ] Use HTTPS for all communication
- [ ] Validate filter/sort parameters against whitelist
- [ ] Sanitize string inputs

See: [security.rules.md](./rules/generative/frontend/jwebmp/aggrid/security.rules.md)
```

---

## Code Quality Targets

| Metric | Target | Tool |
|--------|--------|------|
| **Code Coverage** | ≥80% | Jacoco |
| **Critical Issues** | 0 | SonarQube |
| **Code Smells** | 0 | SonarQube |
| **Line Length** | Soft: 120 chars | IDE |
| **Test Class Naming** | *Test.java | Convention |

**See**: [code-quality.rules.md](./rules/generative/frontend/jwebmp/aggrid/code-quality.rules.md)

---

## CI/CD Workflow

```bash
# Local development
mvn clean verify            # Full build + tests + coverage
mvn clean verify sonar:sonar # Local SonarQube analysis

# GitHub Actions (automatic on push)
# - Runs Maven build
# - Executes all tests
# - Generates coverage report
# - Publishes to Codecov

# Release
git tag v2.0.0
mvn clean deploy            # Publish to Maven Central
```

**See**: [cicd-integration.rules.md](./rules/generative/frontend/jwebmp/aggrid/cicd-integration.rules.md)

---

## Styling & Theming

```java
// Set built-in theme
grid.setTheme("ag-theme-alpine");  // Other: balham, quartz, etc.

// Custom CSS override
grid.addStyle("--ag-background-color", "#f5f5f5");
grid.addStyle("--ag-cell-horizontal-padding", "12px");

// Row styling
grid.getOptions().getRowClassRules()
  .put("highlight-row", "data.status === 'PENDING'");
```

**See**: [styling-theming.rules.md](./rules/generative/frontend/jwebmp/aggrid/styling-theming.rules.md)

---

## Dependency Injection (GuicedEE)

```java
// Inject grid service
@Service
public class MyGridService {
  
  @Inject
  private OrderRepository orderRepository;
  
  public List<Order> fetchOrders() {
    return orderRepository.findAll();
  }
}

// Use in grid
public class MyGrid extends AgGrid<MyGrid> {
  
  @Override
  public List<Order> fetchData() {
    MyGridService service = IGuiceContext.get(MyGridService.class);
    return service.fetchOrders();
  }
}
```

**See**: [dependency-injection.rules.md](./rules/generative/frontend/jwebmp/aggrid/dependency-injection.rules.md)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Grid not rendering | Check: AG Grid CSS loaded, grid ID unique, DOM container exists |
| WebSocket not connecting | Check: Server logs for connection errors, network tab in DevTools |
| No data showing | Check: `fetchData()` returns data, column `field` matches data keys |
| Memory leak in console | Check: Unsubscribe from observables using `takeUntil(destroy$)` |
| Slow grid initialization | Check: Enable lazy loading of column definitions |
| CSRF errors on POST | Check: CSRF token interceptor configured in Angular |

---

## Migration Guide: v1.x → v2.0

```markdown
### Quick Migration:

1. Update Maven: `<version>2.0.0</version>`
2. Update API:
   - `setGridId()` → `setId()`
   - `setGridOptions()` → `setOptions()`
   - WebSocket: `sync` → `Uni<>` (non-blocking)
3. Run: `mvn clean verify`
4. Test: All unit tests pass + coverage ≥80%
5. Deploy

Full guide: [migration-and-upgrade.rules.md](./rules/generative/frontend/jwebmp/aggrid/migration-and-upgrade.rules.md)
```

---

## Key Terminology

| Term | Definition |
|------|-----------|
| **AgGrid** | Java class wrapping AG Grid (extends DivSimple<J>) |
| **AgGridOptions** | Configuration object serialized to Angular |
| **AgGridColumnDef** | Column definition (Java → JSON → AG Grid) |
| **ICellRenderer** | Custom cell component interface |
| **WebSocketAbstractCallReceiver** | Backend handler for grid events (non-blocking Uni<>) |
| **CRTP** | Curiously Recurring Template Pattern (fluent API) |
| **FetchData** | Server-side data fetching pattern |
| **PageConfigurator** | Plugin lifecycle manager (IPageConfigurator) |

**Full Glossary**: [GLOSSARY.md](./rules/generative/frontend/jwebmp/aggrid/GLOSSARY.md)

---

## Documentation Map

```
QUICK_REFERENCE.md (this file)
    ↓
[grid-configuration.rules.md] → Create grid, CRTP fluent API
[column-definitions.rules.md] → Add/configure columns
[cell-renderers.rules.md] → Custom cell rendering
[event-handling.rules.md] → Row selection, callbacks
[data-binding.rules.md] → Server data fetching
[websocket-integration.rules.md] → Real-time updates
[performance.rules.md] → Optimization, batching
[security.rules.md] → CSRF, XSS, validation
[testing-strategy.rules.md] → Unit & integration tests
[code-quality.rules.md] → Coverage, SonarQube
[cicd-integration.rules.md] → Build & deployment
[migration-and-upgrade.rules.md] → Version upgrades
```

---

## Related Documents

- **README.md** — Rules index and navigation
- **[../../../../../../PACT.md](../../../../../../PACT.md)** — Product intent & ADRs
- **[../../../../../../RULES.md](../../../../../../RULES.md)** — Technology stack rules
- **[../../../../../../GUIDES.md](../../../../../../GUIDES.md)** — Step-by-step how-to
- **[../../../../../../IMPLEMENTATION.md](../../../../../../IMPLEMENTATION.md)** — Code layout
- **[docs/architecture/README.md](../../../../../../docs/architecture/README.md)** — Architecture diagrams
