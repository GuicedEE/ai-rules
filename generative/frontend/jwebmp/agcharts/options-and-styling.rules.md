# Options and Styling — AgCharts (JWebMP)

Purpose
- Define how to shape `AgChartOptions` and series options for AG Charts 12.2.0 (38 chart-level options) using CRTP setters and JWebMP components.

Option model — All 38 AG Charts 12.2.0 Options

**Core Chart Elements (19 options)**
- `axes`: List of axis objects (NumberAxis, TimeAxis, CategoryAxis, LogAxis, OrdinalTimeAxis, UnitTimeAxis, GroupedCategoryAxis); use `AgAxisBaseOptions` subclasses.
- `series`: List of series objects; use concrete options (AgBarSeriesOptions, AgLineSeriesOptions, etc.) extending `AgSeriesBaseOptions`.
- `legend`: Chart legend configuration; use `AgChartLegendOptions` with enabled/position/formatter/listeners.
- `tooltip`: Chart-level tooltip; use `AgChartTooltipOptions` with showDelay/hideDelay/position/formatting.
- `theme`: Theme name (string, e.g., "light", "dark") or theme object; use `AgChartTheme` for palette customization.
- `locale`: Localization settings; use `AgLocaleOptions` for number/time format and label translations.
- `background`: Chart background fill; use `AgChartBackground` with fill color or image.
- `seriesArea`: Series area appearance; use `AgSeriesAreaOptions` for fill/stroke styling.
- `overlays`: Decorative overlays (lines, bands); use `AgChartOverlaysOptions`.
- `navigator`: Mini chart for range selection (enterprise-only); use `AgNavigatorOptions` with miniChart/mask/handle styling.
- `gradientLegend`: Continuous gradient legend (enterprise-only); use `AgGradientLegendOptions`.
- `width`, `height`, `minWidth`, `minHeight`: Chart sizing in pixels; use Integer properties.
- `padding`: Chart padding; use Integer (uniform) or `AgPadding` object (directional).
- `title`, `subtitle`, `footnote`: Chart captions; use `AgChartCaptionOptions` with text/font/alignment.

**Interaction & Feature Options (19 options) — Added December 2025**
- `highlight`: Chart-level highlighting; use `AgChartHighlightOptions` with highlightedItem/unhighlightedItem/highlightedSeries/unhighlightedSeries styles.
- `animation`: Animation configuration; use `AgChartAnimationOptions` with enabled/duration/easing.
- `zoom`: Zoom and pan control; use `AgChartZoomOptions` with enabled/wheelBehaviour/minZoom.
- `ranges`: Range presets and selection UI; use `AgChartRangesOptions` for filtering/preset buttons.
- `sync`: Multi-chart synchronization; use `AgChartSyncOptions` with enabled/mode (tooltip/highlight/selection).
- `contextMenu`: Right-click menu control; use `AgChartContextMenuOptions` with enabled/customItems.
- `dataSource`: Data source adapter; use `AgChartDataSourceOptions` for remote data fetching.
- `keyboard`: Keyboard input enable/disable; use `AgChartKeyboardOptions` with enabled property.
- `touch`: Touch gesture support; use `AgChartTouchOptions` with enabled/pinchZoom.
- `listeners`: Chart-level event callbacks; use `AgChartListenersOptions` with onClick/onHighlight/onSelection (raw JavaScript).
- `formatter`: Modern formatter configuration; use `AgChartFormatterOptions` (replaces deprecated global formatter).
- `container`: Chart container config; use `AgChartContainerOptions` with id/className/styles.
- `data`: Chart-level data binding; use `AgChartDataOptions` for data source configuration.
- `annotations`: Annotations (lines, labels, shapes); use `AgChartAnnotationsOptions`.
- `initialState`: Initial zoom/pan state; use `AgChartInitialStateOptions` for replay/persistence.
- `misc`: Miscellaneous settings; use `AgChartMiscOptions` for CSP nonce/field notation/Google Fonts.

Patterns
- Build options with CRTP setters; return `(J) this` and avoid builders. Keep immutable defaults minimal; let host apps override.
- Axes: match axis class to data type (e.g., `AgNumberAxisOptions` for numeric, `AgTimeAxisOptions` for dates); pair with series domain/range keys accordingly.
- Legend/tooltip: use configuration objects (not raw maps); set enabled/position/formatter/listeners as needed.
- Theme/styling: apply palettes via `AgChartTheme`; keep enterprise-only palettes behind host-controlled flag.
- Highlight/animation/zoom: enable conditionally based on app scenarios; document rationale in migration notes if defaults change.
- Listeners: pass raw JavaScript function strings via `@JsonRawValue`; server code can generate these dynamically or use predefined templates.
- Sync modes: coordinate across multiple chart instances for UX consistency; document sync channel naming in host GUIDES.md.

Dynamic Series Coloring (AG Charts 12.2.0+)
- **Item Styler (Per-Datum)**: Use `setItemStyler(String)` on `AgSeriesBaseOptions` for conditional styling per data item. The styler function receives each datum and returns style objects (fill, stroke, opacity, etc.).
  ```java
  new AgBarSeriesOptions()
      .setXKey("category")
      .setYKey("value")
      .setItemStyler("""
          (datum) => ({
              fill: datum.value > 100 ? '#FF6B6B' : '#4ECDC4',
              stroke: datum.value > 100 ? '#C92A2A' : '#0B7285'
          })
          """)
  ```
  - Styler is serialized as raw JavaScript via `@JsonRawValue`; evaluated client-side.
  - Avoid workarounds like stacked phantom series; item styler is the native AG Charts approach for per-datum logic.
  - Also available on nested options: `AgSeriesMarkerOptions` and `AgSeriesLabelOptions` each support per-item styling.

- **Segmentation (Range-Based)**: Use `setSegmentation(AgSeriesSegmentationOptions)` to color series segments by axis value ranges. Define axis key (X or Y) and a list of segments with style overrides.
  ```java
  new AgBarSeriesOptions()
      .setXKey("category")
      .setYKey("value")
      .setSegmentation(new AgSeriesSegmentationOptions<>()
          .setKey(AgSegmentationKey.Y)
          .setSegments(List.of(
              new AgSeriesShapeSegmentOptions<>().setStop(50).setFill("#FF6B6B"),
              new AgSeriesShapeSegmentOptions<>().setStart(50).setStop(100).setFill("#FFD93D"),
              new AgSeriesShapeSegmentOptions<>().setStart(100).setFill("#6BCB77")
          )))
  ```
  - Segments are styled independently over defined axis ranges; unspecified properties inherit from series defaults.
  - Useful for threshold-based coloring (e.g., red/yellow/green zones).

- **Series-Level Fill**: Set `setFill(String)` or `setFill(AgGradientColor)` / `setFill(AgPatternFill)` / `setFill(AgImageFill)` for uniform series styling.
  - Single-color fill: `setFill("#FF6B6B")`
  - Gradient fill: `setFill(new AgGradientColor<>().setType("linear")...)` (supports linear/radial).
  - Pattern/image: `setFill(new AgPatternFill<>()...)` or `setFill(new AgImageFill<>()...)`.

- **Highlight Integration**: Combine `itemStyler` with `setHighlight(AgSeriesHighlightOptions)` for distinct hover/selection states.
  ```java
  new AgBarSeriesOptions()
      .setItemStyler("(datum) => ({ fill: datum.value > 100 ? '#FF6B6B' : '#4ECDC4' })")
      .setHighlight(new AgSeriesHighlightOptions<>()
          .setItemStyler("(datum) => ({ fill: datum.value > 100 ? '#AA0000' : '#009080', opacity: 0.9 })"))
  ```

- **Best Practices**:
  - Prefer `itemStyler` for data-driven logic; avoids phantom series and legend clutter.
  - Use `segmentation` for fixed threshold bands (e.g., performance zones, SLA tiers).
  - Apply fill opacity sparingly; ensure sufficient contrast for accessibility.
  - Test color logic across all data states (edge cases, nulls, zero values).
  - Document color mappings in host GUIDES.md for maintainability.

Deprecation (AG Charts 12.2.0 alignment)
- Removed: `highlightStyle` in series; use series-level `highlight` or chart-level `highlight`.
- Removed: `formatterFunction`, `formatterFunctions`, `formatterFormats` (global formatter); use `AgChartFormatterOptions` instead.
- Removed: `seriesId` field; use `id` only.
- Kept for compatibility: deprecated formatter classes under `options/formatters/` (not serialized).

Example (options construction)
```java
AgBarChart chart = new AgBarChart()
    .setId("salesChart")
    .setOptions(new AgChartOptions()
        .setTitle(new AgChartCaptionOptions().setText("Quarterly Sales"))
        .setAxes(List.of(
            new AgCategoryAxisOptions().setType("category").setKeys(List.of("quarter")),
            new AgNumberAxisOptions().setType("number")))
        .setLegend(new AgChartLegendOptions().setPosition("bottom"))
        .setHighlight(new AgChartHighlightOptions()
            .setHighlightedItem(new AgChartHighlightStyleOptions().setFill("red").setOpacity(1.0))
            .setUnhighlightedItem(new AgChartHighlightStyleOptions().setOpacity(0.3)))
        .setAnimation(new AgChartAnimationOptions().setEnabled(true).setDuration(500))
        .setSeries(List.of(new AgBarSeriesOptions()
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
