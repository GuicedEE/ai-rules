# Column Definitions Rules

**Define grid columns, types, and filtering/sorting behavior**

---

## Overview

Column definitions (`AgGridColumnDef`) specify how data is presented in the grid. Each column can have a field, header, width, type, filter, sort behavior, and custom renderer.

---

## AgGridColumnDef Structure

```java
public class AgGridColumnDef {
    private String field;                    // Property name from row data
    private String headerName;               // Column header label
    private Integer width;                   // Column width in pixels
    private String type;                     // Column type: "text", "number", "date", "boolean"
    private Boolean sortable;                // Enable sorting
    private String sort;                     // Initial sort: "asc", "desc"
    private Boolean filterable;              // Enable filtering
    private String filter;                   // Filter type: "text", "number", "date", "set"
    private Class<?> cellRenderer;           // Custom renderer class
    private Class<?> headerComponent;        // Custom header component
    private Boolean hide;                    // Hide column initially
    private Boolean resizable;               // Allow column resize
    private Integer minWidth;                // Minimum column width
    private Integer maxWidth;                // Maximum column width
    private Boolean editable;                // Allow cell editing
    private String cellEditor;               // Editor component
    
    // Fluent setters
    @SuppressWarnings("unchecked")
    public AgGridColumnDef setField(String field) {
        this.field = field;
        return this;
    }
    
    @SuppressWarnings("unchecked")
    public AgGridColumnDef setHeaderName(String header) {
        this.headerName = header;
        return this;
    }
    
    // ... more setters
}
```

---

## Column Types

### Text Columns

```java
new AgGridColumnDef()
    .setField("name")
    .setHeaderName("Name")
    .setType("text")
    .setWidth(200)
    .setFilter("text")
    .setSortable(true)
```

### Number Columns

```java
new AgGridColumnDef()
    .setField("salary")
    .setHeaderName("Salary")
    .setType("number")
    .setWidth(150)
    .setFilter("number")
    .setSortable(true)
```

### Date Columns

```java
new AgGridColumnDef()
    .setField("hireDate")
    .setHeaderName("Hire Date")
    .setType("date")
    .setWidth(150)
    .setFilter("date")
    .setSortable(true)
```

### Boolean Columns

```java
new AgGridColumnDef()
    .setField("active")
    .setHeaderName("Active")
    .setType("boolean")
    .setWidth(100)
    .setFilter("set")
```

---

## Filtering

### Text Filter

```java
new AgGridColumnDef()
    .setField("email")
    .setHeaderName("Email")
    .setFilter("text")
    // Filter options: "contains", "notContains", "equals", "startsWith", "endsWith"
```

### Number Filter

```java
new AgGridColumnDef()
    .setField("age")
    .setHeaderName("Age")
    .setFilter("number")
    // Filter options: "equals", "greaterThan", "lessThan", "greaterThanOrEqual", "lessThanOrEqual"
```

### Date Filter

```java
new AgGridColumnDef()
    .setField("joinDate")
    .setHeaderName("Join Date")
    .setFilter("date")
    // Filter options: "equals", "greaterThan", "lessThan", "inRange"
```

### Set Filter (Dropdown)

```java
new AgGridColumnDef()
    .setField("department")
    .setHeaderName("Department")
    .setFilter("set")
    // Renders unique values from column as checkboxes
```

---

## Sorting

### Single Column Sort

```java
new AgGridColumnDef()
    .setField("name")
    .setHeaderName("Name")
    .setSort("asc")  // Initial sort ascending
    .setSortable(true)
```

### Disable Sorting

```java
new AgGridColumnDef()
    .setField("description")
    .setHeaderName("Description")
    .setSortable(false)
```

---

## Width & Resizing

### Fixed Width

```java
new AgGridColumnDef()
    .setField("id")
    .setHeaderName("ID")
    .setWidth(80)
    .setResizable(false)  // Prevent resizing
```

### Min/Max Width

```java
new AgGridColumnDef()
    .setField("name")
    .setHeaderName("Name")
    .setMinWidth(150)
    .setMaxWidth(400)
    .setResizable(true)
```

---

## Custom Cell Renderers

See [cell-renderers.rules.md](./cell-renderers.rules.md) for detailed renderer implementation.

```java
new AgGridColumnDef()
    .setField("status")
    .setHeaderName("Status")
    .setWidth(150)
    .setCellRenderer(StatusBadgeRenderer.class)
```

---

## Custom Headers

See [headers.rules.md](./headers.rules.md) for header components.

```java
new AgGridColumnDef()
    .setField("salary")
    .setHeaderName("Salary")
    .setHeaderComponent(SalaryHeaderComponent.class)
    .setWidth(150)
```

---

## Visibility & Display

### Hidden Column

```java
new AgGridColumnDef()
    .setField("internalId")
    .setHeaderName("Internal ID")
    .setHide(true)  // Not visible by default, but available for export
```

---

## Complete Column Definition Example

```java
List<AgGridColumnDef> columns = List.of(
    new AgGridColumnDef()
        .setField("id")
        .setHeaderName("ID")
        .setType("number")
        .setWidth(80)
        .setSortable(true)
        .setFilter("number")
        .setResizable(false),
    
    new AgGridColumnDef()
        .setField("name")
        .setHeaderName("Employee Name")
        .setType("text")
        .setWidth(200)
        .setMinWidth(150)
        .setMaxWidth(400)
        .setSortable(true)
        .setFilter("text")
        .setResizable(true),
    
    new AgGridColumnDef()
        .setField("email")
        .setHeaderName("Email")
        .setType("text")
        .setWidth(250)
        .setFilter("text"),
    
    new AgGridColumnDef()
        .setField("department")
        .setHeaderName("Department")
        .setType("text")
        .setWidth(150)
        .setFilter("set"),  // Dropdown filter
    
    new AgGridColumnDef()
        .setField("salary")
        .setHeaderName("Salary")
        .setType("number")
        .setWidth(150)
        .setFilter("number")
        .setSortable(true),
    
    new AgGridColumnDef()
        .setField("joinDate")
        .setHeaderName("Join Date")
        .setType("date")
        .setWidth(150)
        .setFilter("date"),
    
    new AgGridColumnDef()
        .setField("active")
        .setHeaderName("Active")
        .setType("boolean")
        .setWidth(100)
        .setFilter("set"),
    
    new AgGridColumnDef()
        .setField("actions")
        .setHeaderName("Actions")
        .setWidth(150)
        .setResizable(false)
        .setCellRenderer(ActionsRenderer.class)  // Edit, Delete buttons
);
```

---

## Best Practices

### ✅ DO

- Always specify `field` and `headerName`
- Use appropriate column types for proper filtering/sorting
- Set explicit widths to prevent layout issues
- Use custom renderers for complex display logic
- Group related columns (ID, Name, Actions) logically

### ❌ DO NOT

- Use raw field names without `headerName` (poor UX)
- Enable both filtering and sorting on every column if unnecessary
- Create overly wide columns without `maxWidth`
- Use cell renderers for simple display (just format the field value)

---

## Related Documents

- **[Cell Renderers](./cell-renderers.rules.md)** — Custom rendering
- **[Headers](./headers.rules.md)** — Custom header components
- **[Grid Configuration](./grid-configuration.rules.md)** — Grid-level options
