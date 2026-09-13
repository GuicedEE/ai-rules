# activitymaster: Domain and modules

Read this reference when working on the topics below. Commands run from the skill directory.

- [Core Architecture](#core-architecture)
- [Module Structure](#module-structure)
- [Adding a New Module](#adding-a-new-module)

## Core Architecture

### FSDM Domain Services

See [references/fsdm-services.md](../references/fsdm-services.md) for complete service reference.

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

See [references/feature-modules.md](../references/feature-modules.md) for detailed coverage.

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
`@SortedUpdate` takes `sortOrder` (ordering/dedup key) and `taskCount` (progress total contribution);
`ISystemUpdate.update(...)` returns `Uni<Boolean>` — resolve the ActivityMaster system yourself from
the passed `enterprise` (the method is **not** handed a `system`/`identityToken`). Implement the
**stateless** overload (see *ISystemUpdate & @SortedUpdate Mechanism* below).

```java
@SortedUpdate(sortOrder = {appropriate_order}, taskCount = {number_of_progress_tasks})
public class {ModuleName}Install implements ISystemUpdate {
    // Stateless-session overload (JDBC-batchable, no growing persistence context)
    @Override
    public Uni<Boolean> update(Mutiny.StatelessSession session, IEnterprise<?, ?> enterprise) {
        // Create classification hierarchies, type records, etc. — NO bulk data.
        // Advance progress with logProgress(source, message, delta); return true when done.
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

