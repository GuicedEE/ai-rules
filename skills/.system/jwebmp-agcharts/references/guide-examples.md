# jwebmp-agcharts: Examples

Read this reference when working on the topics below. Commands run from the skill directory.

- [Multi-Series Example](#multi-series-example)
- [Common Patterns](#common-patterns)

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

