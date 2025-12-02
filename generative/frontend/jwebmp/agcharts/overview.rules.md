# Overview — AgCharts JWebMP Wrapper

Purpose
- Provide JWebMP components that render AG Charts 12.2.0 via Angular 20 using the JWebMP client/TypeScript bridge.
- Enforce specification-driven design with CRTP fluent setters and forward-only documentation; generated Angular output stays read-only.
- Full AG Charts 12.2.0 compliance: all 38 chart-level options implemented as CRTP Java classes with Jackson JSON serialization.

Scope and stacks
- Java 25 LTS + Maven; JWebMP Client + TypeScript + Angular 20; GuicedEE Client + Vert.x reactive (Mutiny `Uni`).
- AG Charts version lock: **12.2.0 minimum and only supported version**; no backwards compatibility with earlier versions.
- Default logging: Log4j2 (apply if/when logging is added).
- Dependencies: `ag-charts-community@^12.2.0`, optionally `ag-charts-enterprise@^12.2.0`, `ag-charts-angular@^12.2.0`, `ag-charts-locale@^12.2.0`; declared by `AgChartsPageConfigurator`.

Architecture anchors
- Context/container/component diagrams — `../../../../../docs/architecture/README.md`, `../../../../../docs/architecture/c4-context.md`, `../../../../../docs/architecture/c4-container.md`, `../../../../../docs/architecture/c4-component-agcharts.md`.
- Sequences — `../../../../../docs/architecture/sequence-initial-load.md`, `../../../../../docs/architecture/sequence-data-update.md` (listener naming and merge behavior).
- ERD — `../../../../../docs/architecture/erd-chart-model.md` (options/series relationships).
- Trust boundaries: browser/EventBus websocket ↔ server receivers (`InitialOptionsReceiver`, `DataReceiver`); host services provide data/options; enterprise package licensing handled by host app.

Glossary and prompt alignment
- Topic-first glossary — ./GLOSSARY.md (listener naming, options model terms).
- Keep CRTP fluent pattern (return `(J) this`); avoid builders. No inline string HTML; use JWebMP components for markup.
- Stage gates: blanket approval recorded in PACT; proceed through Stage 1–4 without waiting but document transitions in RULES/GUIDES/IMPLEMENTATION.

See also
- Topic index — ./README.md
- Angular rules — ../../../language/angular/README.md and angular-20 override
- TypeScript rules — ../../../language/typescript/README.md
- JWebMP client rules — ../client/README.md
- GuicedEE client/reactive rules — ../../../backend/guicedee/README.md, ../../../backend/vertx/README.md
