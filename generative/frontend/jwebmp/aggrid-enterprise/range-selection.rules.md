# range-selection.rules.md — AG Grid Enterprise Range Selection Configuration

**Configuration guide for cell range selection and clipboard management**

---

## Overview

**Range Selection** enables users to select rectangular ranges of cells, copy values to clipboard, and integrate with external applications.

### Key Concepts

- **Enable Range Selection** — Fluent API: `enableRangeSelection()`
- **Cell Range** — Rectangular selection (e.g., A1:C5)
- **Copy-to-Clipboard** — Automatic copy of selected range
- **Single-Cell Range** — Control single-cell selection behavior

---

## Configuration

### Enable Range Selection

```java
public class MyGrid extends AgGridEnterprise<MyGrid> {
    public MyGrid() {
        setID("myGrid");
        enableRangeSelection();  // Fluent API
    }
}
```

### Advanced Configuration

```java
RangeSelectionOptions rangeSelection = new RangeSelectionOptions();
rangeSelection.setEnableRangeSelection(true);
rangeSelection.setHandleMinWidth(2);  // Resize handle width
rangeSelection.setEnableRangeHandle(true);  // Show fill handle

grid.getOptions().setRangeSelectionOptions(rangeSelection);
```

---

## Usage Patterns

### Basic Range Selection

User selects rectangular range of cells:
1. Click on cell A1
2. Drag to cell C5
3. Range highlighted in blue
4. Ctrl+C (Cmd+C on Mac) copies to clipboard

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Click + Drag | Select range |
| Shift + Click | Extend range |
| Ctrl+C / Cmd+C | Copy range to clipboard |
| Escape | Clear selection |

---

## Clipboard Control

### Suppress Clipboard for Sensitive Data

```java
// Don't copy PII columns to clipboard
RangeSelectionOptions rangeSelection = new RangeSelectionOptions();
rangeSelection.setSuppressCopyOnClipboard(true);

grid.getOptions().setRangeSelectionOptions(rangeSelection);
```

### Custom Copy Handler

```java
// Format copied data (e.g., quotes for CSV)
grid.getOptions().setOnRangeSelectionChanged(event -> {
    RangeSelection selection = event.getSelection();
    String formatted = formatAsCSV(selection);
    copyToClipboard(formatted);
});
```

---

## Single-Cell Range

### Allow Single-Cell Ranges

```java
RangeSelectionOptions rangeSelection = new RangeSelectionOptions();
rangeSelection.setEnableSingleCellRange(true);

grid.getOptions().setRangeSelectionOptions(rangeSelection);
```

When enabled: Single cell can be treated as a 1×1 range for copy.  
When disabled: Single cell copy uses cellClicked event instead.

---

## Integration with Other Features

### Range Selection + Charts

Users can select data range and create chart:

```java
grid.enableRangeSelection()
    .enableCharts();

// User selects range → Creates chart from selection
```

### Range Selection + Server-Side Model

Works with large datasets:

```java
grid.enableRangeSelection()
    .useServerSideRowModel();

// Copy only visible (loaded) range to clipboard
```

---

## Performance

Range selection is lightweight; no performance impact on large datasets.

---

## Accessibility

- **Keyboard-Navigable** — Use Shift+Arrow to extend selection
- **Screen Reader Support** — Range announced when selected

---

## Testing

### Unit Test

```java
@Test
void rangeSelectionEnabledCorrectly() {
    RangeSelectionOptions opts = new RangeSelectionOptions();
    opts.setEnableRangeSelection(true);
    
    String json = mapper.writeValueAsString(opts);
    assertTrue(json.contains("\"enableRangeSelection\":true"));
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Range selection terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Code examples

---

**End of range-selection.rules.md**
