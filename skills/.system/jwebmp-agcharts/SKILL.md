---
name: jwebmp-agcharts
description: "Build JWebMP AG Charts community visualizations with Java chart options, generated TypeScript, data binding, and themes."
metadata:
  short-description: AG Charts 13.1.0 charting integration
---

# JWebMP AG Charts

Enterprise-grade charting library integration for JWebMP with AG Charts 13.1.0 and Angular 21.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Chart options](references/guide-chart-options.md): Chart Types; Axes Configuration; Legend Configuration; Tooltip Configuration; Theming; Animation; Zoom & Pan; Navigator Component; Gradient Legend; Context Menu.
- [Examples](references/guide-examples.md): Multi-Series Example; Common Patterns.
- [Integration](references/guide-integration.md): Complete Chart Options (38); NPM Dependencies; JPMS Module; Installation; Exported Packages.

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
