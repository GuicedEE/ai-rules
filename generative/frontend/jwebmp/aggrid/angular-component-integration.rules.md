# Angular Component Integration Rules

**Integrate AgGrid as an Angular component in applications**

---

## Overview

AgGrid in JWebMP extends Angular components (`IComponent<J>`) and integrates with the Angular module system for proper lifecycle management and dependency injection.

---

## Component Structure

### Basic Grid Component

```java
@Log4j2
public class AgGrid<J extends AgGrid<J>> extends DivSimple<J> implements INgComponent<J> {
    
    protected String gridId;
    protected List<AgGridColumnDef> columnDefs;
    protected List<?> rowData;
    protected Map<String, Object> gridOptions;
    
    @Override
    protected void init() {
        super.init();
        
        this.gridId = UUID.randomUUID().toString();
        this.gridOptions = new LinkedHashMap<>();
        this.columnDefs = new ArrayList<>();
        this.rowData = new ArrayList<>();
        
        // Set element tag
        setTag("ag-grid-angular");
        
        // Bind grid properties
        addAttribute("[gridOptions]", "gridOptions");
        addAttribute("[columnDefs]", "columnDefs");
        addAttribute("[rowData]", "rowData");
        addAttribute("(gridReady)", "onGridReady($event)");
        
        log.debug("Initialized AgGrid component: {}", gridId);
    }
    
    @Override
    public void preBuild() {
        super.preBuild();
        // Called before Angular renders
    }
    
    @Override
    public void init() {
        super.init();
        // Setup configuration
    }
    
    @Override
    public void postBuild() {
        super.postBuild();
        // Called after Angular renders
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        
        // Clean up listeners and subscriptions
        gridId = null;
        columnDefs.clear();
        rowData.clear();
        gridOptions.clear();
        
        log.debug("Destroyed AgGrid component");
    }
}
```

---

## Lifecycle Hooks

### Component Lifecycle Methods

```java
public class MyGrid extends AgGrid<MyGrid> {
    
    @Inject
    private DataService dataService;
    
    @Inject
    private ChangeDetectorRef changeDetector;
    
    @Override
    protected void preBuild() {
        super.preBuild();
        log.info("Grid preBuild: preparing configuration");
    }
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("600px")
            .setTheme("ag-theme-alpine")
            .enableRowSelection("single");
        
        log.info("Grid init: configuration applied");
    }
    
    @Override
    protected void postBuild() {
        super.postBuild();
        
        // After Angular renders, load initial data
        dataService.findAll()
            .subscribe().with(data -> {
                this.rowData = data;
                changeDetector.markForCheck();
                log.info("Grid postBuild: {} rows loaded", data.size());
            });
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        log.info("Grid destroyed: cleaning up resources");
    }
    
    // Optional: Respond to grid ready event
    public void onGridReady(GridReadyEvent event) {
        log.info("AG Grid ready");
        this.gridApi = event.api;
        this.columnApi = event.columnApi;
    }
}
```

---

## Angular Module Integration

### Module Registration

```typescript
// app.module.ts (Generated or Manual)
import { NgModule } from '@angular/core';
import { AgGridModule } from 'ag-grid-angular';

@NgModule({
  imports: [
    AgGridModule.withComponents([])  // Register custom components
  ],
  declarations: [
    // Grid components
  ]
})
export class AppModule { }
```

### JWebMP Module Annotation

```java
@NgImportModule(
    imports = {
        "AgGridModule.withComponents([])",
        "RowSelectionModule"
    }
)
public class AgGrid<J extends AgGrid<J>> extends DivSimple<J> {
    // ...
}
```

---

## Template Binding

### Two-Way Data Binding

```html
<ag-grid-angular
  [gridOptions]="gridOptions"
  [columnDefs]="columnDefs"
  [rowData]="rowData"
  (gridReady)="onGridReady($event)">
</ag-grid-angular>
```

### Property Binding from Java

```java
public class MyGrid extends AgGrid<MyGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        // Bind to Angular component properties
        addAttribute("[gridOptions]", "gridConfig");
        addAttribute("[columnDefs]", "columns");
        addAttribute("[rowData]", "rows");
        
        // Bind events
        addAttribute("(onRowSelected)", "handleRowSelect($event)");
        addAttribute("(onCellClicked)", "handleCellClick($event)");
    }
}
```

---

## Change Detection

### Manual Change Detection

```java
public class ReactiveGrid extends AgGrid<ReactiveGrid> {
    
    @Inject
    private ChangeDetectorRef changeDetector;
    
    private Subscription dataSubscription;
    
    @Override
    protected void init() {
        super.init();
        
        // Subscribe to data updates
        dataSubscription = dataService.dataUpdates()
            .subscribe(newData -> {
                this.rowData = newData;
                // Mark component for change detection
                changeDetector.markForCheck();
            });
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (dataSubscription != null) {
            dataSubscription.unsubscribe();
        }
    }
}
```

### OnPush Change Detection Strategy

```java
@Component(
    selector: 'app-grid',
    changeDetection: ChangeDetectionStrategy.OnPush
)
public class OptimizedGrid extends AgGrid<OptimizedGrid> {
    // Optimized for performance
    // Only detects changes when input properties change
}
```

---

## Rendering Grid in Template

### Template Usage

```html
<div class="grid-container">
  <app-my-grid [data]="gridData"></app-my-grid>
</div>
```

### Component Declaration

```java
@PageConfigurator
public class GridPageConfigurator implements IPageConfigurator<GridPageConfigurator> {
    
    @Override
    public Page<?> configure(Page<?> page) {
        MyGrid grid = new MyGrid()
            .setHeight("600px")
            .setTheme("ag-theme-alpine");
        
        page.getBody().add(grid);
        return page;
    }
}
```

---

## Dependency Injection

### Injecting Services into Grid

```java
public class ServiceIntegratedGrid extends AgGrid<ServiceIntegratedGrid> {
    
    @Inject
    private DataRepository repository;
    
    @Inject
    private NotificationService notificationService;
    
    @Inject
    private AuthService authService;
    
    @Override
    protected void init() {
        super.init();
        
        // Use injected services
        repository.findAll()
            .subscribe().with(data -> {
                this.rowData = data;
                notificationService.info("Loaded " + data.size() + " records");
            });
    }
    
    public void deleteRecord(String recordId) {
        if (!authService.hasPermission("DELETE_RECORD")) {
            notificationService.warn("You don't have permission to delete");
            return;
        }
        
        repository.delete(recordId)
            .subscribe().with(result -> {
                notificationService.success("Record deleted");
                refresh();
            });
    }
}
```

---

## Event Integration

### Input/Output Decorators

```java
public class BidirectionalGrid extends AgGrid<BidirectionalGrid> {
    
    // Inputs: accept data from parent component
    private List<?> inputRowData;
    private List<AgGridColumnDef> inputColumns;
    
    // Outputs: emit events to parent component
    private String selectedRowId;
    
    public BidirectionalGrid setInputData(List<?> data) {
        this.inputRowData = data;
        this.rowData = new ArrayList<>(data);
        return this;
    }
    
    public BidirectionalGrid setInputColumns(List<AgGridColumnDef> columns) {
        this.inputColumns = columns;
        this.columnDefs = new ArrayList<>(columns);
        return this;
    }
    
    public void onRowSelectJS(String rowId) {
        this.selectedRowId = rowId;
        // Emit to parent component
        notifyParent("rowSelected", rowId);
    }
    
    private void notifyParent(String event, Object data) {
        // Trigger @Output event
    }
}
```

---

## Performance Optimization

### Virtual Scrolling Setup

```java
public class VirtualScrollGrid extends AgGrid<VirtualScrollGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        // Enable virtual scrolling for large datasets
        this.gridOptions.put("rowBuffer", 10);
        this.gridOptions.put("suppressRowVirtualisation", false);
        this.gridOptions.put("rowHeight", 25);
        
        // Enable row model optimization
        this.gridOptions.put("rowModelType", "clientSide");
    }
}
```

### Lazy Loading

```java
public class LazyLoadGrid extends AgGrid<LazyLoadGrid> {
    
    @Inject
    private LazyLoadService lazyLoadService;
    
    @Override
    protected void init() {
        super.init();
        
        // Load initial rows
        lazyLoadService.getFirstPage()
            .subscribe().with(data -> {
                this.rowData = data;
            });
    }
    
    public void onVirtualScroll(String scrollEvent) {
        // Load more data as user scrolls
        lazyLoadService.getNextPage()
            .subscribe().with(data -> {
                this.rowData.addAll(data);
            });
    }
}
```

---

## Error Handling in Components

```java
@Log4j2
public class RobustGrid extends AgGrid<RobustGrid> {
    
    @Inject
    private ErrorHandler errorHandler;
    
    @Override
    protected void init() {
        super.init();
        
        try {
            loadData();
        } catch (Exception e) {
            log.error("Error during grid initialization", e);
            errorHandler.handleError(e);
        }
    }
    
    private void loadData() {
        dataService.findAll()
            .onFailure()
            .invoke(error -> {
                log.error("Data load failed", error);
                errorHandler.handleError(error);
            })
            .subscribe().asCompletionStage();
    }
}
```

---

## Best Practices

### ✅ DO

- Implement proper lifecycle hooks
- Use `@Inject` for service dependencies
- Clean up subscriptions in `onDestroy()`
- Mark for change detection after async updates
- Implement error handling
- Use `ChangeDetectionStrategy.OnPush` for performance

### ❌ DO NOT

- Create nested component hierarchies without necessity
- Leave subscriptions without cleanup
- Perform synchronous blocking operations
- Ignore change detection
- Directly manipulate DOM
- Mix framework patterns

---

## Related Documents

- **[Grid Configuration](./grid-configuration.rules.md)** — Configuration options
- **[Dependency Injection](./dependency-injection.rules.md)** — Service injection patterns
- **[Angular 20](../../../language/angular/angular-20.rules.md)** — Lifecycle, RxJS, modules
- **[JWebMP Components](../../jwebmp/README.md)** — Component base classes
