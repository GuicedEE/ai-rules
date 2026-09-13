# activitymaster: Transports

Read this reference when working on the topics below. Commands run from the skill directory.

- [REST API Architecture](#rest-api-architecture)
- [GraphQL Architecture](#graphql-architecture)
- [Event Bus Architecture](#event-bus-architecture)

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

