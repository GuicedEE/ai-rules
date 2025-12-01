# AgCharts (JWebMP Angular Wrapper) — Topic Index

Use this topic when building or maintaining the AgCharts JWebMP plugin that renders AG Charts via Angular 20 and the JWebMP client/TypeScript bridge. Apply it alongside the JWebMP Angular and client rules; do not place project docs inside the `rules/` submodule.

Scope and policy
- Forward-only, documentation-first (stage gates auto-approved per prompt; still traceable in Pact/Guides/Implementation).
- CRTP fluent style only; no builders. Generated Angular/TypeScript artifacts remain read-only.
- Dependencies: `ag-charts-community` (optionally `ag-charts-enterprise`), `ag-charts-angular`, `ag-charts-locale`, JWebMP client with EventBus websocket bridge.
- Diagrams: see `../../../../../docs/architecture/README.md` (context/container/component, sequences, ERD) for evidence.

How to use this index
- Start with Overview, then follow the module relevant to your change. Each rule links back here and to upstream rules (Angular 20, TypeScript, JWebMP client).
- For enterprise-only topics, use `../agcharts-enterprise/README.md`.

Topics
- Overview and scope — ./overview.rules.md
- Angular bundling and page configurator — ./angular-integration.rules.md
- Options and styling (axes/legend/theme/overlays) — ./options-and-styling.rules.md
- Chart components and CRTP patterns — ./chart-components.rules.md
- Data/event channels and lifecycle — ./data-and-events.rules.md
- Testing and validation — ./testing.rules.md
- Release and migration notes — ./release-notes.md
- Glossary (topic-first) — ./GLOSSARY.md

See also
- Frontend category — ../../README.md
- JWebMP topic — ../README.md
- Angular language rules — ../../../language/angular/README.md and angular-20 override
- TypeScript rules — ../../../language/typescript/README.md
- CI/CD (GitHub Actions) — ../../../platform/ci-cd/README.md and ../../../platform/ci-cd/providers/github-actions.md
