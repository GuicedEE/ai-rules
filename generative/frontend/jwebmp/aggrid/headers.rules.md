# Headers Rules

**Create and customize grid column headers**

---

## Overview

Custom header components allow adding filtering, sorting, icons, tooltips, and other interactive elements to column headers.

---

## Header Component Interface

```java
public interface IHeaderComponent<C extends IHeaderComponent<C>> extends IComponent<C> {
    // Inherits from IComponent; implements column header rendering
}
```

### Basic Header Implementation

```java
public class CustomHeader extends Div<CustomHeader> 
    implements IHeaderComponent<CustomHeader> {
    
    private String columnName;
    private String sortDirection;  // "asc", "desc", null
    
    public CustomHeader setColumnName(String name) {
        this.columnName = name;
        return this;
    }
    
    public CustomHeader setSortDirection(String direction) {
        this.sortDirection = direction;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("custom-header");
        
        // Column name
        Span nameSpan = new Span()
            .setText(columnName)
            .addCssClass("column-name");
        
        // Sort indicator
        if (sortDirection != null) {
            Span sortSpan = new Span()
                .setText(sortDirection.equals("asc") ? "▲" : "▼")
                .addCssClass("sort-indicator");
            add(nameSpan, sortSpan);
        } else {
            add(nameSpan);
        }
    }
}
```

---

## Built-In Header Examples

### Sortable Header with Icon

```java
public class SortableHeader extends Div<SortableHeader> 
    implements IHeaderComponent<SortableHeader> {
    
    private String columnName;
    private Consumer<String> onSort;  // Callback for sort action
    
    public SortableHeader setColumnName(String name) {
        this.columnName = name;
        return this;
    }
    
    public SortableHeader setOnSort(Consumer<String> callback) {
        this.onSort = callback;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("sortable-header");
        
        Span nameSpan = new Span().setText(columnName);
        
        Button sortBtn = new Button()
            .addCssClass("sort-btn")
            .setText("⇅")
            .setOnClick(event -> {
                if (onSort != null) {
                    onSort.accept("toggle");
                }
            });
        
        add(nameSpan, sortBtn);
    }
}
```

### Filterable Header

```java
public class FilterableHeader extends Div<FilterableHeader> 
    implements IHeaderComponent<FilterableHeader> {
    
    private String columnName;
    private Consumer<String> onFilter;
    
    public FilterableHeader setColumnName(String name) {
        this.columnName = name;
        return this;
    }
    
    public FilterableHeader setOnFilter(Consumer<String> callback) {
        this.onFilter = callback;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("filterable-header");
        
        // Header label
        Div headerDiv = new Div()
            .setText(columnName)
            .addCssClass("header-label");
        
        // Filter input
        Input filterInput = new Input()
            .addCssClass("filter-input")
            .addAttribute("type", "text")
            .addAttribute("placeholder", "Filter...")
            .addAttribute("(input)", "onFilterInput($event.target.value)");
        
        add(headerDiv, filterInput);
    }
}
```

### Info Header with Tooltip

```java
public class InfoHeader extends Div<InfoHeader> 
    implements IHeaderComponent<InfoHeader> {
    
    private String columnName;
    private String tooltipText;
    
    public InfoHeader setColumnName(String name) {
        this.columnName = name;
        return this;
    }
    
    public InfoHeader setTooltip(String text) {
        this.tooltipText = text;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("info-header");
        
        Span nameSpan = new Span().setText(columnName);
        
        Span infoIcon = new Span()
            .setText("ℹ")
            .addCssClass("info-icon")
            .addAttribute("title", tooltipText)
            .addAttribute("data-toggle", "tooltip");
        
        add(nameSpan, infoIcon);
    }
}
```

---

## Header Registration

### Column Definition with Header

```java
new AgGridColumnDef()
    .setField("salary")
    .setHeaderName("Salary")
    .setHeaderComponent(SalaryInfoHeader.class)
    .setWidth(150)
```

### Grid Initialization with Headers

```java
@Override
protected void init() {
    super.init();
    
    List<AgGridColumnDef> columns = List.of(
        new AgGridColumnDef()
            .setField("name")
            .setHeaderName("Name")
            .setHeaderComponent(SortableHeader.class),
        
        new AgGridColumnDef()
            .setField("email")
            .setHeaderName("Email")
            .setHeaderComponent(FilterableHeader.class),
        
        new AgGridColumnDef()
            .setField("salary")
            .setHeaderName("Salary")
            .setHeaderComponent(InfoHeader.class)
            .setHeaderComponentParams(Map.of(
                "tooltip", "Annual compensation"
            ))
    );
    
    this.setColumnDefs(columns);
}
```

---

## Header Styling

### Header CSS

```css
.custom-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px;
    font-weight: 600;
    color: #2c3e50;
}

.column-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.sort-indicator {
    margin-left: 8px;
    font-size: 12px;
    color: #3b82f6;
}

.sortable-header .sort-btn {
    padding: 4px 8px;
    font-size: 12px;
    background: transparent;
    border: none;
    cursor: pointer;
    color: #7f8c8d;
    transition: color 0.2s;
}

.sortable-header .sort-btn:hover {
    color: #3b82f6;
}

.filterable-header .filter-input {
    width: 100%;
    padding: 4px;
    border: 1px solid #bdc3c7;
    border-radius: 3px;
    font-size: 12px;
    margin-top: 4px;
}

.info-header .info-icon {
    margin-left: 8px;
    font-size: 14px;
    cursor: help;
    color: #7f8c8d;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 16px;
    height: 16px;
}
```

---

## Header-Renderer Communication

### Parameter Passing

```java
new AgGridColumnDef()
    .setField("status")
    .setHeaderComponent(StatusHeaderWithFilter.class)
    .setHeaderComponentParams(Map.of(
        "allowMultipleSelection", true,
        "filterOptions", List.of("ACTIVE", "INACTIVE", "PENDING")
    ))
```

### Component Parameter Reception

```java
public class StatusHeaderWithFilter extends Div<StatusHeaderWithFilter> 
    implements IHeaderComponent<StatusHeaderWithFilter> {
    
    private boolean allowMultipleSelection;
    private List<String> filterOptions;
    
    public void setAllowMultipleSelection(boolean allow) {
        this.allowMultipleSelection = allow;
    }
    
    public void setFilterOptions(List<String> options) {
        this.filterOptions = options;
    }
    
    @Override
    protected void init() {
        super.init();
        
        // Build filter UI based on parameters
        filterOptions.forEach(option -> {
            CheckBox cb = new CheckBox()
                .setText(option);
            if (allowMultipleSelection) {
                cb.setType("checkbox");
            } else {
                cb.setType("radio");
            }
            add(cb);
        });
    }
}
```

---

## Grouping Headers

### Column Group Headers

```java
new AgGridColumnDef()
    .setField("firstName")
    .setHeaderName("First Name")
    .setColumnGroupShow("open"),  // Show only when group open

new AgGridColumnDef()
    .setField("lastName")
    .setHeaderName("Last Name")
    .setColumnGroupShow("open")
```

---

## Best Practices

### ✅ DO

- Keep headers lightweight (avoid heavy computation)
- Provide clear visual feedback for sort/filter state
- Use tooltips for complex column purposes
- Test header components in isolation
- Implement proper event handling

### ❌ DO NOT

- Place heavy data fetching in header `init()`
- Make headers overly wide (leaves no room for data)
- Duplicate column name in header and renderer
- Ignore accessibility (provide tooltips, proper semantic HTML)

---

## Related Documents

- **[Column Definitions](./column-definitions.rules.md)** — Header assignment
- **[Cell Renderers](./cell-renderers.rules.md)** — Renderer patterns (similar structure)
- **[Styling & Theming](./styling-theming.rules.md)** — Header styling and CSS
