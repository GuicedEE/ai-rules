# Data and Events — AgCharts (JWebMP)

Purpose
- Describe the websocket/EventBus channels that carry chart options and data between the Angular 20 client and the JWebMP server.

Channels and naming
- Options listener: `<componentId>Options` registered by `AgChart#initializeOptionsListener`; routes to `InitialOptionsReceiver`.
- Data listener: `<componentId>Data` registered by `AgChart#initializeDataListener`; routes to `DataReceiver`.
- Listener names come from the `DivSimple` id; keep ids stable to avoid orphaned listeners.

Flow (initial load)
- Client `ngAfterViewInit` calls `fetchOptions()` → EventBus sends request → server `getInitialOptions()` (Mutiny `Uni`) → payload added via `AjaxResponse` → client sets `chartOptions` and marks `chartReady`.
- See `../../../../../docs/architecture/sequence-initial-load.md` for timing and signals.

Flow (data updates)
- Client `fetchDataChannel()` requests data channel → `getInitialData()` response optionally wrapped in `DynamicData` → client merges payload into existing series/options data.
- Subsequent server pushes may reuse the same listener to stream updates; merge logic avoids overwriting other options.
- See `../../../../../docs/architecture/sequence-data-update.md` for merge behavior and error notes.

Guardrails
- Validate payload shapes (raw object vs `{ out: [...] }`) on the server to avoid client parse errors.
- Keep websocket registration idempotent; avoid duplicate listener registration on rerender.
- Do not introduce blocking calls inside receivers; rely on Mutiny `Uni` for async behavior.

See also
- Topic index — ./README.md
- Angular integration — ./angular-integration.rules.md
- Chart components — ./chart-components.rules.md
- Architecture sequences — ../../../../../docs/architecture/sequence-initial-load.md, ../../../../../docs/architecture/sequence-data-update.md
