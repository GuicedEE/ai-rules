# jwebmp-agcharts: Chart options

Read this reference when working on the topics below. Commands run from the skill directory.

- [Chart Types](#chart-types)
- [Axes Configuration](#axes-configuration)
- [Legend Configuration](#legend-configuration)
- [Tooltip Configuration](#tooltip-configuration)
- [Theming](#theming)
- [Animation](#animation)
- [Zoom & Pan](#zoom--pan)
- [Navigator Component](#navigator-component)
- [Gradient Legend](#gradient-legend)
- [Context Menu](#context-menu)

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

