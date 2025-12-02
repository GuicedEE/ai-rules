# Styling & Theming Rules

**Customize grid appearance with AG Grid themes and CSS**

---

## Overview

AG Grid provides built-in themes and extensive CSS customization options for styling grids to match application branding.

---

## Built-In Themes

### Theme Options

```java
// Alpine theme - Modern, light
grid.setTheme("ag-theme-alpine");

// Balham theme - Classic, compact
grid.setTheme("ag-theme-balham");

// Balham Dark - Dark variant
grid.setTheme("ag-theme-balham-dark");

// Quartz theme - Professional, spacious
grid.setTheme("ag-theme-quartz");

// Quartz Dark - Dark variant
grid.setTheme("ag-theme-quartz-dark");

// Material theme - Material Design
grid.setTheme("ag-theme-material");
```

### Applying a Theme

```java
public class ThemedGrid extends AgGrid<ThemedGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        this.setHeight("600px")
            .setWidth("100%")
            .setTheme("ag-theme-alpine")
            .enableRowSelection("multiple");
    }
}
```

---

## CSS Theme Variables

### Alpine Theme Variables

```css
.ag-theme-alpine {
    /* Colors */
    --ag-background-color: #ffffff;
    --ag-foreground-color: #333333;
    --ag-border-color: #e0e0e0;
    
    /* Headers */
    --ag-header-background-color: #f5f5f5;
    --ag-header-cell-text-color: #333333;
    --ag-header-column-border-color: #e0e0e0;
    
    /* Rows */
    --ag-row-border-color: #e0e0e0;
    --ag-row-hover-color: #f1f1f1;
    --ag-row-selected-background-color: #e3f2fd;
    
    /* Cells */
    --ag-cell-horizontal-padding: 12px;
    --ag-cell-horizontal-padding-focused: 10px;
    --ag-cell-vertical-padding: 8px;
    
    /* Fonts */
    --ag-font-size: 13px;
    --ag-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", sans-serif;
    
    /* Icons */
    --ag-icon-size: 16px;
    
    /* Range selection */
    --ag-range-selection-border-color: #bbdefb;
    --ag-range-selection-background-color: rgba(187, 222, 251, 0.1);
}
```

### Quartz Theme Variables

```css
.ag-theme-quartz {
    /* Spacious layout */
    --ag-row-height: 32px;
    --ag-header-height: 40px;
    
    /* Colors - Professional */
    --ag-background-color: #ffffff;
    --ag-header-background-color: #f9fafb;
    --ag-row-hover-color: #f3f4f6;
    
    /* Accent */
    --ag-row-selected-background-color: #dbeafe;
    --ag-accent-color: #3b82f6;
}
```

---

## Custom CSS Overrides

### Global Theme Override

```css
/* Override Alpine theme colors */
.ag-theme-alpine {
    --ag-header-background-color: #1e40af;
    --ag-header-cell-text-color: #ffffff;
    --ag-background-color: #f8fafc;
    --ag-row-selected-background-color: #dbeafe;
}

/* Increase padding */
.ag-theme-alpine {
    --ag-cell-vertical-padding: 12px;
}

/* Custom fonts */
.ag-theme-alpine {
    --ag-font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    --ag-font-size: 14px;
}
```

### Component-Specific Styling

```css
/* Style specific grid instance */
#ordersGrid {
    --ag-header-background-color: #2c3e50;
    --ag-header-cell-text-color: #ecf0f1;
    border: 2px solid #34495e;
}

/* Style specific column */
.ag-theme-alpine .ag-header-cell[data-column-id="status"] {
    background-color: #e8f5e9;
    font-weight: bold;
}

/* Style specific cell renderer */
.ag-theme-alpine .badge {
    padding: 4px 8px;
    border-radius: 4px;
    font-weight: 500;
}

.badge-success { background-color: #d4edda; color: #155724; }
.badge-warning { background-color: #fff3cd; color: #856404; }
.badge-danger { background-color: #f8d7da; color: #721c24; }
```

---

## Row & Cell Styling

### Row Class Rules

```java
public class CustomStyledGrid extends AgGrid<CustomStyledGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        this.gridOptions.put("getRowClass", new String[]{
            "rowClassRules", "{"
            + "'highlight': 'data.importance === \"high\"',"
            + "'warning': 'data.status === \"pending\"',"
            + "'danger': 'data.status === \"failed\"'"
            + "}"
        });
    }
}
```

### CSS Row Classes

```css
.ag-theme-alpine .highlight {
    background-color: #fff9e6 !important;
    border-left: 4px solid #ffc107;
}

.ag-theme-alpine .warning {
    background-color: #fff3cd !important;
    opacity: 0.9;
}

.ag-theme-alpine .danger {
    background-color: #f8d7da !important;
    color: #721c24;
}
```

### Cell Styling

```java
new AgGridColumnDef()
    .setField("status")
    .setHeaderName("Status")
    .setCellStyle(new String[]{
        "backgroundColor", "data.status === 'ACTIVE' ? '#d4edda' : '#f8d7da'",
        "color", "data.status === 'ACTIVE' ? '#155724' : '#721c24'",
        "fontWeight", "'bold'"
    })
```

---

## Header Styling

### Header Cell Styling

```css
.ag-theme-alpine .ag-header-cell {
    background-color: #2c3e50;
    color: #ecf0f1;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 12px;
    letter-spacing: 0.5px;
}

.ag-theme-alpine .ag-header-cell:hover {
    background-color: #34495e;
}
```

### Custom Header Component Styling

```java
public class StyledHeader extends Div<StyledHeader> implements IComponent<StyledHeader> {
    
    private String headerText;
    private String tooltipText;
    
    public StyledHeader setHeaderText(String text) {
        this.headerText = text;
        return this;
    }
    
    public StyledHeader setTooltip(String tooltip) {
        this.tooltipText = tooltip;
        return this;
    }
    
    @Override
    protected void init() {
        super.init();
        
        addCssClass("custom-header");
        setText(headerText);
        addAttribute("title", tooltipText);
        
        Span icon = new Span()
            .addCssClass("header-icon")
            .setText("ℹ");
        
        add(icon);
    }
}
```

```css
.custom-header {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    color: #2c3e50;
}

.header-icon {
    font-size: 14px;
    cursor: help;
    color: #7f8c8d;
}
```

---

## Responsive Styling

### Mobile-Friendly Grid

```java
public class ResponsiveGrid extends AgGrid<ResponsiveGrid> {
    
    @Override
    protected void init() {
        super.init();
        
        // Responsive columns
        this.gridOptions.put("columnDefs", generateResponsiveColumns());
        
        // Compact view on mobile
        this.gridOptions.put("suppressRowVirtualisation", false);
        this.gridOptions.put("rowHeight", 28);
        
        // Mobile-friendly padding
        this.gridOptions.put("cellHorizontalPadding", 8);
    }
}
```

```css
/* Mobile styling */
@media (max-width: 768px) {
    .ag-theme-alpine {
        --ag-cell-vertical-padding: 6px;
        --ag-cell-horizontal-padding: 8px;
        --ag-font-size: 12px;
    }
    
    .ag-theme-alpine .ag-header-cell {
        font-size: 11px;
    }
    
    /* Hide non-essential columns */
    .ag-theme-alpine .ag-header-cell[data-column-id="description"] {
        display: none;
    }
}
```

---

## Dark Mode Support

### Dark Theme CSS

```css
/* Dark mode theme */
@media (prefers-color-scheme: dark) {
    .ag-theme-alpine.dark {
        --ag-background-color: #1e1e1e;
        --ag-foreground-color: #e0e0e0;
        --ag-border-color: #424242;
        
        --ag-header-background-color: #2c2c2c;
        --ag-header-cell-text-color: #e0e0e0;
        
        --ag-row-hover-color: #2c2c2c;
        --ag-row-selected-background-color: #1a3a52;
    }
}
```

### Dark Mode Toggle

```java
public class DarkModeGrid extends AgGrid<DarkModeGrid> {
    
    private boolean darkMode = false;
    
    public void toggleDarkMode() {
        darkMode = !darkMode;
        if (darkMode) {
            addCssClass("dark");
        } else {
            removeCssClass("dark");
        }
    }
}
```

---

## Animation & Transitions

### Row Animation

```css
/* Animate row highlights */
.ag-theme-alpine .ag-row {
    transition: background-color 0.2s ease, color 0.2s ease;
}

.ag-theme-alpine .ag-row.highlight {
    animation: highlightIn 0.3s ease;
}

@keyframes highlightIn {
    0% { background-color: inherit; }
    50% { background-color: #ffeb3b; }
    100% { background-color: #fff9e6; }
}
```

### Cell Transitions

```css
.ag-theme-alpine .ag-cell {
    transition: background-color 0.15s ease;
}

.ag-theme-alpine .ag-cell:focus {
    background-color: #e3f2fd;
    box-shadow: inset 0 0 3px #1976d2;
}
```

---

## Accessibility Styling

### High Contrast Mode

```css
@media (prefers-contrast: more) {
    .ag-theme-alpine {
        --ag-header-background-color: #000000;
        --ag-header-cell-text-color: #ffffff;
        --ag-row-border-color: #000000;
        --ag-foreground-color: #000000;
        --ag-background-color: #ffffff;
    }
}
```

### Focus Indicator Styling

```css
.ag-theme-alpine .ag-cell:focus {
    outline: 3px solid #1976d2;
    outline-offset: -2px;
}

.ag-theme-alpine .ag-header-cell:focus {
    outline: 2px solid #1976d2;
}
```

---

## Performance Optimization

### CSS Performance

```css
/* Use will-change sparingly */
.ag-theme-alpine .ag-row.active {
    will-change: background-color;
}

/* Use transform for animations (GPU-accelerated) */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-5px); }
    to { opacity: 1; transform: translateY(0); }
}

.ag-theme-alpine .ag-row {
    animation: fadeIn 0.2s ease;
}
```

---

## Best Practices

### ✅ DO

- Choose a base theme and customize via CSS variables
- Use meaningful color semantics (success, warning, danger)
- Provide sufficient contrast for accessibility
- Test responsive design on mobile
- Use CSS transitions for smooth UX
- Document custom styling in design system

### ❌ DO NOT

- Override all theme variables (pick selective overrides)
- Use `!important` excessively
- Create overly complex gradient/animation effects
- Ignore dark mode and accessibility
- Hard-code colors (use CSS variables)

---

## Related Documents

- **[Grid Configuration](./grid-configuration.rules.md)** — Theme selection
- **[Cell Renderers](./cell-renderers.rules.md)** — Renderer-specific styling
- **[Headers](./headers.rules.md)** — Header component styling

---

## See Also

- [AG Grid Theming Documentation](https://www.ag-grid.com/angular-data-grid/themes/)
- [CSS Variables Reference](https://www.ag-grid.com/angular-data-grid/grid-options/)
