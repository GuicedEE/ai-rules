---
name: activitymaster
description: Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management. Provides canonical domain services (Enterprise, Address, Events, Arrangements, ResourceItem, Classification, InvolvedParty, Rules, Products) with reactive persistence via Hibernate Reactive 7, Vert.x 5, GuicedEE DI, and PostgreSQL. Features security token propagation, an ActivityMaster-native Vert.x auth bridge (User + roles from the DB on the call scope), IProgressable SPI progress reporting for on-demand loaders, ActiveFlag row-state enforcement, flag-driven scope-restricted (secure-by-default) row security, geography-mirrored scope tokens, client libraries, modular service APIs, JAX-RS REST endpoints, GraphQL schema federation, Vert.x event bus consumers, and on-demand data loading patterns. Use when working with Activity Master services, FSDM domain models, enterprise management, reactive persistence, authentication/auth context, security/scope tokens, progress reporting, REST/GraphQL APIs, event bus integration, or building applications with canonical warehouse schemas.
metadata:
  short-description: FSDM enterprise resource management platform
---

# ActivityMaster

Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management.

## Overview

ActivityMaster is a comprehensive enterprise platform built on:
- **FSDM Domain Services** — Enterprise, Address, Events, Arrangements, ResourceItem, InvolvedParty, Classification, Rules, Products
- **Reactive Persistence** — Hibernate Reactive 7 + PostgreSQL
- **Async Workflows** — Vert.x 5 event-driven architecture
- **GuicedEE DI** — Dependency injection with lifecycle hooks
- **JAX-RS REST** — Jakarta REST endpoints with fire-and-forget relationship persistence
- **GraphQL** — SDL-first schema federation via `IGraphQLSchemaProvider` SPI
- **Event Bus** — Vert.x event bus consumers for async operations via `@VertxEventDefinition`
- **Security** — Token propagation, ActiveFlag enforcement, and **flag-driven scope-restricted** (secure-by-default) row security with geography-mirrored scope tokens
- **Modular Design** — 20+ specialized modules

## Core Architecture

### FSDM Domain Services

See [references/fsdm-services.md](references/fsdm-services.md) for complete service reference.

#### Enterprise Service
Manages organizations, companies, and business entities:
- Enterprise creation and lifecycle
- Organization hierarchies
- Business relationships
- Security token assignment

#### Address Service
Geographic location management:
- Physical addresses with validation
- Address standardization
- Location hierarchies
- Geocoding integration

#### Events Service
Event and activity tracking:
- Event scheduling and management
- Recurring events
- Event participants
- Calendar integration

#### Arrangements Service
Resource arrangements and bookings:
- Resource allocation
- Time-based arrangements
- Conflict detection
- Booking workflows

#### ResourceItem Service
Physical and virtual resource management:
- Resource catalogs
- Resource tracking
- Availability management
- Resource hierarchies

#### InvolvedParty Service
Party/person management:
- Party lifecycle (create, find, search)
- Classification-based party search
- Relationship tracking (parties ↔ events, arrangements, resources)

#### Classification Service
Taxonomies and categorization:
- Classification trees
- Tag management
- Category hierarchies
- Type systems

> **Classification names are NOT unique** — the same name is frequently reused across different
> data concepts, rules and hierarchies (e.g. ISO codes shared by the Languages, Country and
> Currency concepts). Always resolve a classification with the **data-concept-scoped** lookup
> `IClassificationService.find(session, name, EnterpriseClassificationDataConcepts concept, system, token...)`.
> The name-only `find(session, name, system, token...)` collapses every concept into one bucket and
> will return the wrong row (or throw `NonUniqueResult`) when names collide.
>
> The `IManageClassifications` link helpers (`addOrUpdateClassification`, `addOrReuseClassification`,
> `updateClassification`, `addClassification`) all expose an overload that accepts an
> `EnterpriseClassificationDataConcepts concept`. **Pass the concept whenever you know it.** Omitting it
> only defaults to `NoClassificationDataConceptName` — never use the no-concept overload as a shortcut
> when the value can exist under multiple concepts.

#### Rules Service
Business rules and governance:
- Rule definitions
- Rule types and categorization
- Rule application to entities

#### Products Service
Product catalogs and definitions:
- Product lifecycle
- Product categorization
- Product relationships

## REST API Architecture

### URL Pattern

All REST services follow:
```
/{enterprise}/{domain}/{requestingSystemName}/{operation}
```

Examples:
- `POST /acme/event/billing-system/create`
- `POST /acme/arrangement/booking-system/find`
- `PUT /acme/party/crm-system/update`
- `GET /acme/geography/Geography System/country/ZA`

### Core REST Services

| Service | Base Path | Operations |
|---------|-----------|------------|
| `EventRestService` | `{enterprise}/event` | find, create, update |
| `ArrangementRestService` | `{enterprise}/arrangement` | find, create, update, pivot |
| `PartyRestService` | `{enterprise}/party` | find, create, update, search |
| `ResourceItemRestService` | `{enterprise}/resource-item` | find, create, update |
| `GeographyRestService` | `{enterprise}/geography` | find country, install data |
| `CerialMasterRestService` | `{enterprise}/cerial` | serial port operations |

### REST Request/Response DTOs

Each domain has a standard set of DTOs:

```java
// Find DTO (request)
public class EventFindDTO {
    public UUID eventId;
    public List<EventDataIncludes> includes;  // which relationships to hydrate
}

// Create DTO (request)
public class EventCreateDTO {
    public Map<String, String> types;           // type name → value
    public Map<String, String> classifications; // classification name → value
    public Map<String, String> parties;         // classification name → party UUID
    public Map<String, String> resources;       // classification name → resource UUID
    public Map<String, String> products;        // product name → value
    public Map<String, String> rules;           // rule name → value
    public Map<String, String> arrangements;    // classification name → arrangement UUID
    public Map<String, String> children;        // classification name → child UUID
}

// Update DTO (request)
public class EventUpdateDTO {
    public UUID eventId;
    public RelationshipUpdateEntry classifications;
    public RelationshipUpdateEntry types;
    public RelationshipUpdateEntry parties;
    // ... same pattern for all relationship categories
}

// RelationshipUpdateEntry — upsert + delete in one call
public class RelationshipUpdateEntry {
    public Map<String, String> addOrUpdate;  // name → value (upsert)
    public List<String> delete;              // names to expire
}

// Response DTO
public class EventDTO {
    public UUID eventId;
    public Map<String, String> types;
    public Map<String, String> classifications;
    public Map<String, String> parties;
    public Map<String, String> resources;
    public Map<String, String> products;
    public Map<String, String> rules;
    public Map<String, String> arrangements;
    public Map<String, String> children;
}
```

### DataIncludes Pattern

Each domain defines an enum of includable relationships:

```java
public enum EventDataIncludes {
    Types, Classifications, Parties, Resources, Products, Rules, Arrangements, Children
}

public enum ArrangementDataIncludes {
    Types, Classifications, Parties, Resources, Events, Rules, Products, RuleTypes, Arrangements
}

public enum PartyDataIncludes {
    Types, Classifications, Resources, Identifications, Addresses
}

public enum ResourceItemDataIncludes {
    Types, Classifications, Parties, Identifications
}
```

### Fire-and-Forget Pattern

REST create/update endpoints return immediately after creating the primary entity.
Relationship persistence runs asynchronously via `SessionUtils.fireAndForget(...)`:

```java
@POST
@Path("{requestingSystemName}/create")
public Uni<EventDTO> create(..., EventCreateDTO dto) {
    return SessionUtils.<ISystems<?, ?>>withActivityMaster(enterpriseName, systemName, tuple ->
            Uni.createFrom().item(tuple.getItem3())
    ).chain(system -> eventService.createEvent(null, primaryType, system)
            .map(event -> {
                UUID eventId = event.getId();
                // Fire-and-forget: relationships persist in parallel sessions
                if (hasAnyRelationship(dto)) {
                    persistCreateRelationshipsAsync(enterpriseName, systemName, eventId, dto);
                }
                // Return immediately from DTO — no DB round-trip
                return buildCreateResponseFromDto((Event) event, dto);
            })
    );
}

// Each relationship category gets its own session + transaction
private void persistCreateRelationshipsAsync(String enterprise, String system, UUID id, CreateDTO dto) {
    SessionUtils.fireAndForget(SessionUtils.withActivityMaster(enterprise, system, tuple -> {
        Mutiny.Session s = tuple.getItem1();
        ISystems<?, ?> sys = tuple.getItem3();
        UUID[] token = tuple.getItem4();
        return service.find(s, id).chain(entity -> {
            Uni<Void> chain = Uni.createFrom().voidItem();
            for (var entry : dto.classifications.entrySet()) {
                chain = chain.chain(() -> entity.addOrUpdateClassification(s, entry.getKey(), entry.getValue(), sys, token).replaceWithVoid());
            }
            return chain;
        });
    }), "entity " + id + " classifications");
}
```

### Pivot Query Pattern

For optimized multi-relationship reads, use native SQL with UNION ALL:

```java
@POST
@Path("{requestingSystemName}/pivot")
public Uni<ArrangementPivotResponse> findPivoted(..., ArrangementPivotRequest request) {
    // Builds a UNION ALL native query across relationship tables
    // Returns PivotEntry objects with EntityRef (id + name), value, timestamp
    // Single DB round-trip for multiple relationship types
}
```

## GraphQL Architecture

### Schema Federation via SPI

GraphQL schemas are composed from multiple modules using `IGraphQLSchemaProvider` SPI:

```java
public class FsdmGraphQLSchemaProvider implements IGraphQLSchemaProvider<FsdmGraphQLSchemaProvider> {
    @Override
    public TypeDefinitionRegistry getTypeDefinitions() {
        return new SchemaParser().parse(SDL);
    }

    @Override
    public RuntimeWiring.Builder configureWiring(RuntimeWiring.Builder builder) {
        return builder.type("Query", q -> q
                .dataFetcher("involvedParties", domain(session -> new InvolvedParty().builder(session)))
                .dataFetcher("arrangements", domain(session -> new Arrangement().builder(session)))
                // ... all 7 FSDM domains
        );
    }
}
```

### Core FSDM GraphQL Schema

```graphql
scalar JSON

enum FilterOperand {
    Equals, NotEquals, Like, NotLike, LessThan, LessThanEqualTo,
    GreaterThan, GreaterThanEqualTo, Null, NotNull, InList, NotInList
}

input FilterInput {
    path: String!
    operand: FilterOperand = Equals
    value: String
    values: [String!]
}

input QueryInput {
    enterprise: String!
    system: String!
    filters: [FilterInput!]
    orderBy: String
    descending: Boolean = false
    first: Int
    max: Int
    activeOnly: Boolean = true
    inDateRange: Boolean = true
}

type Query {
    involvedParties(query: QueryInput!): [JSON!]!
    arrangements(query: QueryInput!): [JSON!]!
    events(query: QueryInput!): [JSON!]!
    products(query: QueryInput!): [JSON!]!
    resourceItems(query: QueryInput!): [JSON!]!
    classifications(query: QueryInput!): [JSON!]!
    rules(query: QueryInput!): [JSON!]!
}
```

### Extending GraphQL from Feature Modules

Feature modules extend the schema using `extend type Query`:

```java
// Geography module contributes its own type + query
public class GeographyGraphQLSchemaProvider implements IGraphQLSchemaProvider<GeographyGraphQLSchemaProvider> {
    private static final String SDL = """
        type GeographyCountry {
            geographyId: String
            geonameId: String
            iso: String
            iso3: String
            countryName: String
            capital: String
            population: Int
            countryDialCode: String
            ...
        }
        
        extend type Query {
            geographyCountry(enterprise: String!, system: String!, iso: String!): GeographyCountry
        }
    """;

    @Override
    public RuntimeWiring.Builder configureWiring(RuntimeWiring.Builder builder) {
        return builder
                .type("Query", q -> q.dataFetcher("geographyCountry", countryFetcher()))
                .type("GeographyCountry", t -> t
                        .dataFetcher("geographyId", env -> ((GeographyCountry) env.getSource()).getGeographyId().toString())
                );
    }
}
```

### GraphQL Data Fetcher Pattern

All GraphQL data fetchers use `SessionUtils.withActivityMaster` and bridge `Uni` → `Future`:

```java
private DataFetcher<Future<List<Map<String, Object>>>> domain(Function<Mutiny.Session, QueryBuilderSCD> builderFn) {
    return env -> {
        Map<String, Object> input = env.getArgument("query");
        String enterprise = (String) input.get("enterprise");
        String system = (String) input.get("system");

        Uni<List<Map<String, Object>>> uni = SessionUtils.withActivityMaster(enterprise, system, tuple -> {
            WarehouseQuerySpec spec = toSpec(input).setEnterprise(tuple.getItem2());
            QueryBuilderSCD queryBuilder = builderFn.apply(tuple.getItem1()).applyQuerySpec(spec);
            return queryBuilder.getAll().map(rows -> serialize(rows));
        });

        return Future.fromCompletionStage(uni.subscribeAsCompletionStage());
    };
}
```

### GraphQL Registration

Register via ServiceLoader:
```
# META-INF/services/com.guicedee.vertx.graphql.services.IGraphQLSchemaProvider
com.guicedee.activitymaster.fsdm.graphql.FsdmGraphQLSchemaProvider
```

## Event Bus Architecture

### @VertxEventDefinition Pattern

Event bus consumers are registered via `@VertxEventDefinition` annotation:

```java
@Log4j2
public class GeographyEventConsumers {
    @Inject
    private IGeographyService<?> geographyService;

    @VertxEventDefinition(value = "geography.install.country",
            options = @VertxEventOptions(worker = true))
    public String installCountry(Message<String> message) {
        String countryCode = message.body();
        log.info("Event bus request: installing country {}", countryCode);

        SessionUtils.<String>withActivityMaster(applicationEnterpriseName, GeographySystemName, tuple -> {
            var session = tuple.getItem1();
            var system = tuple.getItem3();
            var token = tuple.getItem4();
            return geographyService.installCountry(session, system, countryCode, token)
                    .replaceWith("Country " + countryCode.toUpperCase() + " installed");
        }).await().indefinitely();

        return "Country " + countryCode.toUpperCase() + " installation complete";
    }
}
```

### Event Bus Consumer Guidelines

1. **Worker threads** — Use `@VertxEventOptions(worker = true)` for blocking/long-running operations
2. **Blocking allowed** — Event consumers run on worker threads, so `.await().indefinitely()` is safe
3. **Security context** — Use `SessionUtils.withActivityMaster(...)` for enterprise/system/token resolution
4. **Return value** — Return a status string for request/reply patterns
5. **Message body** — Keep bodies simple (String, JSON). The body is the routing key.

### Event Bus Addresses Convention

```
{module}.{action}.{target}
```

Examples:
- `geography.install.country` — body: ISO-3166 code
- `geography.install.languages` — body: enterprise name
- `geography.download.country` — body: ISO-3166 code

## Module Structure

### Core Modules

#### activity-master-core
Core FSDM implementation with domain entities and services:

```xml
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master</artifactId>
</dependency>
```

Features:
- FSDM entity models with EntityAssist integration
- Reactive service implementations
- Security token infrastructure
- ActiveFlag lifecycle management
- REST endpoints (Event, Arrangement, Party, ResourceItem)
- GraphQL schema (7 FSDM domains via `FsdmGraphQLSchemaProvider`)
- ISystemUpdate installers (ClassificationBaseSetup, EventsBaseSetup, ArrangementsBaseSetup, etc.)
- Test harness and fixtures

#### activity-master-client
Client library for consuming Activity Master services:

```xml
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master-client</artifactId>
</dependency>
```

Features:
- CRTP-style fluent builders and DTOs
- Token cache helpers
- Secure SecurityToken propagation
- Reactive integrations (Mutiny)
- JPMS-friendly ServiceLoader discovery
- REST DTO classes (EventDTO, ArrangementDTO, PartyDTO, ResourceItemDTO, etc.)
- `SessionUtils` — canonical enterprise/system/token resolution
- `RestClients` — REST client endpoint declarations

#### activity-master-bom
Bill of Materials for version management:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.activity-master</groupId>
      <artifactId>activity-master-bom</artifactId>
      <version>${activitymaster.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

### Feature Modules

See [references/feature-modules.md](references/feature-modules.md) for detailed coverage.

- **conversations** — Chat and messaging
- **documents** — Document management and versioning
- **files** — File storage and retrieval
- **forums** — Discussion forums and threads
- **geography** — On-demand GeoNames geographic data (countries, provinces, districts, towns, postal codes, timezones, languages) via REST/event bus/GraphQL
- **images** — Image storage and processing
- **mail** — Email integration and templates
- **notifications** — Notification delivery system
- **payments** — Payment processing and billing
- **profiles** — User profiles and preferences
- **realtor** — Real estate specific features
- **tasks** — Task management and tracking
- **todo** — Todo lists and reminders
- **user-sessions** — Session management
- **wallet** — Digital wallet and transactions

### Infrastructure Modules

#### cerial
Serialization framework for Activity Master:
- Custom serialization strategies
- JSON/XML converters
- Data transformation pipelines
- REST endpoints via `CerialMasterRestService`
- GraphQL schema via `CerialMasterGraphQLSchemaProvider`

#### cerial-client
Client library for cerial services:
- Serialization helpers
- DTO transformations
- Type converters

## Adding a New Module

### Step 1: Create Maven Module

```xml
<parent>
  <groupId>com.activity-master</groupId>
  <artifactId>activitymaster-parent</artifactId>
  <version>${project.version}</version>
</parent>

<artifactId>activity-master-{module-name}</artifactId>
```

### Step 2: Create module-info.java

```java
module com.guicedee.activitymaster.{modulename} {
    requires com.guicedee.activitymaster;
    requires com.guicedee.activitymaster.client;
    requires com.entityassist;
    requires com.guicedee.persistence;
    requires com.guicedee.vertx;
    requires io.smallrye.mutiny;
    requires jakarta.ws.rs;
    
    // Open entity packages for Hibernate + Guice
    opens com.guicedee.activitymaster.{modulename}.db.entities
        to org.hibernate.orm.core, com.google.guice, com.entityassist;
    
    // Exports
    exports com.guicedee.activitymaster.{modulename}.services;
    exports com.guicedee.activitymaster.{modulename}.rest;
    
    // SPI providers
    provides ISystemUpdate with {ModuleName}Install;
    provides IGraphQLSchemaProvider with {ModuleName}GraphQLSchemaProvider;
}
```

### Step 3: Create ISystemUpdate for Schema Setup

Only the lightweight taxonomy/type system is installed at startup. Never load bulk data at startup.

```java
@SortedUpdate(order = {appropriate_order})
public class {ModuleName}Install implements ISystemUpdate {
    @Override
    public Uni<Void> runUpdate(Mutiny.Session session, IEnterprise<?, ?> enterprise,
                               ISystems<?, ?> system, UUID... identityToken) {
        // Create classification hierarchies, type records, etc.
        // Do NOT load bulk data here
    }
}
```

### Step 4: Create REST Service

```java
@Path("{enterprise}/{module-name}")
@Produces(MediaType.APPLICATION_JSON)
@Log4j2
public class {ModuleName}RestService {
    @Inject
    private I{ModuleName}Service<?> service;

    @POST
    @Path("{requestingSystemName}/find")
    public Uni<{ModuleName}DTO> find(@PathParam("enterprise") String enterpriseName,
                                      @PathParam("requestingSystemName") String systemName,
                                      {ModuleName}FindDTO findDto) {
        return SessionUtils.<{ModuleName}DTO>withActivityMaster(enterpriseName, systemName, tuple -> {
            Mutiny.Session session = tuple.getItem1();
            // ... query logic
        });
    }

    @POST
    @Path("{requestingSystemName}/create")
    public Uni<{ModuleName}DTO> create(...) { ... }

    @PUT
    @Path("{requestingSystemName}/update")
    public Uni<{ModuleName}DTO> update(...) { ... }
}
```

### Step 5: Create GraphQL Schema Provider (Optional)

```java
public class {ModuleName}GraphQLSchemaProvider implements IGraphQLSchemaProvider<{ModuleName}GraphQLSchemaProvider> {
    private static final String SDL = """
        type {ModuleName}Type { ... }
        extend type Query {
            {moduleName}Query(enterprise: String!, system: String!, ...): {ModuleName}Type
        }
    """;

    @Override
    public TypeDefinitionRegistry getTypeDefinitions() {
        return new SchemaParser().parse(SDL);
    }

    @Override
    public RuntimeWiring.Builder configureWiring(RuntimeWiring.Builder builder) {
        return builder.type("Query", q -> q.dataFetcher("{moduleName}Query", fetcher()));
    }
}
```

Register in `META-INF/services/com.guicedee.vertx.graphql.services.IGraphQLSchemaProvider`.

### Step 6: Create Event Bus Consumers (Optional)

```java
@Log4j2
public class {ModuleName}EventConsumers {
    @Inject
    private I{ModuleName}Service<?> service;

    @VertxEventDefinition(value = "{module}.{action}",
            options = @VertxEventOptions(worker = true))
    public String handle{Action}(Message<String> message) {
        // ... process event
    }
}
```

### Step 7: Create Tests

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class {ModuleName}Test {
    @Inject private I{ModuleName}Service<?> service;
    private Mutiny.SessionFactory sessionFactory;

    @BeforeAll
    void setup() {
        IGuiceContext.instance();
        sessionFactory = IGuiceContext.get(Key.get(Mutiny.SessionFactory.class, Names.named("activityMaster")));
    }

    @Test void testCrud() { ... }
}
```

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

## Lifecycle & Bootstrap

### Enterprise Creation Flow

See [references/enterprise-lifecycle.md](references/enterprise-lifecycle.md) for detailed flow.

```
createNewEnterprise() → loadUpdates() → startNewEnterprise()
```

1. **createNewEnterprise()** — Initialize new enterprise with base data
2. **loadUpdates()** — Load classifications/types via `ISystemUpdate`/`@SortedUpdate`
3. **startNewEnterprise()** — Register admin user via `IPasswordsService`, execute post-startup

### ISystemUpdate Pattern

System updates use `@SortedUpdate` for ordered execution:

```java
@SortedUpdate(order = 100)
public class LoadClassifications implements ISystemUpdate {
    @Override
    public Uni<Void> runUpdate(Mutiny.Session session, IEnterprise<?, ?> enterprise,
                               ISystems<?, ?> system, UUID... identityToken) {
        // Load classification data — taxonomy and type systems only
    }
}
```

Register via `module-info.java`:

```java
provides ISystemUpdate with LoadClassifications;
```

### Current ISystemUpdate Implementations

| Module | Class | Order | Purpose |
|--------|-------|-------|---------|
| core | `ClassificationBaseSetup` | — | Base classification types |
| core | `EventsBaseSetup` | — | Event type classifications |
| core | `ArrangementsBaseSetup` | — | Arrangement type classifications |
| core | `AddressBaseSetup` | — | Address type classifications |
| core | `ResourceItemsBaseSetup` | — | Resource item types |
| core | `ProductsBaseSetup` | — | Product type classifications |
| core | `TimeServiceSetup` | — | Time-related classifications |
| core | `UnknownResourceItemTypeSetup` | — | Default unknown resource type |
| geography | `GeographySystemInstall` | 1000 | Geographic hierarchy taxonomy only |
| cerial | `CerialMasterInstall` | — | Serial port classifications |
| profiles | `ProfileMasterInstall` | — | Profile type classifications |
| mail | `MailMasterInstall` | — | Mail template classifications |
| user-sessions | `SessionMasterInstall` | — | Session type classifications |

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
    Uni<Void> loadLanguages(Mutiny.Session session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> installCountry(Mutiny.Session session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
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

These were discovered debugging the geography on-demand install (countries, languages, timezones). They apply to **any** FSDM loader/service that is handed a `Mutiny.Session` and creates + reads classifications in the same flow.

1. **Never nest `SessionUtils.withActivityMaster(...)` inside a flow that already owns a session/transaction.**
   `withActivityMaster` (and `withSessionTx`) **always opens a brand-new session and transaction**. A nested transaction cannot see the still-uncommitted rows written by the outer transaction, so a follow-up `find` fails with `NoResultException`. Service methods that receive a `Mutiny.Session` must operate **directly on that session**:
   ```java
   // ❌ BAD — opens a new tx that can't see the caller's uncommitted writes
   public Uni<...> createPlanet(Mutiny.Session session, ...) {
       return SessionUtils.withActivityMaster(enterprise, system.getName(), tuple -> {
           var s = tuple.getItem1(); // different session/tx!
           ...
       });
   }
   // ✅ GOOD — reuse the caller's session/tx
   public Uni<...> createPlanet(Mutiny.Session session, ISystems<?,?> system, UUID... token) {
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

8. **Default security for bulk loads must be batched + stateless — never per-row.** The per-row `IWarehouseCoreTable.createDefaultSecurity(Mutiny.Session, system, token)` re-resolves the seven canonical group/folder tokens (Administrators, Everyone, Everywhere, Systems, Applications, Plugins, Guests) **and** issues find+persist round-trips for *every* row (~21 sequential round-trips/row). On a bulk load (thousands of geography rows) that is catastrophic. It is intentionally a **no-op** on the live session; use the batched `ISecurityTokenService` entry points instead, which resolve the seven tokens **once** and write on a `Mutiny.StatelessSession` (no growing persistence context):
   - `applyDefaultSecurityToTable(session, prototypeTable, system, token)` — idempotent full-table pass (`getAll` + per-row count gate + one stateless batch). Good for bootstrap / re-installs.
   - `applyDefaultSecurityToRows(session, rows, system, token)` — **scan-free, gate-free**; secures an explicit set of just-created rows in one stateless transaction. Preferred for bulk imports.

   The geography loader uses a **per-session collector** to feed the scan-free variant: creators `record(session, geo)` the row they just persisted (synchronous, zero round-trips) instead of calling per-row security, and each load phase `flush(session, system, token)` secures the whole batch at the end (within the same session, before reads). Key the accumulator by `Mutiny.Session` so concurrent loads never interleave, and remove the entry on flush so nothing leaks across phases/enterprises. Grants applied: Administrators=CRUD, Everywhere=read, Systems/Applications/Plugins=create/update/read, Guests=read, Everyone=none.

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

    public Uni<Void> loadProvincesASCII1(Mutiny.Session session, ISystems<?,?> system, UUID... token) {
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
        info.setServerName(System.getenv("DB_HOST"));
        info.setPort(System.getenv("DB_PORT"));
        info.setDatabaseName(System.getenv("DB_NAME"));
        info.setUsername(System.getenv("DB_USER"));
        info.setPassword(System.getenv("DB_PASS"));
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

## Testing with Testcontainers

### PostgreSQL Test Module

```java
@EntityManager(value = "activityMasterTest", defaultEm = true)
public class PostgreSQLTestDBModule
        extends DatabaseModule<PostgreSQLTestDBModule>
        implements IGuiceModule<PostgreSQLTestDBModule> {

    private static final PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>(System.getenv("TEST_DB_CONTAINER_IMAGE"))
            .withDatabaseName("activitymaster_test")
            .withUsername("postgres")
            .withPassword("postgres");

    static { postgres.start(); }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(
            PersistenceUnitDescriptor unit, Properties filteredProperties) {
        PostgresConnectionBaseInfo info = new PostgresConnectionBaseInfo();
        info.setServerName(postgres.getHost());
        info.setPort(String.valueOf(postgres.getFirstMappedPort()));
        info.setDatabaseName(postgres.getDatabaseName());
        info.setUsername(postgres.getUsername());
        info.setPassword(postgres.getPassword());
        info.setReactive(true);
        return info;
    }
}
```

### Test Harness

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class ActivityMasterTest {

    @Inject
    private IEnterpriseService enterpriseService;

    private Mutiny.SessionFactory sessionFactory;

    @BeforeAll
    public void setup() {
        IGuiceContext.instance();
        sessionFactory = IGuiceContext.get(
            Key.get(Mutiny.SessionFactory.class, Names.named("activityMaster")));
    }

    @Test
    void testEnterpriseLifecycle() {
        Enterprise enterprise = new Enterprise()
            .setName("Test Corp")
            .setActiveFlag(ActiveFlag.Active);

        sessionFactory.withSession(session ->
            session.withTransaction(tx ->
                enterpriseService.createEnterprise(enterprise)
                    .chain(created ->
                        enterpriseService.getEnterprise(created.getId(), null)
                    )
                    .invoke(retrieved -> {
                        assertNotNull(retrieved);
                        assertEquals("Test Corp", retrieved.get().getName());
                    })
            )
        ).replaceWithVoid();
    }
}
```

## CRTP Fluent Builders

### Request Builders

```java
// Enterprise creation with fluent builder
EnterpriseCreateRequest request = new EnterpriseCreateRequest()
    .setName("ACME Corp")
    .setDescription("Widget manufacturer")
    .setActiveFlag(ActiveFlag.Active)
    .setSecurityToken(token);

enterpriseService.create(request)
    .replaceWithVoid();
```

### Query Builders

```java
// Type-safe query building
var qb = new Enterprise().builder(session);
Uni<List<Enterprise>> results = qb
    .where(qb.getAttribute("name"), Operand.Like, "ACME%")
    .where(qb.getAttribute("activeFlag"), Operand.Equals, ActiveFlag.Active)
    .orderBy(qb.getAttribute("name"), OrderByType.ASC)
    .setMaxResults(50)
    .getAll();
```

### WarehouseQuerySpec (GraphQL/REST shared)

For dynamic queries (GraphQL, pivot endpoints):

```java
WarehouseQuerySpec spec = new WarehouseQuerySpec();
spec.setOrderBy("name");
spec.setDescending(false);
spec.setActiveOnly(true);
spec.setInDateRange(true);
spec.setMax(50);
spec.addFilter(new WarehouseQueryFilter()
    .setPath("name")
    .setOperand(Operand.Like)
    .setValue("ACME%"));

QueryBuilderSCD queryBuilder = new InvolvedParty().builder(session).applyQuerySpec(spec);
queryBuilder.getAll();
```

## Configuration & Environment

### Environment Variables

See [references/configuration.md](references/configuration.md) for complete reference.

| Variable | Purpose | Required |
|---|---|---|
| `DB_URL` | PostgreSQL JDBC URL | Yes |
| `DB_USER` | Database username | Yes |
| `DB_PASS` | Database password | Yes |
| `DB_HOST` | Database hostname | Yes |
| `DB_PORT` | Database port | Yes |
| `DB_NAME` | Database name | Yes |
| `JWT_TEST_TOKEN` | Test JWT token | Test only |
| `OAUTH2_ISSUER_URL` | OAuth2 issuer URL | Yes |
| `JWKS_URI` | JWKS endpoint | Yes |
| `TEST_DB_CONTAINER_IMAGE` | Testcontainers image | Test only |
| `ENVIRONMENT` | Runtime environment | No |
| `TRACING_ENABLED` | Enable distributed tracing | No |
| `ENABLE_DEBUG_LOGS` | Enable debug logging | No |

### CI Secrets (GitHub Actions)

- `USERNAME` — GitHub username for publishing
- `USER_TOKEN` — GitHub token
- `SONA_USERNAME` — Sonatype username
- `SONA_PASSWORD` — Sonatype password
- `POSTGRES_APP_PASSWORD` — PostgreSQL application password
- `KEYCLOAK_ADMIN_PASSWORD` — Keycloak admin password

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
@SortedUpdate(order = 1000)
public class GeographySystemInstall implements ISystemUpdate {
    // Creates: Planet → Continent → Country hierarchy TYPES only
    // Does NOT load actual country data
}

// ✅ Good — bulk data triggered on demand
@POST @Path("{system}/install/countries")
public Uni<String> installCountries(...) { ... }

// ❌ Bad — loading CSV data at startup
@SortedUpdate(order = 1200)
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

## Installation

```xml
<!-- BOM for version management -->
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.activity-master</groupId>
      <artifactId>activity-master-bom</artifactId>
      <version>${activitymaster.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Core module -->
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master</artifactId>
</dependency>

<!-- Client module -->
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master-client</artifactId>
</dependency>
```

## References

- Module: `com.guicedee.activitymaster`
- Hibernate Reactive: 7.x
- Vert.x: 5.x
- PostgreSQL: 15+
- GuicedEE: Latest
- Java: 25+
- License: Apache 2.0

**For detailed service documentation:** See [references/fsdm-services.md](references/fsdm-services.md)
**For module details:** See [references/feature-modules.md](references/feature-modules.md)
**For configuration:** See [references/configuration.md](references/configuration.md)
**For enterprise lifecycle:** See [references/enterprise-lifecycle.md](references/enterprise-lifecycle.md)
