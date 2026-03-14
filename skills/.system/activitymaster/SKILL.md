---
name: activitymaster
description: Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management. Provides canonical domain services (Enterprise, Address, Events, Arrangements, ResourceItem, Classification) with reactive persistence via Hibernate Reactive 7, Vert.x 5, GuicedEE DI, and PostgreSQL. Features security token propagation, ActiveFlag row-state enforcement, client libraries, and modular service APIs. Use when working with Activity Master services, FSDM domain models, enterprise management, reactive persistence, or building applications with canonical warehouse schemas.
metadata:
  short-description: FSDM enterprise resource management platform
---

# ActivityMaster

Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management.

## Overview

ActivityMaster is a comprehensive enterprise platform built on:
- **FSDM Domain Services** — Enterprise, Address, Events, Arrangements, ResourceItem, Classification
- **Reactive Persistence** — Hibernate Reactive 7 + PostgreSQL
- **Async Workflows** — Vert.x 5 event-driven architecture
- **GuicedEE DI** — Dependency injection with lifecycle hooks
- **Security** — Token propagation and ActiveFlag enforcement
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

#### Classification Service
Taxonomies and categorization:
- Classification trees
- Tag management
- Category hierarchies
- Type systems

## Module Structure

### Core Modules

#### activity-master-core
Core FSDM implementation with domain entities and services:

```xml
<dependency>
  <groupId>com.guicedee.activitymaster</groupId>
  <artifactId>activity-master</artifactId>
</dependency>
```

Features:
- FSDM entity models with EntityAssist integration
- Reactive service implementations
- Security token infrastructure
- ActiveFlag lifecycle management
- Test harness and fixtures

#### activity-master-client
Client library for consuming Activity Master services:

```xml
<dependency>
  <groupId>com.guicedee.activitymaster</groupId>
  <artifactId>activity-master-client</artifactId>
</dependency>
```

Features:
- CRTP-style fluent builders and DTOs
- Token cache helpers
- Secure SecurityToken propagation
- Reactive integrations (Mutiny)
- JPMS-friendly ServiceLoader discovery

#### activitymaster-bom
Bill of Materials for version management:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.guicedee.activitymaster</groupId>
      <artifactId>activitymaster-bom</artifactId>
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
- **geography** — Geographic data and mapping
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

#### cerial-client
Client library for cerial services:
- Serialization helpers
- DTO transformations
- Type converters

## Quick Start

### 1. Set Up Environment

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Configure database and authentication:

```bash
DB_URL=jdbc:postgresql://localhost:5432/activitymaster
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

public void createEnterprise() {
    // Create new enterprise with fluent builder
    Enterprise enterprise = new Enterprise()
        .setName("ACME Corporation")
        .setDescription("Leading widget manufacturer")
        .setActiveFlag(ActiveFlag.Active);

    // Persist reactively
    enterpriseService.createEnterprise(enterprise)
        .invoke(created -> log.info("Created: {}", created.getId()))
        .await().indefinitely();
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

### Token Cache

Built-in token caching for system operations:

```java
// System token cache helper
String systemToken = SYSTEM_TOKEN_CACHE.get();

// Use cached token for service calls
enterpriseService.getEnterprise(id, systemToken)
    .await().indefinitely();
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
    public void executeUpdate(Session session) {
        // Load classification data
    }
}
```

Register via `module-info.java`:

```java
provides ISystemUpdate with LoadClassifications;
```

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
        ).await().indefinitely();
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
    .await().indefinitely();
```

### Query Builders

```java
// Type-safe query building
var qb = new Enterprise().builder(session);
List<Enterprise> results = qb
    .where(qb.getAttribute("name"), Operand.Like, "ACME%")
    .where(qb.getAttribute("activeFlag"), Operand.Equals, ActiveFlag.Active)
    .orderBy(qb.getAttribute("name"), OrderByType.ASC)
    .setMaxResults(50)
    .getAll()
    .await().indefinitely();
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

## Documentation Structure

Activity Master follows strict documentation governance:

### Documentation-as-Code Policy

1. **Stage 1** — Architecture diagrams (C4 context/container/component, sequences, ERD)
2. **Stage 2** — Rules, guides, glossary artifacts
3. **Stage 3** — Implementation code
4. **Stage 4** — Testing and validation

**Forward-Only Rule:** Stage 1/2 documents must be updated before Stage 3/4 code changes.

### Key Documents

- **PACT.md** — Human–AI collaboration pact and stage approvals
- **RULES.md** — Project conventions and stack references
- **GUIDES.md** — How-to guidance and API mappings
- **GLOSSARY.md** — Topic-first terminology
- **IMPLEMENTATION.md** — Module layout and runtime expectations
- **docs/architecture/** — C4/sequence/ERD diagrams (Mermaid)
- **docs/PROMPT_REFERENCE.md** — Selected stacks and toolchain

### Rules Repository

The `rules/` submodule is the canonical source for enterprise RULES, GUIDES, and GLOSSARY artifacts. Host-specific docs live at repo root and link back to the submodule.

**Important:** Treat `rules/` as read-only; do not modify its contents.

## Service APIs

### IActivityMasterService

Main service interface aggregating all FSDM services:

```java
public interface IActivityMasterService {
    IEnterpriseService enterprises();
    IAddressService addresses();
    IEventsService events();
    IArrangementsService arrangements();
    IResourceItemService resources();
    IClassificationService classifications();
}
```

### IEnterpriseService

```java
public interface IEnterpriseService {
    Uni<Enterprise> createEnterprise(Enterprise enterprise);
    Uni<Enterprise> updateEnterprise(Enterprise enterprise, SecurityToken token);
    Uni<Void> deleteEnterprise(String id, SecurityToken token);
    Uni<Optional<Enterprise>> getEnterprise(String id, SecurityToken token);
    Uni<List<Enterprise>> listEnterprises(SecurityToken token);
    Uni<List<Enterprise>> searchEnterprises(String query, SecurityToken token);
}
```

### IAddressService

```java
public interface IAddressService {
    Uni<Address> createAddress(Address address, String enterpriseId);
    Uni<Address> updateAddress(Address address, SecurityToken token);
    Uni<Void> deleteAddress(String id, SecurityToken token);
    Uni<Optional<Address>> getAddress(String id, SecurityToken token);
    Uni<List<Address>> listAddresses(String enterpriseId, SecurityToken token);
    Uni<Address> validateAddress(Address address);
}
```

### IEventsService

```java
public interface IEventsService {
    Uni<Event> createEvent(Event event, String enterpriseId);
    Uni<Event> updateEvent(Event event, SecurityToken token);
    Uni<Void> cancelEvent(String id, SecurityToken token);
    Uni<Optional<Event>> getEvent(String id, SecurityToken token);
    Uni<List<Event>> listEvents(String enterpriseId, SecurityToken token);
    Uni<List<Event>> listEventsByDateRange(LocalDate start, LocalDate end, SecurityToken token);
}
```

## Best Practices

### 1. Security Token Propagation

Always pass `SecurityToken` for access-controlled operations:

```java
// ✅ Good
enterpriseService.getEnterprise(id, token);

// ❌ Bad
enterpriseService.getEnterprise(id, null);  // No security context
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
    .await().indefinitely();

// ❌ Bad - Blocking
Enterprise created = enterpriseService.createEnterprise(enterprise)
    .await().indefinitely();
Address address = addressService.createAddress(address, created.getId())
    .await().indefinitely();
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

## Installation

```xml
<!-- BOM for version management -->
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.guicedee.activitymaster</groupId>
      <artifactId>activitymaster-bom</artifactId>
      <version>${activitymaster.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Core module -->
<dependency>
  <groupId>com.guicedee.activitymaster</groupId>
  <artifactId>activity-master</artifactId>
</dependency>

<!-- Client module -->
<dependency>
  <groupId>com.guicedee.activitymaster</groupId>
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
