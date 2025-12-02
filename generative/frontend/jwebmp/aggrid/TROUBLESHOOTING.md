# TROUBLESHOOTING.md

**Common Issues, Diagnostics, and Solutions**

---

## Grid Rendering Issues

### Grid Not Displaying at All

**Symptoms**: 
- Empty div with AG Grid CSS not loaded
- Console: "Cannot find element with ID 'myGrid'"

**Diagnosis**:
```javascript
// In browser console:
1. Check if AG Grid CSS loaded:
   document.querySelector('link[href*="ag-grid"]') // Should not be null

2. Check if grid container exists:
   document.getElementById('myGrid') // Should exist

3. Check grid instance:
   window.agGridGrids // Should contain your grid
```

**Solution**:
```java
// Ensure AG Grid CSS is imported
@NgImportModule("AgGridModule")
public class MyGrid extends AgGrid<MyGrid> { }

// Ensure grid ID is unique
public MyGrid() {
  setID("uniqueGridId"); // Must be globally unique on page
  setHeight("500px");    // Set explicit height
}
```

**See**: [grid-configuration.rules.md](./grid-configuration.rules.md)

---

### Columns Not Showing

**Symptoms**:
- Grid shows but no columns render
- Header row empty

**Diagnosis**:
```java
// Check column definitions
MyGrid grid = new MyGrid();
List<AgGridColumnDef> cols = grid.getColumnDefs();
if (cols.isEmpty()) {
  System.out.println("ERROR: No columns defined!");
}

// Verify field names match data
List<Person> data = grid.fetchData();
Person first = data.get(0);
// Field names in columnDefs must match getter names in Person class
```

**Solution**:
```java
// Add columns during grid initialization
public MyGrid() {
  super();
  addColumnDef(new AgGridColumnDef<>("id", "ID"));
  addColumnDef(new AgGridColumnDef<>("name", "Name"));
  addColumnDef(new AgGridColumnDef<>("email", "Email"));
}
```

**See**: [column-definitions.rules.md](./column-definitions.rules.md)

---

### Rows Not Showing (But Columns Render)

**Symptoms**:
- Column headers visible
- No data rows
- Network tab shows data request successful

**Diagnosis**:
```java
// Test fetchData() directly
MyGrid grid = new MyGrid();
List<Person> data = grid.fetchData();
System.out.println("Data count: " + data.size()); // Should be > 0

// Verify data serialization
ObjectMapper mapper = new ObjectMapper();
String json = mapper.writeValueAsString(data);
System.out.println(json); // Should contain row data with field names
```

**Solution**:
```java
// Implement fetchData() correctly
@Override
public List<Person> fetchData() {
  PersonService service = IGuiceContext.get(PersonService.class);
  List<Person> data = service.getAllPersons();
  
  if (data == null || data.isEmpty()) {
    System.out.warn("WARNING: fetchData() returned no rows!");
  }
  
  return data;
}

// Verify rowIdFieldName matches actual data
@Override
public String getRowIdFieldName() {
  return "id"; // Must exist in Person class as getId()
}
```

**See**: [data-binding.rules.md](./data-binding.rules.md)

---

### Rows Show But Look Wrong (Styling Issues)

**Symptoms**:
- Data appears but formatting is broken
- Row heights inconsistent
- Text overflow

**Diagnosis**:
```css
/* Check if AG Grid theme CSS loaded */
.ag-root { /* Should apply */ }
.ag-theme-alpine { /* Should apply */ }

/* Check if custom CSS conflicts */
.ag-cell { /* Should have default padding */ }
```

**Solution**:
```java
// Ensure theme is set
grid.setTheme("ag-theme-alpine");

// Add custom CSS carefully (don't override critical styles)
grid.addStyle("--ag-font-size", "12px");
grid.addStyle("--ag-row-height", "32px");
```

**See**: [styling-theming.rules.md](./styling-theming.rules.md)

---

## WebSocket & Real-Time Update Issues

### WebSocket Not Connecting

**Symptoms**:
- DevTools Network tab: WebSocket connection pending/failed
- Console errors: "WebSocket closed with code 1000"
- Real-time updates not working

**Diagnosis**:
```javascript
// In browser console:
1. Check WebSocket connection status:
   // Look for ws:// or wss:// in Network tab
   
2. Check grid event source:
   console.log('Grid ID:', gridElement.id);
   
3. Check browser console for errors:
   // Should see "WebSocket connected" message
```

**Server-Side Diagnosis**:
```bash
# Check if WebSocket receiver is registered
grep -r "WebSocketAbstractCallReceiver" src/
# Should find GridEventReceiver or similar

# Check server logs for WebSocket handshake
tail -f logs/app.log | grep -i websocket

# Verify GuicedEE discovered the receiver
# Add debug logging:
@Log4j2
public class GridEventReceiver extends WebSocketAbstractCallReceiver<...> {
  public GridEventReceiver() {
    log.info("GridEventReceiver initialized - ready for WebSocket connections");
  }
}
```

**Solution**:
```java
// Ensure receiver is properly annotated
@Component
@Slf4j
public class GridEventReceiver extends WebSocketAbstractCallReceiver<GridEventMessage, AjaxResponse<GridUpdateMessage>> {
  
  @Override
  public Uni<AjaxResponse<GridUpdateMessage>> onCall(GridEventMessage message) {
    log.info("Received grid event: {}", message);
    return Uni.createFromItem(message)
      .onItem().transform(m -> new AjaxResponse<>(m));
  }
}

// Verify it's registered in SPI:
// src/main/resources/META-INF/services/com.guicedee.guicedee.services.GuiceInjectionModule
```

**See**: [websocket-integration.rules.md](./websocket-integration.rules.md)

---

### WebSocket Latency > 200ms

**Symptoms**:
- Real-time updates slow to appear
- Batched updates coming one-by-one
- Server processing updates in isolation

**Diagnosis**:
```typescript
// In browser console, add timing:
const startTime = performance.now();
gridApi.applyTransaction({ update: [row] });
const elapsed = performance.now() - startTime;
console.log(`Update latency: ${elapsed}ms`);
```

**Solution**:
```java
// Implement batch processing on server
@Component
public class GridUpdateBatcher {
  
  private static final int BATCH_SIZE = 100;
  private static final long BATCH_INTERVAL_MS = 100;
  
  private final BlockingQueue<GridUpdate<?>> updateQueue = new LinkedBlockingQueue<>();
  
  public void queueUpdate(GridUpdate<?> update) {
    updateQueue.offer(update);
  }
  
  private void emitBatch(List<GridUpdate<?>> batch) {
    // Emit all updates together via single WebSocket message
    messagingTemplate.convertAndSend(
      "/topic/grid/updates",
      new BatchUpdateMessage(batch)
    );
  }
}
```

**See**: [performance.rules.md](./performance.rules.md)

---

## Performance Issues

### Grid Initialization > 500ms

**Symptoms**:
- Long blank screen before grid appears
- Browser feels frozen during init
- User experience poor

**Diagnosis**:
```typescript
// Measure grid init time in browser
const startTime = performance.now();
const gridApi = // grid initialization code
gridApi.onFirstDataRendered(() => {
  const elapsed = performance.now() - startTime;
  console.log(`Grid initialized in ${elapsed}ms`);
  if (elapsed > 500) {
    console.warn('SLOW: Grid initialization exceeded 500ms target!');
  }
});
```

**Solution**:
```java
// Lazy load column definitions
public class GridInitializer {
  
  async initializeGrid(gridId: string): Promise<void> {
    // Step 1: Create empty grid (fast)
    const gridApi = await this.createEmptyGrid(gridId);
    
    // Step 2: Fetch columns in parallel
    const columnDefs = await this.loadColumnDefs(gridId);
    
    // Step 3: Set columns and data
    gridApi.setColumnDefs(columnDefs);
    const datasource = new ServerSideDatasource(this.gridService);
    gridApi.setGridOption('datasource', datasource);
  }
}
```

**See**: [performance.rules.md](./performance.rules.md)

---

### Grid Memory Leak (Browser Memory Increasing)

**Symptoms**:
- Browser memory usage increasing over time
- Grid slow after leaving/returning to page
- Occasional "Out of memory" errors

**Diagnosis**:
```typescript
// In browser DevTools Memory tab:
1. Take heap snapshot
2. Leave grid page and return
3. Take another heap snapshot
4. Compare: If size increased significantly, likely leak

// Check subscriptions
// In component.ts:
private subscriptions: Subscription[] = [];

ngOnInit() {
  // If subscription never unsubscribed, it's a leak
  this.service.data$.subscribe(data => {
    // ...
  }); // ← LEAK: No unsubscribe
}
```

**Solution**:
```typescript
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

export class GridComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  ngOnInit() {
    this.gridService.data$
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => {
        this.gridApi.applyTransaction({ update: [data] });
      });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
    this.gridApi?.destroy();
  }
}
```

**See**: [performance.rules.md](./performance.rules.md)

---

### 10,000+ Rows Rendering Slowly

**Symptoms**:
- Scrolling is sluggish
- CPU usage high
- Rendering takes >1 second

**Diagnosis**:
```javascript
// Check if virtual scrolling enabled
const gridOptions = gridApi.getGridOptions();
console.log('Viewport height:', gridApi.getVerticalPixelRange().bottom);
console.log('Total rows:', gridApi.getDisplayedRowCount());
// If rendering all rows: virtual scrolling not working
```

**Solution**:
```java
// Implement server-side pagination
@GetMapping("/data")
public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> getGridData(
  @RequestParam(defaultValue = "0") int page,
  @RequestParam(defaultValue = "50") int pageSize // Max 50 per page
) {
  // Never fetch all rows; always paginate
  Page<OrderRow> result = orderRepository.findAll(
    PageRequest.of(page, pageSize)
  );
  return ResponseEntity.ok(new AjaxResponse<>(
    new PagedResponse<>(result)
  ));
}

// Client-side: Configure datasource
const datasource = new ServerSideDatasource(this.gridService);
gridOptions.datasource = datasource;
gridOptions.cacheBlockSize = 50; // Fetch 50 at a time
```

**See**: [performance.rules.md](./performance.rules.md)

---

## Security Issues

### CSRF Token Error on POST

**Symptoms**:
- POST/PUT/DELETE requests return 403 Forbidden
- Server logs: "Invalid CSRF token"
- Error in DevTools Network tab

**Diagnosis**:
```javascript
// Check CSRF token in cookies
document.cookie // Look for XSRF-TOKEN
// Check request headers
// Should have X-XSRF-TOKEN header in POST/PUT/DELETE
```

**Solution**:
```typescript
// Configure CSRF interceptor in Angular
@NgModule({
  imports: [
    HttpClientXsrfModule.withOptions({
      cookieName: 'XSRF-TOKEN',
      headerName: 'X-XSRF-TOKEN'
    })
  ]
})
export class AppModule { }

// Ensure Spring Security configured
@Configuration
@EnableWebSecurity
public class SecurityConfig {
  
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      .csrf(csrf -> csrf
        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
      );
    return http.build();
  }
}
```

**See**: [security.rules.md](./security.rules.md)

---

### XSS Attack Via Cell Renderer

**Symptoms**:
- Unexpected JavaScript executing in browser
- Alert boxes appearing unexpectedly
- Network requests to malicious sites

**Diagnosis**:
```java
// Check if cell renderer using innerHTML
// BAD:
cell.innerHTML = userSuppliedData; // XSS VULNERABILITY!

// Check if using innerHTML with unsanitized data
// Angular template: [innerHTML]="data" // DANGER
```

**Solution**:
```typescript
// Use textContent instead of innerHTML
const cell = document.createElement('span');
cell.textContent = userSuppliedData; // Safe: text only, no HTML

// Or use Angular sanitization
<div [innerHTML]="userSuppliedData | sanitizeHtml"></div>

// In cell renderer
@Component({
  selector: 'app-cell-renderer',
  template: `<span>{{ data }}</span>` // Safe: Angular escapes by default
})
export class SafeCellRenderer { }
```

**See**: [security.rules.md](./security.rules.md)

---

## Testing Issues

### Tests Failing with "Grid not found"

**Symptoms**:
- Unit tests fail: `Cannot find grid with ID 'testGrid'`
- `NullPointerException` in test

**Diagnosis**:
```java
// Check if test harness initialized
@SpringBootTest
public class GridTest {
  
  @Autowired
  private AgGridTestHarness harness; // May be null
  
  @Test
  public void testGrid() {
    // Test harness not initialized
  }
}
```

**Solution**:
```java
@SpringBootTest
public class GridTest {
  
  @Autowired
  private WebApplicationContext context;
  
  private MockMvc mockMvc;
  
  @BeforeEach
  public void setup() {
    mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
  }
  
  @Test
  public void shouldCreateGrid() {
    MyGrid grid = new MyGrid();
    assertThat(grid).isNotNull();
  }
}
```

**See**: [testing-strategy.rules.md](./testing-strategy.rules.md)

---

### Coverage Below 80% Target

**Symptoms**:
- Build fails: `Execution failed: line coverage 75% is less than 80%`
- Jacoco report shows red areas

**Diagnosis**:
```bash
# Generate coverage report
mvn clean test jacoco:report

# Open report
open target/site/jacoco/index.html

# Check which classes lack coverage
# Look for red packages/classes
```

**Solution**:
```java
// Write tests for all public methods
// BAD: No test
public class GridService {
  public List<GridRow> fetchData() {
    return repository.findAll();
  }
}

// GOOD: Test coverage
@SpringBootTest
public class GridServiceTest {
  
  @Autowired
  private GridService service;
  
  @Mock
  private GridRepository repository;
  
  @Test
  public void shouldFetchData() {
    List<GridRow> expected = List.of(new GridRow());
    when(repository.findAll()).thenReturn(expected);
    
    List<GridRow> actual = service.fetchData();
    
    assertThat(actual).isEqualTo(expected);
  }
}
```

**See**: [testing-strategy.rules.md](./testing-strategy.rules.md)

---

## Deployment Issues

### "Module not found: com.jwebmp.plugins.aggrid"

**Symptoms**:
- Maven build fails: `Could not find artifact`
- `mvn clean install` hangs

**Diagnosis**:
```bash
# Check Maven settings
cat ~/.m2/settings.xml

# Check repository availability
mvn dependency:tree | grep aggrid
# Should show version resolved

# Check if published to Maven Central
# https://search.maven.org/search?q=aggrid
```

**Solution**:
```bash
# Update pom.xml to latest stable version
# Check: https://mvnrepository.com/artifact/com.jwebmp.plugins/aggrid

<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>aggrid</artifactId>
  <version>2.0.0</version>
</dependency>

# If using SNAPSHOT:
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>aggrid</artifactId>
  <version>2.0.0-SNAPSHOT</version>
</dependency>

# May require:
<repository>
  <id>ossrh</id>
  <url>https://s01.oss.sonatype.org/content/repositories/snapshots</url>
  <snapshots>
    <enabled>true</enabled>
  </snapshots>
</repository>
```

**See**: [RULES.md](../../../../../../RULES.md)

---

## Need More Help?

### Documentation Quick Links

- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** — Templates and checklists
- **[README.md](./README.md)** — Rules index and navigation
- **[grid-configuration.rules.md](./grid-configuration.rules.md)** — Basic setup
- **[websocket-integration.rules.md](./websocket-integration.rules.md)** — Real-time updates
- **[performance.rules.md](./performance.rules.md)** — Optimization
- **[security.rules.md](./security.rules.md)** — Security hardening
- **[testing-strategy.rules.md](./testing-strategy.rules.md)** — Testing patterns

### Getting Support

1. **Check this troubleshooting guide** (you're reading it!)
2. **Review relevant rules files** (linked above)
3. **Check GitHub Issues**: https://github.com/JWebMP/AgGrid/issues
4. **Review existing tests** in `src/test/java/`
5. **Contact team** with: error message, code snippet, browser/server logs

---

## Document Metadata

- **Version**: 1.0
- **Updated**: December 2, 2025
- **Related**: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md), [README.md](./README.md), all rules files
