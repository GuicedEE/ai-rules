# dynamic-series-coloring.rules.md — AG Grid Enterprise Dynamic Series Coloring

**Configuration guide for conditional cell coloring with 5 coloring strategies**

---

## Overview

**Dynamic Series Coloring** applies conditional colors to cells based on values or custom logic. Five strategies enable different coloring patterns: SOLID, VALUE_GRADIENT, VALUE_RANGE, POSITIVE_NEGATIVE, CUSTOM_CALLBACK.

### Key Concepts

- **Color Strategy** — Algorithm determining cell color
- **Color Gradient** — Smooth color transition (min → max)
- **Color Ranges** — Discrete color buckets by value
- **Positive/Negative** — Separate colors for positive/negative values
- **Custom Callback** — User-defined coloring function

---

## Configuration

### Strategy 1: SOLID (Single Color)

All cells same color:

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.SOLID);
coloring.setColor("#0066cc");  // Blue

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Strategy 2: VALUE_GRADIENT (Min ↔ Max)

Smooth color gradient from min to max value:

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_GRADIENT);
coloring.setMinColor("#ffffff");  // White
coloring.setMaxColor("#00aa00");  // Green
coloring.setValueRange(0, 100);   // Min/max values

grid.getOptions().setDynamicSeriesColoring(coloring);
```

**Result:** 
- 0 → White
- 50 → Light green
- 100 → Dark green

### Strategy 3: VALUE_RANGE (Buckets)

Color ranges based on value thresholds:

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_RANGE);

// Define color ranges
coloring.setColorRanges(List.of(
    new ColorRange(0, 25, "#ff0000"),      // Red: 0-25
    new ColorRange(25, 50, "#ffcc00"),     // Yellow: 25-50
    new ColorRange(50, 75, "#ffff00"),     // Light yellow: 50-75
    new ColorRange(75, 100, "#00aa00")     // Green: 75-100
));

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Strategy 4: POSITIVE_NEGATIVE (Polarity)

Separate colors for positive/negative values:

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.POSITIVE_NEGATIVE);
coloring.setPositiveColor("#00aa00");  // Green for profit
coloring.setNegativeColor("#ff0000");  // Red for loss
coloring.setZeroColor("#cccccc");      // Gray for zero

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Strategy 5: CUSTOM_CALLBACK (Function)

Custom coloring function:

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.CUSTOM_CALLBACK);
coloring.setColorCallback((row, column, value) -> {
    double v = (double) value;
    if (v > 100) return "#00aa00";        // High: green
    else if (v > 50) return "#ffcc00";    // Medium: yellow
    else return "#ff0000";                 // Low: red
});

grid.getOptions().setDynamicSeriesColoring(coloring);
```

---

## Usage Patterns

### Sales Heatmap (VALUE_GRADIENT)

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_GRADIENT);
coloring.setMinColor("#ffffff");     // White (low sales)
coloring.setMaxColor("#000066");     // Dark blue (high sales)
coloring.setValueRange(0, 1000000);  // $0 to $1M

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Performance Score (VALUE_RANGE)

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_RANGE);
coloring.setColorRanges(List.of(
    new ColorRange(0, 60, "#ff0000"),      // F: Red
    new ColorRange(60, 75, "#ff9900"),     // D: Orange
    new ColorRange(75, 85, "#ffcc00"),     // C: Yellow
    new ColorRange(85, 95, "#99cc00"),     // B: Light green
    new ColorRange(95, 100, "#00aa00")     // A: Green
));

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Profit/Loss (POSITIVE_NEGATIVE)

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.POSITIVE_NEGATIVE);
coloring.setPositiveColor("#00aa00");  // Green for profit
coloring.setNegativeColor("#ff0000");  // Red for loss
coloring.setZeroColor("#ffffff");      // White for break-even

grid.getOptions().setDynamicSeriesColoring(coloring);
```

### Smart Rules (CUSTOM_CALLBACK)

```java
ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.CUSTOM_CALLBACK);
coloring.setColorCallback((row, column, value) -> {
    if (column.equals("status") && value.equals("Alert")) {
        return "#ff0000";  // Red for alert status
    }
    if (column.equals("utilization") && ((Double) value) > 95) {
        return "#ff9900";  // Orange for over-utilization
    }
    return "#f5f5f5";      // Default gray
});

grid.getOptions().setDynamicSeriesColoring(coloring);
```

---

## Integration with Other Features

### Coloring + Charts

Charts inherit cell colors:

```java
grid.enableCharts();

ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.VALUE_GRADIENT);

// Chart colors match grid cell colors
```

### Coloring + Range Selection

Selected ranges use coloring:

```java
grid.enableRangeSelection();

ColoringConfig coloring = new ColoringConfig();
coloring.setStrategy(ColoringStrategy.POSITIVE_NEGATIVE);

// Range selection shows profit/loss colors
```

---

## Performance

Dynamic coloring adds minimal overhead:
- **VALUE_GRADIENT** — Lightweight (linear interpolation)
- **VALUE_RANGE** — Very lightweight (bucket lookup)
- **POSITIVE_NEGATIVE** — Negligible
- **CUSTOM_CALLBACK** — Depends on callback complexity

---

## Accessibility

### Color Blind Friendly

Avoid relying solely on color; add patterns:

```java
// Use text indicators in addition to color
new AgGridColumnDef<>("score")
    .setValueFormatter(params -> {
        double score = (double) params.getValue();
        String rating = score > 75 ? "GOOD" : score > 50 ? "OK" : "POOR";
        return score + " (" + rating + ")";
    })
```

### High Contrast

Use accessible color palette:

```java
coloring.setPositiveColor("#006600");  // Dark green
coloring.setNegativeColor("#990000");  // Dark red
```

---

## Testing

### Unit Test: Coloring Config

```java
@Test
void coloringStrategyConfigured() {
    ColoringConfig coloring = new ColoringConfig();
    coloring.setStrategy(ColoringStrategy.VALUE_GRADIENT);
    coloring.setMinColor("#ffffff");
    coloring.setMaxColor("#00aa00");
    
    String json = mapper.writeValueAsString(coloring);
    assertTrue(json.contains("\"strategy\":\"VALUE_GRADIENT\""));
}
```

---

## See Also

- [README.md](./README.md) — Parent index
- [GLOSSARY.md](./GLOSSARY.md) — Coloring terminology
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — Color examples
- [Charts](./charts.rules.md) — Chart coloring integration
- [Range Selection](./range-selection.rules.md) — Colored ranges

---

**End of dynamic-series-coloring.rules.md**
