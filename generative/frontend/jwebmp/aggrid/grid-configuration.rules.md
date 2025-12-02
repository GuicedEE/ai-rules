# Grid Configuration Rules

**Define, configure, and initialize AgGrid using the CRTP fluent API**

---

## Overview

AgGrid configuration in JWebMP uses the **CRTP (Curiously Recurring Template Pattern)** fluent API to provide type-safe, chainable setup. This ensures subclass-specific fluent methods return the correct type and prevent configuration errors at compile time.

### Key Concepts

- **Fluent API**: Chain configuration methods like `.setHeight()`, `.enableRowSelection()`, `.bindRowData()`
- **CRTP Pattern**: Subclasses return their own type, not the base AgGrid type
- **JSON Serialization**: Configuration serializes to JSON for Angular template binding
- **Page Configurator**: Lifecycle hook for grid initialization in JWebMP context

---

## CRTP Fluent API Pattern

### Base AgGrid Class Structure

```java
public abstract class AgGrid<J extends AgGrid<J>> extends DivSimple<J> {
    
    protected String gridId;
    protected Map<String, Object> gridOptions = new LinkedHashMap<>();
    
    // Fluent setter returning (J) this for type safety
    @SuppressWarnings("unchecked")
    public J setHeight(String height) {
        addAttribute("style", "height: " + height + ";");
        this.gridOptions.put("domLayout", "normal");
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J setWidth(String width) {
        addAttribute("style", "width: " + width + ";");
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J setTheme(String themeName) {
        // themeName: "ag-theme-alpine", "ag-theme-balham", "ag-theme-quartz"
        addCssClass(themeName);
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J enableRowSelection(String mode) {
        // mode: "single", "multiple"
        this.gridOptions.put("rowSelection", mode);
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J enablePagination(int pageSize) {
        this.gridOptions.put("pagination", true);
        this.gridOptions.put("paginationPageSize", pageSize);
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J bindColumnDefs(String variableName) {
        // variableName: JavaScript variable name for columns (e.g., "columnDefs")
        addAttribute("[columnDefs]", variableName);
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J bindRowData(String variableName) {
        // variableName: JavaScript variable name for rows (e.g., "rowData")
        addAttribute("[rowData]", variableName);
        return (J) this;
    }
    
    @SuppressWarnings("unchecked")
    public J bindGridOptions(String variableName) {
        // variableName: JavaScript variable name for options (e.g., "gridOptions")
        addAttribute("[gridOptions]", variableName);
        return (J) this;
    }
}
```

### Subclass Usage

```java
public class MyGrid extends AgGrid<MyGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        // CRTP fluent chain — each method returns MyGrid, not AgGrid
        this.setHeight("600px")
            .setWidth("100%")
            .setTheme("ag-theme-alpine")
            .enableRowSelection("multiple")
            .enablePagination(20)
            .bindColumnDefs("columnDefs")
            .bindRowData("rowData");
        
        // Configure column definitions
        List<AgGridColumnDef> columns = List.of(
            new AgGridColumnDef()
                .setField("id")
                .setHeaderName("ID")
                .setWidth(80),
            new AgGridColumnDef()
                .setField("name")
                .setHeaderName("Name")
                .setWidth(150),
            new AgGridColumnDef()
                .setField("status")
                .setHeaderName("Status")
                .setCellRenderer(StatusBadgeRenderer.class)
        );
        
        this.setColumnDefs(columns);
        this.gridId = UUID.randomUUID().toString();
    }
    
    public List<MyRecord> fetchData() {
        // Fetch from database
        return repository.findAll();
    }
}
```

---

## AgGridOptions Configuration

AgGridOptions is a POJO that serializes to JSON for Angular template binding.

### Structure

```java
@JsonIgnoreProperties(ignoreUnknown = true)
public class AgGridOptions {
    
    private String domLayout;                  // "normal", "autoHeight", "print"
    private Boolean pagination;                 // Enable pagination
    private Integer paginationPageSize;        // Rows per page
    private String rowSelection;               // "single", "multiple"
    private Boolean suppressRowClickSelection; // Disable row click for selection
    private Integer rowHeight;                 // Default row height (28px)
    private Boolean enableColMove;             // Allow column reordering
    private Boolean enableSorting;             // Allow column sorting
    private Boolean enableFilter;              // Enable column filtering
    private String theme;                      // CSS theme class
    private Map<String, Object> localeText;    // Locale translations
    
    // Getters/setters and fluent methods
    @SuppressWarnings("unchecked")
    public AgGridOptions setDomLayout(String layout) {
        this.domLayout = layout;
        return this;
    }
    
    @SuppressWarnings("unchecked")
    public AgGridOptions setPagination(boolean enabled) {
        this.pagination = enabled;
        return this;
    }
    
    // ... more setters
}
```

### Common Options

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `domLayout` | String | `"normal"` | Layout mode: `"normal"`, `"autoHeight"`, `"print"` |
| `pagination` | Boolean | `false` | Enable client-side pagination |
| `paginationPageSize` | Integer | `10` | Rows to display per page |
| `rowSelection` | String | `null` | Row selection mode: `"single"`, `"multiple"` |
| `rowHeight` | Integer | `28` | Default row height in pixels |
| `enableColMove` | Boolean | `true` | Allow column reordering |
| `enableSorting` | Boolean | `true` | Allow column sorting |
| `enableFilter` | Boolean | `true` | Enable column filtering |
| `suppressRowClickSelection` | Boolean | `false` | Prevent row selection on click |
| `localeText` | Map | `{}` | Locale-specific strings (filter, sort, page labels) |

---

## Theme Configuration

### Available Themes

AG Grid Community Edition provides multiple built-in themes:

```java
// Apply theme via CSS class
grid.setTheme("ag-theme-alpine");      // Modern, light theme
grid.setTheme("ag-theme-balham");      // Classic, compact theme
grid.setTheme("ag-theme-quartz");      // Professional, spacious theme
grid.setTheme("ag-theme-material");    // Material Design variant
```

### Custom Theme Overrides

```css
/* Override theme colors in application CSS */
.ag-theme-alpine {
    --ag-header-background-color: #f0f0f0;
    --ag-header-cell-text-color: #333;
    --ag-row-hover-color: #e8e8e8;
    --ag-row-selected-background-color: #007bff;
}
```

---

## Row Selection Configuration

### Single Selection

```java
grid.setTheme("ag-theme-alpine")
    .enableRowSelection("single")
    .bindColumnDefs("columnDefs")
    .bindRowData("rowData");
```

### Multiple Selection

```java
grid.setTheme("ag-theme-alpine")
    .enableRowSelection("multiple")
    .bindColumnDefs("columnDefs")
    .bindRowData("rowData");
```

### Row Selection Events

See [event-handling.rules.md](./event-handling.rules.md) for handling `onRowSelectJS` callbacks.

---

## Pagination Configuration

### Server-Side Pagination

For datasets with 1000+ rows, enable pagination to improve performance:

```java
grid.enablePagination(20)  // 20 rows per page
    .bindColumnDefs("columnDefs")
    .bindRowData("rowData");
```

**Server-side responsibility**:
- Slice data based on `pageIndex` and `pageSize` from client request
- Fetch from database using OFFSET/LIMIT (SQL) or equivalent
- Return total row count for pagination controls

See [data-binding.rules.md](./data-binding.rules.md) for fetchData pattern.

### Virtual Scrolling

For extremely large datasets (100K+ rows), use virtual scrolling instead of pagination:

```java
// Virtual scrolling enabled by configuring the grid to render rows as they scroll
grid.setHeight("600px")
    .bindColumnDefs("columnDefs")
    .bindRowData("rowData");
// Note: Virtual scrolling requires lazy-loading strategy on client/server
```

---

## Grid Initialization Lifecycle

### Page Configurator Pattern

Use `PageConfigurator` to initialize grids as part of the JWebMP page lifecycle:

```java
@Log4j2
public class MyGridPageConfigurator implements IPageConfigurator<MyGridPageConfigurator> {
    
    @Override
    public Page<?> configure(Page<?> page) {
        MyGrid grid = new MyGrid()
            .setHeight("600px")
            .setTheme("ag-theme-alpine")
            .enableRowSelection("multiple")
            .enablePagination(20);
        
        page.getBody().add(grid);
        
        log.info("Initialized MyGrid on page: {}", page.getPageTitle());
        return page;
    }
}
```

### Grid Registration

Register the configurator via `PageConfigurator` SPI:

```java
// In META-INF/services/com.jwebmp.core.services.IPageConfigurator
com.example.MyGridPageConfigurator
```

---

## Common Configuration Patterns

### Basic CRUD Grid

```java
public class CrudGrid extends AgGrid<CrudGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("600px")
            .setWidth("100%")
            .setTheme("ag-theme-alpine")
            .enableRowSelection("single")
            .enablePagination(25);
        
        // Columns: ID, Name, Email, Actions
        List<AgGridColumnDef> columns = List.of(
            new AgGridColumnDef().setField("id").setHeaderName("ID").setWidth(80),
            new AgGridColumnDef().setField("name").setHeaderName("Name").setWidth(200),
            new AgGridColumnDef().setField("email").setHeaderName("Email").setWidth(250),
            new AgGridColumnDef()
                .setField("actions")
                .setHeaderName("Actions")
                .setWidth(150)
                .setCellRenderer(ActionsRenderer.class)  // Edit, Delete buttons
        );
        
        this.bindColumnDefs("columns")
            .bindRowData("rows");
    }
}
```

### Dashboard Grid (Read-Only)

```java
public class DashboardGrid extends AgGrid<DashboardGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("400px")
            .setTheme("ag-theme-quartz")
            .enablePagination(50);
        
        // No row selection, minimal configuration
        this.bindColumnDefs("dashboardColumns")
            .bindRowData("dashboardData");
    }
}
```

### Real-Time Monitoring Grid

```java
public class MonitoringGrid extends AgGrid<MonitoringGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("700px")
            .setWidth("100%")
            .setTheme("ag-theme-balham")
            .enableRowSelection("multiple");
        
        // Enable quick filtering for fast search
        this.gridOptions.put("enableQuickFilter", true);
        
        this.bindColumnDefs("monitoringColumns")
            .bindRowData("liveMonitoringData");
    }
}
```

---

## Best Practices

### ✅ DO

- Use CRTP fluent API for readable, type-safe configuration chains
- Set explicit heights and widths to prevent layout surprises
- Use pagination for datasets > 1000 rows
- Apply themes for consistent visual appearance
- Document custom grid subclasses with JavaDoc

### ❌ DO NOT

- Use Lombok `@Builder` on grid classes (conflicts with Angular codegen)
- Hard-code pixel dimensions; use responsive units where possible
- Create nested grids in a single container
- Mix multiple versions of AG Grid on same page
- Set gridOptions after calling `init()`

---

## Related Documents

- **[Column Definitions](./column-definitions.rules.md)** — Define columns and their properties
- **[Cell Renderers](./cell-renderers.rules.md)** — Custom cell rendering
- **[Event Handling](./event-handling.rules.md)** — Row selection, clicks, callbacks
- **[Data Binding](./data-binding.rules.md)** — fetchData, real-time updates
- **[Styling & Theming](./styling-theming.rules.md)** — Themes, CSS customization
- **[CRTP Pattern](../../../backend/fluent-api/crtp.rules.md)** — Detailed CRTP explanation

---

## See Also

- [AG Grid Official Documentation](https://www.ag-grid.com/)
- [JWebMP Component Lifecycle](../../jwebmp/README.md)
- [Angular 20 Lifecycle Hooks](../../../language/angular/angular-20.rules.md)
