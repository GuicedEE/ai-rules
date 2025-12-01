# Options and Styling — AgCharts (JWebMP)

Purpose
- Define how to shape `AgChartOptions` and series options for AG Charts 12.2+ using CRTP setters and JWebMP components.

Option model essentials
- `AgChartOptions` aggregates axes (`options/axes/*`), legend/tooltip (`options/legend/*`, `options/tooltip/*`), theme/background/locale, overlays/navigator/gradient legend/highlight/zoom/sync/ranges/contextMenu/dataSource/animation, formatter, keyboard/touch toggles.
- Series base (`AgSeriesBaseOptions`) provides label/marker/tooltip/segmentation/highlight plus fills (gradient/pattern/image) and raw color strings. Concrete series (bar/line/area/pie/donut/bubble/combination/scatter) layer chart-specific props.
- Deprecated in AG Charts 12.2: `highlightStyle` in series; use `highlight`. `AgSeriesAreaPaddingOptions` replaced by general `Padding`/`PaddingOptions`.

Patterns
- Build options with CRTP setters; return `(J) this` and avoid builders. Keep immutable defaults minimal; let host apps override.
- Axes: use matching axis classes (e.g., `AgNumberAxisOptions`, `AgTimeAxisOptions`); pair with series domain/measure data accordingly.
- Legend/tooltip: prefer configuration objects (`AgChartLegendOptions`, `AgChartTooltipOptions`) instead of raw maps; set `enabled`, `position`, `formatter` as needed.
- Theme/styling: apply palettes via `AgChartTheme`; keep enterprise-only palettes behind host-controlled flag.
- Navigator/gradient legend/highlight/zoom/sync/ranges/contextMenu: enable only when app scenarios require them; document in migration notes if defaults change.

Example (options construction)
```java
AgBarChart chart = new AgBarChart()
    .setId("salesChart")
    .setOptions(new AgChartOptions()
        .setTitle("Quarterly Sales")
        .setAxes(List.of(new AgCategoryAxisOptions(), new AgNumberAxisOptions()))
        .setLegend(new AgChartLegendOptions().setPosition("bottom"))
        .setSeries(List.of(new AgSeriesBarOptions()
            .setXKey("quarter")
            .setYKey("value")
            .setLabel(new AgChartLabelOptions().setEnabled(true)))));
```

See also
- Topic index — ./README.md
- Chart components — ./chart-components.rules.md
- ERD (options relationships) — ../../../../../docs/architecture/erd-chart-model.md
- Angular integration — ./angular-integration.rules.md
- Angular rules — ../../../language/angular/README.md
