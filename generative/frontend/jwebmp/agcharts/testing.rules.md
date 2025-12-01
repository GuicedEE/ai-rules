# Testing and Validation — AgCharts (JWebMP)

Goals
- Provide a minimal validation strategy for AgCharts JWebMP changes (docs-first, forward-only).

What to test
- Options channel: `getInitialOptions()` returns a populated `AgChartOptions` with expected axes/series; Angular client sets `chartReady` and renders without errors.
- Data channel: `getInitialData()` merges into existing options/series without dropping other fields; handles null/empty responses.
- Listener lifecycle: websocket listeners register once per component id and unregister/cleanup on teardown if applicable.
- Dependency wiring: `AgChartsPageConfigurator` registers npm deps; services entries exist for configurator and `AgChartsInclusionsModule`.

How to test
- Prefer docs-first acceptance criteria tied to diagrams: update `../../../../../docs/architecture/sequence-*.md` if flow changes.
- Unit tests at server side: mock `IGuicedContext` and verify receivers return `AjaxResponse` data and listener names.
- Client validation: if generating Angular output, run Angular unit/smoke tests that mount the component with mock EventBus responses; keep generation scripts untouched.
- CI: rely on GitHub Actions baseline in `../../../platform/ci-cd/providers/github-actions.md`; ensure no networked secrets are hardcoded.

See also
- Topic index — ./README.md
- Data and events — ./data-and-events.rules.md
- Angular integration — ./angular-integration.rules.md
- RULES — ../../../../../RULES.md
