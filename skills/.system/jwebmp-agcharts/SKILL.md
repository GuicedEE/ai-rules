---
name: jwebmp-agcharts
description: Enterprise-grade charting library integration for JWebMP with Angular 21. Provides CRTP-based fluent Java API for AG Charts 13.1.0 with TypeScript type generation, reactive data binding, and server-side chart configuration. Supports line, bar, area, scatter, bubble, pie, donut, histogram charts with advanced axes, theming, tooltips, legends, zoom, and navigator components. Use when working with AG Charts, creating data visualizations, configuring chart options, building dashboards, or implementing charting features in JWebMP applications.
metadata:
  short-description: AG Charts 13.1.0 charting integration
---

# JWebMP AG Charts

Enterprise-grade charting library integration for JWebMP with AG Charts 13.1.0 and Angular 21.

## Core Features

- **Complete AG Charts 13.1.0 API** — All 38 official chart options implemented
- **CRTP Fluent Builders** — Type-safe, self-referencing setters
- **Angular 21 Integration** — Seamless component integration
- **TypeScript Type Generation** — Automatic interface generation
- **Reactive Data Binding** — Real-time chart updates
- **Multiple Chart Types** — Line, Bar, Area, Scatter, Bubble, Pie, Donut, Histogram
- **Advanced Axes** — Number, Time, Log, Category, Grouped Category
- **Rich Interactions** — Tooltips, legends, zoom, pan, highlighting, animations

## Quick Start

### Basic Line Chart

```java
@NgComponent
public class LineChartComponent implements INgComponent<LineChartComponent> {
    @Override
    public String render() {
        AgChartOptions<LineChartComponent> options = new AgChartOptions<>(this)
            .setData("""
                [
                    { month: 'Jan', sales: 100 },
                    { month: 'Feb', sales: 150 },
                    { month: 'Mar', sales: 130 }
                ]
                """)
            .setSeries(List.of(
                new AgLineSeriesOptions<>()
                    .setXKey("month")
                    .setYKey("sales")
                    .setYName("Sales")
            ))
            .setAxes(List.of(
                new AgCategoryAxisOptions<>()
                    .setType("category")
                    .setPosition(AgCartesianAxisPosition.BOTTOM),
                new AgNumberAxisOptions<>()
                    .setType("number")
                    .setPosition(AgCartesianAxisPosition.LEFT)
            ));

        return """
            <ag-charts-angular [options]="chartOptions">
            </ag-charts-angular>
            """;
    }
}
```

## Chart Types

### Cartesian Charts

#### Line Chart

```java
new AgLineSeriesOptions<>()
    .setXKey("date")
    .setYKey("value")
    .setStroke("blue")
    .setStrokeWidth(2)
    .setMarker(new AgSeriesMarkerOptions<>()
        .setEnabled(true)
        .setShape(AgMarkerShape.CIRCLE));
```

#### Bar Chart

```java
new AgBarSeriesOptions<>()
    .setXKey("category")
    .setYKey("amount")
    .setFill("steelblue")
    .setStroke("navy")
    .setStrokeWidth(1);
```

#### Area Chart

```java
new AgAreaSeriesOptions<>()
    .setXKey("x")
    .setYKey("y")
    .setFill("rgba(0, 150, 136, 0.5)")
    .setStroke("rgb(0, 150, 136)")
    .setFillOpacity(0.7);
```

#### Scatter Chart

```java
new AgScatterSeriesOptions<>()
    .setXKey("weight")
    .setYKey("height")
    .setMarker(new AgSeriesMarkerOptions<>()
        .setShape(AgMarkerShape.CIRCLE)
        .setSize(8)
        .setFill("red"));
```

#### Bubble Chart

```java
new AgBubbleSeriesOptions<>()
    .setXKey("x")
    .setYKey("y")
    .setSizeKey("size")
    .setColorKey("category")
    .setMarker(new AgSeriesMarkerOptions<>()
        .setMaxSize(30));
```

### Polar Charts

#### Pie Chart

```java
new AgPieSeriesOptions<>()
    .setAngleKey("value")
    .setCalloutLabelKey("label")
    .setSectorLabelKey("value")
    .setInnerRadiusOffset(0);
```

#### Donut Chart

```java
new AgDonutSeriesOptions<>()
    .setAngleKey("value")
    .setCalloutLabelKey("category")
    .setInnerRadiusRatio(0.7)
    .setInnerLabels(List.of(
        new AgDonutInnerLabel<>()
            .setText("Total")
            .setFontSize(24)
            .setFontWeight("bold")
    ))
    .setInnerCircle(new AgDonutInnerCircle<>()
        .setFill("white"));
```

## Axes Configuration

### Number Axis

```java
new AgNumberAxisOptions<>()
    .setType("number")
    .setPosition(AgCartesianAxisPosition.LEFT)
    .setTitle(new AgAxisCaptionOptions<>()
        .setText("Revenue ($)")
        .setEnabled(true))
    .setLabel(new AgAxisLabelOptions<>()
        .setFormat(",.0f"))
    .setMin(0)
    .setMax(1000);
```

### Category Axis

```java
new AgCategoryAxisOptions<>()
    .setType("category")
    .setPosition(AgCartesianAxisPosition.BOTTOM)
    .setTitle(new AgAxisCaptionOptions<>()
        .setText("Quarter")
        .setFontSize(14));
```

### Time Axis

```java
new AgTimeAxisOptions<>()
    .setType("time")
    .setPosition(AgCartesianAxisPosition.BOTTOM)
    .setInterval(new AgAxisTimeIntervalOptions<>()
        .setTimeUnit(AgTimeIntervalUnit.MONTH)
        .setStep(1))
    .setLabel(new AgAxisLabelOptions<>()
        .setFormat("%b %Y"));
```

### Log Axis

```java
new AgLogAxisOptions<>()
    .setType("log")
    .setPosition(AgCartesianAxisPosition.LEFT)
    .setBase(10)
    .setMin(1)
    .setMax(10000);
```

### Grouped Category Axis

```java
new AgGroupedCategoryAxisOptions<>()
    .setType("grouped-category")
    .setPosition(AgCartesianAxisPosition.BOTTOM);
```

## Legend Configuration

```java
new AgChartLegendOptions<>()
    .setEnabled(true)
    .setPosition(new AgChartLegendPositionOptions<>()
        .setPosition("bottom"))
    .setSpacing(20)
    .setItem(new AgChartLegendItemOptions<>()
        .setMarker(new AgChartLegendItemMarkerOptions<>()
            .setShape(AgMarkerShape.CIRCLE)
            .setSize(12))
        .setLabel(new AgChartLegendItemLabelOptions<>()
            .setFontSize(12)))
    .setPagination(new AgChartLegendPaginationOptions<>()
        .setMarker(new AgChartLegendPaginationButtonOptions<>()
            .setSize(15)));
```

## Tooltip Configuration

```java
new AgChartTooltipOptions<>()
    .setEnabled(true)
    .setMode(AgTooltipMode.GROUPED)
    .setPosition(new AgTooltipPositionOptions<>()
        .setType("pointer")
        .setXOffset(10)
        .setYOffset(10))
    .setInteraction(new AgTooltipInteractionOptions<>()
        .setEnabled(true))
    .setDelay(0);
```

## Theming

### Built-in Themes

```java
options.setTheme(AgChartThemeName.AG_MATERIAL);
// Or: AG_POLYCHROME, AG_VIVID, AG_SOLAR, AG_DEFAULT
```

### Custom Theme

```java
AgChartTheme theme = new AgChartTheme()
    .setPalette(new AgChartThemePalette()
        .setFills(List.of("#5470C6", "#91CC75", "#FAC858"))
        .setStrokes(List.of("#5470C6", "#91CC75", "#FAC858")))
    .setOverrides(new AgChartThemeParams()
        .setCommon(new AgChartThemeCommonOptions()
            .setBackground(new AgChartBackground()
                .setFill("#FFFFFF"))));

options.setTheme(theme);
```

## Animation

```java
options.setAnimation(new AgAnimationOptions()
    .setEnabled(true)
    .setDuration(1000));
```

## Zoom & Pan

```java
options.setZoom(new AgZoomOptions()
    .setEnabled(true)
    .setEnableAxisDragging(true)
    .setEnableScrolling(true)
    .setEnableSelecting(true));
```

## Navigator Component

Mini-chart for large datasets:

```java
options.setNavigator(new AgNavigatorOptions()
    .setEnabled(true)
    .setHeight(30)
    .setMin(0.2)
    .setMax(0.8));
```

## Gradient Legend

For heatmaps and continuous scales:

```java
options.setGradientLegend(new AgGradientLegendOptions()
    .setEnabled(true)
    .setPosition("right")
    .setGradient(new AgGradientLegendGradientOptions()
        .setPreferredLength(200)));
```

## Context Menu

```java
options.setContextMenu(new AgContextMenuOptions()
    .setEnabled(true));
```

## Multi-Series Example

```java
AgChartOptions<MyComponent> options = new AgChartOptions<>(this)
    .setTitle(new AgChartCaptionOptions<>()
        .setText("Quarterly Sales by Region")
        .setEnabled(true))
    .setData(salesData)
    .setSeries(List.of(
        new AgBarSeriesOptions<>()
            .setXKey("quarter")
            .setYKey("north")
            .setYName("North Region")
            .setFill("#4285F4"),
        new AgBarSeriesOptions<>()
            .setXKey("quarter")
            .setYKey("south")
            .setYName("South Region")
            .setFill("#34A853"),
        new AgLineSeriesOptions<>()
            .setXKey("quarter")
            .setYKey("average")
            .setYName("Average")
            .setStroke("#EA4335")
            .setStrokeWidth(3)
    ))
    .setAxes(List.of(
        new AgCategoryAxisOptions<>()
            .setType("category")
            .setPosition(AgCartesianAxisPosition.BOTTOM),
        new AgNumberAxisOptions<>()
            .setType("number")
            .setPosition(AgCartesianAxisPosition.LEFT)
            .setTitle(new AgAxisCaptionOptions<>().setText("Sales ($)"))
    ))
    .setLegend(new AgChartLegendOptions<>()
        .setEnabled(true)
        .setPosition(new AgChartLegendPositionOptions<>()
            .setPosition("bottom")));
```

## CRTP Pattern

All options classes use CRTP for type-safe fluent builders:

```java
public class AgChartOptions<J extends AgChartOptions<J>>
        extends ChartOptionsBase<J> {

    public J setTitle(AgChartCaptionOptions<?> title) {
        this.title = title;
        return (J) this;
    }

    public J setSeries(List<AgSeriesBaseOptions<?>> series) {
        this.series = series;
        return (J) this;
    }
}
```

Method chaining returns correct type:

```java
AgChartOptions<MyComponent> options = new AgChartOptions<>(this)
    .setTitle(title)    // Returns AgChartOptions<MyComponent>
    .setSeries(series)  // Still AgChartOptions<MyComponent>
    .setLegend(legend); // Type-safe throughout
```

## Complete Chart Options (38)

### Core Elements (19)
- `axes`, `series`, `legend`, `tooltip`, `theme`
- `locale`, `background`, `seriesArea`, `overlays`, `navigator`
- `gradientLegend`, `width`, `height`, `minWidth`, `minHeight`
- `padding`, `title`, `subtitle`, `footnote`

### Interactions & Features (19)
- `highlight`, `animation`, `zoom`, `ranges`, `sync`
- `contextMenu`, `dataSource`, `keyboard`, `touch`, `listeners`
- `formatter`, `container`, `data`, `annotations`, `initialState`
- `misc`

## NPM Dependencies

```json
{
  "dependencies": {
    "ag-charts-angular": "^13.1.0",
    "ag-charts-community": "^13.1.0"
  }
}
```

## Common Patterns

### Dynamic Data Updates

```java
@NgDataService
public class ChartDataService implements INgDataService<ChartDataService> {
    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        return repository.getChartData();
    }
}
```

### Responsive Charts

```java
options
    .setWidth(null)  // Auto-width
    .setHeight(400)
    .setMinWidth(300)
    .setMinHeight(200);
```

### Event Handling

Use Angular event bindings in template:

```typescript
<ag-charts-angular
    [options]="chartOptions"
    (chartReady)="onChartReady($event)"
    (seriesNodeClick)="onNodeClick($event)">
</ag-charts-angular>
```

## JPMS Module

```java
module com.jwebmp.plugins.agcharts {
    requires transitive com.jwebmp.core;
    requires transitive com.jwebmp.core.angular;
    requires com.fasterxml.jackson.annotation;

    exports com.jwebmp.plugins.agcharts;
    exports com.jwebmp.plugins.agcharts.options;
    exports com.jwebmp.plugins.agcharts.options.axes;
    exports com.jwebmp.plugins.agcharts.options.series;
    exports com.jwebmp.plugins.agcharts.options.legend;
    exports com.jwebmp.plugins.agcharts.options.tooltip;
    exports com.jwebmp.plugins.agcharts.options.theme;
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>agcharts</artifactId>
</dependency>
```

## Exported Packages

- `com.jwebmp.plugins.agcharts` — Core plugin
- `com.jwebmp.plugins.agcharts.options` — Main options
- `com.jwebmp.plugins.agcharts.options.axes` — Axis configuration
- `com.jwebmp.plugins.agcharts.options.series` — Series types
- `com.jwebmp.plugins.agcharts.options.legend` — Legend configuration
- `com.jwebmp.plugins.agcharts.options.tooltip` — Tooltip configuration
- `com.jwebmp.plugins.agcharts.options.theme` — Theme support
- `com.jwebmp.plugins.agcharts.options.navigator` — Navigator component
- `com.jwebmp.plugins.agcharts.options.animation` — Animation control
- `com.jwebmp.plugins.agcharts.options.zoom` — Zoom/pan control

## Best Practices

- **Use CRTP pattern correctly** — Always use generic type `<J extends YourClass<J>>`
- **Set required fields** — Ensure `type`, `xKey`, `yKey` for series
- **Leverage themes** — Use built-in themes for consistency
- **Handle null data** — Check for null/undefined before rendering
- **Optimize updates** — Batch data updates to minimize re-renders
- **Follow Angular patterns** — Use observables for reactive data
- **Test with real data** — Use production-like datasets

## References

- Module: `com.jwebmp.plugins.agcharts`
- AG Charts: 13.1.0
- Angular: 20
- Java: 25+
- License: Apache 2.0
- [AG Charts Documentation](https://charts.ag-grid.com/)
- [AG Charts API Reference](https://charts.ag-grid.com/javascript/api/)
