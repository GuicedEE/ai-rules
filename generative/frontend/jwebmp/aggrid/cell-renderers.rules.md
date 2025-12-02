# Cell Renderers Rules

**Implement custom cell rendering as Angular components**

---

## Overview

Cell renderers customize how grid cells are displayed. In JWebMP AgGrid, renderers are **Angular components** that extend `IComponent` or `INgComponent`, providing full lifecycle support and dependency injection.

---

## ICellRenderer Interface

```java
public interface ICellRenderer<C extends ICellRenderer<C>> extends IComponent<C> {
    // Inherits from IComponent; no additional methods
    // Convention: cell data passed via component properties during initialization
}
```

### Component Structure

```java
public class StatusBadgeRenderer extends Div<StatusBadgeRenderer> 
    implements ICellRenderer<StatusBadgeRenderer> {
    
    private String status;  // Set by grid from row data
    private String statusClass;
    
    public StatusBadgeRenderer setStatus(String status) {
        this.status = status;
        this.statusClass = switch (status) {
            case "ACTIVE" -> "badge-success";
            case "INACTIVE" -> "badge-secondary";
            case "PENDING" -> "badge-warning";
            case "FAILED" -> "badge-danger";
            default -> "badge-info";
        };
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("badge", statusClass);
        setText(status);
        addAttribute("title", "Status: " + status);
    }
    
    @Override
    protected void preBuild() {
        super.preBuild();
        // Lifecycle hook before Angular renders
    }
}
```

---

## Built-In Renderer Examples

### Status Badge Renderer

```java
@Log4j2
public class StatusBadgeRenderer extends Div<StatusBadgeRenderer> 
    implements ICellRenderer<StatusBadgeRenderer> {
    
    private String status;
    
    public StatusBadgeRenderer setStatus(String status) {
        this.status = status;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        String cssClass = switch (status) {
            case "ACTIVE" -> "badge bg-success";
            case "INACTIVE" -> "badge bg-secondary";
            case "PENDING" -> "badge bg-warning";
            case "FAILED" -> "badge bg-danger";
            default -> "badge bg-info";
        };
        
        addCssClass(cssClass);
        setText(status);
        
        log.debug("Initialized StatusBadgeRenderer for status: {}", status);
    }
}
```

### Action Buttons Renderer

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
        
        addCssClass("btn-group", "btn-group-sm");
        
        // Edit button
        Button editBtn = new Button()
            .addCssClass("btn", "btn-primary", "btn-sm")
            .setText("Edit")
            .setOnClick("editRecord('" + recordId + "')");
        
        // Delete button
        Button deleteBtn = new Button()
            .addCssClass("btn", "btn-danger", "btn-sm")
            .setText("Delete")
            .setOnClick("deleteRecord('" + recordId + "')");
        
        add(editBtn, deleteBtn);
    }
}
```

### Currency Renderer

```java
public class CurrencyRenderer extends Span<CurrencyRenderer> 
    implements ICellRenderer<CurrencyRenderer> {
    
    private BigDecimal amount;
    private String currencyCode = "USD";
    
    public CurrencyRenderer setAmount(BigDecimal amount) {
        this.amount = amount;
        return this;
    }
    
    public CurrencyRenderer setCurrencyCode(String code) {
        this.currencyCode = code;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        String symbol = switch (currencyCode) {
            case "EUR" -> "€";
            case "GBP" -> "£";
            case "JPY" -> "¥";
            default -> "$";
        };
        
        String formatted = String.format("%s %,.2f", symbol, amount);
        setText(formatted);
        
        addCssClass(amount.signum() < 0 ? "text-danger" : "text-success");
    }
}
```

### Progress Bar Renderer

```java
public class ProgressRenderer extends Div<ProgressRenderer> 
    implements ICellRenderer<ProgressRenderer> {
    
    private Integer percentage;
    
    public ProgressRenderer setPercentage(Integer percent) {
        this.percentage = Math.max(0, Math.min(100, percent));
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("progress");
        addAttribute("style", "height: 24px;");
        
        Div bar = new Div()
            .addCssClass("progress-bar")
            .addAttribute("style", "width: " + percentage + "%;")
            .setText(percentage + "%");
        
        add(bar);
    }
}
```

### Custom Link Renderer

```java
public class LinkRenderer extends Anchor<LinkRenderer> 
    implements ICellRenderer<LinkRenderer> {
    
    private String href;
    private String label;
    
    public LinkRenderer setHref(String href) {
        this.href = href;
        return this;
    }
    
    public LinkRenderer setLabel(String label) {
        this.label = label;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        setUrl(href);
        setText(label);
        setTarget("_blank");
        addCssClass("link-primary");
    }
}
```

---

## Renderer Registration

### Column Definition with Renderer

```java
new AgGridColumnDef()
    .setField("status")
    .setHeaderName("Status")
    .setWidth(150)
    .setCellRenderer(StatusBadgeRenderer.class)
```

### Grid Initialization with Renderer Reference

```java
@Override
protected void init() {
    super.init();
    
    // Ensure renderer is registered with component registry
    addConfiguration(AnnotationUtils.getNgComponentReference(StatusBadgeRenderer.class));
    
    List<AgGridColumnDef> columns = List.of(
        new AgGridColumnDef()
            .setField("status")
            .setHeaderName("Status")
            .setCellRenderer(StatusBadgeRenderer.class),
        
        new AgGridColumnDef()
            .setField("actions")
            .setHeaderName("Actions")
            .setCellRenderer(ActionsRenderer.class)
    );
    
    this.setColumnDefs(columns)
        .bindRowData("rowData");
}
```

---

## Renderer Lifecycle

### Initialization Flow

```java
public class LifecycleRenderer extends Div<LifecycleRenderer> 
    implements ICellRenderer<LifecycleRenderer> {
    
    private String cellValue;
    
    // Called when grid sets cell data
    public LifecycleRenderer setCellValue(String value) {
        this.cellValue = value;
        return this;
    }
    
    // Called before Angular initializes component
    @Override
    protected void preBuild() {
        super.preBuild();
        // Configure component structure
    }
    
    // Called during initialization
    @Override
    protected void init() {
        super.init();
        // Set up event listeners, final styling
        setText(cellValue);
    }
    
    // Called after component is rendered in Angular
    @Override
    protected void postBuild() {
        super.postBuild();
        // Access DOM after render
    }
}
```

---

## Data Binding to Renderers

### Property Mapping

The grid automatically maps row field values to renderer properties:

```java
// Row data
{
  "id": 1,
  "name": "John Doe",
  "status": "ACTIVE",
  "salary": 75000
}

// Column definition with renderer
new AgGridColumnDef()
    .setField("status")
    .setCellRenderer(StatusBadgeRenderer.class)

// Grid automatically calls:
new StatusBadgeRenderer().setStatus("ACTIVE")
```

### Complex Data Binding

```java
public class EmployeeDetailsRenderer extends Div<EmployeeDetailsRenderer> 
    implements ICellRenderer<EmployeeDetailsRenderer> {
    
    private Employee employee;  // Row object
    
    public EmployeeDetailsRenderer setEmployee(Employee emp) {
        this.employee = emp;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        if (employee != null) {
            Div nameDiv = new Div().setText(employee.getName());
            Div emailDiv = new Div()
                .setText(employee.getEmail())
                .addCssClass("text-muted", "small");
            
            add(nameDiv, emailDiv);
        }
    }
}
```

---

## Best Practices

### ✅ DO

- Keep renderers focused on display logic only
- Use semantic HTML elements (Span, Div, Button, Anchor)
- Apply CSS classes for styling consistency
- Implement nullness checks for optional fields
- Use explicit return types in setter methods

### ❌ DO NOT

- Perform business logic in renderers (data mutations)
- Create overly complex nested component hierarchies
- Bind direct to database objects (use DTOs)
- Implement modal dialogs within renderers
- Use jQuery or direct DOM manipulation

---

## Performance Considerations

### Renderer Optimization

```java
// Cache repeated calculations
public class OptimizedRenderer extends Div<OptimizedRenderer> 
    implements ICellRenderer<OptimizedRenderer> {
    
    private String formattedValue;
    
    public OptimizedRenderer setValue(String rawValue) {
        // Expensive computation cached once
        this.formattedValue = expensiveFormat(rawValue);
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        setText(formattedValue);  // Use cached value
    }
    
    private String expensiveFormat(String value) {
        // Complex formatting logic
        return value;
    }
}
```

---

## Related Documents

- **[Column Definitions](./column-definitions.rules.md)** — Define columns with renderers
- **[Headers](./headers.rules.md)** — Custom header components
- **[Event Handling](./event-handling.rules.md)** — Renderer click events
- **[Angular Component Integration](./angular-component-integration.rules.md)** — Component lifecycle
- **[JWebMP Components](../../jwebmp/README.md)** — Component base classes

---

## See Also

- [AG Grid Cell Rendering Documentation](https://www.ag-grid.com/angular-data-grid/cell-rendering/)
- [JWebMP Component Lifecycle](../../jwebmp/README.md)
