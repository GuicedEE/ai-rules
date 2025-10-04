# UWE Server Migration & Coding Rules

Updated: 2025-09-21 16:23 (local)
Maintainer: Junie (JetBrains AI) — consolidated rules from recent migration work across Staff, Sessions and Web-Server modules.

Purpose:
- Provide a single, authoritative reference for patterns and rules we follow in UWE servers after the Mutiny/Vert.x 5 migration and enterprise scoping clean-up.
- Make it easy for contributors to implement new listeners/actions consistently and review legacy code for compliance.

Latest lessons (2025-09-21 16:18):
- Reactive actions: DefaultSessionsActionListener must instantiate actions via Guice and execute them inside sessionFactory.withTransaction(session -> action.performReactive(session)). Do not open nested transactions or subscribe inside actions; return a Uni from performReactive.
- Event bus payloads: Producers must publish the same typed payload that the @VertxEventDefinition consumer expects. Example: publish the PackingSession object to "packingSession.update"; do not wrap it in JsonObject.
- Hibernate Reactive fetch: Transparent lazy loading is not supported. Always call session.fetch(entity/proxy) before accessing or updating fields/methods (e.g., IResourceItem.updateData).
- Cache and UI flow: Only Actions call service.updateCache(..., system, token). After cache updates, publish the appropriate DataFetch (e.g., PackingSessionDataFetch) for UI refresh.
- Cleanup after deletes: When removing lines/stations, expire their DB objects after cache update to prevent stale state.

Generated frontend assets (do not edit):
- Never add, use, or modify HTML (.html), TypeScript (.ts), or CSS (.css) files anywhere in this repository. These are generated assets and will be overwritten by the build/theme pipelines. Any manual changes to these file types will be rejected in review.
- If you need UI changes, update the appropriate generators or theme sources instead (for example: Java component/view definitions in UWE-Web-Assist; theme sources in UWE-Web-Theme; or other designated template/generator modules).

Universal rules for all state management services and update caches (applies to Farm, PackingSession, Staff, Timesheets):
- Scope: All rules in this document apply uniformly across the four core state aggregates and their associated services and caches.
- Actions-only mutations: Only Actions mutate state and call the corresponding service.updateCache(session, id, aggregate, system, identityToken).
- Typed events: All cache-update event publications must use strongly-typed payloads matching the @VertxEventDefinition consumer parameter type (no generic JsonObject wrappers).
- Reactive lifecycle: All writes are executed within sessionFactory.withTransaction and actions return Uni via performReactive(session) so the transaction stays open until pipelines complete.
- Fetch before use: When a proxy/lazy entity is involved (e.g., IResourceItem), call session.fetch(entity) before use to avoid LazyInitializationException.
- UI refresh: After successful cache updates, publish the appropriate DataFetch channel (FarmDataFetch, PackingSessionDataFetch, StaffDataFetch, Timesheets updates) as relevant to the mutation.
- No stored system/token: Resolve enterprise→system→identityToken per request and thread them through to services; never store them on fields.

Core Resolution Chain (Enterprise → System → IdentityToken):
- Always resolve enterprise, then system, then identityToken in the context of the current Mutiny.Session.
  - enterprise = enterpriseService.getEnterprise(session, applicationName)
  - system = IActivityMasterService.getISystem(session, GraderSystemName, enterprise)
  - identityToken = IActivityMasterService.getISystemToken(session, GraderSystemName, enterprise)
- Never pass null for system or identityToken to downstream services.
- Do not cache/hold system or identityToken as fields on actions/listeners. Resolve per request.
- Typical pattern:
  enterpriseService.getEnterprise(session, applicationName)
    .chain(enterprise -> getISystem(session, GraderSystemName, enterprise)
      .chain(system -> getISystemToken(session, GraderSystemName, enterprise)
        .chain(identityToken -> /* perform with system, identityToken */)))

Farm & Session Access:
- Farm access must be done with the resolved system and identityToken:
  farmService.getFarm(session, message.getFarmId(), system, identityToken)
- PackingSession access is done off session id:
  packingSessionService.getSession(session, message.getPackingSessionId())
- Validate every fetch (farm, packing shed, session, station). Log with clear ❌ error messages and return failed Uni with meaningful details.

Actions (General Rules):
- Execution model: Actions execute synchronously. They are the only place where mutations to core state occur to preserve ordering and consistency. ✓
- Scope of responsibility: Actions perform updates to the base four types — Farm, PackingSession, Staff, and Timesheets — and persist the JSON/state snapshot to the database to maintain the exact sequence of updates. ✓
- Listeners vs Actions: Listeners may execute asynchronously and should primarily provide information, coordinate inputs, or schedule multiple actions/listeners. They generally must not directly mutate core state; defer to Actions for writes. ✓
- Base classes SHOULD NOT own system/identityToken state. Resolve within each perform/processing method.
- Thread system and identityToken to every downstream server/service method that supports them (e.g., updateCache, createStation, planNewSession/startNewSession, updateStation, updateStaffMember, timesheet updates, etc.).
- Use DefaultObjectMapper from IGuiceContext for all (de)serializations, and protect against bad input with try/catch and warnings.
- PerformAfter: If an action has performAfter, resolve the enterprise→system→token again there (do not reuse cached references).
- Publishing: Set sendToGroup and groupName explicitly where a web push is required.

Staff Server — Actions:
- Follow the CheckStaffChecksumAction and SetStaffChecksumAction pattern:
  - Resolve enterprise→system→token, then fetch farm and packing shed, then do staff operations.
  - Use staffService.getStaff or getStaffEnabled and update via staffService.updateStaffMember(session, farm.getName(), farm, username, staff, system, token)
  - Publish web updates using the appropriate VertxEventPublisher (e.g., LoadStaffToWeb) after successful updates.
- Clock-in/out and timesheet actions:
  - Resolve chain, fetch farm → session → station, then call timesheetService methods.
  - Ensure message data includes timeSheet, stationId, staffNumber as expected by web listeners.

Staff Server — Listeners:
- Remove/avoid any reference to CallScoper and legacy TaskGroupRequest.
- Use helper getFarmWithEnterpriseChain(session, message) in DefaultStaffListener to resolve enterprise→system→token and then get the farm.
- When routing hardware COM-port messages, group by COM port using MultiTimedComPortSender (not legacy TaskGroup)
  - Build Map<Integer, List<MessageSpec>> per COM port and enqueue with a label.

Sessions Server — Actions:
- DefaultSessionAction must not hold system/token. Each action resolves the chain when needed.
- Updated actions use the chain and thread system/token through:
  - packingSessionService.updateCache(..., system, token)
  - packingSessionService.planNewSession/startNewSession(..., system, token)
  - stationService.updateStation/createStation(..., system, token)
  - timesheetService.updateTimesheet/createTimesheet(..., system, token)
- AddSessionLineAction: resolve chain up-front; pass system/token to processSessionLine and createStations.
- PlanSessionAction & FinalizeSessionAction: resolve chain and use system/token; performAfter uses its own chain resolution.
- SetStationStaffLoggedInAction: resolve chain; set station staff with message-provided uuids then update cache.
- RemoveTotalsFromSession: resolve chain; also pass system/token to stationService.updateStation and timesheet cache updates.
- XstReceivedAction: resolve chain; update station running values and process incoming measurements only if session started.
- AddMeasurementUnitToSessionStation: resolve chain; compute totals (barcode/scale/waste), update session/line/station, update cache, publish staff/web updates.

Web Server — Graders Listeners:
- Do NOT modify DefaultGraderSelectListener (per project directive). Use its existing getSelectedGraders(message) where available.
- Each listener must resolve enterprise→system→token and then farm; never pass null.
- When acting on multiple graders, group by COM port and enqueue via MultiTimedComPortSender.
- Examples updated:
  - UpdateGraderFilterListener, UpdateGraderStyleListener, UpdateGraderWasteListener,
    ClearInstructionsGradersListener, EnableClockInGradersListener,
    ClearImageFlashListener, ClearImageFileNumberForGradersListener,
    RestartGradersListener, StartUIDTagSwipeSimulationGradersListener.

Data & Serialization (Vert.x full-object payloads):
- New default (2025-09): EventBus messages now carry full typed objects (DTOs/messages), not generic maps. Prefer strongly typed payloads in listeners/actions.
- Avoid parsing Map<String, Object> from message.getData() in new/updated code. Keep Map-based handling only where interacting with legacy emitters that still send maps.
- Always use IGuiceContext.get(DefaultObjectMapper) for any remaining (de)serializations (e.g., file I/O, legacy interop) and protect against bad input with try/catch.
- Defensive parsing: catch JsonProcessingException/NumberFormatException; log warnings and continue when safe.
- Prefer immutable/"final" locals in lambdas to avoid capture issues.

State Caching: updateCache utilization (Actions vs Listeners)
- Purpose: Keep server-side caches and persisted JSON/state snapshots consistent after any mutation to the four core types (Farm, PackingSession, Staff, Timesheets).
- Golden rule: Only Actions perform mutations and therefore only Actions call service.updateCache(...). Listeners should not mutate or update caches directly; they schedule Actions and (optionally) publish DataFetch for UI refreshes.
- Always resolve and thread enterprise→system→identityToken into updateCache calls. Never pass null.
- Typical call signature (varies by service): service.updateCache(session, id, aggregate, system, identityToken)

Per core type patterns:
- PackingSession (IPackingSessionService.updateCache):
  - When to call: After adding/removing lines, creating/updating stations, recalculating running or total values, starting/finalizing sessions.
  - Follow-up: Publish PackingSessionDataFetch to push the full SessionDTO to the web.
  - Example: RemoveSessionLineAction removes the line, then packingSessionService.updateCache(...), then publishes PackingSessionDataFetch, and finally expires DB objects for stations/line.
- Farm (IFarmService.updateCache or FarmIdentifiableAction updates):
  - When to call: After farm-level metadata changes (e.g., SessionMetaDataDoneLines/Groups), pack instructions changes, materials updates.
  - Follow-up: Publish FarmDataFetch to refresh farm-wide UI, or publish FarmIdentifiableAction events to update specific metadata then trigger a DataFetch when state affects UI.
- Staff (IStaffService.updateCache or updateStaffMember which internally updates cache):
  - When to call: After staff enable/disable, details edits, and especially after staff-to-station assignments that affect UI aggregates.
  - Follow-up: Publish StaffDataFetch to refresh staff lists; for station assignments also publish PackingSessionDataFetch if session aggregates change.
- Timesheets (ITimesheetService.updateCache):
  - When to call: After clock-in/out, timesheet create/update/delete.
  - Follow-up: Publish appropriate staff timesheets data updates and, if aggregates roll up into session, publish PackingSessionDataFetch.

Listener behavior with caches:
- Validation/coordination only: Listeners validate payloads and publish IdentifiableAction messages; they generally do NOT call updateCache.
- UI-refresh without mutation: If a listener is purely informational, it may publish a DataFetch (e.g., PackingSessionDataFetch) to refresh the client view; but do not call updateCache.
- Multi-step flows: For multi-action sequences, listeners may orchestrate a series of actions; each action is responsible for its own updateCache and subsequent DataFetch publication.

Examples in repository:
- AddSessionLineAction: After creating stations and adding the line to the session, it calls IPackingSessionService.updateCache(... system, token) then publishes an update.
- RemoveSessionLineAction: Removes line, conditionally publishes Farm metadata updates, calls IPackingSessionService.updateCache(...), publishes PackingSessionDataFetch, and expires DB objects.

Numbering & Conventions:
- Be mindful of stationNumber vs graderNumber offsets in some protocols:
  - Many areas use stationNumber = graderNumber (+/- 1) depending on source. Double check conversions.
- Use farm.getSystemPackingShed() for consistent grader lookups when working at "system" scope.

Publishing & WebSocket Groups:
- Set message.setSendToGroup(true) and message.setGroupName("<Group>") before publishing when needed.
- Keep listener-name consistent when pushing to web for dynamic options/graphs.

Prohibited / Removed Patterns:
- No CallScoper usage anywhere.
- No legacy TaskGroupRequest routing; use MultiTimedComPortSender groups instead.
- No storing system or identityToken as class fields; resolve per action/listener execution.

Error Handling & Logging:
- Use concise, emoji-prefixed logs for clarity (✅ success, ❌ error, ⚠️ warning, ℹ️ info, 🔄 processing, 📋 step).
- Return Uni failures with precise IllegalStateException messages for missing farm/packshed/session/station/etc.

Reference Implementations in Repo (as of this rules update):
- Staff Actions: CheckStaffChecksumAction, SetStaffChecksumAction, ResetStaffGraderChecksumsAction, ClockInAction, ClockOutAction,
  AddTimeSheetAction, UpdateTimeSheetAction, DeleteTimeSheetAction, RequestClockInAction, RequestClockOutAction, RequestClockOutAllAction,
  AddMeasurementUnitToStaffStationAction, AddBulkMeasurementUnitToStaffStationAction, StartSessionStaffConfigurator, UIDReceivedAction.
- Staff Listeners: DefaultStaffListener.getFarmWithEnterpriseChain, CreateStaffListener, CreateUnallocatedStaffListener,
  CreateStaffTimeSheetListener, DeleteStaffTimeSheetListener, DeleteStationsStaffTimeSheetListener, ImportStaffStartingStationsListener,
  StaffListListener, StaffTimeSheetOptionsToWebListener, StaffTimeSheetsListListener, StaffTimeSheetsResourceListListener,
  StaffToWebListener, UIDListener, UpdateStaffDBListener, UpdateStaffTimeSheetListener, graphs/*.
- Sessions Actions: PlanSessionAction, FinalizeSessionAction, AddSessionLineAction, RemoveSessionLineAction,
  SetSessionNameAction, SetSessionBonusAction, SetSessionLinePackingGroupAction, StartSessionAction,
  StationResetRunningValues, RemoveTotalsFromSession, AddMeasurementUnitToSessionStation, XstReceivedAction, XstReceivedListener.
- Web Server Graders: UpdateGraderFilterListener, UpdateGraderStyleListener, UpdateGraderWasteListener,
  ClearInstructionsGradersListener, EnableClockInGradersListener, ClearImageFlashListener,
  ClearImageFileNumberForGradersListener, RestartGradersListener, StartUIDTagSwipeSimulationGradersListener.

Checklist For New/Updated Code:
- [ ] Resolve enterprise→system→identityToken per request with Mutiny.Session.
- [ ] Fetch farm with system/token; validate farm/packshed/session/station.
- [ ] Thread system/token into all downstream service calls.
- [ ] Use DefaultObjectMapper; parse defensive; log clearly.
- [ ] Publish to correct bus/groups; set sendToGroup and groupName as required.
- [ ] Avoid CallScoper/legacy TaskGroupRequest; group by COM port for hardware.
- [ ] Do not store system/token on fields; avoid static state.

UWE Domain Model & Web Payloads:
- Top-level DTOs delivered to the web client:
  - FarmDTO: complete farm graph including packing sheds, servers, and grader availability/state where relevant to UI.
  - SessionDTO: the full, current packing session view including lines, stations, running/totalized values, and assigned PackInstructionGroup per station.
  - StaffDTO[]: the full list of staff members for the farm/packing shed context, including enabled/disabled state.
  - StaffTimesheets[]: per session, per staff member timesheet arrays as requested by the UI flows (listeners already exist for list/resources/options).
- Hierarchy and capacities:
  - Farm contains many Packing Sheds. Each Packing Shed has 1–4 Servers. Each Server can host up to 253 graders (address space 2–255, starting from 2).
  - A Farm has many Pack Instructions, which define items that can be packed and are shared across sheds.
  - Each Pack Instruction may reference up to 3 materials. Material Images are uploaded via the web client and made selectable; default Material Image index is 0 (none set).
  - A Farm has many Staff across sheds. Packing is performed within a PackingSession context.
  - A Farm has many Packing Sessions; a summary per farm is stored as PackingSessionMetaData.
  - A Packing Session contains many Lines; each Line has multiple Stations. Each Station is associated with a grader device that records weights and reports into the system.
  - Each Station has an assigned PackInstructionGroup defining 1–5 instructions that can be packed at that station.
  - A Station can have 0–5 Staff assigned. Use the special Unassigned staff member with id -10111 when no user is bound.
- Aggregations and propagation rules:
  - Results aggregate at Station → Line → Session → Farm and independently per Staff and Timesheet views.
  - Any mutation at a lower level must update aggregates up the chain and refresh related caches.
  - After mutations affecting farm/session/staff/timesheets, publish the corresponding DataFetch channel to refresh UI:
    - FarmDataFetch → full FarmDTO
    - PackingSessionDataFetch → full SessionDTO
    - StaffDataFetch → full StaffDTO[]
    - Staff Timesheets listeners push their per-staff/session arrays as implemented.
- Numbering and conversions:
  - Be mindful of stationNumber vs graderNumber offsets; confirm conversions when interacting with hardware protocols or COM-port routing.
- Material Images handling:
  - Ensure uploaded images are indexed and accessible for Pack Instruction material selection. Default selection is 0 (no image).
- Validation and error handling:
  - Validate fetches (farm, shed, server, grader, session, line, station). Fail fast with meaningful messages and do not proceed on nulls.

Notes:
- Keep DefaultGraderSelectListener unchanged unless explicitly authorized.
- When adding helpers, prefer package-local utilities (e.g., DefaultStaffListener#getFarmWithEnterpriseChain) to reduce duplication.

Web Update Channels (DataFetch strategy):
- FarmDataFetch
  - Client: UWE-Web-Assist/providers/FarmDTODataService publishes UWEServerMessage to "FarmDataFetch".
  - Server: Listener responds and pushes FULL FarmDTO to web group for the requesting socket or group as needed.
- PackingSessionDataFetch
  - Client: UWE-Web-Assist/providers/PackingSessionDTODataService publishes to "PackingSessionDataFetch".
  - Server: Listeners (e.g., PackingSessionDTOListener, SelectPackingSessionListener) push FULL SessionDTO to web.
- StaffDataFetch
  - Client: UWE-Web-Assist/providers/StaffDTODataService publishes to "StaffDataFetch". ✓
  - Server: StaffListListener now also listens to "StaffDataFetch" and publishes FULL StaffDTO[] to web (group name LoadStaffWeb).
- Staff Timesheets (as-is)
  - Existing listeners: StaffTimeSheetsListListener, StaffTimeSheetsResourceListListener, options listeners.

Payload expectations:
- FarmDataFetch → Full FarmDTO (includes PackInstruction metadata/images availability state where applicable).
- PackingSessionDataFetch → Full SessionDTO for the selected session.
- StaffDataFetch → Full StaffDTO[] list for the farm/packshed context.
- StaffTimesheets → Arrays of PackingStaffTimesheet per staff per session as requested by the UI components.

Update triggers:
- After any mutation to farm/session/staff/timesheets that affects web state, publish the corresponding DataFetch channel to refresh UI. Avoid spamming; batch where possible.

Events: End-to-End Pattern (UI → Server → Action)
- Purpose: Standardize how UI events trigger backend processing and UI refreshes.
- Building blocks:
  - UI Event (Web-Assist): Java class extending a Click base (e.g., SelectedLineClick) that prepares payload and publishes a UWEServerMessage via a @Named VertxEventPublisher.
  - Listener (Server): @VertxEventDefinition("<Address>") reactive consumer that validates payload, adjusts keys to downstream expectations, and publishes a typed IdentifiableAction.
  - Action (Server): @SessionActionable/@StaffActionable class that resolves enterprise→system→identityToken per request, loads domain entities, performs mutation, updates caches, and publishes DataFetch updates for the web.
- Naming conventions:
  - Web-Assist @Named publisher names must match the server listener address annotation value.
  - Downstream action identifiers (e.g., SessionAction.RemoveLineFromSessionAction) must match what listeners set when wrapping into IdentifiableAction objects.
  - Payload key names are contract-sensitive; ensure exact keys matching downstream expectations (e.g., "sessionLineId").
- Example: Delete Session Line
  1) UI Event: DeleteSessionLineEvent extends SelectedLineClick, injects @Named("DeleteLineListener") VertxEventPublisher<UWEServerMessage>, and publishes a message with data["sessionLineId"] = selectedLine.id.
  2) Listener: DeleteSessionLineListener @VertxEventDefinition("DeleteLineListener") receives UWEServerMessage, validates sessionLineId, ensures data uses key "sessionLineId", wraps into PackingSessionIdentifiableAction, sets SessionAction.RemoveLineFromSessionAction, and publishes via SessionUpdate channel.
  3) Action: RemoveSessionLineAction @SessionActionable(RemoveLineFromSessionAction) resolves enterprise→system→identityToken, loads Farm → PackingShed → PackingSession, finds SessionLine by UUID from data["sessionLineId"], removes it, updates cache via packingSessionService.updateCache(..., system, token), publishes PackingSessionDataFetch to refresh UI, and expires station/line DB objects.
- Checklist for new events:
  - [ ] Define UI event class; attach to component/button; ensure Selected*Click base writes required attributes (e.g., [attr.line]).
  - [ ] Inject @Named VertxEventPublisher; name must match @VertxEventDefinition on server.
  - [ ] Put exact payload keys expected by the downstream action; avoid mismatches (e.g., prefer "sessionLineId" over "lineId").
  - [ ] Server listener: validate payload, normalize keys for downstream, and wrap into the correct IdentifiableAction with proper enum.
  - [ ] Action: resolve enterprise→system→identityToken per request; never reuse cached values; validate all fetches; update caches; publish DataFetch.
  - [ ] Logging: use emoji prefixes (✅, ❌, ⚠️, ℹ️, 🔄, 📋) consistently across event, listener, action.
  - [ ] Tests/manual: click in UI should result in server mutation and UI refresh through DataFetch.
- Do/Don’t:
  - Do prefer strongly-typed payloads going forward; Map<String,Object> support remains for legacy emitters only.
  - Don’t store system/identityToken in fields; resolve per message.
  - Don’t change listener/action names arbitrarily; they are contract addresses.

Barcode Printing & Scanning (Pack Instructions)
- Purpose: Support printing scannable barcodes for Pack Instructions, with a unique batch per day. Scans are ingested by the Barcode servers and update barcode-specific results in sessions (separate from scale results).

What is printed
- A barcode label encodes at minimum: farmId, packInstructionId, packingDate (yyyy-MM-dd), uniqueDailyBatchId, and optional lot/extra metadata.
- Unique daily batch rule: For a given Farm × Pack Instruction × Date, each print job receives a monotonic batch number (resets daily per pack instruction). Stored in BarcodeBatchSummary.
- Layouts: Templates live in UWE-BarcodeBatch-Server/src/main/resources/barcode_templates; printing is handled by BarcodeBatch-Server actions/listeners.

High-level flows
1) Printing flow (Batch generation)
   - UI (Web-Assist): Initiates a "Print Barcodes" request for a Pack Instruction and quantity (future work: add UI entry point).
   - Listener (BarcodeBatch-Server): BarcodeBatchActionListener receives request, validates the pack instruction, creates/updates a BarcodeBatchSummary for today, and generates barcodes with the encoded identifiers.
   - Action (BarcodeBatch-Server): Persists/updates the daily batch summary, renders the template, and sends to printer/PDF. Publishes a summary back to web if required.
   - State: Batch summaries are keyed by LocalDate; see UWE-Client BarcodeBatch/BarcodeBatchSummary types and TypeMappings support.

2) Scanning flow (Results ingestion)
   - Hardware → UWE-Barcode-Server: The scanner sends barcode strings; BarcodeMessageDecoder parses farmId, packInstructionId, date, batchId, etc. Duplicate checks occur via BarcodeDuplicateCheck/Save listeners.
   - Sessions update chain: A valid scan schedules Sessions actions that accrue barcode totals per station/line/session (see AddMeasurementUnitToSessionStation and downstream aggregations).
   - Caching & publish: After mutation, Actions call IPackingSessionService.updateCache(session, sessionId, aggregate, system, token) and publish PackingSessionDataFetch so the UI reflects new scanned totals.

Where results appear (barcode-specific fields)
- StationDetailsDTO (via TypeMappings):
  - scannedBoxes ← barcodeTotalBoxes
  - scannedPallets ← barcodeTotalPallets
  - scannedEkwEquivalent ← scannedEkwEquivalent
  - totalScannedCount ← barcodeTotalCount
  - wastePercentageBarcode ← barcodeWastePercentage
- Session/Farm aggregates (ResultsDTO):
  - scannedUnits ← barcodeTotalCount
  - scannedBoxes ← barcodeTotalBoxes
  - scannedPallets ← barcodeTotalPallets
  - scannedBonusEkw ← barcodeTotalBonusEkw
  - scannedEkwCount ← barcodeTotalEkwCount
  - scannedEkwEquivalent ← barcodeTotalEkwEquivalent
  - scannedBonusCents ← barcodeTotalBonusCents
- Staff aggregates (StaffDTO / staff dashboards):
  - perStaff.scannedUnits, scannedBoxes, scannedPallets, scannedEkwEquivalent, scannedBonusEkw/Cents roll up from staff-assigned stations’ barcode totals for the active session.
  - Publishing: After Actions that mutate scanned/weighed results, also publish StaffDataFetch when staff-facing aggregates change (e.g., staff assignment-based totals or bonus impacts).
- Timesheets aggregates (PackingStaffTimesheet and related DTOs):
  - Per-staff, per-session barcode totals accrue into the timesheet views alongside scale totals (fields mirror scanned* and weighed* semantics).
  - Publishing: Timesheet listeners push updated arrays; Actions that change results should ensure ITimesheetService.updateCache has been called where applicable and that the appropriate timesheet web updates are emitted.
- The scale path remains separate (weighed* fields); analogous weighed* values appear in the same aggregates (StationDetailsDTO, ResultsDTO, Staff aggregates, and Timesheets).

Pack Instruction results view
- PackInstructionResultsToWebListener prepares per-instruction results. It detects barcode vs scale mode using message.sessionstorage.scaleOrBarcode. In barcode mode it reads packingSession.getBarcodeResults(), maps via TypeMappings, and publishes to the web.

End-to-end chain (to use when we extend UI)
- Printing (to be wired):
  - UI event → @Named("BarcodeBatchAction") publisher → @VertxEventDefinition("BarcodeBatchAction") listener in UWE-BarcodeBatch-Server → Actions to create daily batch and generate labels → optional DataFetch/Toast to UI.
- Scanning (existing servers):
  - Scanner device → UWE-Barcode-Server decode listeners → de-dup listeners → Sessions action (e.g., AddMeasurementUnitToSessionStation) to apply scan → IPackingSessionService.updateCache → PackingSessionDataFetch to UI.
- Always resolve enterprise → system → identityToken on the server side before calling services.

Rules & constraints
- Daily uniqueness: Batch id increments per Pack Instruction per day; do not reuse across days or instructions.
- Idempotency: Duplicate scans must be detected and rejected (handled in Barcode-Server duplicate listeners) to keep totals correct.
- Separation of concerns: Listeners validate/route; Actions mutate and update caches (see Actions vs Listeners section).
- UI: When we add the print UI, carry packInstructionId, farmId, date, qty, and optional lot metadata; expect a BarcodeBatchSummaryDTO back for display.

Next steps (for future work)
- Add a Web-Assist button and event to print barcodes for a selected Pack Instruction.
- Implement a server listener address and wire it to BarcodeBatch-Server’s action to generate a daily batch and return a summary.
- Add a simple report/view showing today’s batches (using BarcodeBatchSummaryDTO) and links to reprint.

End of document.


## UI/UX Lessons (2025-09-21 16:39)
- Use callouts for major headings in planning/empty-state screens (e.g., “Planning phase” and “Bonus Configuration”) to guide users and reduce empty panels.
- Target Reach (EKW) is read-only during planning. Users may adjust the number of units of target reach and downstream rates, but not the base EKW value.
- Prefer WaCallout for section headers over plain text for important contextual guidance.

# UWE Server Migration & Coding Rules

Updated: 2025-09-21 18:21 (local)
Maintainer: Junie (JetBrains AI) — consolidated rules from recent migration work across Staff, Sessions and Web-Server modules.

Purpose:
- Provide a single, authoritative reference for patterns and rules we follow in UWE servers after the Mutiny/Vert.x 5 migration and enterprise scoping clean-up.
- Make it easy for contributors to implement new listeners/actions consistently and review legacy code for compliance.

Latest lessons (2025-09-21):
- Reactive actions: DefaultSessionsActionListener must instantiate actions via Guice and execute them inside sessionFactory.withTransaction(session -> action.performReactive(session)). Do not open nested transactions or subscribe inside actions; return a Uni from performReactive.
- Event bus payloads: Producers must publish the same typed payload that the @VertxEventDefinition consumer expects. Example: publish the PackingSession object to "packingSession.update"; do not wrap it in JsonObject.
- Hibernate Reactive fetch: Transparent lazy loading is not supported. Always call session.fetch(entity/proxy) before accessing or updating fields/methods (e.g., IResourceItem.updateData).
- Cache and UI flow: Only Actions call service.updateCache(..., system, token). After cache updates, publish the appropriate DataFetch (e.g., PackingSessionDataFetch) for UI refresh.
- Cleanup after deletes: When removing lines/stations, expire their DB objects after cache update to prevent stale state.

UI — Session Lines (2025-09-21 18:21):
- Collapsed header must display: Line name • station range and count • packing group name.
  - Format: "{{name}} — {firstStation–lastStation} ({count}) • Group: {packInstructionGroupDTO.name}".
  - If no stations: show "no stations" and hide range/count.
  - If no packing group: show "No Packing Group".
- Danger callout visibility in LineDetailsProperties:
  - Show ONLY when there is no packing group name AND all five instructions are unset.
  - Do NOT show when any instruction is set, even if group name is still empty (prevents sticky warning during setup).
- Instruction selection UX:
  - Selecting an instruction writes it into packInstructionGroupDTO.instruction{1..5} based on clickedIndex and closes the selection dialog.
- AddSessionLineEvent click handling:
  - Read attributes case-insensitively (DOM may lowercase names).
  - Accept from/to station range; if to < from, swap.
  - Build selectedGraders = [{graderNumber:n, selected:true}] for inclusive range.
  - Include line name (generate default if blank) and explicit fromStation/toStation in message data for diagnostics.

Universal rules for all state management services and update caches (applies to Farm, PackingSession, Staff, Timesheets):
- Scope: All rules in this document apply uniformly across the four core state aggregates and their associated services and caches.
- Actions-only mutations: Only Actions mutate state and call the corresponding service.updateCache(session, id, aggregate, system, identityToken).
- Typed events: All cache-update event publications must use strongly-typed payloads matching the @VertxEventDefinition consumer parameter type (no generic JsonObject wrappers).
- Reactive lifecycle: All writes are executed within sessionFactory.withTransaction and actions return Uni via performReactive(session) so the transaction stays open until pipelines complete.
- Fetch before use: When a proxy/lazy entity is involved (e.g., IResourceItem), call session.fetch(entity) before use to avoid LazyInitializationException.
- UI refresh: After successful cache updates, publish the appropriate DataFetch channel (FarmDataFetch, PackingSessionDataFetch, StaffDataFetch, Timesheets updates) as relevant to the mutation.
- No stored system/token: Resolve enterprise→system→identityToken per request and thread them through to services; never store them on fields.

Core Resolution Chain (Enterprise → System → IdentityToken):
- Always resolve enterprise, then system, then identityToken in the context of the current Mutiny.Session.
  - enterprise = enterpriseService.getEnterprise(session, applicationName)
  - system = IActivityMasterService.getISystem(session, GraderSystemName, enterprise)
  - identityToken = IActivityMasterService.getISystemToken(session, GraderSystemName, enterprise)
- Never pass null for system or identityToken to downstream services.
- Do not cache/hold system or identityToken as fields on actions/listeners. Resolve per request.
- Typical pattern:
  enterpriseService.getEnterprise(session, applicationName)
    .chain(enterprise -> getISystem(session, GraderSystemName, enterprise)
      .chain(system -> getISystemToken(session, GraderSystemName, enterprise)
        .chain(identityToken -> /* perform with system, identityToken */)))

Farm & Session Access:
- Farm access must be done with the resolved system and identityToken:
  farmService.getFarm(session, message.getFarmId(), system, identityToken)
- PackingSession access is done off session id:
  packingSessionService.getSession(session, message.getPackingSessionId())
- Validate every fetch (farm, packing shed, session, station). Log with clear ❌ error messages and return failed Uni with meaningful details.

Actions (General Rules):
- Execution model: Actions execute synchronously. They are the only place where mutations to core state occur to preserve ordering and consistency. ✓
- Scope of responsibility: Actions perform updates to the base four types — Farm, PackingSession, Staff, and Timesheets — and persist the JSON/state snapshot to the database to maintain the exact sequence of updates. ✓
- Listeners vs Actions: Listeners may execute asynchronously and should primarily provide information, coordinate inputs, or schedule multiple actions/listeners. They generally must not directly mutate core state; defer to Actions for writes. ✓
- Base classes SHOULD NOT own system/identityToken state. Resolve within each perform/processing method.
- Thread system and identityToken to every downstream server/service method that supports them (e.g., updateCache, createStation, planNewSession/startNewSession, updateStation, updateStaffMember, timesheet updates, etc.).
- Use DefaultObjectMapper from IGuiceContext for all (de)serializations, and protect against bad input with try/catch and warnings.
- PerformAfter: If an action has performAfter, resolve the enterprise→system→token again there (do not reuse cached references).
- Publishing: Set sendToGroup and groupName explicitly where a web push is required.

Staff Server — Actions:
- Follow the CheckStaffChecksumAction and SetStaffChecksumAction pattern:
  - Resolve enterprise→system→token, then fetch farm and packing shed, then do staff operations.
  - Use staffService.getStaff or getStaffEnabled and update via staffService.updateStaffMember(session, farm.getName(), farm, username, staff, system, token)
  - Publish web updates using the appropriate VertxEventPublisher (e.g., LoadStaffToWeb) after successful updates.
- Clock-in/out and timesheet actions:
  - Resolve chain, fetch farm → session → station, then call timesheetService methods.
  - Ensure message data includes timeSheet, stationId, staffNumber as expected by web listeners.

Staff Server — Listeners:
- Remove/avoid any reference to CallScoper and legacy TaskGroupRequest.
- Use helper getFarmWithEnterpriseChain(session, message) in DefaultStaffListener to resolve enterprise→system→token and then get the farm.
- When routing hardware COM-port messages, group by COM port using MultiTimedComPortSender (not legacy TaskGroup)
  - Build Map<Integer, List<MessageSpec>> per COM port and enqueue with a label.

Sessions Server — Actions:
- DefaultSessionAction must not hold system/token. Each action resolves the chain when needed.
- Updated actions use the chain and thread system/token through:
  - packingSessionService.updateCache(... system, token)
  - packingSessionService.planNewSession/startNewSession(... system, token)
  - stationService.updateStation/createStation(... system, token)
  - timesheetService.updateTimesheet/createTimesheet(... system, token)
- AddSessionLineAction: resolve chain up-front; pass system/token to processSessionLine and createStations.
- PlanSessionAction & FinalizeSessionAction: resolve chain and use system/token; performAfter uses its own chain resolution.
- SetStationStaffLoggedInAction: resolve chain; set station staff with message-provided uuids then update cache.
- RemoveTotalsFromSession: resolve chain; also pass system/token to stationService.updateStation and timesheet cache updates.
- XstReceivedAction: resolve chain; update station running values and process incoming measurements only if session started.
- AddMeasurementUnitToSessionStation: resolve chain; compute totals (barcode/scale/waste), update session/line/station, update cache, publish staff/web updates.

Web Server — Graders Listeners:
- Do NOT modify DefaultGraderSelectListener (per project directive). Use its existing getSelectedGraders(message) where available.
- Each listener must resolve enterprise→system→token and then farm; never pass null.
- When acting on multiple graders, group by COM port and enqueue via MultiTimedComPortSender.
- Examples updated:
  - UpdateGraderFilterListener, UpdateGraderStyleListener, UpdateGraderWasteListener,
    ClearInstructionsGradersListener, EnableClockInGradersListener,
    ClearImageFlashListener, ClearImageFileNumberForGradersListener,
    RestartGradersListener, StartUIDTagSwipeSimulationGradersListener.

Data & Serialization (Vert.x full-object payloads):
- New default (2025-09): EventBus messages now carry full typed objects (DTOs/messages), not generic maps. Prefer strongly typed payloads in listeners/actions.
- Avoid parsing Map<String, Object> from message.getData() in new/updated code. Keep Map-based handling only where interacting with legacy emitters that still send maps.
- Always use IGuiceContext.get(DefaultObjectMapper) for any remaining (de)serializations (e.g., file I/O, legacy interop) and protect against bad input with try/catch.
- Defensive parsing: catch JsonProcessingException/NumberFormatException; log warnings and continue when safe.
- Prefer immutable/"final" locals in lambdas to avoid capture issues.

State Caching: updateCache utilization (Actions vs Listeners)
- Purpose: Keep server-side caches and persisted JSON/state snapshots consistent after any mutation to the four core types (Farm, PackingSession, Staff, Timesheets).
- Golden rule: Only Actions perform mutations and therefore only Actions call service.updateCache(...). Listeners should not mutate or update caches directly; they schedule Actions and (optionally) publish DataFetch for UI refreshes.
- Always resolve and thread enterprise→system→identityToken into updateCache calls. Never pass null.
- Typical call signature (varies by service): service.updateCache(session, id, aggregate, system, identityToken)

Per core type patterns:
- PackingSession (IPackingSessionService.updateCache):
  - When to call: After adding/removing lines, creating/updating stations, recalculating running or total values, starting/finalizing sessions.
  - Follow-up: Publish PackingSessionDataFetch to push the full SessionDTO to the web.
  - Example: RemoveSessionLineAction removes the line, then packingSessionService.updateCache(...), then publishes PackingSessionDataFetch, and finally expires DB objects for stations/line.
- Farm (IFarmService.updateCache or FarmIdentifiableAction updates):
  - When to call: After farm-level metadata changes (e.g., SessionMetaDataDoneLines/Groups), pack instructions changes, materials updates.
  - Follow-up: Publish FarmDataFetch to refresh farm-wide UI, or publish FarmIdentifiableAction events to update specific metadata then trigger a DataFetch when state affects UI.
- Staff (IStaffService.updateCache or updateStaffMember which internally updates cache):
  - When to call: After staff enable/disable, details edits, and especially after staff-to-station assignments that affect UI aggregates.
  - Follow-up: Publish StaffDataFetch to refresh staff lists; for station assignments also publish PackingSessionDataFetch if session aggregates change.
- Timesheets (ITimesheetService.updateCache):
  - When to call: After clock-in/out, timesheet create/update/delete.
  - Follow-up: Publish appropriate staff timesheets data updates and, if aggregates roll up into session, publish PackingSessionDataFetch.

Listener behavior with caches:
- Validation/coordination only: Listeners validate payloads and publish IdentifiableAction messages; they generally do NOT call updateCache.
- UI-refresh without mutation: If a listener is purely informational, it may publish a DataFetch (e.g., PackingSessionDataFetch) to refresh the client view; but do not call updateCache.
- Multi-step flows: For multi-action sequences, listeners may orchestrate a series of actions; each action is responsible for its own updateCache and subsequent DataFetch publication.

Examples in repository:
- AddSessionLineAction: After creating stations and adding the line to the session, it calls IPackingSessionService.updateCache(... system, token) then publishes an update.
- RemoveSessionLineAction: Removes line, conditionally publishes Farm metadata updates, calls IPackingSessionService.updateCache(...), publishes PackingSessionDataFetch, and expires DB objects.

Numbering & Conventions:
- Be mindful of stationNumber vs graderNumber offsets in some protocols:
  - Many areas use stationNumber = graderNumber (+/- 1) depending on source. Double check conversions.
- Use farm.getSystemPackingShed() for consistent grader lookups when working at "system" scope.

Publishing & WebSocket Groups:
- Set message.setSendToGroup(true) and message.setGroupName("<Group>") before publishing when needed.
- Keep listener-name consistent when pushing to web for dynamic options/graphs.

Prohibited / Removed Patterns:
- No CallScoper usage anywhere.
- No legacy TaskGroupRequest routing; use MultiTimedComPortSender groups instead.
- No storing system or identityToken as class fields; resolve per action/listener execution.

Error Handling & Logging:
- Use concise, emoji-prefixed logs for clarity (✅ success, ❌ error, ⚠️ warning, ℹ️ info, 🔄 processing, 📋 step).
- Return Uni failures with precise IllegalStateException messages for missing farm/packshed/session/station/etc.

Reference Implementations in Repo (as of this rules update):
- Staff Actions: CheckStaffChecksumAction, SetStaffChecksumAction, ResetStaffGraderChecksumsAction, ClockInAction, ClockOutAction,
  AddTimeSheetAction, UpdateTimeSheetAction, DeleteTimeSheetAction, RequestClockInAction, RequestClockOutAction, RequestClockOutAllAction,
  AddMeasurementUnitToStaffStationAction, AddBulkMeasurementUnitToStaffStationAction, StartSessionStaffConfigurator, UIDReceivedAction.
- Staff Listeners: DefaultStaffListener.getFarmWithEnterpriseChain, CreateStaffListener, CreateUnallocatedStaffListener,
  CreateStaffTimeSheetListener, DeleteStaffTimeSheetListener, DeleteStationsStaffTimeSheetListener, ImportStaffStartingStationsListener,
  StaffListListener, StaffTimeSheetOptionsToWebListener, StaffTimeSheetsListListener, StaffTimeSheetsResourceListListener,
  StaffToWebListener, UIDListener, UpdateStaffDBListener, UpdateStaffTimeSheetListener, graphs/*.
- Sessions Actions: PlanSessionAction, FinalizeSessionAction, AddSessionLineAction, RemoveSessionLineAction,
  SetSessionNameAction, SetSessionBonusAction, SetSessionLinePackingGroupAction, StartSessionAction,
  StationResetRunningValues, RemoveTotalsFromSession, AddMeasurementUnitToSessionStation, XstReceivedAction, XstReceivedListener.
- Web Server Graders: UpdateGraderFilterListener, UpdateGraderStyleListener, UpdateGraderWasteListener,
  ClearInstructionsGradersListener, EnableClockInGradersListener, ClearImageFlashListener,
  ClearImageFileNumberForGradersListener, RestartGradersListener, StartUIDTagSwipeSimulationGradersListener.

Checklist For New/Updated Code:
- [ ] Resolve enterprise→system→identityToken per request with Mutiny.Session.
- [ ] Fetch farm with system/token; validate farm/packshed/session/station.
- [ ] Thread system/token into all downstream service calls.
- [ ] Use DefaultObjectMapper; parse defensive; log clearly.
- [ ] Publish to correct bus/groups; set sendToGroup and groupName as required.
- [ ] Avoid CallScoper/legacy TaskGroupRequest; group by COM port for hardware.
- [ ] Do not store system/token on fields; avoid static state.

UWE Domain Model & Web Payloads:
- Top-level DTOs delivered to the web client:
  - FarmDTO: complete farm graph including packing sheds, servers, and grader availability/state where relevant to UI.
  - SessionDTO: the full, current packing session view including lines, stations, running/totalized values, and assigned PackInstructionGroup per station.
  - StaffDTO[]: the full list of staff members for the farm/packing shed context, including enabled/disabled state.
  - StaffTimesheets[]: per session, per staff member timesheet arrays as requested by the UI flows (listeners already exist for list/resources/options).
- Hierarchy and capacities:
  - Farm contains many Packing Sheds. Each Packing Shed has 1–4 Servers. Each Server can host up to 253 graders (address space 2–255, starting from 2).
  - A Farm has many Pack Instructions, which define items that can be packed and are shared across sheds.
  - Each Pack Instruction may reference up to 3 materials. Material Images are uploaded via the web client and made selectable; default Material Image index is 0 (none set).
  - A Farm has many Staff across sheds. Packing is performed within a PackingSession context.
  - A Farm has many Packing Sessions; a summary per farm is stored as PackingSessionMetaData.
  - A Packing Session contains many Lines; each Line has multiple Stations. Each Station is associated with a grader device that records weights and reports into the system.
  - Each Station has an assigned PackInstructionGroup defining 1–5 instructions that can be packed at that station.
  - A Station can have 0–5 Staff assigned. Use the special Unassigned staff member with id -10111 when no user is bound.
- Aggregations and propagation rules:
  - Results aggregate at Station → Line → Session → Farm and independently per Staff and Timesheet views.
  - Any mutation at a lower level must update aggregates up the chain and refresh related caches.
  - After mutations affecting farm/session/staff/timesheets, publish the corresponding DataFetch channel to refresh UI:
    - FarmDataFetch → full FarmDTO
    - PackingSessionDataFetch → full SessionDTO
    - StaffDataFetch → full StaffDTO[]
    - Staff Timesheets listeners push their per-staff/session arrays as implemented.
- Numbering and conversions:
  - Be mindful of stationNumber vs graderNumber offsets; confirm conversions when interacting with hardware protocols or COM-port routing.
- Material Images handling:
  - Ensure uploaded images are indexed and accessible for Pack Instruction material selection. Default selection is 0 (no image).
- Validation and error handling:
  - Validate fetches (farm, shed, server, grader, session, line, station). Fail fast with meaningful messages and do not proceed on nulls.

Notes:
- Keep DefaultGraderSelectListener unchanged unless explicitly authorized.
- When adding helpers, prefer package-local utilities (e.g., DefaultStaffListener#getFarmWithEnterpriseChain) to reduce duplication.

Web Update Channels (DataFetch strategy):
- FarmDataFetch
  - Client: UWE-Web-Assist/providers/FarmDTODataService publishes UWEServerMessage to "FarmDataFetch".
  - Server: Listener responds and pushes FULL FarmDTO to web group for the requesting socket or group as needed.
- PackingSessionDataFetch
  - Client: UWE-Web-Assist/providers/PackingSessionDTODataService publishes UWEServerMessage to "PackingSessionDataFetch".
  - Server: Session update listeners publish full SessionDTO after cache updates.
- StaffDataFetch
  - Client: UWE-Web-Assist/providers/StaffDTODataService publishes UWEServerMessage to "StaffDataFetch".
  - Server: Staff update listeners publish full StaffDTO[] after cache updates.

Appendix: Error Message Conventions
- Use clear, human-readable messages with identifiers for debugging.
- Prefix with emojis to quickly triage in logs (see Error Handling & Logging section).



# Update: SaveSessionLineAction and Direct Action Invocation Preference

Updated: 2025-09-21 21:34 (local)

Context:
- We introduced SaveSessionLineAction to persist edits made to a session line (e.g., editing the instruction selections on the line’s PackInstructionGroup) without requiring any listener-side coordination.
- This aligns with our Actions-only mutations rule and reduces unnecessary hops through listeners that don’t add orchestration value.

Guidelines:
- Prefer publishing directly to Action channels from the web client when the operation is a single, self-contained mutation that does not require multi-step orchestration. Avoid routing through a Listener solely to call an Action.
- Listeners should validate/coordinate and fan-out to multiple Actions only when truly needed. They must not update caches directly.
- Actions must: resolve enterprise→system→identityToken within the action’s reactive pipeline; perform the mutation; call the appropriate updateCache; then publish the DataFetch to refresh UI.

Sessions — SaveSessionLineAction
- Event: "SaveSessionLine" (@VertxEventDefinition on SaveSessionLineAction)
- Purpose: Persist the current line state (including any instruction selections) into the session snapshot and refresh the UI. No hardware/COM-port flow.
- Inputs: UWEServerMessage that includes data["sessionLine"] as a PackingSessionLineDTO; standard farmId, packshedId, packingSessionId are taken from the message envelope.
- Behavior: Loads enterprise→system→identityToken → farm → session; applies the provided instruction selections onto the line’s pack instruction group; calls IPackingSessionService.updateCache(session, sessionId, session, system, identityToken); publishes PackingSessionDataFetch for full UI refresh.
- When to use: Any “Save Line” UX that only needs to persist current selections/state. If a packingGroupId is also being set/changed, prefer SetSessionLinePackingGroupAction; otherwise SaveSessionLineAction suffices.

Web Client Preference (2025-09-21):
- The Save Line button should publish directly to "SaveSessionLine" when no packing group ID is being applied. If a packing group is selected, the client should publish directly to "SetSessionLinePackingGroup" with sessionLineId and packingGroupId.
- In both cases, bypass listener layers that do not add coordination logic.

Rationale:
- Reduces latency and complexity.
- Keeps all state mutations confined to Actions, in line with our cache consistency guarantees.
- Simplifies error handling and logging by having a single authoritative place for the mutation pipeline.


# Actions & Listeners — Global Directive (2025-09-21 21:36)

Scope: These directives apply to ALL servers and modules (Sessions, Staff, Web-Server, Messaging, Barcode, BarcodeBatch, etc.). They codify our universal approach for Actions and Listeners and supersede older, module-specific habits.

Key principles
- Actions are the only units that mutate core state and call updateCache. Always resolve enterprise → system → identityToken within the action’s reactive pipeline. After successful cache updates, publish the appropriate DataFetch to refresh the UI.
- Listeners do not mutate state. They validate inputs, normalize payloads, and orchestrate one or more Actions when coordination is needed. They may publish DataFetch for read-only refreshes but must never call updateCache directly.
- Prefer direct Action invocation when no multi-step orchestration is required. From the Web client, publish straight to the Action address (e.g., SetSessionLinePackingGroup, SaveSessionLine, Staff mutations). Bypass pass-through listeners that only forward to an Action.
- Typed event payloads. Prefer strongly-typed objects on the event bus. Keep Map support only for legacy compatibility. Use DefaultObjectMapper defensively where needed.
- Reactive lifecycle. All writes occur inside sessionFactory.withTransaction; Actions return a Uni and do not subscribe internally. Fetch proxies before use.

What this means in practice
- Web → Server: Choose the Action address directly for single-step mutations. Examples: SaveSessionLine (persist line), SetSessionLinePackingGroup (set group IDs), Staff enable/disable, Timesheet updates.
- Listeners remain for: input normalization across multiple emitters, fan-out to multiple Actions, hardware routing (COM-port grouping), and read-only DataFetch flows.
- After any mutation impacting Farm/Session/Staff/Timesheets, the Action calls the correct service.updateCache(... system, token) and then publishes the related DataFetch (FarmDataFetch, PackingSessionDataFetch, StaffDataFetch, etc.).

Global checklist (Actions)
- [ ] Resolve enterprise → system → identityToken inside the action’s reactive pipeline.
- [ ] Load farm/session/station as applicable; validate all fetches and fail fast with clear ❌ messages.
- [ ] Perform mutation(s), update aggregates, and call the relevant service.updateCache(..., system, identityToken).
- [ ] Publish appropriate DataFetch to refresh the UI.
- [ ] Do not subscribe inside actions; return Uni and let the caller manage subscription.

Global checklist (Listeners)
- [ ] Do not mutate state or call updateCache.
- [ ] Validate payloads and normalize keys/types for downstream Actions.
- [ ] Orchestrate when necessary (multi-step flows); otherwise prefer direct Action invocation from the client.
- [ ] Use typed payloads when possible; support legacy Map emitters with defensive parsing.
- [ ] Keep logs concise with emoji prefixes (✅, ❌, ⚠️, ℹ️, 🔄, 📋).

Notes
- The previously documented Sessions-specific guidance (SaveSessionLineAction, SetSessionLinePackingGroupAction) reflects this universal rule set and should be followed analogously in Staff, Web-Server, and other modules.
