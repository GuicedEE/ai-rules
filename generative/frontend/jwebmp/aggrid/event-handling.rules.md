# Event Handling Rules

**Handle row selection, clicks, and custom events**

---

## Overview

AgGrid events allow grids to respond to user interactions (row selection, cell clicks) and trigger server-side actions via WebSocket or HTTP.

---

## Row Selection Events

### Single Row Selection

```java
public class SingleSelectGrid extends AgGrid<SingleSelectGrid> {
    
    @Inject
    private RecordService recordService;
    
    public void onRowSelectJS(String rowId) {
        log.info("Row selected: {}", rowId);
        
        recordService.getRecord(rowId)
            .subscribe().with(record -> {
                // Handle selected record (show details, populate form, etc.)
                log.info("Loaded record: {}", record);
            });
    }
    
    @Override
    protected void init() {
        super.init();
        
        this.enableRowSelection("single")
            .bindColumnDefs("columns")
            .bindRowData("rows");
    }
}
```

### Multiple Row Selection

```java
public class MultiSelectGrid extends AgGrid<MultiSelectGrid> {
    
    @Inject
    private BulkActionService bulkActionService;
    
    private List<String> selectedRowIds = new ArrayList<>();
    
    public void onRowSelectJS(String rowId) {
        if (!selectedRowIds.contains(rowId)) {
            selectedRowIds.add(rowId);
        }
        log.info("Selected rows: {}", selectedRowIds);
    }
    
    public void onRowDeselectJS(String rowId) {
        selectedRowIds.remove(rowId);
        log.info("Deselected rows: {}", selectedRowIds);
    }
    
    public void bulkDelete() {
        bulkActionService.deleteRecords(selectedRowIds)
            .subscribe().with(result -> {
                log.info("Deleted {} records", result);
                selectedRowIds.clear();
            });
    }
    
    @Override
    protected void init() {
        super.init();
        
        this.enableRowSelection("multiple")
            .bindColumnDefs("columns")
            .bindRowData("rows");
    }
}
```

---

## Cell Click Events

### Cell Click Handler

```java
public class ClickableGrid extends AgGrid<ClickableGrid> {
    
    @Inject
    private DetailService detailService;
    
    public void onCellClickedJS(String rowId, String column) {
        log.info("Cell clicked: row={}, column={}", rowId, column);
        
        switch (column) {
            case "email" -> handleEmailClick(rowId);
            case "phone" -> handlePhoneClick(rowId);
            case "profile" -> handleProfileClick(rowId);
            default -> {}
        }
    }
    
    private void handleEmailClick(String rowId) {
        detailService.getEmail(rowId)
            .subscribe().with(email -> {
                // Show email dialog or navigate
                log.info("Email: {}", email);
            });
    }
    
    private void handlePhoneClick(String rowId) {
        detailService.getPhone(rowId)
            .subscribe().with(phone -> {
                // Show phone or dial
                log.info("Phone: {}", phone);
            });
    }
    
    private void handleProfileClick(String rowId) {
        detailService.getProfile(rowId)
            .subscribe().with(profile -> {
                // Navigate to profile page
                log.info("Profile: {}", profile);
            });
    }
}
```

---

## Custom Renderer Events

### Button Click in Renderer

```java
public class ActionsRenderer extends Div<ActionsRenderer> 
    implements ICellRenderer<ActionsRenderer> {
    
    private String recordId;
    
    public ActionsRenderer setRecordId(String recordId) {
        this.recordId = recordId;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("btn-group");
        
        // Edit button
        Button editBtn = new Button()
            .addCssClass("btn", "btn-sm", "btn-primary")
            .setText("Edit")
            .setOnClick("editRecord('" + recordId + "')");
        
        // Delete button
        Button deleteBtn = new Button()
            .addCssClass("btn", "btn-sm", "btn-danger")
            .setText("Delete")
            .setOnClick("deleteRecord('" + recordId + "')");
        
        add(editBtn, deleteBtn);
    }
}
```

### Handling Renderer Events

```java
public class GridWithActionsPage implements IPageConfigurator<GridWithActionsPage> {
    
    @Inject
    private RecordService recordService;
    
    @Override
    public Page<?> configure(Page<?> page) {
        CrudGrid grid = new CrudGrid()
            .setHeight("600px")
            .setTheme("ag-theme-alpine");
        
        page.getBody().add(grid);
        
        // Listen for action events (EditRecord, DeleteRecord)
        page.getJavaScriptReferences()
            .add("window.editRecord = function(id) { " +
                "console.log('Edit ' + id); " +
                "fetch('/api/records/' + id).then(r => r.json()).then(data => console.log(data)); " +
                "}");
        
        page.getJavaScriptReferences()
            .add("window.deleteRecord = function(id) { " +
                "if (confirm('Delete this record?')) { " +
                "fetch('/api/records/' + id, {method: 'DELETE'}).then(r => console.log('Deleted')); " +
                "} " +
                "}");
        
        return page;
    }
}
```

---

## WebSocket Event Integration

### Server-Side Row Selection Handler

```java
@Log4j2
public class RowSelectReceiver extends WebSocketAbstractCallReceiver<CrudGrid> {
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String rowId = (String) call.getParameters().get("rowId");
            String action = (String) call.getParameters().get("action");
            
            CrudGrid grid = IGuiceContext.get(CrudGrid.class);
            
            switch (action) {
                case "select" -> {
                    var record = grid.getRecordById(rowId);
                    response.addDataResponse("recordDetails", record);
                    log.info("Row selected: {}", rowId);
                }
                case "delete" -> {
                    grid.deleteRecord(rowId);
                    response.addDataResponse("deleted", true);
                    log.info("Row deleted: {}", rowId);
                }
                default -> response.setStatus(400);
            }
            
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error handling row event", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

---

## Filter & Sort Change Events

### Filter Changed Event

```java
public void onFilterChangedJS(String filterCriteria) {
    log.info("Filter applied: {}", filterCriteria);
    
    dataService.search(filterCriteria)
        .subscribe().with(results -> {
            log.info("Search returned {} results", results.size());
            // Update grid data
        });
}
```

### Sort Changed Event

```java
public void onSortChangedJS(String sortColumn, String direction) {
    log.info("Sort applied: {} {}", sortColumn, direction);
    
    dataService.findSorted(sortColumn, direction)
        .subscribe().with(results -> {
            log.info("Sorted {} rows", results.size());
            // Update grid data
        });
}
```

---

## Double-Click Events

```java
public class DoubleClickGrid extends AgGrid<DoubleClickGrid> {
    
    @Inject
    private EditService editService;
    
    public void onCellDoubleClickedJS(String rowId, String column) {
        log.info("Cell double-clicked: row={}, column={}", rowId, column);
        
        editService.getEditForm(rowId, column)
            .subscribe().with(form -> {
                // Show modal or inline editor
                log.info("Opened editor for row: {}", rowId);
            });
    }
}
```

---

## Keyboard Navigation

### Key Press Handlers

```java
@Override
protected void init() {
    super.init();
    
    // Enable keyboard shortcuts
    this.gridOptions.put("enableRangeSelection", true);
    this.gridOptions.put("enableCellTextSelection", false);
    
    // Listen for custom key events via JavaScript
    addAttribute("(onkeydown)", "onGridKeyDown($event)");
}

public void onGridKeyDown(String keyCode) {
    switch (keyCode) {
        case "Delete" -> deleteSelectedRows();
        case "Enter" -> editSelectedRow();
        case "Escape" -> clearSelection();
        default -> {}
    }
}

private void deleteSelectedRows() {
    log.info("Delete key pressed - removing selected rows");
}

private void editSelectedRow() {
    log.info("Enter key pressed - editing selected row");
}

private void clearSelection() {
    log.info("Escape key pressed - clearing selection");
}
```

---

## API Events Reference

### Common Grid Events

| Event | Triggered | Purpose |
|-------|-----------|---------|
| `onRowSelected` | User selects row | Handle row selection |
| `onRowDeselected` | User deselects row | Handle row deselection |
| `onCellClicked` | User clicks cell | Handle cell interaction |
| `onCellDoubleClicked` | User double-clicks cell | Handle cell edit |
| `onFilterChanged` | User applies filter | Handle filtering |
| `onSortChanged` | User applies sort | Handle sorting |
| `onPaginationChanged` | User changes page | Handle pagination |
| `onGridReady` | Grid initializes | Perform post-init tasks |

---

## Best Practices

### ✅ DO

- Log all events with context (row ID, column name)
- Validate action parameters server-side
- Provide user feedback (toast, notification, modal)
- Handle errors gracefully with try-catch
- Clean up listeners in `onDestroy()`

### ❌ DO NOT

- Perform expensive operations synchronously
- Trust client-side event data without validation
- Update grid state without server confirmation
- Leave WebSocket listeners registered after grid destruction
- Hard-code action names (use enum or constants)

---

## Related Documents

- **[WebSocket Integration](./websocket-integration.rules.md)** — Server-side receivers
- **[Cell Renderers](./cell-renderers.rules.md)** — Custom renderer events
- **[Angular Component Integration](./angular-component-integration.rules.md)** — Component lifecycle hooks
- **[Dependency Injection](./dependency-injection.rules.md)** — Access services in event handlers
