# ActivityMaster Enterprise Lifecycle Reference

Complete reference for enterprise creation, initialization, updates, and lifecycle management.

## Contents

- [Enterprise Lifecycle Overview](#enterprise-lifecycle-overview)
- [Phase 1: Enterprise Creation](#phase-1-enterprise-creation)
- [Phase 2: Loading Updates (ISystemUpdate)](#phase-2-loading-updates-isystemupdate)
- [Phase 3: Enterprise Startup](#phase-3-enterprise-startup)
- [Phase 3b: Default Security Provisioning](#phase-3b-default-security-provisioning)
- [Complete Lifecycle Flow](#complete-lifecycle-flow)
- [ActiveFlag Lifecycle](#activeflag-lifecycle)
- [Update Tracking](#update-tracking)
- [Best Practices](#best-practices)

## Enterprise Lifecycle Overview

ActivityMaster uses a structured lifecycle for enterprise management with three main phases:

1. **Creation** - Initial enterprise entity creation
2. **Updates** - Loading and applying ISystemUpdate implementations
3. **Startup** - Final initialization and activation

```
createNewEnterprise() → loadUpdates() → startNewEnterprise()
```

---

## Phase 1: Enterprise Creation

### createNewEnterprise()

Initial creation of the enterprise entity with basic information.

```java
public class EnterpriseLifecycleManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> createNewEnterprise(EnterpriseCreationRequest request) {
        Enterprise enterprise = new Enterprise()
            .setId(UUID.randomUUID().toString())
            .setName(request.getName())
            .setDescription(request.getDescription())
            .setEnterpriseType(request.getType())
            .setActiveFlag(ActiveFlag.Unknown) // Start as Unknown
            .setCreatedAt(LocalDateTime.now())
            .setUpdatedAt(LocalDateTime.now());

        return enterpriseService.createEnterprise(enterprise);
    }
}
```

### Enterprise Creation Flow

```java
@Path("/enterprises")
@Singleton
public class EnterpriseResource {
    @Inject
    EnterpriseLifecycleManager lifecycleManager;

    @POST
    @Path("/create")
    public Uni<Enterprise> createEnterprise(EnterpriseCreationRequest request) {
        return lifecycleManager.createNewEnterprise(request)
            .invoke(created -> log.info("Enterprise created: {}", created.getId()));
    }
}
```

### Creation Request Model

```java
public class EnterpriseCreationRequest {
    @NotBlank
    private String name;

    private String description;

    @NotBlank
    private String type;

    private String parentEnterpriseId;

    private Map<String, String> metadata;

    // Getters and setters
}
```

---

## Phase 2: Loading Updates (ISystemUpdate)

### ISystemUpdate Interface

System updates seed **taxonomy/type structures** (classifications, type records) after enterprise
creation. The interface `com.guicedee.activitymaster.fsdm.client.services.systems.ISystemUpdate`
**extends `IProgressable`** and exposes the **`update(...)` overload returning `Uni<Boolean>`** for a
`Mutiny.StatelessSession`. It **defaults to throwing `UnsupportedOperationException`**, so an updater
overrides it to do its work.

```java
public interface ISystemUpdate extends IProgressable {
    // Stateless-session overload — the install loop runs this
    default Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
        return Uni.createFrom().failure(new UnsupportedOperationException(
                getClass().getSimpleName() + " has no stateless update overload"));
    }
}
```

> There is **no** `applyUpdate(Enterprise, SecurityToken)`, `getUpdateId()`, `getDescription()`, or
> `isApplied(...)` method — those never existed. Updates receive only `(session, enterprise)` and
> resolve everything else (the ActivityMaster system, tokens) themselves from `enterprise`.


### Update Ordering & Gating with @SortedUpdate

`@SortedUpdate` (a Guice `@BindingAnnotation`, `@Retention(RUNTIME)`) both **orders** and **gates**
each update:

```java
@Retention(RetentionPolicy.RUNTIME)
@BindingAnnotation
public @interface SortedUpdate {
    int sortOrder();               // ascending order + dedup key (unique!)
    int taskCount();               // progress tasks contributed (summed into setTotalTasks)
    boolean optional() default false;  // declared; NOT consumed by the current run loop
    boolean force()    default false;  // re-run every install (bypass the applied-updates skip)
}
```

- **`sortOrder`** — updates are stored in a `TreeMap<Integer, Class>` keyed by `sortOrder`, so they run
  ascending and **a duplicate `sortOrder` silently overrides** the earlier class. Keep them unique.
- **`taskCount`** — `loadUpdates` sums every applicable update's `taskCount` into
  `setTotalTasks(...)` so the `IProgressable` percentage is accurate; each update advances it with
  `logProgress(source, msg, delta)`.
- **`force`** — see [Update Tracking](#update-tracking): `force=false` runs the update **once per
  enterprise**; `force=true` **re-runs it on every install**, ignoring the applied record.
- **`optional`** — declared but **not currently consumed** by `getUpdates`/`loadUpdates`; reserved.

### Example System Update

Concrete `ProductsBaseSetup` (core), showing the real stateless signature, progress reporting, and the
`map(... -> true)` completion signal:

```java
@SortedUpdate(sortOrder = 0, taskCount = 6)
@Log4j2
public class ProductsBaseSetup implements ISystemUpdate {
    @Inject private IClassificationService<?> service;

    @Override
    public Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
        ISystemsService<?> systemsService = IGuiceContext.get(ISystemsService.class);
        return systemsService.findSystem(session, enterprise, ActivityMasterSystemName)
            .chain(system -> service.create(session, ProductClassifications.Products, system)
                .chain(base -> service.create(session, ProductClassifications.ProductGroup, system, ProductClassifications.Products)
                    .chain(() -> service.create(session, ProductClassifications.ProductTypeName, system, ProductClassifications.ProductGroup))
                    .chain(() -> service.create(session, ProductClassifications.ProductPremiumType, system, ProductClassifications.ProductGroup))
                    .chain(() -> service.create(session, ProductClassifications.ProductBaseCost, system, ProductClassifications.ProductGroup))
                    .invoke(() -> logProgress("Products System", "Loaded Product Classifications...", 5))
                    .map(r -> true)));      // Boolean success signal — completion is then recorded
    }
}
```

Register in `module-info.java`:

```java
provides ISystemUpdate with com.guicedee.activitymaster.fsdm.injections.updates.ProductsBaseSetup;
```

### loadUpdates() — the real run loop (EnterpriseService)

Discovery, ordering, filtering, progress totals and sequential execution all live in
`EnterpriseService` — **not** a `EnterpriseLifecycleManager`, and discovery is a **ClassGraph
annotation scan**, not `ServiceLoader.load(ISystemUpdate.class)`:

```java
public Uni<Integer> loadUpdates(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
    return getUpdates(session, enterprise)                    // discover + filter (see below)
        .chain(applicable -> {
            setCurrentTask(0);
            int tasks = 0;
            for (var e : applicable.entrySet())               // sum taskCount across applicable updates
                tasks += e.getValue().getAnnotation(SortedUpdate.class).taskCount();
            setTotalTasks(tasks);

            var handlers = IGuiceContext.loaderToSet(ServiceLoader.load(IOnSystemUpdate.class));
            return systemsService.getActivityMaster(session, enterprise)
                .chain(system -> processUpdates(session,                 // sequential recursion
                        new ArrayList<>(applicable.entrySet()), 0, enterprise, system, handlers)
                    .chain(() -> updateLastUpdateDate(session, enterprise, system)  // stamp LastUpdateDate = today
                        .chain(a -> Uni.createFrom().item(applicable.size()))));
        });
}

// Discovery + applicability filter
public Uni<Map<Integer, Class<? extends ISystemUpdate>>> getUpdates(Mutiny.StatelessSession s, IEnterprise<?,?> ent) {
    return Uni.createFrom().item(() -> {
        Map<Integer, Class<? extends ISystemUpdate>> available = new TreeMap<>();
        for (ClassInfo ci : GuiceContext.instance().getScanResult()
                .getClassesWithAnnotation(SortedUpdate.class.getCanonicalName())) {
            if (ci.isAbstract() || ci.isInterface()) continue;
            var clazz = (Class<? extends ISystemUpdate>) ci.loadClass();
            available.put(clazz.getAnnotation(SortedUpdate.class).sortOrder(), clazz);  // dedup by sortOrder
        }
        return available;
    }).chain(available -> getEnterpriseAppliedUpdates(s, ent).map(applied -> {
        Map<Integer, Class<? extends ISystemUpdate>> applicable = new TreeMap<>();
        for (var e : available.entrySet()) {
            String name = stripGuiceEnhancer(e.getValue().getCanonicalName());
            SortedUpdate du = e.getValue().getAnnotation(SortedUpdate.class);
            if (!applied.contains(name) || du.force())        // ← the skip / force rule
                applicable.put(e.getKey(), e.getValue());
        }
        return applicable;
    }));
}
```

`processUpdates(...)` walks the sorted list **one update at a time** (never parallel — one action per
session). Each update is instantiated with `IGuiceContext.get(clazz)` (so `@Inject` works), wrapped
with `IOnSystemUpdate` `onSystemUpdateStart/End/Fail` callbacks, then `performUpdate(...)` runs it and
records completion.

> **A failing update does not abort the sweep.** `processUpdates` does `.onFailure().recoverWithItem(null)`,
> logs the error, fires `IOnSystemUpdate.onSystemUpdateFail(clazz)`, and continues. Because completion
> is only recorded on **success**, a failed update stays "not applied" and is retried next install.

### Current core ISystemUpdate order

| Class (module) | `sortOrder` | `taskCount` |
|---|:--:|:--:|
| `ClassificationBaseSetup` (core) | `-500` | 3 |
| `AddressBaseSetup` (core) | `-400` | 15 |
| `ArrangementsBaseSetup` (core) | `-300` | 3 |
| `UnknownResourceItemTypeSetup` (core) | `-201` | 1 |
| `ResourceItemsBaseSetup` (core) | `-200` | 3 |
| `EventsBaseSetup` (core) | `-100` | 3 |
| `ProductsBaseSetup` (core) | `0` | 6 |
| `ProfileMasterInstall` (profiles) | `50` | 1 |
| `SessionMasterInstall` (user-sessions) | `75` | 1 |
| `CerialMasterInstall` (cerial) | `500` | 3 |
| `GeographySystemInstall` (geography) | `1000` | 12 |
| `ImageSystemInstall` (images) | `1100` | 1 |
| `MailMasterInstall` (mail) | `1500` | 4 |
| `TimeServiceSetup` (core) | `Integer.MAX_VALUE - 200` | 1 |


---

## Phase 3: Enterprise Startup

### startNewEnterprise()

Final activation and initialization after all updates are applied.

```java
import com.google.inject.Singleton;

@Singleton
public class EnterpriseLifecycleManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> startNewEnterprise(Enterprise enterprise, SecurityToken token) {
        log.info("Starting enterprise: {}", enterprise.getId());

        return validateEnterpriseReady(enterprise, token)
                .chain(() -> activateEnterprise(enterprise, token))
                .chain(activated -> performStartupTasks(activated, token))
                .invoke(started -> log.info("Enterprise {} started successfully", started.getId()));
    }

    private Uni<Void> validateEnterpriseReady(Enterprise enterprise, SecurityToken token) {
        // Ensure all required updates are applied
        // Validate data integrity
        return Uni.createFrom().voidItem();
    }

    private Uni<Enterprise> activateEnterprise(Enterprise enterprise, SecurityToken token) {
        enterprise.setActiveFlag(ActiveFlag.Active);
        enterprise.setUpdatedAt(LocalDateTime.now());

        return enterpriseService.updateEnterprise(enterprise, token);
    }

    private Uni<Enterprise> performStartupTasks(Enterprise enterprise, SecurityToken token) {
        // Send welcome notifications
        // Initialize background jobs
        // Set up default configurations
        return Uni.createFrom().item(enterprise);
    }
}
```

---

## Phase 3b: Default Security Provisioning

During install (`SecurityTokenSystem.createDefaults` → `applyDefaultsToNewEnterprise` /
`applyDefaultsToNewEnterpriseAfterActivityMaster`) every warehouse record is given its default
security — a fan-out of canonical group/folder grants. Because this can be an *exhaustive* number of
inserts, it runs as **batched inserts on a `Mutiny.StatelessSession`**.

### Why creation is NOT gated by the security-enabled flag

`ActivityMasterConfiguration.isSecurityEnabled()` is **call-scoped** (`CallScopeProperties` key
`fsdm.securities`) and **secure-by-default** (returns `true` with no scope/property). It governs
row-level read **enforcement**, not data creation. The install deliberately **disables** it for the
duration of bootstrap (`EnterpriseService.startNewEnterprise` → `setSecurityEnabled(false)`) so the
bulk securing queries are not filtered while the security graph is still being built.

Because the flag is `false` throughout install — *including inside the stateless transaction* —
gating default-security row creation on it would skip provisioning entirely and leave every installed
record with zero security. Default-security creation is therefore **unconditional**; the flag only
decides whether later reads are filtered. (If you need a true opt-out, add a separate
deployment-level flag rather than overloading the read-enforcement bypass.)

### Per-record grant matrix (7 rows)

| Token (`SECURITY_*`) | Resolver | C | U | D | R |
|---|---|:-:|:-:|:-:|:-:|
| `ADMINISTRATORS` | `getAdministratorsFolder` | ✅ | ✅ | ✅ | ✅ |
| `EVERYONE`       | `getEveryoneGroup`        | ❌ | ❌ | ❌ | ❌ |
| `EVERYWHERE`     | `getEverywhereGroup`      | ❌ | ❌ | ❌ | ✅ |
| `SYSTEMS`        | `getSystemsFolder`        | ✅ | ✅ | ❌ | ✅ |
| `APPLICATIONS`   | `getApplicationsFolder`   | ✅ | ✅ | ❌ | ✅ |
| `PLUGINS`        | `getPluginsFolder`        | ✅ | ✅ | ❌ | ✅ |
| `GUESTS`         | `getGuestsFolder`         | ❌ | ❌ | ❌ | ✅ |

### Install flow

```java
// SecurityTokenSystem (simplified) — creation is unconditional (NOT flag-gated)
private Uni<Void> createDefaultSecurityForTableReactive(Mutiny.Session session,
        WarehouseCoreTable<?,?,?,?> table, ISystems<?,?> system, UUID... token) {

    return resolveDefaultSecurityContext(session, system, token)  // 7 tokens + ent + activeFlag (cached once)
        .chain(ctx -> table.builder(session).inDateRange().getAll()
            .chain(items -> {
                // idempotency gate: cheap countDefaultSecurity per row, keep only rows with 0
                // then batch-insert the rest on ONE stateless transaction:
                return sessionFactory.withStatelessTransaction(stateless -> {
                    Uni<Long> chain = Uni.createFrom().item(0L);
                    for (var item : pending) {
                        chain = chain.chain(t -> item.createDefaultSecurity(
                                stateless, system, ctx.enterprise(), ctx.activeFlag(), ctx.tokens(), token)
                            .map(t::sum));
                    }
                    return chain;
                }).replaceWithVoid();
            }));
}
```

Enable JDBC batching in `persistence.xml`:

```xml
<property name="hibernate.jdbc.batch_size" value="50"/>
<property name="hibernate.jdbc.batch_versioned_data" value="true"/>
<property name="hibernate.order_inserts" value="true"/>
<property name="hibernate.order_updates" value="true"/>
```

### Canonical user-group / folder hierarchy

`createGroupsAndFolders(...)` links parent→child edges in `security.securitytokenxsecuritytoken`;
membership is walked child→parent by `getApplicableSecurityTokenIds(...)`:

```
(enterprise root)
  ├── Everyone
  │     ├── Administrators
  │     └── Guests
  │           ├── Registered Guests
  │           └── Visitors Guests
  └── Everywhere
```

> **Single-session rule:** never run `createDefaultSecurity` concurrently on one session. Records must
> be committed before being secured on a *separate* stateless transaction (FK visibility) — the
> install loads committed rows, then secures them on a fresh stateless transaction.

### Existing-database clients — the security implementation update path

A client that already has a **populated database** (data created before the security implementation, or
an enterprise being upgraded) adopts security by **re-running the same `SecurityTokenSystem.createDefaults`
provisioning** — it is the upgrade/migration path, not just a fresh-install step, because every step is
**idempotent**:

- **Canonical classifications + token hierarchy** (`createSecurityClassifications`, `createSecurityTokens`,
  `createGroupsAndFolders`) — `classificationService.create(...)` / `securityTokenService.create(...)` are
  **name + concept + enterprise scoped**, so re-running is a no-op when the row already exists and only
  fills in anything missing/repaired.
- **Per-record default security** (`applyDefaultsToNewEnterprise[AfterActivityMaster]` →
  `createDefaultSecurityForTableReactive`) loads every existing row and runs a cheap per-row
  **`countDefaultSecurity` gate**: rows that already carry default security are **skipped**, and only rows
  with **zero** security rows (the pre-existing/unsecured data) are secured — in one stateless batch per
  table. So re-running secures legacy rows exactly once, without duplicating grants.

**Order on an existing database (and why):** the **security hierarchy comes first**, then the
implementation:

1. **Security hierarchy** — `createGroupsAndFolders(...)` (idempotently) establishes/repairs the canonical
   `Everyone → Administrators/Guests/… + Everywhere` token tree, plus the `Systems`/`Applications`/`Plugins`
   folders.
2. **Security implementation** — the per-record default-security fan-out then runs; it **resolves the 7
   canonical group/folder tokens from that hierarchy**, so the hierarchy must exist before the fan-out can
   stamp grants.

> **Baseline before hierarchy-driven scoping.** This baseline security implementation must be in place
> **before** adopting the **hierarchy-driven security update** (geography-mirrored scope tokens, the
> scope-restricted matrix, and the flag-driven secure-by-default live creates — see the security skill /
> `security-hierarchy` design). You cannot scope-restrict records that have no baseline security, and the
> secure-by-default flag assumes the install/upgrade has completed. So for an existing client the sequence
> is: **(re)provision the canonical hierarchy + default security on all existing rows → then** layer on the
> scope tokens / scope-restricted opt-ins. Enable JDBC batching (above) for throughput on large datasets.

---

## Complete Lifecycle Flow

### Full Enterprise Creation Flow

```java
@Path("/enterprises")
@Singleton
public class EnterpriseResource {
    @Inject
    EnterpriseLifecycleManager lifecycleManager;

    @POST
    @Path("/complete-setup")
    public Uni<Enterprise> completeEnterpriseSetup(EnterpriseCreationRequest request, @Context SecurityToken token) {
        return lifecycleManager.createNewEnterprise(request)
            .invoke(created -> log.info("Phase 1: Enterprise created"))
            .chain(created -> lifecycleManager.loadUpdates(created, token)
                .invoke(() -> log.info("Phase 2: Updates loaded"))
                .replaceWith(created))
            .chain(created -> lifecycleManager.startNewEnterprise(created, token)
                .invoke(started -> log.info("Phase 3: Enterprise started")));
    }
}
```

### With Error Handling

```java
public Uni<Enterprise> completeEnterpriseSetupWithErrorHandling(
        EnterpriseCreationRequest request,
        SecurityToken token) {

    return lifecycleManager.createNewEnterprise(request)
        .invoke(created -> log.info("Created enterprise: {}", created.getId()))
        .onFailure().invoke(ex -> log.error("Failed to create enterprise", ex))
        .onFailure().recoverWithUni(ex -> {
            // Handle creation failure
            return Uni.createFrom().failure(new EnterpriseCreationException("Creation failed", ex));
        })
        .chain(created -> lifecycleManager.loadUpdates(created, token)
            .invoke(() -> log.info("Loaded updates for: {}", created.getId()))
            .onFailure().invoke(ex -> log.error("Failed to load updates", ex))
            .onFailure().recoverWithUni(ex -> {
                // Rollback: mark enterprise as failed
                created.setActiveFlag(ActiveFlag.Deleted);
                return enterpriseService.updateEnterprise(created, token)
                    .chain(() -> Uni.createFrom().failure(
                        new EnterpriseUpdateException("Update failed", ex)));
            })
            .replaceWith(created))
        .chain(created -> lifecycleManager.startNewEnterprise(created, token)
            .invoke(started -> log.info("Started enterprise: {}", started.getId()))
            .onFailure().invoke(ex -> log.error("Failed to start enterprise", ex)));
}
```

---

## ActiveFlag Lifecycle

### ActiveFlag States

```java
public enum ActiveFlag {
    Unknown,    // Initial state before startup
    Deleted,    // Soft deleted
    Active,     // Fully operational
    Permanent   // Cannot be deleted
}
```

### State Transitions

```
Unknown → Active    (via startNewEnterprise)
Active → Deleted    (via soft delete)
Active → Permanent  (via admin action)
Any → Deleted       (via force delete)
```

### State Transition Implementation

```java
@Singleton
public class EnterpriseStateManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> transitionToActive(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() != ActiveFlag.Unknown) {
            return Uni.createFrom().failure(
                new IllegalStateException("Can only activate Unknown enterprises"));
        }

        enterprise.setActiveFlag(ActiveFlag.Active);
        return enterpriseService.updateEnterprise(enterprise, token);
    }

    public Uni<Enterprise> transitionToDeleted(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() == ActiveFlag.Permanent) {
            return Uni.createFrom().failure(
                new IllegalStateException("Cannot delete Permanent enterprises"));
        }

        enterprise.setActiveFlag(ActiveFlag.Deleted);
        return enterpriseService.updateEnterprise(enterprise, token);
    }

    public Uni<Enterprise> transitionToPermanent(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() != ActiveFlag.Active) {
            return Uni.createFrom().failure(
                new IllegalStateException("Can only make Active enterprises Permanent"));
        }

        enterprise.setActiveFlag(ActiveFlag.Permanent);
        return enterpriseService.updateEnterprise(enterprise, token);
    }
}
```

---

## Update Tracking

### Completion is a classification on the Enterprise — not an audit table

There is **no** `system_update_audit` table or `SystemUpdateAudit` entity. An update's completion is
recorded as a **relationship classification on the Enterprise itself**, under the
`EnterpriseClassifications.UpdateClass` name, whose *value* is the update's canonical class name.

```java
// EnterpriseService.performUpdate(...) — record completion ON SUCCESS
Uni<Void> performUpdate(Mutiny.StatelessSession session, ISystemUpdate o, IEnterprise<?,?> enterprise) {
    return systemsService.getActivityMaster(session, enterprise)
        .chain(system -> o.update(session, enterprise)                 // run the update
            .chain(ok -> enterprise.addClassification(session,
                    UpdateClass.toString(),                            // classification NAME
                    o.getClass().getCanonicalName(),                   // classification VALUE = the class
                    system)
                .replaceWithVoid()));
}

// EnterpriseService.getEnterpriseAppliedUpdates(...) — read the applied set
public Uni<Set<String>> getEnterpriseAppliedUpdates(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
    return systemsService.getActivityMaster(session, enterprise)
        .chain(system -> enterprise.findClassifications(session, UpdateClass.toString(), system)
            .map(rels -> {
                Set<String> set = new LinkedHashSet<>();
                for (var rel : rels) {
                    String v = rel.getValue();
                    // Guice-proxied classes are recorded/compared by their plain name
                    if (v.contains("$$EnhancerByGuice$$")) v = v.substring(0, v.indexOf("$$EnhancerByGuice$$"));
                    set.add(v);
                }
                return set;
            }));
}
```

Separately, after the whole sweep completes, `updateLastUpdateDate(...)` upserts
`EnterpriseClassifications.LastUpdateDate` = today (a coarse "last ran" marker, not per-update state).

### The `force` skip rule (exact)

`getUpdates(...)` decides applicability with a single condition per candidate:

```java
String name = stripGuiceEnhancer(clazz.getCanonicalName());
SortedUpdate du = clazz.getAnnotation(SortedUpdate.class);
if (!enterpriseAppliedUpdates.contains(name) || du.force()) {
    applicable.put(sortOrder, clazz);   // include this update in the run
}
```

| `force()` | In the applied-classification set? | Runs this install? |
|---|:--:|:--:|
| `false` (default) | no  | ✅ once |
| `false` (default) | yes | ⛔ **skipped** (idempotent run-once) |
| `true` | no  | ✅ |
| `true` | yes | ✅ **re-runs every install** |

So `force = true` means **"always re-run, ignore the applied record"** — for updates that must
reconcile/repair state on every boot (they must be safe to re-execute; the underlying
`IClassificationService.create(...)` is name+concept+enterprise scoped and therefore idempotent).
`force = false` runs exactly once per enterprise: the first success writes the `UpdateClass`
classification, and every later install sees it and skips. `force` does **not** clear the record — it
just bypasses the skip (re-adding the same classification value is a harmless upsert).


---

## Best Practices

### 1. Idempotent Updates

An update runs once per enterprise (its class name is recorded under `UpdateClass`), but write update
bodies to be **safe to re-run** anyway — a `force = true` update re-runs every install, and a
previously-failed update is retried. Rely on the underlying idempotent creates
(`IClassificationService.create(...)` is name+concept+enterprise scoped) rather than a bespoke
"already applied" check:

```java
@Override
public Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
    // create(...) is a no-op if the classification already exists → safe to re-run
    return service.create(session, MyClassifications.Root, system).map(r -> true);
}
```

### 2. Operate on the passed session — never open a new transaction

The update is handed a live `session` inside the install transaction. Do **not** call
`sessionFactory.withTransaction(...)` or nest `SessionUtils.withActivityMaster(...)` — a new
transaction cannot see the caller's uncommitted writes. Chain everything on the supplied session:

```java
@Override
public Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?,?> enterprise) {
    return performTaxonomy(session, enterprise).map(r -> true);   // same session/tx
}
```

### 3. Update dependencies — lower `sortOrder` runs first

```java
@SortedUpdate(sortOrder = -500, taskCount = 3)   // core taxonomy — runs first
public class ClassificationBaseSetup implements ISystemUpdate { }

@SortedUpdate(sortOrder = 1000, taskCount = 12)  // depends on the base taxonomy — runs later
public class GeographySystemInstall implements ISystemUpdate { }
```

Pick a `sortOrder` after every taxonomy your update consumes, and keep it **unique** (a duplicate
`sortOrder` silently overrides the other class in the `TreeMap`).

### 4. Re-runnable repairs use `force = true`

If an update must reconcile state on every boot (not just once), set `force = true` so the
applied-updates skip is bypassed. Ensure the body is fully idempotent.

### 5. Progress reporting

Declare an honest `taskCount`, reset with `setCurrentTask(0)` if needed, and advance per unit of work
with `logProgress(source, message, delta)`; use the message-only overload for milestones (see the
`IProgressable` section in the main skill).
