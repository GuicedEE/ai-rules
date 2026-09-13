---
name: jwebmp-agcharts-enterprise
description: "Add licensed AG Charts Enterprise visualizations to JWebMP, including financial charts, heatmaps, treemaps, and sankey diagrams."
metadata:
  short-description: AG Charts Enterprise premium features
---

# JWebMP AG Charts Enterprise

AG Charts Enterprise integration for JWebMP with premium charting features.

## Additional Features

- **Advanced Chart Types** — Heatmaps, Treemaps, Sunburst, Sankey, Waterfall
- **Financial Charts** — Candlestick, OHLC
- **Advanced Animations** — Premium animation effects
- **Enterprise Features** — Export, server-side rendering

## Advanced Chart Types

### Heatmap

```java
new AgHeatmapSeriesOptions<>()
    .setXKey("date")
    .setYKey("category")
    .setColorKey("value")
    .setColorRange(List.of("#FFFFFF", "#FF0000"));
```

### Treemap

```java
new AgTreemapSeriesOptions<>()
    .setLabelKey("name")
    .setSizeKey("size")
    .setColorKey("value");
```

### Sunburst

```java
new AgSunburstSeriesOptions<>()
    .setLabelKey("name")
    .setSizeKey("size")
    .setColorKey("category");
```

### Sankey

```java
new AgSankeySeriesOptions<>()
    .setFromKey("source")
    .setToKey("target")
    .setSizeKey("value");
```

### Waterfall

```java
new AgWaterfallSeriesOptions<>()
    .setXKey("category")
    .setYKey("value");
```

### Candlestick

```java
new AgCandlestickSeriesOptions<>()
    .setXKey("date")
    .setOpenKey("open")
    .setHighKey("high")
    .setLowKey("low")
    .setCloseKey("close");
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>agcharts-enterprise</artifactId>
</dependency>
```

**Note:** Requires valid AG Charts Enterprise license.

## References

- Module: `com.jwebmp.plugins.agchartsenterprise`
- AG Charts Enterprise: 13.1.0
- Java: 25+
- License: Apache 2.0 (code), AG Charts Enterprise license required
- [AG Charts Enterprise](https://charts.ag-grid.com/license-pricing/)
