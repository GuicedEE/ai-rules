# ActivityMaster Feature Modules Reference

Complete reference for all ActivityMaster feature modules beyond the core FSDM services.

## Contents

- [Module Categories](#module-categories)
- [Conversations Module](#conversations-module)
- [Documents Module](#documents-module)
- [Files Module](#files-module)
- [Forums Module](#forums-module)
- [Geography Module](#geography-module)
- [Images Module](#images-module)
- [Geography Country Flags Module](#geography-country-flags-module)
- [Mail Module](#mail-module)
- [Notifications Module](#notifications-module)
- [SEO Module](#seo-module)
- [Payments Module](#payments-module)
- [Profiles Module](#profiles-module)
- [Tasks Module](#tasks-module)
- [Todo Module](#todo-module)
- [User Sessions Module](#user-sessions-module)
- [Wallet Module](#wallet-module)
- [Realtor Module](#realtor-module)
- [Module Integration Patterns](#module-integration-patterns)

## Module Categories

### Core Infrastructure
- **core**: Base services, FSDM implementation, security
- **client**: Client-side libraries and utilities
- **bom**: Bill of Materials for dependency management
- **cerial**: Core serialization framework
- **cerial-client**: Client-side serialization

### Communication & Collaboration
- **conversations**: FSDM-backed party conversations and messages
- **mail**: Email integration and templates
- **notifications**: FSDM-backed recipient notifications and delivery

### Content Management
- **documents**: Document storage and versioning
- **files**: File upload, storage, and management
- **images**: Image processing and optimization
- **seo**: FSDM-backed SEO files and rendered routes

### Community & Social
- **forums**: FSDM forums, posts, and organic subscriptions
- **profiles**: User profiles and preferences

### Task Management
- **tasks**: Task assignment and tracking
- **todo**: Personal todo lists

### Financial
- **payments**: Payment processing integration
- **wallet**: Digital wallet and balance management

### Specialized
- **geography**: Location services and spatial data
- **geography-country-flags**: Country-linked flags served by Image Master
- **realtor**: Real estate specific functionality
- **user-sessions**: Session tracking and analytics

---

## Conversations Module

See [Conversation Master](conversations-notifications-seo.md#conversation-master) for the current FSDM model, verified identity, and API contract.

---

## Documents Module

Document Master is a user-scoped plugin storing buckets as Arrangements, documents
as ResourceItems and versions/metadata/ratings as existing FSDM relationships.
It has no parallel document tables or streaming InputStream authorization API.
See the self-contained [Documents contract](documents.md) for current methods,
verified identity, installation/consent, version checks and revocation.

## Marketplace Module

Marketplace Master handles reviewed sellers, catalogue, carts/orders and settlement
proof with FSDM Products, Arrangements, Events and ResourceItems. Products are loaded
through the separately registered Marketplace Products plugin. See the complete
[Marketplace contract](marketplace.md) for both capabilities and the payment boundary.

---

## Files Module

### Overview
General file storage with cloud integration support (S3, Azure Blob, etc.).

### Entity Model

```java
@Entity
@Table(name = "files")
public class File extends BaseEntity<File, File.FileQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "filename")
    private String filename;

    @Column(name = "original_filename")
    private String originalFilename;

    @Column(name = "storage_path")
    private String storagePath;

    @Column(name = "storage_provider")
    private String storageProvider; // LOCAL, S3, AZURE_BLOB

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "checksum")
    private String checksum;

    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt;

    @ManyToOne
    @JoinColumn(name = "uploaded_by")
    private Enterprise uploadedBy;
}
```

### Service API

```java
public interface IFilesService {
    Uni<File> uploadFile(String filename, InputStream data, String mimeType, String uploaderId);
    Uni<InputStream> downloadFile(String id, SecurityToken token);
    Uni<Void> deleteFile(String id, SecurityToken token);
    Uni<File> getFileMetadata(String id, SecurityToken token);
    Uni<List<File>> listUserFiles(String userId, SecurityToken token);
    Uni<String> generateDownloadUrl(String id, Duration expiration, SecurityToken token);
}
```

---

## Forums Module

Forum Master (`com.activity-master:forum-master`) stores forums as FSDM
Arrangements, organic subscriber/moderator links as InvolvedParty relationships,
and posts as Events with private ResourceItems. It has no separate forum tables.

The host supplies verified identity through `ForumIdentityProvider`. Current
subscribers can read and post; the creator alone can add, remove, or replace the
subscriber list. An ordinary subscriber can leave their own membership. Personal
forums contain only their creator; Social and Work forums support up to 50 parties.

`ForumApi.post` publishes to current subscribers other than the poster. Post and
notification persistence share one stateless transaction; notification identity
and explicit publishing grants are required for a nonempty audience. Delivery
starts after commit. Subscriber changes affect future notices.

Read [Forum Master usage](forums.md) for Java and REST operations, context ownership,
limits, host grants, effective-date membership history, and validation boundaries.

## Geography Module

Optional country flag resources are attached through `IGeographyCountryResourceProvider`
in the caller's stateless transaction. See [country flags](geography-country-flags.md)
for the bundled catalog, installer/backfill and Image Master serving contract.

### Overview
On-demand GeoNames geographic data management. Geography data is **never loaded at startup** — only the
lightweight classification taxonomy (planet, continents, geographic hierarchy types) is created during
system installation. All bulk data (countries, provinces, districts, towns/cities, postal codes,
timezones, languages, feature codes) is loaded **on demand** via REST endpoints or Vert.x event bus messages.

The module uses the FSDM `Geography` entity with `Classification` relationships to model the full
geographic hierarchy: Planet → Continent → Country → Province → City/District → Town → PostalCode → Suburb.

### Architecture

```
Startup (GeographySystemInstall @SortedUpdate 1000):
  └─ Creates classification taxonomy (Planet, Continent, Country, Province, City, Town, etc.)
  └─ Creates planet "Earth" + 7 continents
  └─ Creates feature class classifications

On-Demand (REST or Event Bus):
  └─ POST install/languages          → loads ISO-639 languages
  └─ POST install/countries          → loads all countries from GeoNames countryInfo.txt
  └─ POST install/feature-codes      → loads GeoNames feature codes
  └─ POST install/timezones          → loads timezone data
  └─ POST install/country/{CC}       → full country install (download + provinces + districts + geodata + postal codes)
  └─ POST install/country/{CC}/provinces   → provinces only
  └─ POST install/country/{CC}/districts   → districts only
  └─ POST install/country/{CC}/geodata     → towns/cities only
  └─ POST install/country/{CC}/postalcodes → postal codes only
  └─ POST download/{CC}              → download GeoNames files without DB install
```

### Data Source

GeoNames export files (downloaded on demand to user home directory):
- `countryInfo.txt` — All country metadata
- `admin1CodesASCII.txt` — Province/state codes
- `admin2Codes.txt` — District/city codes
- `{CC}.txt` — Per-country geo-data (towns, cities, places)
- `{CC}.txt` (postal) — Per-country postal codes
- `hierarchy.txt` — Parent/child geographic relationships
- `iso-languagecodes.txt` — ISO-639 language codes
- `timeZones.txt` — Timezone offsets
- `featureCodes_en.txt` — GeoNames feature code descriptions

### Service API

```java
public interface IGeographyService<J extends IGeographyService<J>> {
    String GeographySystemName = "Geography System";

    // Planet & Continent
    Uni<IGeography<?, ?>> createPlanet(Mutiny.StatelessSession session, String value, String originalUniqueID, ISystems<?, ?> system, UUID... identityToken);
    Uni<IGeography<?, ?>> createContinent(Mutiny.StatelessSession session, String planetName, GeographyContinent continent, ISystems<?, ?> system, String originalUniqueID, UUID... identityToken);
    Uni<IGeography<?, ?>> findPlanet(Mutiny.StatelessSession session, String name, ISystems<?, ?> system, UUID... identityToken);
    Uni<GeographyContinent> findContinent(Mutiny.StatelessSession session, GeographyContinent continent, ISystems<?, ?> system, UUID... identityToken);

    // Country
    Uni<GeographyCountry> findCountry(Mutiny.StatelessSession session, GeographyCountry country, ISystems<?, ?> system, UUID... identityToken);
    Uni<GeographyCountry> findCountryDetailed(Mutiny.StatelessSession session, String iso, ISystems<?, ?> system, UUID... identityToken);

    // On-demand data loading
    Uni<Void> loadLanguages(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> loadCountryInfo(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> loadFeatureCodes(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> loadTimeZones(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> loadProvincesASCII1(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
    Uni<Void> loadDistrictsASCII2(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
    Uni<Void> loadTownsAndCities(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);
    Uni<Void> loadPostalCodes(Mutiny.StatelessSession session, ISystems<?, ?> system, UUID... identityToken);

    // Per-country download and install
    Uni<Void> downloadCountryData(String countryCode, UUID... identityToken);
    Uni<Void> installCountry(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
    Uni<Void> loadCountryGeoData(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);
    Uni<Void> loadCountryPostalCodes(Mutiny.StatelessSession session, ISystems<?, ?> system, String countryCode, UUID... identityToken);

    // Lookups
    Uni<IGeography<?, ?>> findGeographyById(Mutiny.StatelessSession session, UUID geographyID, ISystems<?, ?> system, UUID... identityToken);
    Uni<GeographyPostalCode> findPostalCode(Mutiny.StatelessSession session, GeographyPostalCode postalCode, ISystems<?, ?> system, UUID... identityToken);
    Uni<GeographyTimezone> findTimezone(Mutiny.StatelessSession session, GeographyTimezone timezone, ISystems<?, ?> system, UUID... identityToken);
    Uni<GeographyFeatureCode> findFeatureCode(Mutiny.StatelessSession session, String featureCode, ISystems<?, ?> system, UUID... identityToken);
}
```

### REST Endpoints

All mounted under `/{enterprise}/geography/{system}/`:

| Method | Path | Description |
|--------|------|-------------|
| GET | `country/{iso}` | Find country by ISO-3166 alpha-2 code |
| POST | `install/languages` | Load ISO-639 language data |
| POST | `install/countries` | Load all country info |
| POST | `install/feature-codes` | Load GeoNames feature codes |
| POST | `install/timezones` | Load timezone data |
| POST | `download/{countryCode}` | Download GeoNames files (no DB install) |
| POST | `install/country/{countryCode}` | Full country install (end-to-end) |
| POST | `install/country/{countryCode}/provinces` | Load provinces only |
| POST | `install/country/{countryCode}/districts` | Load districts only |
| POST | `install/country/{countryCode}/geodata` | Load towns/cities only |
| POST | `install/country/{countryCode}/postalcodes` | Load postal codes only |

### Event Bus Addresses

All consumers run on worker threads (`@VertxEventOptions(worker = true)`):

| Address | Body | Description |
|---------|------|-------------|
| `geography.install.country` | ISO-3166 code (e.g. "ZA") | Full country install |
| `geography.install.languages` | Enterprise name | Load language data |
| `geography.install.countries` | Enterprise name | Load country info |
| `geography.install.featurecodes` | Enterprise name | Load feature codes |
| `geography.install.timezones` | Enterprise name | Load timezones |
| `geography.download.country` | ISO-3166 code (e.g. "ZA") | Download GeoNames files only |

### Query Approach

Geography services use **EntityAssist query builders** for all database queries:

```java
// Finding a country by ISO code and classification
return new Geography().builder(session)
    .withName(iso)
    .withClassification((Classification) classification)
    .inActiveRange()
    .inDateRange()
    .withEnterprise(enterprise)
    .get();

// Counting before create (upsert pattern)
return geo.builder(session)
    .withGeoNameID(geoData.getGeonameId().toString())
    .getCount()
    .chain(count -> { ... });
```

Direct `session.find(Geography.class, id)` and `session.persist(geo)` are used as **optimizations**
for primary-key lookups and inserts only.

### Usage Example

```java
// Install South Africa on demand via REST
// POST /myenterprise/geography/Geography System/install/country/ZA

// Or via event bus
@Inject @Named("geography.install.country")
private VertxEventPublisher<String> installPublisher;

installPublisher.request("ZA");  // request/reply
```

### Key Design Decisions

1. **No data at startup** — Only the classification schema + planet + continents are created during `GeographySystemInstall`. All bulk CSV data loading is triggered on demand.
2. **EntityAssist query builders** — All queries use the fluent builder pattern (
ew Geography().builder(session).withName(...).get()`).
3. **Direct session for optimization** — `session.find()` for PK lookups and `session.persist()` for inserts are kept for performance.
4. **Per-country install** — Countries can be installed individually via `installCountry(session, system, "ZA")` which downloads GeoNames files if needed and loads provinces → districts → towns → postal codes.
5. **Worker threads for events** — All event bus consumers use `worker = true` since data loading involves blocking IO (CSV parsing, HTTP downloads).

---

## Images Module

Image Master (`com.activity-master:image-master`, JPMS
`com.guicedee.activitymaster.imagemaster`) stores binaries as secured FSDM
ResourceItems of type `Image`. Its service is `IImageService<?>`; image IDs are
resource UUIDs. Storage and retrieval accept the caller's stateless session,
system and tokens. The caller owns transaction boundaries.

`storeImage` creates an image resource. `getImage` and `getOptimizedImage` retrieve
by UUID; `getImageByClassification` and `getOptimizedImageByClassification` locate
an image by classification/value. Positive dimensions bound image size while
preserving aspect ratio. `ImageRestService` exposes upload, UUID and classification
routes below `{enterprise}/image/{requestingSystemName}`. Reads detect the image
media type, use private browser cache headers and return 404 for missing/unreadable
bytes.

For geography-linked flags, use `geo-country-flags` and its Geography System scope.
The [country flags and Image Master contract](geography-country-flags.md) includes
module setup, exact routes, catalog behavior, security and validation boundaries.

---

## Geography Country Flags Module

`com.activity-master:geo-country-flags` bundles country PNGs and attaches them to
Geography country rows using their two-letter names. `CountryFlagCatalog` accepts
exactly two ASCII letters, normalizes to uppercase and returns defensive byte
copies. A valid absent code returns null. Bundled bytes may be cached; persisted
rows and authorization remain ActivityMaster-owned.

`CountryFlagService.ensureFlag` uses Image Master to store an `Image` resource and
creates a `GeographyXResourceItem` with classification `CountryFlag` and the country
code as its value. The image receives `CountryFlagCountryCode` for Image Master
classification lookup. The complete chain uses the caller's stateless transaction.

`CountryFlagsInstall` runs at order 1110 after Geography (1000) and Images (1100),
creates taxonomy and backfills countries already installed in the enterprise.
`IGeographyCountryResourceProvider` attaches flags during later `createCountry`
calls, including country-info imports. No GeoNames or image download is triggered
by the flag installer. Sequential repeats reuse the existing active link.

Use the self-contained [country flags interaction contract](geography-country-flags.md)
for service calls, deployment setup, code normalization, caching and Image Master
URLs. Existing enterprises must run updates after adding the flags module.

---

## Mail Module

Mail Master is a built-in plugin with its own registration ID and a Plugin identity
under Plugins. It declares Activity Master System and uses existing FSDM mail
Events, private body/attachment ResourceItems, participant links and per-user
Mailbox Arrangements. It adds no email-message table.

The host binds `MailIdentityProvider` or supplies a verified `MailIdentity` to
`IMailFsdmService.ingest`. The current user's party determines mailbox ownership;
addresses and the compatibility mailbox label do not authenticate the actor.
Installation, per-user consent, administrator policy, private writes and audit
are checked/composed in one stateless transaction. SMTP/IMAP transport credentials
remain distinct from FSDM user authority. See the self-contained [Mail contract](mail.md)
and [plugin lifecycle/authorization contract](scoped-plugins.md).

---

## Notifications Module

See [Notification Master](conversations-notifications-seo.md#notification-master) for the current FSDM model, scoped grants, delivery channels, and API contract.

---

## SEO Module

See [SEO Master](conversations-notifications-seo.md#seo-master) for secured per-host SEO files, dynamic FSDM content, publishing, and routes.

---

## Payments Module

Payment Master is a built-in Plugin declaring Activity Master System and Wallet
Master. The host installs both plugins and obtains each user's dependency consent,
in addition to current provider behavior grants and row permissions.

Payment intents are FSDM Events and classified relationships. Wallet alone owns
balanced settlement. Bind `WalletIdentityProvider`, `PaymentHost` and allowlisted
`PaymentGateways`; use `PaymentApi.start`, `get` and verified `confirm`. Callback
verification and checkout run outside DB transactions, while settlement and Wallet
posting are atomic. Redirects never credit a wallet. This module adds no payment
entity table, generic refund API or automatic provider authorization. See the
self-contained [Payment contract](payments.md).

---

## Profiles Module

Profiles use `IProfileService<?>` and `ComprehensiveProfileDTO` backed by FSDM involved-party names and classifications. See [Profiles and user sessions](guide-profiles-and-user-sessions.md) for the actual Java API, REST create/update/find endpoints, and GraphQL profile queries.

---

## Tasks Module

### Overview
Task assignment, tracking, and collaboration with dependencies and workflows.

### Entity Model

```java
@Entity
@Table(name = "tasks")
public class Task extends BaseEntity<Task, Task.TaskQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    private TaskStatus status; // TODO, IN_PROGRESS, REVIEW, COMPLETED, CANCELLED

    @Column(name = "priority")
    @Enumerated(EnumType.STRING)
    private TaskPriority priority; // LOW, MEDIUM, HIGH, CRITICAL

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "estimated_hours")
    private Integer estimatedHours;

    @Column(name = "actual_hours")
    private Integer actualHours;

    @ManyToOne
    @JoinColumn(name = "assignee_id")
    private Enterprise assignee;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private Enterprise createdBy;

    @ManyToMany
    @JoinTable(name = "task_dependencies")
    private List<Task> dependencies;
}
```

### Service API

```java
public interface ITasksService {
    Uni<Task> createTask(Task task, String assigneeId, String creatorId);
    Uni<Task> updateTask(String id, Task updates, SecurityToken token);
    Uni<Task> updateTaskStatus(String id, TaskStatus status, SecurityToken token);
    Uni<Task> assignTask(String id, String assigneeId, SecurityToken token);
    Uni<Task> addDependency(String taskId, String dependencyId, SecurityToken token);
    Uni<List<Task>> listUserTasks(String userId, SecurityToken token);
    Uni<List<Task>> listOverdueTasks(SecurityToken token);
}
```

---

## Todo Module

### Overview
Personal todo lists with priorities and due dates.

### Entity Model

```java
@Entity
@Table(name = "todo_items")
public class TodoItem extends BaseEntity<TodoItem, TodoItem.TodoItemQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "notes")
    private String notes;

    @Column(name = "is_completed")
    private Boolean isCompleted;

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "priority")
    private Integer priority;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @ManyToOne
    @JoinColumn(name = "owner_id")
    private Enterprise owner;
}
```

---

## User Sessions Module

User application state uses `IUserSessionService<?>` and JSON resource items linked to involved parties. See [Profiles and user sessions](guide-profiles-and-user-sessions.md) for loading, value serialization, update/expiry, and REST/GraphQL adapter guidance, including current transport and implementation limits.

---

## Wallet Module

Wallet Master is a built-in Plugin declaring Activity Master System. The host
binds `WalletIdentityProvider`, installs the catalogue registration on an authorized
party, obtains each user's dependency consent and provisions explicit provider
behavior grants. Every call and retry checks current admission and row permissions.

Wallets and clearing accounts are typed FSDM Arrangements, business actions are
Events, and posted core transaction entries are the authoritative balance ledger.
`WalletApi` exposes create, balance, history and transfer/deposit/withdrawal through
its owning REST/GraphQL adapters. Both movement arrangements require write access;
clearing arrangements are separately host-provisioned. There is no wallet balance
column or parallel wallet-account table. See the self-contained
[Wallet and transaction contract](transactions.md).

---

## Realtor Module

### Overview
Real estate specific functionality including property listings, showings, and offers.

### Entity Model

```java
@Entity
@Table(name = "properties")
public class Property extends BaseEntity<Property, Property.PropertyQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "listing_type")
    private String listingType; // SALE, RENT

    @Column(name = "property_type")
    private String propertyType; // HOUSE, APARTMENT, CONDO

    @Column(name = "price")
    private BigDecimal price;

    @Column(name = "bedrooms")
    private Integer bedrooms;

    @Column(name = "bathrooms")
    private Integer bathrooms;

    @Column(name = "square_feet")
    private Integer squareFeet;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @ManyToOne
    @JoinColumn(name = "address_id")
    private Address address;

    @ManyToOne
    @JoinColumn(name = "agent_id")
    private Enterprise agent;
}
```

### Service API

```java
public interface IRealtorService {
    Uni<Property> createListing(Property property, String addressId, String agentId);
    Uni<List<Property>> searchProperties(PropertySearchCriteria criteria, SecurityToken token);
    Uni<List<Property>> findPropertiesNearby(Double lat, Double lng, Double radiusKm, SecurityToken token);
    Uni<Property> updateListing(String id, Property updates, SecurityToken token);
}
```

---

## Module Integration Patterns

### Cross-Module Communication

```java
// Example: Task with document attachments
tasksService.createTask(task, assigneeId, creatorId)
    .chain(created ->
        documentsService.uploadDocument(document, fileData, creatorId)
            .chain(doc -> {
                // Link document to task (via custom join table)
                return taskDocumentService.linkDocument(created.getId(), doc.getId(), token);
            })
    )
    .replaceWithVoid();
```

### Event-Driven Integration

```java
// Notification on task assignment
@Singleton
public class TaskEventHandler {
    @Inject
    INotificationsService notificationsService;

    public Uni<Void> onTaskAssigned(Task task) {
        return notificationsService.sendNotification(
            task.getAssignee().getId(),
            "New Task Assigned",
            "You have been assigned: " + task.getTitle(),
            NotificationType.PUSH
        ).replaceWithVoid();
    }
}
```

### Module Dependencies

Common dependency chains:
- **Tasks** → **Notifications** → **Mail**
- **Conversations** → **Notifications** → **Profiles**
- **Payments** → **Wallet** → **Notifications**
- **Documents** → **Files** → **Images**
- **Forums** → **Profiles** → **Images**
