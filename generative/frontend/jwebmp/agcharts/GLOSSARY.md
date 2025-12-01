# Glossary — AgCharts (JWebMP Wrapper)

Precedence and usage
- Topic-first: load this glossary after base Angular 20, TypeScript, and JWebMP client glossaries. Do not duplicate definitions in host projects; link here.
- Prompt language alignment: refer to chart listener channels as `<componentId>Options` / `<componentId>Data`; use CRTP setters returning `(J) this`; avoid builders and inline string HTML.

Terms
- AgChart base: JWebMP component that generates Angular signals and websocket listeners for options/data (`AgChart#initializeOptionsListener`, `AgChart#initializeDataListener`, `AgChart#fetchOptions`, `AgChart#fetchDataChannel`).
- Options channel: EventBus websocket listener suffixed with `Options`; returns `AgChartOptions` payloads (see `../../../../../docs/architecture/sequence-initial-load.md`).
- Data channel: EventBus websocket listener suffixed with `Data`; streams data payloads merged into series or options data (see `../../../../../docs/architecture/sequence-data-update.md`).
- AgChartOptions model: Aggregates axes, legend, tooltip, theme, locale, overlays, navigator, gradient legend, sync/zoom/ranges/contextMenu, animation, formatter, keyboard/touch controls. Series options inherit from `AgSeriesBaseOptions`.
- Chart wrappers: Concrete CRTP subclasses (bar/line/area/pie/donut/bubble/combination/scatter) that preconfigure `AgChartOptions` and expose `getInitialOptions()` / `getInitialData()` returning Mutiny `Uni`.
- Page configurator: `AgChartsPageConfigurator` registering npm deps (`ag-charts-community`, optional `ag-charts-enterprise`, `ag-charts-angular`, `ag-charts-locale`) for Angular builds.

See also
- Topic index — ./README.md
- JWebMP client glossary — ../client/GLOSSARY.md
- TypeScript glossary — ../../../language/typescript/GLOSSARY.md
- Angular glossary and version override — ../../../language/angular/GLOSSARY.md, ../../../language/angular/angular-20.rules.md
