# activitymaster: Persistence

Read this reference when working on the topics below. Commands run from the skill directory.

- [Quick Start](#quick-start)
- [ActiveFlag Lifecycle](#activeflag-lifecycle)
- [JSON Resource Items (MongoDB Document Store)](#json-resource-items-mongodb-document-store)
- [Reactive Patterns with Mutiny](#reactive-patterns-with-mutiny)
- [Database Configuration](#database-configuration)

## Quick Start

### 1. Set Up Environment

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Configure database and authentication:

```bash
DB_URL=postgresql://localhost:5432/activitymaster
DB_USER=postgres
DB_PASS=secretpassword
JWT_TEST_TOKEN=your-test-token
OAUTH2_ISSUER_URL=https://auth.example.com
JWKS_URI=https://auth.example.com/.well-known/jwks.json
```

### 2. Build and Test

```bash
mvn -B clean verify
```

### 3. Use Client Services

```java
@Inject
private IActivityMasterService activityMaster;

@Inject
private IEnterpriseService enterpriseService;

public Uni<Void> createEnterprise() {
    // Create new enterprise with fluent builder
    Enterprise enterprise = new Enterprise()
        .setName("ACME Corporation")
        .setDescription("Leading widget manufacturer")
        .setActiveFlag(ActiveFlag.Active);

    // Persist reactively
    return enterpriseService.createEnterprise(enterprise)
        .invoke(created -> log.info("Created: {}", created.getId()))
        .replaceWithVoid();
}
```

## ActiveFlag Lifecycle

All entities support `ActiveFlag` row-state management:

```java
public enum ActiveFlag {
    Unknown,    // Initial/undefined state
    Deleted,    // Soft-deleted
    Active,     // Active/visible
    Permanent   // Cannot be deleted
}
```

### ActiveFlag Enforcement

```java
// Query only active records
var qb = new Enterprise().builder(session);
qb.where(qb.getAttribute("activeFlag"), Operand.Equals, ActiveFlag.Active)
  .getAll();

// Soft delete
enterprise.setActiveFlag(ActiveFlag.Deleted);
enterpriseService.updateEnterprise(enterprise, token);

// Range queries
qb.where(qb.getAttribute("activeFlag"),
         Operand.InList,
         ActiveFlag.getActiveRange());  // Active to Permanent
```

## JSON Resource Items (MongoDB Document Store)

Resource items whose **type is a JSON type** (`JsonPacket`, any type name containing `json`, or any name
in `RESOURCE_ITEM_JSON_TYPES`) store their payload as a MongoDB **document** instead of the relational
`resource.resourceitemdatavalue` column — the relational SCD/security rows are still written (empty
payload) so visibility/security behave identically; only the bytes move. Implemented by
`com.guicedee.activitymaster.fsdm.ResourceItemJsonStore` (core, `@Singleton`).

The capability is **opt-in**: the store resolves a Vert.x `MongoClient` lazily and is **disabled** (all
reads/writes fall back to relational) unless one is bound — ActivityMaster ships `ActivityMasterMongoModule`,
gated by `MONGO_*` env vars. JSON items support named collections, id/name/criteria reads, partial field &
child updates (`$set`/`$unset`/`$push`/`$pull`), and a fluent `ResourceItem`/`IResourceItemService` document
API; everything no-ops when MongoDB is absent so the same code runs in both configurations.

### Dual representation: Mongo = current JSON, relational = versioned/timed history

Treat the two stores as complementary, not as a one-or-the-other swap:

- **MongoDB holds the *current* JSON representation** — the live, mutable document read back on load and
  updated in place (whole-document upsert, or partial `$set`/`$push`/`$pull` for hot paths).
- **The relational ActivityMaster ResourceItem (SCD rows) is the *versioned/timed history*** — keep writing
  it on every save (it carries the effective-from/to window, ActiveFlag and security matrix). It is the
  audit/history record **and** the read fallback when a Mongo document is absent (mid-migration, Mongo
  unavailable, or a Mongo-less deployment).

This makes the dual-write **permanent and intentional**: read Mongo-first, fall back to relational; never
drop the relational write just because Mongo now serves reads. A per-record marker (e.g. a classification on
the owning party) records that a record's live JSON lives in Mongo, so loaders know to source it there.

> **Partial updates require reference-free JSON.** The field/child operations (`$set`/`$unset`/`$push`/`$pull`)
> are only safe when the document does **not** rely on object-identity / shared-reference serialization
> (e.g. Jackson `@JsonIdentityInfo`, or any scheme where an entity is written in full once and as a bare
> id-reference elsewhere). With such references, *which* occurrence is the full copy depends on whole-document
> serialization order, so a fragment written in isolation can embed a duplicate full object or a dangling
> reference and corrupt the graph on the next full read. For object-identity documents, use **whole-document
> upserts only**; reserve partial updates for flat / reference-free payloads.

> **`SessionUtils.withActivityMaster` placement.** Resolve enterprise/system/token via
> `withActivityMaster(...)` only at **top-level entry points** (REST/event-bus/GUI). It opens its **own**
> session+transaction, so never nest it inside a flow that already owns a `Mutiny.Session` (e.g. an
> `ISystemUpdate.update`, or a service method handed a session) — the new session can't see the caller's
> uncommitted writes. Mid-flow code keeps operating on the supplied session; flag stray
> `getEnterprise`/`getISystem`/`getISystemToken` as conversion candidates for the nearest top-level caller.

**See [references/json-resource-items.md](../references/json-resource-items.md)** for the full API,
collection routing, MongoDB connection setup, environment variables, and the Testcontainers test module —
read it when working with JSON resource items / MongoDB document storage.

## Reactive Patterns with Mutiny

### Chain Operations

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        enterpriseService.createEnterprise(enterprise)
            .chain(created ->
                addressService.createAddress(address, created.getId())
            )
            .chain(address ->
                eventService.createEvent(event, address.getEnterpriseId())
            )
            .invoke(event -> log.info("Complete chain: {}", event.getId()))
    )
);
```

### Parallel Operations

```java
Uni<Enterprise> enterpriseUni = enterpriseService.getEnterprise(id, token);
Uni<List<Address>> addressesUni = addressService.listAddresses(id, token);
Uni<List<Event>> eventsUni = eventService.listEvents(id, token);

Uni.combine().all()
    .unis(enterpriseUni, addressesUni, eventsUni)
    .asTuple()
    .invoke(tuple -> {
        Enterprise enterprise = tuple.getItem1();
        List<Address> addresses = tuple.getItem2();
        List<Event> events = tuple.getItem3();
        // Process combined results
    });
```

### Error Handling

```java
enterpriseService.createEnterprise(enterprise)
    .onFailure().recoverWithUni(throwable -> {
        log.error("Failed to create enterprise", throwable);
        return Uni.createFrom().item(fallbackEnterprise);
    })
    .onFailure().retry().atMost(3);
```

## Database Configuration

### GuicedEE DatabaseModule

```java
@EntityManager(value = "activityMaster", defaultEm = true)
public class ActivityMasterDBModule
        extends DatabaseModule<ActivityMasterDBModule>
        implements IGuiceModule<ActivityMasterDBModule> {

    @Override
    protected String getPersistenceUnitName() {
        return "activityMaster";
    }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(
            PersistenceUnitDescriptor unit, Properties filteredProperties) {
        PostgresConnectionBaseInfo info = new PostgresConnectionBaseInfo();
        info.setServerName(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("DB_HOST", null));
        info.setPort(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("DB_PORT", null));
        info.setDatabaseName(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("DB_NAME", null));
        info.setUsername(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("DB_USER", null));
        info.setPassword(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("DB_PASS", null));
        info.setDefaultConnection(true);
        info.setReactive(true);
        return info;
    }

    @Override
    protected String getJndiMapping() {
        return "jdbc:activityMaster";
    }
}
```

### JPMS Module Registration

```java
module com.myapp.activitymaster {
    requires com.guicedee.activitymaster;
    requires com.guicedee.activitymaster.client;
    requires com.entityassist;
    requires com.guicedee.persistence;

    opens com.myapp.activitymaster.entities
        to org.hibernate.orm.core, com.google.guice, com.entityassist;

    provides IGuiceModule with ActivityMasterDBModule;
}
```

### Required JVM module flags (runtime / jlink)

ActivityMaster's FSDM core (`com.guicedee.activitymaster.fsdm`) and the reactive
Hibernate stack need a few extra JPMS edges opened at launch time that cannot be
expressed as static `requires`/`exports` (they bridge internal Hibernate packages and
cross-module reflective reads). Add these flags to the application launcher — and to
the `jlink` launcher options, the surefire `argLine`, the Dockerfile `ENTRYPOINT`, and
IDE run configurations:

```
--add-exports
org.hibernate.orm.core/org.hibernate.engine.internal=com.guicedee.activitymaster.fsdm
--add-reads
org.hibernate.orm.core=com.guicedee.activitymaster.fsdm
--add-reads
org.jboss.logging=org.hibernate.reactive
```

- `--add-exports org.hibernate.orm.core/org.hibernate.engine.internal=…fsdm` — exposes
  Hibernate's internal engine package to FSDM (entity state/persistence-context access).
- `--add-reads org.hibernate.orm.core=…fsdm` — lets Hibernate ORM reflectively read FSDM
  entity classes during metamodel bootstrap.
- `--add-reads org.jboss.logging=org.hibernate.reactive` — satisfies the JBoss Logging ↔
  Hibernate Reactive read edge used by the reactive provider's logging.

> The companion `--add-reads org.hibernate.orm.core=com.entityassist` edge is **owned by
> the EntityAssist skill** (it is required by any EntityAssist-backed app, not only
> ActivityMaster). Include it as well whenever EntityAssist entities are persisted. See
> the `entityassist` skill → *Required JVM module flags*.

Without these, boot fails with `IllegalAccessError` / `module … does not read …` /
`does not export …` errors from Hibernate ORM core or JBoss Logging.

#### Surefire / Failsafe configuration

Tests that boot the FSDM persistence context need the same module edges on the test
JVM. Add them to the `maven-surefire-plugin` (and `maven-failsafe-plugin`) `argLine`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <argLine>
            --add-reads org.jboss.logging=org.hibernate.reactive
            --add-reads org.hibernate.orm.core=com.guicedee.activitymaster.fsdm
        </argLine>
    </configuration>
</plugin>
```

> Add `--add-reads org.hibernate.orm.core=com.entityassist` to the same `argLine` when
> the tests persist EntityAssist entities, and the
> `--add-exports org.hibernate.orm.core/org.hibernate.engine.internal=com.guicedee.activitymaster.fsdm`
> flag if a test exercises code that touches Hibernate's internal engine package. If a
> parent/aggregate POM already sets `argLine` (e.g. for JaCoCo), append with
> `@{argLine}` so the coverage agent is preserved:
> `<argLine>@{argLine} --add-reads org.jboss.logging=org.hibernate.reactive …</argLine>`.

