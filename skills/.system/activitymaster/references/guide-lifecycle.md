# activitymaster: Lifecycle

Read this reference when working on the topics below. Build commands use the stated DevSuite module or its POM; interaction examples use the verified host context.

- [Lifecycle & Bootstrap](#lifecycle--bootstrap)
- [On-Demand Data Loading Pattern](#on-demand-data-loading-pattern)
- [Progress Reporting (IProgressable + SPI monitors)](#progress-reporting-iprogressable--spi-monitors)

## Lifecycle & Bootstrap

### Enterprise Creation Flow

See [references/enterprise-lifecycle.md](../references/enterprise-lifecycle.md) for detailed flow.

```
createNewEnterprise() → loadUpdates() → startNewEnterprise()
```

1. **createNewEnterprise()** — Initialize new enterprise with base data
2. **loadUpdates()** — Load classifications/types via `ISystemUpdate`/`@SortedUpdate`
3. **startNewEnterprise()** — Register admin user via `IPasswordsService`, execute post-startup

### ISystemUpdate & @SortedUpdate Mechanism

System bootstrap taxonomy/type data is installed by `ISystemUpdate` implementations, ordered and
gated by the `@SortedUpdate` annotation. The mechanism is **run-once + idempotent per enterprise**
with completion tracked in the database, plus a `force` escape hatch for re-runnable updates.

#### The annotation — `@SortedUpdate`

`com.guicedee.activitymaster.fsdm.client.services.systems.SortedUpdate` (a Guice `@BindingAnnotation`,
`@Retention(RUNTIME)`):

| Attribute | Type | Default | Meaning |
|---|---|---|---|
| `sortOrder()` | `int` | — (required) | Ascending execution order **and dedup key**. Updates land in a `TreeMap<Integer, Class>` keyed by `sortOrder`, so **two updates sharing a `sortOrder` collide — the later class silently overrides the earlier one.** Keep them unique. |
| `taskCount()` | `int` | — (required) | How many progress "tasks" this update contributes. `loadUpdates` **sums `taskCount` across all applicable updates** into `setTotalTasks(...)` before the run, so the `IProgressable` percentage is meaningful. Each update advances it via `logProgress(source, msg, delta)`. |
| `optional()` | `boolean` | `false` | Declared "may run after install". **Currently not consumed** by the run loop (`getUpdates`/`loadUpdates`/`processUpdates`) — reserved; do not rely on it to gate execution. |
| `force()` | `boolean` | `false` | **Re-run every install.** See *force semantics* below. |

#### The interface — `ISystemUpdate extends IProgressable`

There is **no `runUpdate(...)`** method and updates are **not** handed a `system` or `identityToken`.
Implement the **stateless** overload — `update(Mutiny.StatelessSession, IEnterprise<?,?>)` returning
`Uni<Boolean>` (it defaults to throwing `UnsupportedOperationException` until you override it):

```java
public interface ISystemUpdate extends IProgressable {
    // Implement this — the stateless-session overload the install loop runs
    default Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) { throw new UnsupportedOperationException(); }
}
```

Resolve the ActivityMaster system yourself inside the body
(`ISystemsService.findSystem(session, enterprise, ActivityMasterSystemName)`), do the taxonomy/type
creation on the passed `StatelessSession`, `logProgress(...)` to advance, and `map(... -> true)`:

```java
@SortedUpdate(sortOrder = 0, taskCount = 6)
public class ProductsBaseSetup implements ISystemUpdate {
    @Inject private IClassificationService<?> service;

    @Override
    public Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
        return IGuiceContext.get(ISystemsService.class)
            .findSystem(session, enterprise, ActivityMasterSystemName)
            .chain(system -> service.create(session, ProductClassifications.Products, system)
                // … chain the rest of the type/classification creation …
                .invoke(() -> logProgress("Products System", "Loaded Product Classifications...", 5))
                .map(r -> true));
    }
}
```

Register via `module-info.java` (ClassGraph discovers by annotation, so the `provides` is for the
Guice/ServiceLoader wiring):

```java
provides ISystemUpdate with {ModuleName}Install;
```

#### Discovery, ordering & sequential execution

`EnterpriseService.loadUpdates(Mutiny.StatelessSession, enterprise)` drives the run:

1. **Discover** — `getUpdates(...)` ClassGraph-scans `getClassesWithAnnotation(SortedUpdate)`, skips
   abstract/interfaces, and puts each concrete class into a `TreeMap` keyed by `sortOrder` (ascending,
   dedup by key).
2. **Filter** against already-applied updates (see completion tracking) — this yields the
   *applicable* map.
3. **Sum `taskCount`** across the applicable updates → `setCurrentTask(0)` + `setTotalTasks(sum)`.
4. **Execute sequentially** via `processUpdates(...)` recursion (never in parallel — one update per
   session at a time). Each update is instantiated through `IGuiceContext.get(clazz)` so `@Inject`
   fields are populated, wrapped with `IOnSystemUpdate` start/end/fail callbacks.
5. **Stamp completion date** — after the sweep, `updateLastUpdateDate` upserts
   `EnterpriseClassifications.LastUpdateDate` = today on the enterprise.

> **A failing update does not abort the sweep.** `processUpdates` does `.onFailure().recoverWithItem(null)`,
> logs the error, fires `IOnSystemUpdate.onSystemUpdateFail(clazz)`, and continues to the next update.
> Because completion is only recorded on **success** (below), a failed update stays "not applied" and
> is retried on the next install.

#### Completion tracking — persisted as an enterprise classification (not a table)

There is **no dedicated "applied updates" table/version column**. Completion is recorded as a
relationship classification on the **Enterprise** itself under the
`EnterpriseClassifications.UpdateClass` name:

- **Record (on success):** `performUpdate(...)` chains after a successful `o.update(...)` and calls
  `enterprise.addClassification(session, UpdateClass.toString(), o.getClass().getCanonicalName(), system)`.
- **Read:** `getEnterpriseAppliedUpdates(...)` does
  `enterprise.findClassifications(session, UpdateClass.toString(), system)` and returns the `Set<String>`
  of stored canonical class names. Guice enhancer suffixes are stripped
  (`…$$EnhancerByGuice$$…` → base class name) on **both** the write-comparison and read side so a
  proxied instance still matches its plain class name.

#### `force` semantics — the exact skip rule

The applicability filter in `getUpdates(...)` is a single line, applied per candidate update:

```java
// value = the @SortedUpdate class; classValue = its (enhancer-stripped) canonical name
SortedUpdate du = value.getAnnotation(SortedUpdate.class);
if (!enterpriseAppliedUpdates.contains(classValue) || du.force()) {
    applicableUpdates.put(key, value);   // include it in this install run
}
```

| `force()` | Already applied to this enterprise? | Included this run? |
|---|:--:|:--:|
| `false` (default) | no  | ✅ runs once |
| `false` (default) | yes | ⛔ **skipped** (idempotent run-once) |
| `true` | no  | ✅ runs |
| `true` | yes | ✅ **runs again every install** (skip bypassed) |

So `force = true` means **"always re-run, ignore the applied-updates record"** — use it for updates
that must reconcile/repair state on every boot (they must be safe to re-execute: the underlying
`IClassificationService.create(...)` is name+concept+enterprise scoped and therefore idempotent). With
`force = false`, an update runs **exactly once per enterprise** — the first successful run writes the
`UpdateClass` classification, and every later install sees it in `enterpriseAppliedUpdates` and skips
it. Note `force` still records completion each successful run (re-adding the same classification is a
harmless upsert); it does not clear it.

#### Current ISystemUpdate implementations

| Module | Class | `sortOrder` | `taskCount` | Purpose |
|--------|-------|:--:|:--:|---------|
| core | `ClassificationBaseSetup` | `-500` | 3 | Base classification attribute types (ISO attrs, etc.) — earliest |
| core | `AddressBaseSetup` | `-400` | 15 | Address type classifications |
| core | `ArrangementsBaseSetup` | `-300` | 3 | Arrangement type classifications |
| core | `UnknownResourceItemTypeSetup` | `-201` | 1 | Default unknown resource type |
| core | `ResourceItemsBaseSetup` | `-200` | 3 | Resource item types |
| core | `EventsBaseSetup` | `-100` | 3 | Event type classifications |
| core | `ProductsBaseSetup` | `0` | 6 | Product type classifications |
| profiles | `ProfileMasterInstall` | `50` | 1 | Profile type classifications |
| user-sessions | `SessionMasterInstall` | `75` | 1 | Session type classifications |
| cerial | `CerialMasterInstall` | `500` | 3 | Serial port classifications |
| geography | `GeographySystemInstall` | `1000` | 12 | Geographic hierarchy **taxonomy only** |
| core | `PluginInstall` | `1010` | 1 | Catalogue/declaration/installation/consent/policy/audit taxonomy |
| core | `BuiltInPluginsInstall` | `1020` | 1 | Forward built-in identity conversion and catalogue provisioning |
| core | `PluginArchitectureInstall` | `1030` | 1 | Forward discovery through the independent plugin SPI |
| conversations | `ConversationPluginInstall` / `ConversationInstall` | `1174` / `1175` | 1 each | Forward plugin conversion / conversation taxonomy |
| documents | `DocumentPluginInstall` / `DocumentInstall` / `DocumentVersionInstall` | `1184` / `1185` / `1186` | 1 each | Forward conversion / document and version taxonomy |
| marketplace-master | `MarketplacePluginInstall` / `MarketplaceInstall` | `1187` / `1188` | 1 each | Separate marketplace/producer registrations / domain taxonomy |
| images | `ImageSystemInstall` | `1100` | 1 | Image type classifications |
| wallet | `WalletSystemInstall` | `1200` | 5 | Plugin catalogue, Wallet/Clearing, balanced posting taxonomy |
| payments | `PaymentSystemInstall` | `1300` | 1 | Plugin catalogue and payment intent taxonomy |
| mail | `MailMasterInstall` | `1500` | 4 | Plugin catalogue and mail Event/resource/mailbox taxonomy |
| core | `TimeServiceSetup` | `Integer.MAX_VALUE - 200` | 1 | Time-related classifications — runs last |

> Negative `sortOrder`s deliberately run the **core taxonomy first** (attribute classifications other
> installs depend on), then feature modules, with `TimeServiceSetup` pinned to the very end. When
> adding a module, pick a `sortOrder` that slots after every taxonomy it consumes.

**Important:** ISystemUpdate should ONLY create taxonomy/type structures. Never load bulk data at startup.


## On-Demand Data Loading Pattern

For modules with large reference datasets (geography, exchange rates, etc.), follow this pattern:

1. **Startup** — ISystemUpdate creates only the structural taxonomy (classification hierarchy, types)
2. **REST endpoint** — POST endpoint triggers data loading
3. **Event bus consumer** — `@VertxEventDefinition` consumer triggers the same logic
4. **Service method** — Shared service method called by both REST and event bus

```java
// Service interface
public interface IGeographyService<J extends IGeographyService<J>> {
    Uni<Void> loadLanguages(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> installCountry(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
}

// REST triggers the service
@POST @Path("{system}/install/languages")
public Uni<String> installLanguages(...) {
    return SessionUtils.withActivityMaster(enterprise, system, tuple ->
        geographyService.loadLanguages(tuple.getItem1(), tuple.getItem3(), tuple.getItem4())
            .replaceWith("Languages loaded successfully")
    );
}

// Event bus triggers the same service
@VertxEventDefinition(value = "geography.install.languages", options = @VertxEventOptions(worker = true))
public String installLanguages(Message<String> message) {
    SessionUtils.withActivityMaster(message.body(), GeographySystemName, tuple ->
        geographyService.loadLanguages(tuple.getItem1(), tuple.getItem3(), tuple.getItem4())
    ).await().indefinitely();
    return "Languages loaded";
}
```

### On-Demand Loader Gotchas (hard-won)

These were discovered debugging the geography on-demand install (countries, languages, timezones). They apply to **any** FSDM loader/service that is handed a `Mutiny.StatelessSession` and creates + reads classifications in the same flow.

1. **Never nest `SessionUtils.withActivityMaster(...)` inside a flow that already owns a session/transaction.**
   `withActivityMaster` (and `withSessionTx`) **always opens a brand-new session and transaction**. A nested transaction cannot see the still-uncommitted rows written by the outer transaction, so a follow-up `find` fails with `NoResultException`. Service methods that receive a `Mutiny.StatelessSession` must operate **directly on that session**:
   ```java
   // ❌ BAD — opens a new tx that can't see the caller's uncommitted writes
   public Uni<...> createPlanet(Mutiny.StatelessSession session, ...) {
       return SessionUtils.withActivityMaster(enterprise, system.getName(), tuple -> {
           var s = tuple.getItem1(); // different session/tx!
           ...
       });
   }
   // ✅ GOOD — reuse the caller's session/tx
   public Uni<...> createPlanet(Mutiny.StatelessSession session, ISystems<?,?> system, UUID... token) {
       var s = session;
       var enterprise = system.getEnterprise();
       ...
   }
   ```
   Only the **top-level entry point** (REST handler, event-bus consumer, `ISystemUpdate.update`) should open the session via `withActivityMaster`.

2. **Classification names are NOT globally unique — always thread the data concept.**
   The same name (e.g. `EUR`, `aa`, an ISO code) can exist under different `EnterpriseClassificationDataConcepts`. A concept-less `find`/`addOrUpdateClassification` defaults to `NoClassificationDataConceptName` and either resolves the wrong row or fails. `IManageClassifications` now exposes concept-aware overloads — use them when the classification lives under a specific concept:
   ```java
   // EUR lives under Currency.concept() (= ClassificationXClassification), not NoClassification
   geo.addOrUpdateClassification(session, "EUR", Currency.concept(), searchValue, value, system, token);
   ```
   `addOrUpdateClassification` / `addOrReuseClassification` / `updateClassification` all accept an optional `EnterpriseClassificationDataConcepts concept` and only fall back to `NoClassificationDataConceptName` when none is supplied. Note these overloads require the classification to **already exist** (the outer `find` is not recovered) — they find-or-create the *relationship*, not the classification.

3. **`create(...)` concept must match the `find(...)` concept.**
   If you create a classification under `X.concept()` you must search it under the **same** concept. A mismatch (e.g. create under `EnterpriseClassificationDataConcepts.Classification` but `findTimeZone` filters on `TimeZone.concept()` = `GeographyXGeography`) silently yields `NoResultException`. Keep `createX`/`findX` concept arguments identical.

4. **Loaders depend on core `ClassificationBaseSetup` taxonomy.**
   Attribute classifications such as `ISO639_1/2`, `ISO6392EnglishName/FrenchName/GermanName` are created by core's `ClassificationBaseSetup` (`@SortedUpdate(sortOrder = -500)`). When a module loads data **on demand** without the full sorted update chain having run (e.g. `EnterpriseService.createNewEnterprise` has `loadUpdates(...)` commented out, and tests call a single `ISystemUpdate.update` directly), those classifications are missing and `addOrReuseClassification(ISO639_2, ...)` fails with `NoResultException`. Make the module's own install self-sufficient by creating the attribute classifications it consumes (idempotent — `create()` is name+concept+enterprise scoped, so it's a no-op if the base setup already ran). Classifications are **enterprise-scoped, not system-scoped**, so creating them under any system of the enterprise makes them findable from every system.

5. **Eagerly-instantiated consumers need the canonical wildcard binder.**
   A service injected as `IService<?>` (e.g. by `VertXModule` eager singletons / event consumers) is NOT satisfied by a raw `bind(IService.class).to(Impl.class)`. Bind the wildcard and concrete-generic keys too:
   ```java
   Key<IGeographyService<?>> wildcard = Key.get(new TypeLiteral<IGeographyService<?>>() {});
   Key<IGeographyService<GeographyService>> concrete = Key.get(new TypeLiteral<IGeographyService<GeographyService>>() {});
   bind(concrete).to(GeographyService.class).in(Singleton.class);
   bind(wildcard).to(concrete);
   bind(IGeographyService.class).to(wildcard);
   ```

6. **Reactive stack traces have no app frames.** A `NoResultException` thrown by `ReactiveAbstractSelectionQuery.reactiveSingleResult` only shows Vert.x/Hibernate-Reactive infra frames. Pinpoint the failing step from the surrounding **log messages** (e.g. the last `Classification '<x>' creation completed successfully` / `Linked data concept to '<x>'`) rather than the stack. Note the create-completion INFO log is only emitted on the *no-parent* branch, so its absence does not by itself prove the create failed.

7. **Never block the event loop to resolve a value — keep link configuration reactive.** Entity hooks that participate in a reactive chain must not call `.await().atMost(...)`. `Classification.configureForClassification` used to resolve the `NoClassification` marker with a blocking `await` on the Vert.x event-loop thread, which **deadlocks** for classification→classification links and surfaces as `io.smallrye.mutiny.TimeoutException` after the await timeout (e.g. 50 s). The fix was to make the contract itself reactive — `IManageClassifications.configureForClassification(...)` now returns `Uni<Void>` and implementors resolve dependencies via `map(...)`:
   ```java
   // ❌ BAD — blocks the event loop, deadlocks for classification→classification links
   c.setClassificationID(svc.getNoClassification(session, system).await().atMost(Duration.ofSeconds(50)));
   // ✅ GOOD — reactive, non-blocking
   return svc.getNoClassification(session, system).map(nc -> { c.setClassificationID(nc); return (Void) null; });
   ```
   Rule: if an `IManageX` link-configuration / hook method needs a DB value, return a `Uni` and `chain`/`map` it — never `await` inside a hook invoked from a subscription.

8. **Keep bulk reference-data security separate from private plugin rows.**
   Use the stateless `ISecurityTokenService.applyDefaultSecurityToRows` or
   `applyDefaultSecurityToTable` batch paths for authorized reference-data imports;
   repeated single-row token lookups are unsuitable for bulk work. The single-entity
   `createDefaultSecurity` path is flag-driven and is not a no-op. A public/reference
   batch matrix is not private user security. Plugin domain code must write restricted
   row grants for the real actor and compose all security with its domain transaction.
   In particular Mail archives initial default grants on new mail Event/resources/
   mailbox and grants Administrators plus the actual user. Applicable-token expansion
   excludes Plugin identities despite compatibility folder grant rows.

## Plugin upgrade and activation

Plugin taxonomy 1010 and built-in conversion 1020/1030 run through the existing
`ISystemUpdate` lifecycle, using caller-owned stateless transactions and the live
core identifying bootstrap credential. Keep sort orders unique. The conversion
preserves durable registration IDs/domain data and live catalogue media, retires
legacy System credentials/hierarchy links and registers Plugin identities under
Plugins. It does not rewrite legacy mailbox ownership or install/consent for users.
Wallet 1200, Payments 1300 and Mail 1500 also provision their catalogue when added
later. Use an authorized enterprise update for an existing tenant; module discovery
alone is not activation. Then install on a real authorized party, obtain individual
consent and provision required provider/domain grants. No plugin-specific schema
migration or startup DDL is needed. See [the plugin lifecycle contract](scoped-plugins.md).

## Progress Reporting (IProgressable + SPI monitors)

Long-running, measurable work — system installs, `ISystemUpdate`s, on-demand reference-data loads —
reports progress through the `IProgressable` mix-in (in `…fsdm.client.services.systems`). This is the
**recommended pattern for addon/feature modules** that load bulk data on demand (the geography addon
uses it across every loader, covered by tests).

### Two collaborating types

| Type | Role |
|---|---|
| `IProgressable` | A **mix-in** a loader/service `implements`. Provides `setTotalTasks` / `setCurrentTask` / `getCurrentTask` / `getTotalTasks` and the `logProgress(...)` overloads. Holds **no state of its own**. |
| `IActivityMasterProgressMonitor` | An **SPI** (`extends IDefaultService`) that actually **holds the counters and renders the update**. Discovered via `ServiceLoader` and cached on `ActivityMasterConfiguration.getProgressMonitors()`. Multiple monitors observe the same progress (console logger, WebSocket-group broadcaster, metrics reporter, …). |

`IProgressable` never stores progress — every call **fans out to every registered monitor**, so the
counters live in the monitors. `ConsoleLogActivityMasterProgressMaster` is the built-in monitor; it
logs `[NN%] source - message (current/total)` and **throttles** to emit only when the completion
percentage actually changes (so a loader advancing thousands of fine-grained tasks does not flood the
log). Register additional monitors via
`META-INF/services/…systems.IActivityMasterProgressMonitor`.

### `logProgress(...)` overload semantics

| Overload | Effect on counters | Use for |
|---|---|---|
| `logProgress(source, message, delta, total)` | sets total (if non-null) **and** advances current by `delta` (if non-null), then publishes with both counts | the rare call that needs to set the total inline |
| `logProgress(source, message, delta)` | advances current by `delta`, publishes with counts | **per-item** progress inside a loop |
| `logProgress(source, message)` | **no counter change** — milestone message only | phase start/finish milestones |

> The counters are computed **once per call** from a single source of truth and then pushed to every
> monitor, so all monitors stay in lock-step. `getPercentageComplete()` (on the monitor) is
> `round(current * 100 / total)`, clamped to `[0,100]`, returning `0` when the total is unknown.

### Canonical addon-loader usage (the geography pattern)

Each load phase: reset the current counter, declare the **real** total from the actual record count
(never a hard-coded magic number), advance by one per item, and emit a finishing milestone.

```java
public class GeographyService implements IProgressable, IGeographyService<GeographyService> {

    public Uni<Void> loadProvincesASCII1(Mutiny.StatelessSession session, ISystems<?,?> system, UUID... token) {
        setCurrentTask(0);                                  // reset the phase
        return parse(...).chain(records -> {
            setTotalTasks(records.size());                  // ← real total, not a guess
            Uni<Void> chain = Uni.createFrom().voidItem();
            for (var ascii : records) {
                chain = chain.chain(() -> createProvince(session, ascii, system, token)
                        // advance by one and publish per item
                        .invoke(p -> logProgress("Geography Service", "Loaded Province Codes - " + ascii.getName(), 1))
                        .replaceWithVoid());
            }
            return chain;
        })
        .invoke(() -> logProgress("Geography Service", "Finished Province Codes"));  // milestone, no advance
    }
}
```

### Rules for addon modules

1. **`implements IProgressable`** on the service/loader doing the work — nothing else to wire; the
   monitors are resolved from configuration.
2. **Real totals only.** `setTotalTasks(records.size())` / `dataMap.size()` — never hard-code an
   estimated count. (The geography loaders were corrected away from magic totals like `47850`/`102850`.)
3. **`setCurrentTask(0)` at the start of every phase** so the percentage gate resets and the next
   phase starts from 0%.
4. **`delta` for items, message-only for milestones.** Use `logProgress(src, msg, 1)` inside the loop
   and `logProgress(src, msg)` for "Finished …" so the totals stay accurate.
5. **`source` is a stable phase label** (e.g. `"Geography Service"`, `"Postal Codes"`) — monitors
   (e.g. a WebSocket group) key their UI off it.

> This is exactly how a WebSocket-group broadcaster plugs in: implement
> `IActivityMasterProgressMonitor.progressUpdate(source, message, currentTask, totalTasks)`, register
> it via `ServiceLoader`, and every loader's progress streams to the subscribed group with live
> `current/total` counts — no change to the loaders.
