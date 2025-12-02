# Usage Examples (CRTP) — AgCharts Enterprise

Overview
- Examples assume CRTP style for fluent APIs in JWebMP.
- These are Java-side pseudocode snippets using JWebMP components. The enterprise plugin ensures the Angular build includes `ag-charts-enterprise` via the Page Configurator; no TS edits.

Prerequisites (Java-only)
- Maven dependencies in your host app:
  - `com.jwebmp.plugins:agcharts` (community)
  - `com.jwebmp.plugins:agcharts-enterprise` (this module)
- Prefer importing the JWebMP BOM to align versions automatically.
- No manual Angular edits. The Page Configurator in this plugin contributes the `ag-charts-enterprise` NPM dependency.
- Load `docs/PROMPT_REFERENCE.md` (architecture + policy index) before prompting so the correct stacks and diagrams are pinned.

## Option type cheat sheet (agents / humans / LLMs)

Use this table when selecting option beans so prompts stay deterministic and humans can see where each class applies.

### Series (Enterprise-only)
| Option class | When to use | Key setters / properties | Tips |
| - | - | - | - |
| `AgRadialColumnSeriesOptions` | Circular column charts driven by categorical angles and numeric radii. | `setAngleKey`, `setRadiusKey`, `setGrouped`, `setStacked`, `setColumnWidthRatio`, `setCornerRadius`, `setLegendItemName`, `setStroke*`. | Pair with `AgRadiusNumberAxisOptions` to control the inner hole via `setInnerRadiusRatio`. |
| `AgRadialBarSeriesOptions` | Radial bars where the numeric value maps to angle and radius is categorical. | `setAngleKey`, `setRadiusKey`, `setStackGroup`, `setNormalizedTo`, `setItemStyler`, `setLineDash`, `setShowInLegend`. | Use when comparing categories around a circular scale (e.g., gauge-like dashboards). |
| `AgHeatmapSeriesOptions` | Heatmap/gridded insights (X/Y categories, color intensity). | `setxKey`, `setyKey`, `setColorKey`, `setColorRange`, `setItemPadding`, `setTextAlign`, `setShowInMiniChart`, `setStroke*`. | Always provide ≥2 colours in `colorRange`; use `setNodeClickRange("nearest")` for better hover fidelity. |
| `AgHeatmapSeriesLabelOptions` | Cell label control for heatmaps. | `setEnabled`, `setFormatter("function(params){...}")`. | Formatter is raw JavaScript; escape strings via `JsUtils.escapeJs` before passing to `.setFormatter`. |
| `AgSankeySeriesOptions` (v2.0.0+) | Flow and process visualization; source→target→value model. | `setSourceKey`, `setTargetKey`, `setValueKey`, `setNodeFill`, `setNodePadding*` (all 4 sides), `setStroke*`. | Use for supply chains, energy flows, process analysis; node padding controls layout spacing. |
| `AgTreemapSeriesOptions` (v2.0.0+) | Hierarchical rectangle partition; 4-dimensional (label/secondary/value/color). | `setLabelKey`, `setSecondaryLabelKey`, `setValueKey`, `setColorKey`, `setColorScale`, `setColorDomain`, `setCornerRadius`. | Best for org charts, budget allocation; color scale options: `viridis`, `plasma`, `inferno`, `magma`, `cividis`. |
| `AgSunburstSeriesOptions` (v2.0.0+) | Circular hierarchy with concentric segments; label/value/color model. | `setLabelKey`, `setValueKey`, `setColorKey`, `setColorScale`, `setColorDomain`, `setCornerRadius`. | Ideal for file systems, category drilldown; supports hover-drilldown interactions via client options. |
| `AgChordSeriesOptions` (v2.0.0+) | Relationship networks in circular layout; source→target→value. | `setSourceKey`, `setTargetKey`, `setValueKey`, `setNodeFill`, `setNodePaddingAngle`, `setStroke*`. | Use for migration flows, collaboration networks; angular padding controls arc spacing (degrees). |
| `AgFunnelSeriesOptions` (v2.0.0+) | Stage progression and conversion funnels; label/value model. | `setLabelKey`, `setValueKey`, `setOrientation` (`vertical`/`horizontal`), `setCornerRadius`, `setFill*`. | Simplest hierarchical series; ideal for sales pipelines and user journey stages. |

### Axis helpers
| Option class | Purpose | Notes |
| - | - | - |
| `AgRadiusNumberAxisOptions` | Numeric radius axis for polar/radial charts. | `setInnerRadiusRatio(0-1)` hollows the center; `setPositionAngle` aligns the axis with a degree value. |
| `AgPolarAxisLabelOptions` + `AgPolarAxisLabelOrientation` | Label styling for polar axes. | Choose orientations (`PARALLEL`, `PERPENDICULAR`, etc.) to keep labels readable; combine with `setFormatter` for unit suffixes. |

### Gauge root options
| Option class | When to use | Key pieces |
| - | - | - |
| `AgLinearGaugeOptions` | Linear gauges (vertical/horizontal). | Required `setValue`. Compose with `setScale(AgLinearGaugeScale)`, `setBar(AgLinearGaugeBarStyle)`, `setLabel(AgLinearGaugeLabelOptions)`, `setTargets(List<AgLinearGaugeTarget>)`, `setSegmentation(AgGaugeSegmentation)`, `setCornerMode`. |
| `AgRadialGaugeOptions` | Radial gauges with bars/needles. | Required `setValue`. Combine with `setNeedle(AgRadialGaugeNeedleStyle)`, `setBar(AgRadialGaugeBarStyle)`, `setScale(AgRadialGaugeScale)`, `setTargets(List<AgRadialGaugeTarget>)`, `setLabel(...)`, `setSecondaryLabel(...)`, plus geometry (`setInnerRadiusRatio`, `setStartAngle`, `setEndAngle`). |
| Shared helpers | Colour bands / targets. | `AgGaugeSegmentation` defines banding; `AgGaugeTarget`/`AgGaugeTargetPlacement` add goal markers; keep units consistent with the gauge scale. |

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
            .withOption("series[0].type", "column")
            .withOption("series[0].xKey", "quarter")
            .withOption("series[0].yKey", "revenue")
            .withLegendShown(true)
            .withData(List.of(
                Map.of("quarter", "Q1", "revenue", 120_000),
                Map.of("quarter", "Q2", 150_000),
                Map.of("quarter", "Q3", 170_000),
                Map.of("quarter", "Q4", 190_000)
            ));
        add(chart);
    }
}
```

Full page example (with layout)
```java
public class DashboardPage extends Page<DashboardPage> {
    @Override
    public void onInitialize() {
        super.onInitialize();
        Div<?> layout = new Div<>().addClass("grid grid-cols-2 gap-4");
        layout.add(new SalesChart<>());
        layout.add(new TimeSeriesChart<>());
        add(layout);
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
            .withOption("pivot.enabled", true) // Enterprise runtime interprets
            .withOption("pivot.groupBy", List.of("region"))
            .withOption("pivot.values", List.of("revenue"))
            .withOption("pivot.aggregation", "sum");
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

- Sankey (v2.0.0+)

```java
public class SankeyChart<J extends SankeyChart<J>> extends Div<J> {
    public SankeyChart() {
        AgSankeyChart<?> chart = new AgSankeyChart<>("process-flow")
            .setSourceKey("from")
            .setTargetKey("to")
            .setValueKey("amount")
            .setData(List.of(
                Map.of("from", "Sales", "to", "Processing", "amount", 120),
                Map.of("from", "Processing", "to", "Fulfillment", "amount", 100)
            ))
            .setFill("#1f77b4")
            .setNodeFill("#2ca02c")
            .setNodePaddingTop(5)
            .setNodePaddingRight(5)
            .setNodePaddingBottom(5)
            .setNodePaddingLeft(5);
        add(chart);
    }
}
```

- Sunburst (v2.0.0+)

```java
public class SunburstChart<J extends SunburstChart<J>> extends Div<J> {
    public SunburstChart() {
        AgSunburstChart<?> chart = new AgSunburstChart<>("hierarchy")
            .setLabelKey("name")
            .setValueKey("value")
            .setColorKey("metric")
            .setData(List.of(
                Map.of("name", "Root", "value", 1000, "metric", 50),
                Map.of("name", "Branch A", "value", 600, "metric", 65)
            ))
            .setColorScale("viridis")
            .setColorDomain(100.0);
        add(chart);
    }
}
```

- Chord (v2.0.0+)

```java
public class ChordChart<J extends ChordChart<J>> extends Div<J> {
    public ChordChart() {
        AgChordChart<?> chart = new AgChordChart<>("relationships")
            .setSourceKey("source")
            .setTargetKey("target")
            .setValueKey("strength")
            .setData(List.of(
                Map.of("source", "Node A", "target", "Node B", "strength", 50),
                Map.of("source", "Node B", "target", "Node C", "strength", 35)
            ))
            .setFill("#1f77b4")
            .setNodePaddingAngle(5);
        add(chart);
    }
}
```

- Funnel (v2.0.0+)

```java
public class FunnelChart<J extends FunnelChart<J>> extends Div<J> {
    public FunnelChart() {
        AgFunnelChart<?> chart = new AgFunnelChart<>("sales-funnel")
            .setLabelKey("stage")
            .setValueKey("count")
            .setData(List.of(
                Map.of("stage", "Awareness", "count", 1000),
                Map.of("stage", "Interest", "count", 700),
                Map.of("stage", "Conversion", "count", 100)
            ))
            .setOrientation("vertical")
            .setFill("#70AD47");
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

AG Grid context (for dashboards combining Grid and Charts)
- While this module focuses on Charts, dashboards often combine AG Grid Enterprise and Charts:
  - Use JWebMP AG Grid plugin for tables/grids.
  - Use cross-filtering or event bridging: grid selection events can be forwarded to charts via shared context ids or custom events.
  - Keep data contracts simple: rows (grid) and series datapoints (charts) should share stable keys (e.g., region, productId).

See also
- Integration — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing — ./licensing-and-activation.rules.md
- Troubleshooting — ./troubleshooting.rules.md
