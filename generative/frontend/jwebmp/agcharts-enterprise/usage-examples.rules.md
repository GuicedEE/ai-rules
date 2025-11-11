# Usage Examples (CRTP) — AgCharts Enterprise

Overview
- Examples assume CRTP style for fluent APIs in JWebMP.
- These are Java-side pseudocode snippets using JWebMP components. The enterprise plugin ensures the Angular build includes `ag-charts-enterprise` via the Page Configurator; no TS edits.

General pattern
- Construct charts the same way as in the community plugin; enterprise unlocks additional series types, interactions, and APIs on the client.

Minimal Java example
- Create a chart using the community API; enterprise features become available when the enterprise plugin is on the classpath.

```java
// Pseudocode example: construct a chart in a JWebMP page/component
public class SalesChart<J extends SalesChart<J>> extends Div<J> {
    public SalesChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Quarterly Sales")
            .withSeries(/* column/line series config */)
            .withLegendShown(true);
        add(chart);
    }
}
```

Pivot chart API (Enterprise)
- Use the same component; enable pivoting through dataset/series options that are recognized by the enterprise runtime.
- Server side defines intent; the client enterprise library performs pivoting.

```java
public class PivotSalesChart<J extends PivotSalesChart<J>> extends Div<J> {
    public PivotSalesChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Sales by Region (Pivot)")
            .withOption("pivot", true) // Enterprise runtime interprets
            .withOption("groupBy", List.of("region"))
            .withOption("values", List.of("revenue"))
            .withOption("aggregation", "sum")
            .withSeries(/* automatically inferred from pivot */);
        add(chart);
    }
}
```

Cross-filtering (Enterprise)
- Enable cross-filter interactivity. Filter selections in one chart update others using shared ids/context.

```java
public class CrossFilterDashboard<J extends CrossFilterDashboard<J>> extends Div<J> {
    public CrossFilterDashboard() {
        String contextId = "sales-dashboard-ctx";
        AgChartComponent<?> bar = new AgChartComponent<>()
            .withId("barSales")
            .withOption("crossFilter", true)
            .withOption("contextId", contextId)
            .withSeries(/* ... */);
        AgChartComponent<?> pie = new AgChartComponent<>()
            .withId("pieRegion")
            .withOption("crossFilter", true)
            .withOption("contextId", contextId)
            .withSeries(/* ... */);
        add(bar);
        add(pie);
    }
}
```

Time series (Enterprise)
- Use time axes and enterprise features like zoom/pan, advanced tooltips.

```java
public class TimeSeriesChart<J extends TimeSeriesChart<J>> extends Div<J> {
    public TimeSeriesChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Requests per Minute")
            .withOption("xAxis.type", "time")
            .withOption("yAxis.type", "number")
            .withOption("navigator.enabled", true) // Enterprise timeline navigator
            .withSeries(/* time series data points */);
        add(chart);
    }
}
```

Chart container (Enterprise)
- Place charts into layout containers (Tabs, SplitPanels, etc.) using JWebMP components. Avoid inline HTML.

```java
public class ChartContainer<J extends ChartContainer<J>> extends Div<J> {
    public ChartContainer() {
        Tabs<?> tabs = new Tabs<>()
            .addTab("Overview", new SalesChart<>())
            .addTab("Trends", new TimeSeriesChart<>());
        add(tabs);
    }
}
```

Additional enterprise examples
- Waterfall chart

```java
public class WaterfallChart<J extends WaterfallChart<J>> extends Div<J> {
    public WaterfallChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Cash Flow Waterfall")
            .withOption("series[0].type", "waterfall")
            .withOption("series[0].data", /* steps with positive/negative deltas */ null);
        add(chart);
    }
}
```

- Treemap

```java
public class TreemapChart<J extends TreemapChart<J>> extends Div<J> {
    public TreemapChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Portfolio Allocation")
            .withOption("series[0].type", "treemap")
            .withOption("series[0].data", /* hierarchical data */ null);
        add(chart);
    }
}
```

- Gantt (if provided by Enterprise at time of use)

```java
public class GanttChart<J extends GanttChart<J>> extends Div<J> {
    public GanttChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Project Plan")
            .withOption("series[0].type", "gantt")
            .withOption("series[0].data", /* tasks with start/end */ null);
        add(chart);
    }
}
```

Notes
- Do not place inline HTML; use JWebMP components.
- No special Java code is needed to enable enterprise beyond including the plugin; ensure licensing on the client when applicable.
- Options shown are illustrative and passed through to the client configuration expected by AG Charts Enterprise.

See alsoW
- Integration — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing — ./licensing-and-activation.rules.md
- Troubleshooting — ./troubleshooting.rules.md
