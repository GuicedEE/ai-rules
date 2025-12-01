# Angular Integration and Page Configurator — AgCharts (JWebMP)

Goals
- Keep Angular 20 generation aligned with JWebMP client/TypeScript rules; treat generated TS as build output.
- Register AG Charts npm deps via `AgChartsPageConfigurator` so Angular builds include the client component.

Dependencies and registration
- `AgChartsPageConfigurator` adds `ag-charts-community`, `ag-charts-angular`, `ag-charts-locale`; add `ag-charts-enterprise` only when host licensing is in place.
- Page configurator is registered under `META-INF/services/com.jwebmp.core.services.IPageConfigurator`; do not relocate generated outputs into `rules/`.
- Module exports/imports: keep `module-info.java` exports for `com.jwebmp.plugins.agcharts` packages that feed the generator (`options/*`, chart classes).

Angular client binding
- Generated Angular component exposes signals: `chartOptions`, `chartReady`, `chartId`, and listener registration helpers (`initializeOptionsListener`, `initializeDataListener`).
- EventBusService over websockets uses listener names derived from `DivSimple` id: `<id>Options` and `<id>Data`; align with server-side registrations.
- Rendering contract: `[options]="chartOptions()"` guarded by `chartReady()`; AG Charts component mounts after options arrive.

Usage patterns
- In server code, extend `AgChart<J>` and override `getInitialOptions()` (required) and `getInitialData()` (optional) returning Mutiny `Uni`.
- Keep CRTP setters in chart/options classes; avoid Lombok builders.
- When adding new Angular bindings, update diagrams and RULES references; do not hand-edit generated TS files.

See also
- Topic index — ./README.md
- Data and events — ./data-and-events.rules.md
- Options and styling — ./options-and-styling.rules.md
- JWebMP Angular rules — ../angular/README.md
- Angular rules — ../../../language/angular/README.md and angular-20 override
