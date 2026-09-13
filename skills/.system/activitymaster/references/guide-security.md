# activitymaster: Security

Read this reference when working on the topics below. Commands run from the skill directory.

- [Security & Token Propagation](#security--token-propagation)

## Security & Token Propagation

### SecurityToken Metadata

All services propagate `SecurityToken` for access control:

```java
public interface IEnterpriseService {
    Uni<Enterprise> createEnterprise(Enterprise enterprise);
    Uni<Enterprise> updateEnterprise(Enterprise enterprise, SecurityToken token);
    Uni<Optional<Enterprise>> getEnterprise(String id, SecurityToken token);
    Uni<List<Enterprise>> listEnterprises(SecurityToken token);
}
```

### SessionUtils System Context (Preferred)

When code must resolve enterprise + system + system token(s), use `SessionUtils.withActivityMaster(...)`. This is the canonical mechanism for system-context operations.

```java
import com.guicedee.activitymaster.fsdm.client.services.SessionUtils;

SessionUtils.withActivityMaster("acme", "classification-loader", tuple -> {
    Mutiny.Session session = tuple.getItem1();
    IEnterprise<?, ?> enterprise = tuple.getItem2();
    ISystems<?, ?> system = tuple.getItem3();
    UUID[] tokens = tuple.getItem4();

    return classificationService.ensureDefaults(session, enterprise, system, tokens[0]);
});
```

Do not hand-roll enterprise/system/token resolution when this helper applies.

### SessionUtils.fireAndForget

For async relationship persistence that should not block the caller:

```java
SessionUtils.fireAndForget(
    SessionUtils.withActivityMaster(enterprise, system, tuple -> {
        // ... async work
    }),
    "label for logging"  // used in error logs if the async work fails
);
```

### Default Security Creation (Batch + Stateless)

Every warehouse record carries a fan-out of **default security rows** — one per canonical
group/folder token. At install/scale this is an *exhaustive* number of inserts, so creation runs as
**batched inserts on a `Mutiny.StatelessSession`** (no first-level cache, no dirty-checking, so the
persistence context never grows and the inserts can be JDBC-batched).

There are **two distinct creation paths**, and only one of them follows the security flag:

| Path | Method | Gated by `isSecurityEnabled()`? | Matrix written |
|---|---|---|---|
| **Stateless batch** (installer / bulk loaders) | `createDefaultSecurity(Mutiny.StatelessSession, system, enterprise, activeFlag, tokens, …)` | ❌ **Never gated** — always public | The world-readable 7-grant default matrix |
| **Live single-create** (single-entity creates) | `createDefaultSecurity(Mutiny.Session, system, identity…)` | ✅ **Follows the flag** (see below) | Flag-dependent (scope-restricted vs. public) |

#### The stateless batch path is unconditional (never gated)

`ActivityMasterConfiguration.isSecurityEnabled()` is **call-scoped** (stored in `CallScopeProperties`
under key `fsdm.securities`) and **secure-by-default** (returns `true` when no scope/property is
present). The enterprise install deliberately **disables** it during bootstrap
(`EnterpriseService.startNewEnterprise` → `setSecurityEnabled(false)`) so that the bulk securing
queries are not filtered while the security graph is still being built.

The **stateless batch** path provisions *data* and must therefore **never** be gated on the flag —
doing so would skip provisioning during install (the flag is `false` there) and leave installed
reference rows with zero security:

```java
// ✅ Correct — the stateless batch path always writes the public matrix; the flag never gates it
record.createDefaultSecurity(stateless, system, ent, activeFlag, tokens);   // runs at install regardless

// ✅ The flag filters READS (enforcement), independently of creation
if (ActivityMasterConfiguration.get().isSecurityEnabled()) {
    queryBuilder.applySecurity(applicableTokenIds);
}
```

> If you need a true "never provision security" switch (e.g. an enterprise that opts out entirely),
> introduce a **separate, persistent/deployment-level** flag — do not overload the call-scoped
> read-enforcement bypass.

#### The live single-create path IS flag-driven (secure-by-default post-install)

The **live** `createDefaultSecurity(Mutiny.Session, ISystems, UUID…)` — called by single-entity
creates (rules, products, parties, events, resource items, etc.) — **now follows the flag** so the
runtime is **scope-restricted secure-by-default** the moment install finishes:

| `isSecurityEnabled()` | When | Matrix written |
|---|---|---|
| **`true`** (steady-state after enterprise install + admin/canonical-token creation) | normal runtime | **Scope-restricted**: Administrators=CRUD, Systems/Applications/Plugins=create/update/read, **no** Everyone/Everywhere/Guests (→ default-deny, not world-readable). Delegates to `createScopeRestrictedSecurity(session, system, null, identity)`. |
| **`false`** (explicitly cleared during enterprise install/bootstrap) | install only | The historical **world-readable** 7-grant matrix (incl. Everywhere/Guests=read), so reference data provisioned during install stays public. |

```java
// Live single-create path — the matrix is chosen at runtime by the flag:
@Override
public Uni<Void> createDefaultSecurity(Mutiny.Session session, ISystems<?,?> system, UUID... identity) {
    if (ActivityMasterConfiguration.get().isSecurityEnabled()) {
        // secure-by-default: scope-restricted, no world-readable grants
        return createScopeRestrictedSecurity(session, system, null, identity);
    }
    // install/bootstrap: historical world-readable 7-grant matrix
    return session.flush()
            .chain(() -> createDefaultAdministratorSecurityAccess(session, system, identity))
            // … Everyone / Everywhere / Systems / Applications / Plugins / Guests …
            .replaceWithVoid()
            // bootstrap-tolerant: skip (don't fail) when the canonical tokens or the owning FK aren't ready yet
            .onFailure().recoverWithUni(t -> isSecurityNotApplicableYet(t)
                    ? Uni.createFrom().voidItem() : Uni.createFrom().failure(t));
}
```

**Net effect:** during install (flag `false`) canonical/reference rows stay world-readable; once
install completes and the runtime returns to secure-by-default (flag `true`), **every subsequent live
create is automatically scope-restricted** — no per-call opt-in needed. To additionally pin a record
to a *specific* scope token, use the per-entity `createScopeRestricted(… scopeToken …)` opt-ins
(below).

#### Security-row counts (and what tests must assert)

The paths write a **different number of grant rows per record**, so any test (or idempotency gate)
that asserts `countDefaultSecurity(session)` must pick the count for the path/flag in effect:

| Path / flag state | Grants written | Rows/record |
|---|---|:--:|
| Stateless batch (install/bulk) — always public | Administrators, Everyone, Everywhere, Systems, Applications, Plugins, Guests | **7** |
| Live single-create, `isSecurityEnabled()` **false** (install/bootstrap) | same world-readable 7-grant matrix | **7** |
| Live single-create, `isSecurityEnabled()` **true** (steady-state secure-by-default, null scope) | Administrators + Systems/Applications/Plugins | **4** |
| Live scope-restricted with an explicit `scopeToken` | the 4 above **+** `scopeToken`=read | **5** |

> ⚠️ **Test gotcha (verified against the security suite).** A record created through a normal domain
> `create(...)` *after* install runs under the secure-by-default flag, so it carries the **restricted
> 4-row** matrix — not 7. Tests that hard-code a `SECURITY_ROWS_PER_RECORD = 7` constant for such
> records fail with `expected: <7> but was: <4>` (seen in `TestActivityMasterAdminLifecycle`). Assert
> **4** (or **5** with an explicit scope token) for live secure-by-default creates; reserve **7** for
> install/batch-path (public) reference rows (e.g. `TestActivityMasterSecurityAccess`, which disables
> the flag, correctly stays at 7). The same record's `canRead`/`canWrite` decisions remain the
> authoritative behavioural check: under the restricted matrix the admin/Systems identity still
> reads+writes while an **empty identity is denied** — exactly the intended secure-by-default outcome,
> so `assertFalse(anonRead)` only holds under the 4-row matrix.

#### The batch API (on `IWarehouseCoreTable`)

```java
// Low-level, stateless batch insert — pure inserts, returns rows written.
Uni<Long> createDefaultSecurity(Mutiny.StatelessSession session,
                                ISystems<?,?> system,
                                IEnterprise<?,?> enterprise,
                                IActiveFlag<?,?> activeFlag,
                                Map<String, ISecurityToken<?,?>> groupFolderTokens,
                                UUID... identityToken);

// Counts the default-security rows already linked to this record (idempotency gate).
Uni<Long> countDefaultSecurity(Mutiny.Session session);
```

The `groupFolderTokens` map is keyed by the `IWarehouseCoreTable.SECURITY_*` constants. Each record
produces **7 rows** with this grant matrix `{create, update, delete, read}`:

| Token key (`SECURITY_*`) | Resolver (`ISecurityTokenService`) | create | update | delete | read |
|---|---|:--:|:--:|:--:|:--:|
| `ADMINISTRATORS` | `getAdministratorsFolder` | ✅ | ✅ | ✅ | ✅ |
| `EVERYONE`       | `getEveryoneGroup`        | ❌ | ❌ | ❌ | ❌ |
| `EVERYWHERE`     | `getEverywhereGroup`      | ❌ | ❌ | ❌ | ✅ |
| `SYSTEMS`        | `getSystemsFolder`        | ✅ | ✅ | ❌ | ✅ |
| `APPLICATIONS`   | `getApplicationsFolder`   | ✅ | ✅ | ❌ | ✅ |
| `PLUGINS`        | `getPluginsFolder`        | ✅ | ✅ | ❌ | ✅ |
| `GUESTS`         | `getGuestsFolder`         | ❌ | ❌ | ❌ | ✅ |

#### Row-level access checks (`canRead` / `canWrite`)

`IWarehouseCoreTable` exposes reactive row-level checks that evaluate a caller's tokens against the
record's default-security rows:

```java
Uni<Boolean> canRead(Mutiny.Session session, ISystems<?,?> system, UUID... identityToken);
Uni<Boolean> canWrite(Mutiny.Session session, ISystems<?,?> system, UUID... identityToken);  // create OR update
```

They expand the supplied identity token(s) into the full applicable set via
`ISecurityTokenService.getApplicableSecurityTokenIds(...)` (the token **plus every group/folder it
belongs to, transitively** — a single `WITH RECURSIVE` query), then return `true` when the record has
an in-date-range security row whose token is in that set with `ReadAllowed` (for `canRead`) or
`CreateAllowed`/`UpdateAllowed` (for `canWrite`).

Because a **system's** identity token (`ISystemsService.getSecurityIdentityToken`) sits under the
`Systems` folder — which is granted create/update/read — a system can both read and write every
default-secured record:

```java
UUID systemToken = systemsService.getSecurityIdentityToken(session, system).await()...;
record.canRead(session, system, systemToken);   // true  — Systems folder grants read
record.canWrite(session, system, systemToken);  // true  — Systems folder grants create/update
```

#### Query-level read trimming (`readableIds` + `IQueryBuilderDefault.canRead`)

Because token expansion is reactive (`Uni`) but the fluent query builder is synchronous, list-query
trimming is a **two-step** operation:

1. **Resolve** the readable entity ids reactively:
   `IWarehouseCoreTable.readableIds(session, system, identityToken...)` returns the `Set<UUID>` of
   record ids the caller may read (it expands the identity tokens, then keeps records whose
   in-date-range security rows grant `ReadAllowed`).
2. **Apply** them synchronously on the builder before `getAll()`:
   `IQueryBuilderDefault.canRead(Collection<UUID> readableEntityIds)` adds the `id IN (...)` trim.

```java
record.readableIds(session, system, identityToken)
      .chain(readable -> new Classification().builder(session)
              .where("name", Operand.Like, "Acme%")
              .canRead(readable)          // security trim — excludes unreadable ids
              .getAll());
```

> The single-arg fluent `IQueryBuilderSecurity.canRead(ISystems, UUID...)` remains a guarded
> pass-through (it honours `isSecurityEnabled()`); the **authoritative** mechanisms are the reactive
> `IWarehouseCoreTable.canRead/canWrite` (row decision) and `readableIds` + `IQueryBuilderDefault.canRead`
> (query trim) pair above.

#### Recommended bulk pattern

Resolve the shared context (tokens + enterprise + active flag) **once** on a normal session, then
write all records' security in a single stateless transaction:

```java
// 1) Resolve once on a normal session (tokens identical for every record/table)
Map<String, ISecurityToken<?,?>> tokens = /* getAdministratorsFolder + ... + getGuestsFolder */;

// 2) Write everything on ONE stateless transaction (JDBC-batched)
sessionFactory.withStatelessTransaction(stateless -> {
    Uni<Long> chain = Uni.createFrom().item(0L);
    for (IWarehouseCoreTable<?,?,?,?> record : records) {
        chain = chain.chain(total -> record
                .createDefaultSecurity(stateless, system, enterprise, activeFlag, tokens)
                .map(total::sum));
    }
    return chain;
});
```

> Single-session rule still applies: never run `createDefaultSecurity` concurrently on the same
> session. Records must be **committed** before securing them on a *separate* stateless transaction
> (FK visibility) — resolve/commit first, then batch-secure.

#### Install wiring

`SecurityTokenSystem` applies this during enterprise install (`createDefaults` →
`applyDefaultsToNewEnterprise[AfterActivityMaster]` → `createDefaultSecurityForTableReactive`). It
resolves the 7 tokens once (cached per install), runs a cheap per-row `countDefaultSecurity` idempotency
gate (skip rows already secured), then batch-inserts the rest on a stateless transaction. Enable JDBC
batching in `persistence.xml` (`hibernate.jdbc.batch_size`, `hibernate.order_inserts`) for throughput.

> **Existing-database clients — the security implementation update path.** Because every step is
> idempotent (canonical classification/token `create` is name+concept+enterprise scoped; the per-row
> `countDefaultSecurity` gate secures only rows with **zero** security and skips already-secured rows),
> **re-running `createDefaults` is the upgrade/migration path** for a client that already has a populated
> database: it (re)builds/repairs the canonical **security hierarchy** first, then secures all pre-existing
> rows. Run this **baseline security implementation before adopting the hierarchy-driven security update**
> (geography-mirrored scope tokens, the scope-restricted matrix, flag-driven secure-by-default) — you
> cannot scope-restrict records that lack baseline security. Full detail:
> [references/enterprise-lifecycle.md](../references/enterprise-lifecycle.md) → *Existing-database clients — the security implementation update path*.

### Scope-Restricted Security (location/branch restriction)

Beyond the world-readable default matrix, records can opt into a **scope-restricted** matrix that is
**not** world-readable. It withholds the `Everyone`/`Everywhere`/`Guests` grants (so default-deny
applies) and instead grants **read** to a single **scope token**. Because the applicable-token climb
is **child → parent**, a record scoped to token `T` is readable **only by identity tokens located at
`T` or below it** (whose ancestors include `T`) — identities shallower than `T`, or in unrelated
branches, cannot read it. That *is* the restriction (there is no explicit DENY row — restriction is
the *absence* of a grant under additive/OR, default-deny semantics).

The scope-restricted matrix: **Administrators=CRUD**, **Systems/Applications/Plugins=create/update/read**,
**Everyone/Everywhere/Guests=omitted**, **scopeToken=read**.

#### Security primitives on `IWarehouseCoreTable`

```java
// Single arbitrary-token grant row with explicit flags (stateless batch).
Uni<Long> createSecurityGrant(Mutiny.StatelessSession session, ISystems<?,?> system,
                              IEnterprise<?,?> enterprise, IActiveFlag<?,?> activeFlag,
                              ISecurityToken<?,?> token,
                              boolean create, boolean update, boolean delete, boolean read,
                              UUID... identityToken);

// Scope-restricted fan-out (stateless batch) — pre-resolved group/folder tokens + a scope token.
Uni<Long> createScopeRestrictedSecurity(Mutiny.StatelessSession session, ISystems<?,?> system,
                                        IEnterprise<?,?> enterprise, IActiveFlag<?,?> activeFlag,
                                        Map<String, ISecurityToken<?,?>> groupFolderTokens,
                                        ISecurityToken<?,?> scopeToken, UUID... identityToken);

// Scope-restricted fan-out (LIVE session) — for a single just-created, still-uncommitted record
// (the stateless batch variant cannot see an uncommitted row). Find-or-create per grant, idempotent.
// A null scopeToken writes the Administrators + System/Application/Plugin hierarchy only.
Uni<Void> createScopeRestrictedSecurity(Mutiny.Session session, ISystems<?,?> system,
                                        ISecurityToken<?,?> scopeToken, UUID... identity);
```

#### Batch entry point on `ISecurityTokenService`

```java
// Multi-entity batch: resolve the group/folder tokens ONCE, then write the restricted matrix for
// every (record → scopeToken) pair in one stateless transaction. null scope entries are skipped.
Uni<Void> applyScopeRestrictedSecurity(Mutiny.Session session,
        Map<? extends IWarehouseCoreTable<?,?,?,?>, ? extends ISecurityToken<?,?>> recordScopes,
        ISystems<?,?> system, UUID... identityToken);

// World-readable batch counterparts (public reference data):
Uni<Void> applyDefaultSecurityToTable(Mutiny.Session session, IWarehouseCoreTable<?,?,?,?> table,
                                      ISystems<?,?> system, UUID... identityToken);  // full-table, idempotent
Uni<Void> applyDefaultSecurityToRows(Mutiny.Session session,
        Collection<? extends IWarehouseCoreTable<?,?,?,?>> rows,
        ISystems<?,?> system, UUID... identityToken);  // scan-free, for just-created rows
```

#### Per-entity opt-in `createScopeRestricted(...)` methods

Each domain service exposes a **scope-restricted** create alongside its public `create(...)` (the
public create is unchanged/world-readable). Internally each refactored its create body to accept a
security-strategy `Function` (public passes `createDefaultSecurity`, restricted passes
`createScopeRestrictedSecurity(scopeToken)`):

| Service | Restricted method | Secures |
|---|---|---|
| `IClassificationService` | `createScopeRestricted(session, name, desc, concept, system, seq, parent, scopeToken, identity…)` | the classification |
| `IInvolvedPartyService` | `createScopeRestricted(session, system, key, idTypes, isOrganic, scopeToken, identity…)` | party **+** its Organic/NonOrganic sub-record |
| `IEventService` | `createEventScopeRestricted(session, eventType, key, scopeToken, system, identity…)` | the event row |
| `IArrangementsService` | `createScopeRestricted(session, type, key, arrangementTypeClassification, arrangementTypeValue, system, scopeToken, identity…)` | the arrangement |
| `IAddressService` | `createScopeRestricted(session, addressClassification, key, system, scopeToken, identity…)` | the address |
| `IProductService` | `createProductScopeRestricted(...)` / `createProductTypeScopeRestricted(...)` | product / product type |
| `IRulesService` | `createRulesScopeRestricted(...)` / `createRulesTypeScopeRestricted(...)` | rules / rules type |
| `IResourceItemService` | `createScopeRestricted(...)` / `createTypeScopeRestricted(...)` | ResourceItemData **+** the type link / resource-item type |
| `IActiveFlagService` | `createScopeRestricted(session, enterprise, name, desc, system, scopeToken, identity…)` | **introduces** security stamping (public `create` stamps none) |

```java
// Opt-in: pin a classification to a scope token (visible only at that scope node or below)
classificationService.createScopeRestricted(session, "RestrictedClassification", "…",
        concept, system, seq, parent, scopeToken, identityToken);

// Multi-entity batch: map each just-created record to the scope token it must be readable under
Map<IWarehouseCoreTable<?,?,?,?>, ISecurityToken<?,?>> recordScopes = /* record → scope token */;
securityTokenService.applyScopeRestrictedSecurity(session, recordScopes, system, token);
```

> **ActiveFlag caveat:** ActiveFlags gate row visibility for *every* record that references them and
> are normally enterprise-global. Restricting a flag is unusual — intended only for tenant/branch-private
> flags. The mechanism is provided; whether to use it is a deployment decision.

> **Redundancy trap:** because the public default grants `Everywhere = read` and `Everywhere` is the
> root of the scope tree, simply *adding* a scope-token grant on top of the public matrix does **not**
> restrict anything (the identity already matches the universal `Everywhere` read). A record is only
> truly restricted when it carries **no `Everywhere = read`** grant **and** a scope-token read grant —
> i.e. the scope-restricted matrix. Public reference data (e.g. geography rows) stays public on purpose.


### Geography Scope Tokens (mirroring location into the token graph)

`Everywhere` is a *security* group; `Planet → Continent → Country → City` is a *geography data*
hierarchy — two different graphs. To make "restrict AppA to Earth" resolvable by the existing
recursive token climb, the coarse geography levels are **mirrored as scope tokens under `Everywhere`**
by `GeographyScopeTokenService` (geography module):

```
Everywhere                         (canonical UserGroup)
  └── GeoScope:<earthId>           (Planet)      ← linked under Everywhere
        └── GeoScope:<africaId>    (Continent)   ← linked under the planet scope
              └── GeoScope:<zaId>  (Country)     ← linked under the continent scope
```

- `ensureScope(session, geo, parentGeo, label, system, token)` find-or-creates a scope `SecurityToken`
  named **`GeoScope:<geographyId>`** (deterministic + idempotent, keyed by the geography **UUID** — so
  two same-named places never collide) using the generic `UserGroup` classification (so it nests under
  `Everywhere` within `enforceMembershipPolicy`), and links it under the parent geo's scope token (or
  `Everywhere` when `parentGeo == null`). `findScope(...)` / `scopeTokenName(geo)` are the helpers.
- Wired into `PlanetService`/`ContinentService`/`CountryService` after persist. **City/Province/Town/
  PostalCode scope tokens are deliberately deferred** (a token per city would mint thousands during a
  bulk load) — enable later behind a toggle with batched creation + security.
- Geography **reference rows stay public** (the 7-grant default matrix). Scope tokens shape the *token
  graph* (so identity tokens can be capped to a branch); restriction belongs on application/business
  records that opt into the scope-restricted matrix.

```java
// Restrict Application "AppA" to Earth (and below): link AppA's identity token under the Earth scope.
geographyService.findPlanet(session, "Earth", system, token)
    .chain(earth -> scopeTokenService.findScope(session, earth, system, token))
    .chain(earthScope -> securityTokenService.link(session, earthScope, appAToken, userGroupClass));
// AppA now expands AppA → GeoScope:<earthId> → Everywhere → root; default-deny restricts elsewhere.
```

### Moving & Looking Up Tokens

```java
// Move a child token from one parent group to another. Temporally CLOSES the oldParent→child edge
// (EffectiveToDate = now, so the WITH RECURSIVE climb stops traversing it) and links newParent→child.
// Other parent memberships are untouched (precise move). oldParent == null → exclusive reparent
// (closes ALL current in-range parent edges first). enforceMembershipPolicy is checked on the new
// parent BEFORE closing any edge (fails cleanly). Idempotent.
Uni<Void> moveToken(Mutiny.Session session, ISecurityToken<?,?> oldParent, ISecurityToken<?,?> newParent,
                    ISecurityToken<?,?> child, IClassification<?,?> classification, String... identifyingToken);

// Name-keyed token lookup (the existing getSecurityToken keys on the token varchar, not the name).
Uni<ISecurityToken<?,?>> getSecurityTokenByName(Mutiny.Session session, String name,
                                                ISystems<?,?> system, UUID... identityToken);
```

> A plain additive `link(...)` still exists for **multi-membership** (a group belonging to several
> parents at once). Use `moveToken` when the child should *leave* its old parent.

### Canonical User-Group / Folder Hierarchy

Install seeds the security taxonomy via `SecurityTokenSystem.createGroupsAndFolders(...)`, linking
parent→child edges in `security.securitytokenxsecuritytoken`. Membership is walked **child→parent** by
`ISecurityTokenService.getApplicableSecurityTokenIds(...)` (a single `WITH RECURSIVE` query):

```
(enterprise root)
  ├── Everyone
  │     ├── Administrators
  │     └── Guests
  │           ├── Registered Guests
  │           └── Visitors Guests
  └── Everywhere
```

Resolve each node via `ISecurityTokenService` getters (`getEveryoneGroup`, `getAdministratorsFolder`,
`getGuestsFolder`, `getRegisteredGuestsFolder`, `getVisitorsGuestsFolder`, `getEverywhereGroup`, plus
`getSystemsFolder`/`getApplicationsFolder`/`getPluginsFolder` for the system folders). Tokens carry a
PK (`getId()` = `SecurityTokenID`) and a varchar token (`getSecurityToken()`).

#### Membership policy (post-build lock-down)

Once the base hierarchy is built the **root and the default groups/folders become structurally
read-only** — only the **Administrators** group may restructure them. `ISecurityTokenService.link(...)`
enforces a **type-based membership policy** (`SecurityTokenService.enforceMembershipPolicy`), raising
`SecurityAccessException` on violations:

| Parent folder | May contain | Rule |
|---|---|---|
| **Systems** (`System`-named) | only `System`-typed tokens | groups/users cannot be added to it |
| **Applications** (`Applications`) | only `Application`-typed tokens | Applications are **always involved parties** |
| **Plugins** (`Plugins`) | only `Plugin`-typed tokens | — |
| generic group/folder (Everyone, Guests, …) | groups & users (`UserGroup`, `User`, `Guests`, `Visitors`, `Registered`, `Identity`) | **except** the type folders above |

Symmetrically, a `System`/`Application`/`Plugin`-typed token may only be parented under its matching
folder (or the enterprise **root** while the canonical tree is first built). The child's *type* is the
`IClassification` passed to `link(...)`; the parent folder is identified by its token name
(`System` / `Applications` / `Plugins`, or the enterprise name for root).

```java
// ✅ allowed — a generic group adds further groups/users
securityTokenService.link(session, everyoneGroup, newUserGroupToken, userGroupClass);
// ✅ allowed — a System-typed token under the Systems folder
securityTokenService.link(session, systemsFolder, newSystemToken, systemClass);
// ⛔ rejected (SecurityAccessException) — a group/user cannot go into the Systems folder
securityTokenService.link(session, systemsFolder, newUserGroupToken, userGroupClass);
// ⛔ rejected — Applications only accepts Application-typed (involved-party) tokens
securityTokenService.link(session, applicationsFolder, newUserGroupToken, userGroupClass);
```

The install itself satisfies the policy (every canonical link is type-correct), so it is unaffected;
the guard only blocks **post-build** attempts to mis-structure the canonical tree. See
`TestActivityMasterSecurityMembershipPolicy`.

### Identity & the User Security Token

Caller identity is carried by **Vert.x 5 auth** (`io.vertx.ext.auth.User`). The authenticated user's
identity claim *is* the **user security token**: a `SecurityToken` row (classification `Identity`) whose
`getSecurityToken()` varchar (a UUID string) is the `identityToken` you pass into the access APIs. On
login, `ActivityMasterAuthBridge` builds that Vert.x `User` from the DB and publishes it (plus the
identity token) onto the **call scope** for the rest of the call (see *ActivityMasterAuthBridge* below).
Two identity flavours exist:

| Identity | How it is resolved | Hierarchy parent | Effective grants |
|---|---|---|---|
| **System** | `ISystemsService.getSecurityIdentityToken(session, system)` → `UUID` | `Systems` folder | create/update/read |
| **User** (e.g. admin) | authenticate, then look up the user's `Identity` `SecurityToken` by name | the folder it was created under (admin → `Administrators`) | depends on folder (admin → CRUD) |

The admin/creator user is created by `IPasswordsService.createAdminAndCreatorUserForEnterprise(...)`,
which mints an `Identity` `SecurityToken` named after the username **as a child of the `Administrators`
folder**. Expanding that token therefore yields `Administrators → Everyone → root`, granting full CRUD.

#### Subject token vs. reader token — who may read the security structure

Two different tokens are in play during any access decision, and they must not be conflated:

| Role | Token | What it is for |
|---|---|---|
| **Subject** (the identity being *evaluated*) | the caller's identity token — a **requesting** system's `getSecurityIdentityToken`, or a user's `Identity` token | the principal whose grants are being checked (`canRead`/`canWrite`/`readableIds`) |
| **Reader** (the context that *enumerates* the security graph) | the **Activity Master system** identity token | the privileged context that walks `security.securitytoken*` to expand applicable tokens and compute the decision |

The **Activity Master system** (`ISystemsService.ActivityMasterSystemName` = `"Activity Master System"`,
resolved by `systemsService.getActivityMaster(...)`) is the canonical **platform/bootstrap** system. Its
identity token is the one threaded through install (`SystemsService` resolves
`getISystemToken(session, ActivityMasterSystemName, enterprise)`) and is the intended **reader** token for
inspecting the security structure itself. `SessionUtils.withActivityMaster(enterprise, "Activity Master System", …)`
hands you exactly this token at `tuple.getItem4()[0]`, which is why it is the natural entry point for
security-structure reads and administrative security flows.

#### Not every system gets this — requesting systems are subjects, not readers

`withActivityMaster(enterprise, **anySystemName**, …)` resolves **that named system's** own identity token,
not the Activity Master system's. A generic requesting system (e.g. `"billing-system"`) parented under the
`Systems` folder therefore receives **row-level grants on default-secured records** (create/update/read), but
that is *all* it gets — it is a **subject**, evaluated against the grant matrix:

- ✅ It can read/write records its `Systems`-folder grant covers (the grant matrix, not arbitrary enumeration).
- ⛔ It is **not** an Administrator, so it cannot **restructure** the security tree — `ISecurityTokenService.link(...)`
  enforces the type-based membership policy (`enforceMembershipPolicy`) and raises `SecurityAccessException`
  on any post-build attempt to mis-parent canonical tokens.
- ⛔ It should **not** be used to enumerate/read the raw security hierarchy. Reserve full security-structure
  reads for the **Activity Master system** token (the privileged reader) or an **Administrators** identity.

> Rule of thumb: pass the **caller's** system/user token as the *subject* into `canRead`/`canWrite`/`readableIds`,
> but perform the security-structure enumeration under the **Activity Master system** context. Do not grant
> arbitrary requesting systems the ability to read the whole security graph — they only ever see records via
> the default-security grant matrix.

#### Logging in as a user and acting as that identity

```java
IPasswordsService<?> passwords = IGuiceContext.get(IPasswordsService.class);

// 1) Authenticate (Vert.x auth User would normally supply this; here via username/password)
passwords.findByUsernameAndPassword(session, "admin", "!@adminadmin", system, true)
    // 2) Resolve the user's identity SecurityToken (created under Administrators)
    .chain(user -> new SecurityToken().builder(session)
            .withName("admin").inActiveRange().inDateRange().get())
    .map(tok -> UUID.fromString(((ISecurityToken<?,?>) tok).getSecurityToken()))
    // 3) Use that identity for row-level access — admin → Administrators → CRUD
    .chain(adminIdentity -> record.canRead(session, system, adminIdentity)
            .chain(r -> record.canWrite(session, system, adminIdentity)));
```

Tests should provision the enterprise (`startNewEnterprise(..., "admin", ...)` creates the admin
user) and then **run their access assertions as the logged-in admin identity** — see
`TestActivityMasterSecurityAdminLogin`.

> When wired into HTTP, the Vert.x `User` from the auth handler supplies the identity UUID directly;
> the username/password lookup above is the equivalent for headless/test flows.

#### ActivityMasterAuthBridge — establishing the Vert.x auth context from the DB

`ActivityMasterAuthBridge` (`…fsdm.auth`, core module) is the ActivityMaster-native bridge that turns a
successful authentication into a populated Vert.x `io.vertx.ext.auth.User` — **no MicroProfile JWT
dependency**. `PasswordsService.findByUsernameAndPassword(...)` calls it on success, so the moment a
user logs in the call has a full auth context built from **our** security model.

What it builds and publishes:

| Step | Source | Result |
|---|---|---|
| **subject / identity token** | `getSecurityTokenByName(username)` → the `Identity` `SecurityToken` UUID | `principal.sub` + `attributes.identityToken` |
| **display name** | party name relationships: Preferred → Full → First → username fallback | `principal.name` |
| **roles** | `getApplicableSecurityTokenIds(identity)` → friendly names of every token it expands to (own token + groups/folders, transitively) | `principal.roles` / `principal.groups` **and** Vert.x `RoleBasedAuthorization`s under provider id `activitymaster` |

The assembled `User` becomes the **current call's auth context**:

- published on `CallScopeProperties` under key `fsdm.vertxUser` — read it anywhere (internal calls
  **and** REST resources share the same call scope) via the static `ActivityMasterAuthBridge.currentUser()`;
- the identity token is mirrored onto the call-scoped `ActivityMasterConfiguration.setIdentityToken(UUID)`
  so **row-level security uses the logged-in identity** for the rest of the call;
- best-effort mirrored onto the request's `RoutingContext` (Vert.x 5 removed the public
  `UserContext.setUser`; the bridge reflects onto the internal `UserContextInternal.setUser` where the
  runtime permits — otherwise the call-scope user is authoritative).

```java
// admin → Identity token under Administrators → expands to {admin, Administrators, Everyone, …}
User user = ActivityMasterAuthBridge.currentUser();           // anywhere inside the same call
user.principal().getString("preferred_username");             // "admin"
user.principal().getString("name");                           // display name, e.g. "Enterprise Creator"
user.authorizations().verify(RoleBasedAuthorization.create("Administrators"));  // true
```

The bridge is **fail-soft**: any problem resolving details/roles is logged and the login still
succeeds (it just yields a thinner — or `null` — user) so authentication is never broken by the auth
context build. `SessionLoginService` (special user-session login) is intentionally **out of scope** —
it does not go through this bridge. See `TestActivityMasterAuthBridge`.

> Note: this supersedes the older "no bespoke call-scope identity mechanism" statement — the
> authenticated identity now lives on the **call scope** (Vert.x `User` + mirrored identity token),
> with `RoutingContext` mirroring as a best-effort convenience for HTTP.


