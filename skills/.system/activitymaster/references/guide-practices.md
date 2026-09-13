# activitymaster: Practices

Read this reference when working on the topics below. Commands run from the skill directory.

- [Best Practices](#best-practices)
- [Documentation Structure](#documentation-structure)
- [Troubleshooting](#troubleshooting)

## Best Practices

### 0. Non-Blocking Rule

Never use `await().indefinitely()` in service flows or REST handlers. Always return `Uni` and continue work via `chain(...)`/`invoke(...)` composition. The ONLY exception is event bus consumers running on worker threads.

### 1. Security Token Propagation

For system-context work, resolve context through `SessionUtils.withActivityMaster(...)` first, then pass the provided token(s) into downstream access-controlled operations:

```java
// ✅ Good
SessionUtils.withActivityMaster("acme", "resource-sync", tuple ->
    resourceItemService.sync(tuple.getItem1(), tuple.getItem2(), tuple.getItem3(), tuple.getItem4()[0])
);

// ❌ Bad
resourceItemService.sync(session, enterprise, system, null);  // No security context
```

### 2. ActiveFlag Management

Use `ActiveFlag` for soft deletes:

```java
// ✅ Good - Soft delete
enterprise.setActiveFlag(ActiveFlag.Deleted);
enterpriseService.updateEnterprise(enterprise, token);

// ❌ Avoid hard deletes unless necessary
enterpriseService.deleteEnterprise(id, token);
```

### 3. Reactive Composition

Chain operations with `Uni`:

```java
// ✅ Good - Reactive chaining
enterpriseService.createEnterprise(enterprise)
    .chain(created -> addressService.createAddress(address, created.getId()))
    .replaceWithVoid();

// ❌ Bad - Blocking
enterpriseService.createEnterprise(enterprise)
    .subscribe().with(created -> {
        // Breaks chain composition and error propagation across async boundaries
        addressService.createAddress(address, created.getId()).subscribe().with(_ -> {
        });
    });
```

### 4. JPMS Module Declarations

Always open entity packages:

```java
// ✅ Required for Hibernate + Guice
opens com.myapp.entities to org.hibernate.orm.core, com.google.guice, com.entityassist;
```

### 5. Test Harness Alignment

Re-use existing test harness for coverage:

```java
// ✅ Good - Use JUnit 5 + Testcontainers
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class MyTest {
    // Use existing PostgreSQLTestDBModule
}
```

### 6. REST Create Pattern — Return DTO Immediately

Create endpoints should return a response built from the input DTO immediately. Relationship persistence happens asynchronously:

```java
// ✅ Good — immediate response, async relationship work
return service.create(entity).map(created -> {
    persistRelationshipsAsync(enterprise, system, created.getId(), dto);
    return buildResponseFromDto(created, dto);  // no DB round-trip
});

// ❌ Bad — waiting for all relationships before responding
return service.create(entity).chain(created ->
    persistAllRelationships(created, dto)  // blocks response
        .chain(() -> refetchFromDB(created.getId()))  // unnecessary round-trip
);
```

### 7. On-Demand Data Loading — Never at Startup

Bulk data (CSVs, external API imports, reference data) must never be loaded in `ISystemUpdate`:

```java
// ✅ Good — taxonomy structure only at startup
@SortedUpdate(sortOrder = 1000, taskCount = 1)
public class GeographySystemInstall implements ISystemUpdate {
    // Creates: Planet → Continent → Country hierarchy TYPES only
    // Does NOT load actual country data
}

// ✅ Good — bulk data triggered on demand
@POST @Path("{system}/install/countries")
public Uni<String> installCountries(...) { ... }

// ❌ Bad — loading CSV data at startup
@SortedUpdate(sortOrder = 1200, taskCount = 1)
public class GeographyInstallCountries implements ISystemUpdate {
    // DO NOT parse countryInfo.txt here
}
```

### 8. GraphQL — Use extend type Query

Feature modules should never redefine the root `Query` type. Always use `extend type Query`:

```graphql
# ✅ Good — extends the shared Query root
extend type Query {
    geographyCountry(enterprise: String!, system: String!, iso: String!): GeographyCountry
}

# ❌ Bad — redefines Query (conflicts with core)
type Query {
    geographyCountry(...): GeographyCountry
}
```

### 9. Classifications — Always Scope the Lookup by Data Concept

Classification names collide across concepts/rules/hierarchies. Use the concept-aware overloads so the
correct row is resolved instead of defaulting to `NoClassificationDataConceptName`:

```java
// ✅ Good — concept-scoped resolve/create/update of the link
party.addOrUpdateClassification(session, code, GeographyClassifications.Languages.concept(), value, system, token);
party.addOrReuseClassification(session, ISO639_2, SomeConcept.concept(), iso_2, system, token);

// ❌ Bad — name-only, collapses every concept into NoClassificationDataConceptName
party.addOrUpdateClassification(session, code, value, system, token);
```

> Note: disambiguation is by **data concept**. Parent/hierarchy-based disambiguation is not yet a
> `find(...)` axis — model distinct buckets as distinct concepts.

### 10. Filter with a JOIN in the WHERE clause — not `session.fetch()`

When you need to *restrict* a query by an associated row (e.g. only classifications in a given concept,
enterprise or active range), join and filter inside the builder's WHERE clause (`withConcept(...)`,
`withEnterprise(...)`, `inActiveRange()`, `inDateRange()`). Do **not** pull the association with
`session.fetch(...)` and filter in Java.

```java
// ✅ Good — the predicate is pushed into SQL via a join on the WHERE clause
new Classification().builder(session)
    .withName(code)
    .withConcept(Languages.concept(), system, token)   // JOIN + WHERE, scopes the row set
    .inActiveRange()
    .inDateRange()
    .withEnterprise(enterprise)
    .getCount()                                          // existence check without materialising rows
    .chain(count -> count > 0 ? findLanguage(...) : create(...));

// ❌ Bad — fetches the whole association, then filters on the heap
classificationService.find(session, name, system, token)
    .chain(c -> session.fetch(c.getConcepts()))         // loads everything
    .map(concepts -> concepts.stream().filter(...));    // filtering should have been SQL
```

Why it matters under Hibernate Reactive: `fetch` triggers an extra round-trip and materialises the
association; a join-on-WHERE keeps the filter in a single query, avoids loading unneeded rows, and sidesteps
lazy-initialisation hazards on the reactive session. Prefer `getCount()` over `get()` + null-check for
existence tests.

### 11. Libraries Operate on the Caller's Session — No Nested Transactions

Library/service methods must accept and use the caller's `Mutiny.Session` and transaction. Do **not** open a
nested unit of work (e.g. `SessionUtils.withActivityMaster(...)`) inside a method that was already handed a
session — nesting sessions on the same Vert.x context causes thread-affinity errors (`HR000069`) and
"Illegal pop()" failures, and breaks one-action-per-session.

```java
// ✅ Good — thread the caller's session/system/token straight through
public Uni<IClassification<?, ?>> createLanguage(Mutiny.Session session, String code, ..., ISystems<?, ?> system, UUID... token) {
    return new Classification().builder(session)
        .withName(code)
        .withConcept(Languages.concept(), system, token)
        ...;
}

// ❌ Bad — opening a nested session inside a library call already given one
public Uni<IClassification<?, ?>> createLanguage(Mutiny.Session session, ...) {
    return SessionUtils.withActivityMaster(enterpriseName, system.getName(), tuple -> {
        var nested = tuple.getItem1();   // second session on the same context
        ...
    });
}
```

`SessionUtils.withActivityMaster(...)` belongs at the **entry point** (REST handler, event consumer,
on-demand installer) that establishes the system context — never deep inside a reusable service.

### 12. On-Demand Loaders — Report Progress via IProgressable

Addon/feature-module loaders that import bulk data should `implements IProgressable` and report
progress so SPI monitors (console, WebSocket group, metrics) can observe it. Declare the **real**
total from the record count, advance by one per item, and emit milestones — never hard-code a total.

```java
// ✅ Good — real total + per-item delta + finishing milestone
setCurrentTask(0);
setTotalTasks(records.size());
chain = chain.chain(() -> create(r).invoke(x -> logProgress("My Loader", "Loaded " + r.getName(), 1)));
... .invoke(() -> logProgress("My Loader", "Finished"));   // milestone, no counter change

// ❌ Bad — magic total + advancing the counter on a milestone
setTotalTasks(47850);                                       // guessed, drifts out of sync
logProgress("My Loader", "Starting", 10);                   // milestones must not advance the counter
```

See the *Progress Reporting (IProgressable + SPI monitors)* section. This is the established pattern
for addon modules (the geography loaders use it, with tests).

## Documentation Structure

Activity Master follows strict documentation governance:

### Documentation-as-Code Policy

1. **Stage 1** — Architecture diagrams (C4 context/container/component, sequences, ERD)
2. **Stage 2** — Skills, glossary, and domain documentation
3. **Stage 3** — Implementation code
4. **Stage 4** — Testing and validation

**Forward-Only Rule:** Stage 1/2 documents must be updated before Stage 3/4 code changes.

### Key Documents

- **GLOSSARY.md** — Topic-first terminology
- **docs/architecture/** — C4/sequence/ERD diagrams (Mermaid)
- **docs/PROMPT_REFERENCE.md** — Selected stacks and toolchain

### Skills Repository

The skills submodule is the canonical source for enterprise skills and domain knowledge. Host-specific docs live at repo root and link back to the submodule.

**Important:** Treat the skills submodule as read-only; do not modify its contents.

## Troubleshooting

### Database Connection Issues

Check `.env` variables:
```bash
echo $DB_URL
echo $DB_USER
```

Verify PostgreSQL is running:
```bash
psql -h localhost -U postgres -d activitymaster
```

### Token Validation Failures

Verify OAuth2 configuration:
```bash
echo $OAUTH2_ISSUER_URL
echo $JWKS_URI
```

Check token cache:
```java
String token = SYSTEM_TOKEN_CACHE.get();
log.info("System token: {}", token);
```

### Hibernate Reactive Issues

Enable debug logging:
```bash
export ENABLE_DEBUG_LOGS=true
```

Check session factory initialization:
```java
Mutiny.SessionFactory factory = IGuiceContext.get(
    Key.get(Mutiny.SessionFactory.class, Names.named("activityMaster")));
assertNotNull(factory);
```

**`LazyInitializationException` / extra round-trips when filtering associations** — you are using
`session.fetch(...)` and filtering in Java. Replace it with a join-on-WHERE filter on the query builder
(`withConcept(...)`, `withEnterprise(...)`, `inActiveRange()`, `inDateRange()`) so the predicate is pushed
into SQL, and use `getCount()` for existence checks. See Best Practice #10.

**`HR000069` (wrong thread) / "Illegal pop()"** — a nested session/transaction was opened inside a method
that was already given one. Remove the inner `SessionUtils.withActivityMaster(...)` and thread the caller's
session through. See Best Practice #11.

### GraphQL Schema Merge Failures

If GraphQL schema fails to compile at startup:
1. Check all `IGraphQLSchemaProvider` implementations parse independently
2. Ensure feature modules use `extend type Query` (not `type Query`)
3. Verify no duplicate type names across providers

