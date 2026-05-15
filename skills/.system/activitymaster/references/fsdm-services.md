# ActivityMaster FSDM Services Reference

Complete reference for all Functional Service Data Model (FSDM) domain services.

## Enterprise Service

### Overview
Manages organizations, companies, and business entities within the system.

### Entity Model

```java
@Entity
@Table(name = "enterprises")
public class Enterprise extends BaseEntity<Enterprise, Enterprise.EnterpriseQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "enterprise_type")
    private String enterpriseType;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name = "parent_enterprise_id")
    private Enterprise parentEnterprise;

    @OneToMany(mappedBy = "parentEnterprise")
    private List<Enterprise> childEnterprises;
}
```

### Service API

```java
public interface IEnterpriseService {
    // Create
    Uni<Enterprise> createEnterprise(Enterprise enterprise);
    Uni<Enterprise> createChildEnterprise(Enterprise child, String parentId, SecurityToken token);

    // Read
    Uni<Optional<Enterprise>> getEnterprise(String id, SecurityToken token);
    Uni<List<Enterprise>> listEnterprises(SecurityToken token);
    Uni<List<Enterprise>> listChildEnterprises(String parentId, SecurityToken token);
    Uni<List<Enterprise>> searchEnterprises(String query, SecurityToken token);
    Uni<Long> countEnterprises(SecurityToken token);

    // Update
    Uni<Enterprise> updateEnterprise(Enterprise enterprise, SecurityToken token);
    Uni<Enterprise> updateEnterpriseType(String id, String type, SecurityToken token);

    // Delete
    Uni<Void> deleteEnterprise(String id, SecurityToken token);
    Uni<Void> softDeleteEnterprise(String id, SecurityToken token);

    // Status
    Uni<Enterprise> activateEnterprise(String id, SecurityToken token);
    Uni<Enterprise> deactivateEnterprise(String id, SecurityToken token);
}
```

### Usage Examples

#### Create Enterprise

```java
Enterprise enterprise = new Enterprise()
    .setId(UUID.randomUUID().toString())
    .setName("ACME Corporation")
    .setDescription("Leading widget manufacturer")
    .setEnterpriseType("CORPORATION")
    .setActiveFlag(ActiveFlag.Active)
    .setCreatedAt(LocalDateTime.now());

enterpriseService.createEnterprise(enterprise)
    .invoke(created -> log.info("Created enterprise: {}", created.getId()))
    .replaceWithVoid();
```

#### Enterprise Hierarchy

```java
// Create parent
Enterprise parent = new Enterprise()
    .setName("ACME Holdings")
    .setEnterpriseType("HOLDING_COMPANY");

enterpriseService.createEnterprise(parent)
    .chain(created ->
        // Create child
        enterpriseService.createChildEnterprise(
            new Enterprise().setName("ACME Widgets"),
            created.getId(),
            token
        )
    )
    .replaceWithVoid();
```

#### Search Enterprises

```java
enterpriseService.searchEnterprises("ACME", token)
    .invoke(results -> {
        results.forEach(e -> log.info("Found: {}", e.getName()));
    })
    .replaceWithVoid();
```

---

## Address Service

### Overview
Manages physical and virtual addresses with validation and standardization.

### Entity Model

```java
@Entity
@Table(name = "addresses")
public class Address extends BaseEntity<Address, Address.AddressQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "street_line_1")
    private String streetLine1;

    @Column(name = "street_line_2")
    private String streetLine2;

    @Column(name = "city")
    private String city;

    @Column(name = "state_province")
    private String stateProvince;

    @Column(name = "postal_code")
    private String postalCode;

    @Column(name = "country")
    private String country;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "address_type")
    private String addressType;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;
}
```

### Service API

```java
public interface IAddressService {
    // Create
    Uni<Address> createAddress(Address address, String enterpriseId);

    // Read
    Uni<Optional<Address>> getAddress(String id, SecurityToken token);
    Uni<List<Address>> listAddresses(String enterpriseId, SecurityToken token);
    Uni<List<Address>> listAddressesByType(String type, SecurityToken token);
    Uni<List<Address>> findAddressesByPostalCode(String postalCode, SecurityToken token);

    // Update
    Uni<Address> updateAddress(Address address, SecurityToken token);

    // Delete
    Uni<Void> deleteAddress(String id, SecurityToken token);

    // Validation
    Uni<Address> validateAddress(Address address);
    Uni<Address> standardizeAddress(Address address);

    // Geocoding
    Uni<Address> geocodeAddress(Address address);
    Uni<List<Address>> findAddressesNearby(Double lat, Double lng, Double radiusKm, SecurityToken token);
}
```

### Usage Examples

#### Create Address

```java
Address address = new Address()
    .setStreetLine1("123 Main Street")
    .setCity("San Francisco")
    .setStateProvince("CA")
    .setPostalCode("94102")
    .setCountry("USA")
    .setAddressType("BILLING")
    .setActiveFlag(ActiveFlag.Active);

addressService.createAddress(address, enterpriseId)
    .invoke(created -> log.info("Address created: {}", created.getId()))
    .replaceWithVoid();
```

#### Validate and Geocode

```java
addressService.validateAddress(address)
    .chain(validated ->
        addressService.geocodeAddress(validated)
    )
    .invoke(geocoded -> {
        log.info("Coordinates: {}, {}", geocoded.getLatitude(), geocoded.getLongitude());
    })
    .replaceWithVoid();
```

---

## Events Service

### Overview
Event and activity scheduling, management, and tracking.

### Entity Model

```java
@Entity
@Table(name = "events")
public class Event extends BaseEntity<Event, Event.EventQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description")
    private String description;

    @Column(name = "event_type")
    private String eventType;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "location")
    private String location;

    @Column(name = "is_recurring")
    private Boolean isRecurring;

    @Column(name = "recurrence_rule")
    private String recurrenceRule;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;

    @ManyToMany
    @JoinTable(
        name = "event_participants",
        joinColumns = @JoinColumn(name = "event_id"),
        inverseJoinColumns = @JoinColumn(name = "participant_id")
    )
    private List<Enterprise> participants;
}
```

### Service API

```java
public interface IEventsService {
    // Create
    Uni<Event> createEvent(Event event, String enterpriseId);
    Uni<Event> createRecurringEvent(Event event, String recurrenceRule, String enterpriseId);

    // Read
    Uni<Optional<Event>> getEvent(String id, SecurityToken token);
    Uni<List<Event>> listEvents(String enterpriseId, SecurityToken token);
    Uni<List<Event>> listEventsByDateRange(LocalDate start, LocalDate end, SecurityToken token);
    Uni<List<Event>> listUpcomingEvents(SecurityToken token);
    Uni<List<Event>> listEventsByType(String type, SecurityToken token);

    // Update
    Uni<Event> updateEvent(Event event, SecurityToken token);
    Uni<Event> rescheduleEvent(String id, LocalDateTime newStart, LocalDateTime newEnd, SecurityToken token);

    // Delete
    Uni<Void> cancelEvent(String id, SecurityToken token);

    // Participants
    Uni<Event> addParticipant(String eventId, String participantId, SecurityToken token);
    Uni<Event> removeParticipant(String eventId, String participantId, SecurityToken token);
    Uni<List<Enterprise>> listParticipants(String eventId, SecurityToken token);
}
```

### Usage Examples

#### Create Event

```java
Event event = new Event()
    .setTitle("Q1 Planning Meeting")
    .setDescription("Quarterly planning session")
    .setEventType("MEETING")
    .setStartTime(LocalDateTime.of(2025, 4, 1, 10, 0))
    .setEndTime(LocalDateTime.of(2025, 4, 1, 12, 0))
    .setLocation("Conference Room A")
    .setActiveFlag(ActiveFlag.Active);

eventsService.createEvent(event, enterpriseId)
    .invoke(created -> log.info("Event created: {}", created.getId()))
    .replaceWithVoid();
```

#### Add Participants

```java
eventsService.createEvent(event, enterpriseId)
    .chain(created ->
        eventsService.addParticipant(created.getId(), participantId1, token)
            .chain(() -> eventsService.addParticipant(created.getId(), participantId2, token))
    )
    .replaceWithVoid();
```

#### List Upcoming Events

```java
eventsService.listUpcomingEvents(token)
    .invoke(events -> {
        events.forEach(e ->
            log.info("Upcoming: {} at {}", e.getTitle(), e.getStartTime())
        );
    })
    .replaceWithVoid();
```

---

## Arrangements Service

### Overview
Resource arrangements, bookings, and conflict detection.

### Entity Model

```java
@Entity
@Table(name = "arrangements")
public class Arrangement extends BaseEntity<Arrangement, Arrangement.ArrangementQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "arrangement_type")
    private String arrangementType;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Column(name = "status")
    private String status;

    @Column(name = "notes")
    private String notes;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToOne
    @JoinColumn(name = "resource_id")
    private ResourceItem resource;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;
}
```

### Service API

```java
public interface IArrangementsService {
    // Create
    Uni<Arrangement> createArrangement(Arrangement arrangement, String resourceId, String enterpriseId);

    // Read
    Uni<Optional<Arrangement>> getArrangement(String id, SecurityToken token);
    Uni<List<Arrangement>> listArrangements(String enterpriseId, SecurityToken token);
    Uni<List<Arrangement>> listArrangementsByResource(String resourceId, SecurityToken token);
    Uni<List<Arrangement>> listArrangementsByDateRange(LocalDate start, LocalDate end, SecurityToken token);

    // Update
    Uni<Arrangement> updateArrangement(Arrangement arrangement, SecurityToken token);
    Uni<Arrangement> updateArrangementStatus(String id, String status, SecurityToken token);

    // Delete
    Uni<Void> cancelArrangement(String id, SecurityToken token);

    // Conflict Detection
    Uni<Boolean> checkAvailability(String resourceId, LocalDateTime start, LocalDateTime end);
    Uni<List<Arrangement>> findConflicts(String resourceId, LocalDateTime start, LocalDateTime end);
}
```

### Usage Examples

#### Create Arrangement with Conflict Check

```java
Arrangement arrangement = new Arrangement()
    .setArrangementType("RESERVATION")
    .setStartTime(LocalDateTime.of(2025, 4, 1, 14, 0))
    .setEndTime(LocalDateTime.of(2025, 4, 1, 16, 0))
    .setStatus("PENDING")
    .setActiveFlag(ActiveFlag.Active);

arrangementsService.checkAvailability(resourceId, arrangement.getStartTime(), arrangement.getEndTime())
    .chain(available -> {
        if (available) {
            return arrangementsService.createArrangement(arrangement, resourceId, enterpriseId);
        } else {
            return Uni.createFrom().failure(new IllegalStateException("Resource not available"));
        }
    })
    .invoke(created -> log.info("Arrangement created: {}", created.getId()))
    .replaceWithVoid();
```

#### Find Conflicts

```java
arrangementsService.findConflicts(resourceId, startTime, endTime)
    .invoke(conflicts -> {
        if (!conflicts.isEmpty()) {
            log.warn("Found {} conflicting arrangements", conflicts.size());
            conflicts.forEach(c ->
                log.warn("Conflict: {} - {}", c.getStartTime(), c.getEndTime())
            );
        }
    })
    .replaceWithVoid();
```

---

## ResourceItem Service

### Overview
Physical and virtual resource catalogs, tracking, and availability management.

### Entity Model

```java
@Entity
@Table(name = "resource_items")
public class ResourceItem extends BaseEntity<ResourceItem, ResourceItem.ResourceItemQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "resource_type")
    private String resourceType;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "unit_of_measure")
    private String unitOfMeasure;

    @Column(name = "is_bookable")
    private Boolean isBookable;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;

    @ManyToOne
    @JoinColumn(name = "parent_resource_id")
    private ResourceItem parentResource;
}
```

### Service API

```java
public interface IResourceItemService {
    // Create
    Uni<ResourceItem> createResource(ResourceItem resource, String enterpriseId);

    // Read
    Uni<Optional<ResourceItem>> getResource(String id, SecurityToken token);
    Uni<List<ResourceItem>> listResources(String enterpriseId, SecurityToken token);
    Uni<List<ResourceItem>> listResourcesByType(String type, SecurityToken token);
    Uni<List<ResourceItem>> listBookableResources(SecurityToken token);

    // Update
    Uni<ResourceItem> updateResource(ResourceItem resource, SecurityToken token);
    Uni<ResourceItem> updateQuantity(String id, Integer quantity, SecurityToken token);

    // Delete
    Uni<Void> deleteResource(String id, SecurityToken token);

    // Availability
    Uni<Boolean> checkAvailability(String id, LocalDateTime start, LocalDateTime end);
    Uni<Integer> getAvailableQuantity(String id, LocalDateTime time);
}
```

### Usage Examples

#### Create Resource

```java
ResourceItem resource = new ResourceItem()
    .setName("Conference Room A")
    .setDescription("Large conference room with AV equipment")
    .setResourceType("MEETING_ROOM")
    .setQuantity(1)
    .setUnitOfMeasure("ROOM")
    .setIsBookable(true)
    .setActiveFlag(ActiveFlag.Active);

resourceItemService.createResource(resource, enterpriseId)
    .invoke(created -> log.info("Resource created: {}", created.getId()))
    .replaceWithVoid();
```

#### List Bookable Resources

```java
resourceItemService.listBookableResources(token)
    .invoke(resources -> {
        resources.forEach(r ->
            log.info("Available: {} ({})", r.getName(), r.getResourceType())
        );
    })
    .replaceWithVoid();
```

#### Check Availability and Quantity

```java
resourceItemService.checkAvailability(resourceId, startTime, endTime)
    .chain(available -> {
        if (available) {
            return resourceItemService.getAvailableQuantity(resourceId, startTime)
                .invoke(qty -> log.info("Available quantity: {}", qty));
        } else {
            log.warn("Resource not available");
            return Uni.createFrom().voidItem();
        }
    })
    .replaceWithVoid();
```

---

## Classification Service

### Overview
Taxonomies, categorization, tags, and type systems.

### Entity Model

```java
@Entity
@Table(name = "classifications")
public class Classification extends BaseEntity<Classification, Classification.ClassificationQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "code")
    private String code;

    @Column(name = "description")
    private String description;

    @Column(name = "classification_type")
    private String classificationType;

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToOne
    @JoinColumn(name = "parent_classification_id")
    private Classification parentClassification;

    @OneToMany(mappedBy = "parentClassification")
    private List<Classification> childClassifications;
}
```

### Service API

```java
public interface IClassificationService {
    // Create
    Uni<Classification> createClassification(Classification classification);
    Uni<Classification> createChildClassification(Classification child, String parentId, SecurityToken token);

    // Read
    Uni<Optional<Classification>> getClassification(String id, SecurityToken token);
    Uni<Optional<Classification>> getClassificationByCode(String code, SecurityToken token);
    Uni<List<Classification>> listClassifications(SecurityToken token);
    Uni<List<Classification>> listClassificationsByType(String type, SecurityToken token);
    Uni<List<Classification>> listChildClassifications(String parentId, SecurityToken token);

    // Update
    Uni<Classification> updateClassification(Classification classification, SecurityToken token);

    // Delete
    Uni<Void> deleteClassification(String id, SecurityToken token);

    // Tree Operations
    Uni<List<Classification>> getClassificationTree(String rootId, SecurityToken token);
    Uni<List<Classification>> getClassificationPath(String id, SecurityToken token);
}
```

### Usage Examples

#### Create Classification Hierarchy

```java
// Create root
Classification root = new Classification()
    .setName("Products")
    .setCode("PROD")
    .setClassificationType("TAXONOMY")
    .setActiveFlag(ActiveFlag.Active);

classificationService.createClassification(root)
    .chain(created ->
        // Create child
        classificationService.createChildClassification(
            new Classification()
                .setName("Electronics")
                .setCode("PROD-ELEC")
                .setClassificationType("TAXONOMY"),
            created.getId(),
            token
        )
    )
    .replaceWithVoid();
```

#### Get Classification Tree

```java
classificationService.getClassificationTree(rootId, token)
    .invoke(tree -> {
        tree.forEach(c ->
            log.info("Classification: {} ({})", c.getName(), c.getCode())
        );
    })
    .replaceWithVoid();
```

#### Find by Code

```java
classificationService.getClassificationByCode("PROD-ELEC", token)
    .invoke(optional ->
        optional.ifPresent(c -> log.info("Found: {}", c.getName()))
    )
    .replaceWithVoid();
```

---

## Common Patterns

### Reactive CRUD Pattern

All services follow this reactive pattern:

```java
// Create
service.create(entity, enterpriseId)
    .invoke(created -> log.info("Created: {}", created.getId()));

// Read
service.get(id, token)
    .invoke(optional -> optional.ifPresent(e -> log.info("Found: {}", e)));

// Update
service.update(entity, token)
    .invoke(updated -> log.info("Updated: {}", updated.getId()));

// Delete
service.delete(id, token)
    .invoke(() -> log.info("Deleted: {}", id));
```

### Security Token Pattern

All read/update/delete operations require `SecurityToken`:

```java
SecurityToken token = SecurityToken.fromRequest(request);

enterpriseService.getEnterprise(id, token)
    .replaceWithVoid();
```

For system-driven workflows (scheduled tasks, bootstrap loaders, background sync), prefer `SessionUtils.withActivityMaster(...)` to resolve enterprise + system + token context in one place:

```java
SessionUtils.withActivityMaster("acme", "classification-loader", tuple ->
    classificationService.refreshDefaults(
        tuple.getItem1(),
        tuple.getItem2(),
        tuple.getItem3(),
        tuple.getItem4()[0]
    )
);
```

### ActiveFlag Pattern

All entities support soft delete via `ActiveFlag`:

```java
// Query active only
var qb = new Enterprise().builder(session);
qb.where(qb.getAttribute("activeFlag"), Operand.Equals, ActiveFlag.Active)
  .getAll();

// Soft delete
entity.setActiveFlag(ActiveFlag.Deleted);
service.update(entity, token);
```

### Parallel Operations

```java
Uni.combine().all().unis(
    enterpriseService.getEnterprise(id1, token),
    addressService.getAddress(id2, token),
    eventsService.getEvent(id3, token)
).asTuple()
    .invoke(tuple -> {
        var enterprise = tuple.getItem1();
        var address = tuple.getItem2();
        var event = tuple.getItem3();
    })
    .replaceWithVoid();
```

### Error Handling

```java
enterpriseService.getEnterprise(id, token)
    .onFailure().recoverWithItem(Optional.empty())
    .invoke(optional -> {
        if (optional.isEmpty()) {
            log.warn("Enterprise not found: {}", id);
        }
    })
    .replaceWithVoid();
```
