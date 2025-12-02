# side-bar-and-status-bar.rules.md — AG Grid Enterprise Side Bar and Status Bar Configuration

**Configuration guide for grid side bar (tool panels) and status bar (metrics display)**

---

## Overview

**Side Bar** provides a collapsible panel with tool panels for columns, filters, and custom panels.  
**Status Bar** displays grid metrics (row count, selection count, custom aggregations) at the bottom.

### Key Concepts

- **Side Bar** — Collapsible panel with tool panels
- **Tool Panels** — Individual panels (Columns, Filters, Custom)
- **Status Bar** — Bottom bar showing metrics
- **Status Panels** — Individual metric displays

---

## Side Bar Configuration

### Enable Side Bar

```java
public class MyGrid extends AgGridEnterprise<MyGrid> {
    public MyGrid() {
        setID("myGrid");
        sideBarFiltersAndColumns();  // Fluent API for quick setup
    }
}
```

### Custom Side Bar Configuration

```java
List<SideBarToolPanelDef> toolPanels = List.of(
    new SideBarToolPanelDef()
        .setId("columns")
        .setLabelDefault("Columns")
        .setLabelValue("Column 1")
        .setIcon("<img src='...'>"),
    
    new SideBarToolPanelDef()
        .setId("filters")
        .setLabelDefault("Filters")
        .setLabelValue("Filter 1")
);

SideBarOptions sideBar = new SideBarOptions();
sideBar.setToolPanels(toolPanels);
sideBar.setPosition("right");   // "left" or "right"
sideBar.setDefaultToolPanel("columns");  // Default panel on open

grid.getOptions().setSideBarOptions(sideBar);
```

### Side Bar Positioning

```java
sideBar.setPosition("left");    // Left side
// or
sideBar.setPosition("right");   // Right side (default)
```

---

## Status Bar Configuration

### Enable Status Bar

```java
List<StatusBarPanelDef> statusPanels = List.of(
    new StatusBarPanelDef()
        .setKey("totalAndFiltered"),    // Show total/filtered row count
    new StatusBarPanelDef()
        .setKey("selectedCount")        // Show selected row count
);

StatusBarOptions statusBar = new StatusBarOptions();
statusBar.setStatusPanels(statusPanels);

grid.getOptions().setStatusBarOptions(statusBar);
```

### Custom Status Bar Panels

```java
// Custom aggregation panel
StatusBarPanelDef customPanel = new StatusBarPanelDef()
    .setKey("customTotal")
    .setWidgetFunction(new CustomStatusBarComponent());

statusPanels.add(customPanel);
```

**Built-in Status Panels:**

| Panel | Purpose |
|-------|---------|
| `totalAndFiltered` | Show total/filtered row count |
| `selectedCount` | Show selected row count |
| `sumAgg` | Sum aggregation for selected column |
| `avgAgg` | Average aggregation for selected column |
| `minAgg` | Minimum aggregation for selected column |
| `maxAgg` | Maximum aggregation for selected column |

---

## Tool Panel Details

### Columns Panel

Allow users to show/hide columns:

```java
new SideBarToolPanelDef()
    .setId("columns")
    .setLabelDefault("Columns")
```

Features:
- Show/hide columns via checkbox
- Reorder columns via drag-drop
- Search for columns

### Filters Panel

Configure filters visually:

```java
new SideBarToolPanelDef()
    .setId("filters")
    .setLabelDefault("Filters")
```

Features:
- Add/remove filters per column
- Set filter conditions (equals, contains, >, <, etc.)
- Apply filters in real-time

---

## Integration with Other Features

### Side Bar + Row Grouping

Show grouping panel:

```java
grid.showRowGroupPanel()
    .sideBarFiltersAndColumns();

// Side bar shows columns + filters
// Row group panel allows group configuration
```

### Status Bar + Pivot Tables

Show pivot aggregation totals:

```java
PivotingOptions pivoting = new PivotingOptions();
pivoting.setPivotMode(true);
pivoting.setPivotRowTotals(true);
pivoting.setPivotColumnGroupTotals(true);

grid.getOptions().setPivotingOptions(pivoting);

// Status bar shows grand totals
```

---

## Accessibility

- **Keyboard Navigation** — Tab through panels and controls
- **Screen Reader Support** — Panel labels and metric values announced
- **High Contrast** — Ensure colors meet WCAG AA standards

---

## Testing

### Unit Test: Side Bar Options

```java
@Test
void sideBarConfiguredCorrectly() {
    SideBarOptions sideBar = new SideBarOptions();
    sideBar.setPosition("right");
    
    String json = mapper.writeValueAsString(sideBar);
    assertTrue(json.contains("\"position\":\"right\""));
}
```

### Unit Test: Status Bar Options

```java
@Test
void statusBarPanelsConfigured() {
    List<StatusBarPanelDef> panels = List.of(
        new StatusBarPanelDef().setKey("totalAndFiltered")
    );
    
    StatusBarOptions statusBar = new StatusBarOptions();
    statusBar.setStatusPanels(panels);
    
    String json = mapper.writeValueAsString(statusBar);
    assertTrue(json.contains("\"totalAndFiltered\""));
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Side bar/status bar terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Configuration templates
- [Row Grouping](./row-grouping.rules.md) — Row group panel configuration
- [Pivot Tables](./pivot-tables-and-aggregation.rules.md) — Pivot aggregation with status bar

---

**End of side-bar-and-status-bar.rules.md**
