---
name: jwebmp-chartjs
description: Chart.js integration for JWebMP providing simple yet flexible charting. Supports line, bar, radar, doughnut, pie, polar area, bubble, and scatter charts with responsive design, animations, and plugins. Use when working with Chart.js, creating simple charts, building dashboards, or implementing lightweight charting in JWebMP applications.
metadata:
  short-description: Chart.js charting integration
---

# JWebMP Chart.js

Chart.js integration for JWebMP providing simple yet flexible charting.

## Core Features

- **8 Chart Types** — Line, Bar, Radar, Doughnut, Pie, Polar Area, Bubble, Scatter
- **Responsive** — Auto-resize to container
- **Animations** — Smooth chart animations
- **Plugins** — Extensible plugin system
- **Mixed Charts** — Combine chart types
- **Accessibility** — Screen reader support

## Quick Start

### Line Chart

```java
ChartJS lineChart = new ChartJS()
    .setType(ChartType.LINE)
    .setData(new ChartData()
        .setLabels(List.of("Jan", "Feb", "Mar", "Apr", "May", "Jun"))
        .setDatasets(List.of(
            new Dataset()
                .setLabel("Sales 2024")
                .setData(List.of(12, 19, 3, 5, 2, 3))
                .setBorderColor("rgb(75, 192, 192)")
                .setTension(0.1)
        )))
    .setOptions(new ChartOptions()
        .setResponsive(true)
        .setMaintainAspectRatio(true));
```

### Bar Chart

```java
ChartJS barChart = new ChartJS()
    .setType(ChartType.BAR)
    .setData(new ChartData()
        .setLabels(List.of("Red", "Blue", "Yellow", "Green", "Purple", "Orange"))
        .setDatasets(List.of(
            new Dataset()
                .setLabel("# of Votes")
                .setData(List.of(12, 19, 3, 5, 2, 3))
                .setBackgroundColor(List.of(
                    "rgba(255, 99, 132, 0.2)",
                    "rgba(54, 162, 235, 0.2)",
                    "rgba(255, 206, 86, 0.2)",
                    "rgba(75, 192, 192, 0.2)",
                    "rgba(153, 102, 255, 0.2)",
                    "rgba(255, 159, 64, 0.2)"
                ))
                .setBorderWidth(1)
        )));
```

### Pie/Doughnut Chart

```java
ChartJS pieChart = new ChartJS()
    .setType(ChartType.PIE)  // or ChartType.DOUGHNUT
    .setData(new ChartData()
        .setLabels(List.of("Red", "Blue", "Yellow"))
        .setDatasets(List.of(
            new Dataset()
                .setData(List.of(300, 50, 100))
                .setBackgroundColor(List.of(
                    "rgb(255, 99, 132)",
                    "rgb(54, 162, 235)",
                    "rgb(255, 205, 86)"
                ))
        )));
```

## Chart Types

```java
ChartType.LINE           // Line chart
ChartType.BAR            // Vertical bar chart
ChartType.HORIZONTAL_BAR // Horizontal bar chart
ChartType.RADAR          // Radar/spider chart
ChartType.DOUGHNUT       // Doughnut chart
ChartType.PIE            // Pie chart
ChartType.POLAR_AREA     // Polar area chart
ChartType.BUBBLE         // Bubble chart
ChartType.SCATTER        // Scatter plot
```

## Chart Options

```java
new ChartOptions()
    .setResponsive(true)
    .setMaintainAspectRatio(true)
    .setAspectRatio(2)
    .setPlugins(new PluginsOptions()
        .setTitle(new TitleOptions()
            .setDisplay(true)
            .setText("Chart Title"))
        .setLegend(new LegendOptions()
            .setDisplay(true)
            .setPosition("top")))
    .setScales(new ScalesOptions()
        .setX(new ScaleOptions().setDisplay(true))
        .setY(new ScaleOptions()
            .setDisplay(true)
            .setBeginAtZero(true)));
```

## Dataset Options

```java
new Dataset()
    .setLabel("Dataset 1")
    .setData(dataPoints)
    .setBackgroundColor("rgba(75, 192, 192, 0.2)")
    .setBorderColor("rgb(75, 192, 192)")
    .setBorderWidth(2)
    .setPointRadius(5)
    .setPointHoverRadius(7)
    .setTension(0.4)      // Line tension (0 = straight, 1 = curved)
    .setFill(true);       // Fill area under line
```

## Mixed Charts

```java
new ChartData()
    .setDatasets(List.of(
        new Dataset()
            .setType(ChartType.LINE)
            .setLabel("Line Dataset")
            .setData(List.of(10, 20, 30)),
        new Dataset()
            .setType(ChartType.BAR)
            .setLabel("Bar Dataset")
            .setData(List.of(15, 25, 35))
    ));
```

## Animations

```java
new ChartOptions()
    .setAnimation(new AnimationOptions()
        .setDuration(1000)
        .setEasing("easeInOutQuart")
        .setDelay(0));
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>chartjs</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.plugins.chartjs`
- Chart.js: 4.x
- Java: 25+
- License: Apache 2.0
- [Chart.js Docs](https://www.chartjs.org/docs/)
