# jwebmp-agcharts: Integration

Read this reference when working on the topics below. Commands run from the skill directory.

- [Complete Chart Options (38)](#complete-chart-options-38)
- [NPM Dependencies](#npm-dependencies)
- [JPMS Module](#jpms-module)
- [Installation](#installation)
- [Exported Packages](#exported-packages)

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

