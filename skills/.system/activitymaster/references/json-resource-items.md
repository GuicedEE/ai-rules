# JSON Resource Items (MongoDB Document Store)

Detailed reference for storing JSON-typed `ResourceItem` payloads in MongoDB via
`com.guicedee.activitymaster.fsdm.ResourceItemJsonStore`. Load this file when working with JSON
resource items, MongoDB document storage, named collections, criteria lookups, partial field/child
updates, or the fluent `ResourceItem` document API.

## Contents

- [Concept](#concept)
- [When a resource item is "JSON"](#when-a-resource-item-is-json)
- [Opt-in — MongoDB connection](#opt-in--mongodb-connection)
- [Collections — addressable by name](#collections--addressable-by-name)
- [Reads — by id, by name, by criteria](#reads--by-id-by-name-by-criteria)
- [Partial updates — fields & children](#partial-updates--fields--children)
- [Service-level API (IResourceItemService)](#service-level-api-iresourceitemservice)
- [Fluent entity API (IResourceItem / ResourceItem)](#fluent-entity-api-iresourceitem--resourceitem)
- [Create / read / update flow](#create--read--update-flow)
- [Configuration (environment variables)](#configuration-environment-variables)
- [Testing with Testcontainers](#testing-with-testcontainers)

## Concept

Resource items whose **type is a JSON type** store their payload as a MongoDB **document** instead of
the relational `resource.resourceitemdatavalue` column. The relational `ResourceItemData` /
`ResourceItemDataValue` rows are still written (with an *empty* payload) so the FSDM SCD / security
structure stays intact — only the bytes live in MongoDB. Implemented by `ResourceItemJsonStore` (core,
`@Singleton`).

**Net effect:** the FSDM relational structure (SCD windows, default security rows, type links) is
always written so security/visibility behave identically to binary resource items — only the *bytes*
are relocated to MongoDB. Lookups, partial updates and the fluent API all degrade to no-ops / relational
fallback when MongoDB is absent, so the same code runs in both configurations.

## When a resource item is "JSON"

A type is treated as JSON when its name:
- equals one of the configured JSON type names (default `JsonPacket`, the `ResourceItemTypes.JsonPacket`
  classification), extendable via `RESOURCE_ITEM_JSON_TYPES` (comma-separated), **or**
- **contains** `json` (case-insensitive) — e.g. `InvoiceJson`, `MyJsonPayload`.

```java
ResourceItemJsonStore store = IGuiceContext.get(ResourceItemJsonStore.class);
store.isEnabled();                       // true only when a MongoClient is bound (else relational fallback)
store.isJsonType("JsonPacket");          // true
store.isJsonType("InvoiceJson");         // true  (name contains "json")
store.isJsonType("Documents");           // false
```

## Opt-in — MongoDB connection

The store resolves a Vert.x `io.vertx.ext.mongo.MongoClient` **lazily** from the injector. When none is
bound the store is **disabled** and every read/write transparently falls back to relational storage —
deployments that do not use JSON resource items never need a MongoDB instance.

Bind the client with a GuicedEE persistence `MongoModule` (subclass it, provide a `MongoConnectionInfo`,
register as an `IGuiceModule` SPI). ActivityMaster ships `ActivityMasterMongoModule` (logical name
`activityMaster`), which is **opt-in** via `MONGO_*` environment variables; `enabled()` returns `false`
unless one of `MONGO_ENABLED` / `MONGO_URL` / `MONGO_HOST` is set.

```java
public class MyAppMongoModule extends MongoModule<MyAppMongoModule>
        implements IGuiceModule<MyAppMongoModule> {
    @Override protected MongoConnectionInfo getMongoConnectionInfo() {
        return new MongoConnectionInfo()
                .setName("activityMaster")
                .setConnectionString(Environment.getProperty("MONGO_URL", "mongodb://localhost:27017"))
                .setDatabaseName(Environment.getProperty("MONGO_DATABASE", "activitymaster"))
                .setDefaultConnection(true);   // bind without @Named so ResourceItemJsonStore resolves it
    }
}
```

## Collections — addressable by name

By default every JSON resource item lands in one collection (`resourceitemdata_json`, overridable with
`RESOURCE_ITEM_JSON_COLLECTION`). Specific types can be **routed to their own collections** with
`RESOURCE_ITEM_JSON_COLLECTIONS` (e.g. `InvoiceJson=invoices,ContractJson=contracts`). Id-keyed reads
transparently search **every known collection**, so `getData` keeps working regardless of routing.

```java
store.getDefaultCollection();             // "resourceitemdata_json"
store.collectionForType("InvoiceJson");   // "invoices" (or the default when not routed)
store.knownCollections();                 // default + every routed collection
store.listCollections();                  // Uni<List<String>> — collections that exist in the DB
```

## Reads — by id, by name, by criteria

```java
// payload bytes / JsonObject for a resource item (searches all known collections)
Uni<byte[]>     bytes = store.fetch(resourceItemId);
Uni<JsonObject> json  = store.fetchJson(resourceItemId);

// document by _id or by a name field in a named collection
Uni<JsonObject> byId   = store.getById("invoices", id);
Uni<JsonObject> byName = store.getByName("invoices", "ACME-001");          // default "name" field
Uni<JsonObject> byFld  = store.getByField("invoices", "sku", "SKU-1");

// native Mongo criteria over the default or a named collection
Uni<List<JsonObject>> hits  = store.find(new JsonObject().put("author", "Tolkien"));
Uni<List<JsonObject>> hits2 = store.find("invoices", new JsonObject().put("paid", false));
Uni<List<JsonObject>> hits3 = store.findByField("status", "active");

store.existsInMongo(resourceItemId);      // Uni<Boolean>
```

> Results are stripped of the internal Mongo `_id` but **retain** `ResourceItemJsonStore.RESOURCE_ID_FIELD`
> (`_resourceItemId`) so a criteria hit can be mapped back to its resource item.

## Partial updates — fields & children

Mutate individual fields/children with MongoDB update operators; dot-notation supports nesting and
array indices (`address.city`, `items.0.qty`). Values accept any JSON-compatible Java type
(`String`/number/`Boolean`/`null`, `List`/array → `JsonArray`, `Map`/POJO → `JsonObject`, enums →
name, Vert.x `JsonObject`/`JsonArray`). Updates **upsert** (create the document if missing).

```java
store.setField(id, "status", "active");                       // $set
store.setFields(id, Map.of("region", "Free State", "qty", 7)); // $set (multi)
store.unsetField(id, "meta.reviewer");                        // $unset (nested)
store.pushChild(id, "history", new JsonObject().put("action","created")); // $push
store.pullChild(id, "history", new JsonObject().put("action","created")); // $pull
store.delete(id);                                             // remove from all known collections
```

## Service-level API (IResourceItemService)

The client interface exposes default methods so callers never touch the store directly (all no-op when
MongoDB is not configured):

| Method | Effect |
|---|---|
| `findJsonResourceData(JsonObject query)` | criteria lookup over the default collection |
| `findJsonResourceData(String collection, JsonObject query)` | criteria lookup over a named collection |
| `getJsonResourceData(UUID id)` | fetch a resource item's JSON document |
| `updateJsonResourceField(UUID id, String path, Object value)` | `$set` a (possibly nested) field |
| `removeJsonResourceField(UUID id, String path)` | `$unset` a field/child |
| `addJsonResourceChild(UUID id, String arrayPath, JsonObject child)` | `$push` a child |
| `removeJsonResourceChild(UUID id, String arrayPath, Object match)` | `$pull` matching children |

## Fluent entity API (IResourceItem / ResourceItem)

A JSON-typed `ResourceItem` carries a fluent document API (no-op unless JSON-typed + MongoDB on):

```java
ResourceItem farm = new ResourceItem(); farm.setId(farmId);
farm.storeField("acres", 120);                                 // string/int/bool/list/map/POJO
farm.storeFields(Map.of("region", "Free State", "hectares", 48.5));
farm.addJsonChild("crops", new JsonObject().put("name", "maize"));
farm.removeField("organic");
Uni<JsonObject> doc = farm.getJson();
```

## Create / read / update flow

Create a JSON resource item exactly like any other (the payload is JSON bytes); `getData` reads it back
from MongoDB; `updateResourceData` replaces the document:

```java
resourceItemService.createType(session, ResourceItemTypes.JsonPacket, system)
    .chain(t -> resourceItemService.create(session, ResourceItemTypes.JsonPacket.name(), "the-hobbit",
            json.getBytes(StandardCharsets.UTF_8), system));   // payload → MongoDB, relational value row empty

new ResourceItem(){{ setId(id); }}.getData(session);           // reads JSON back from MongoDB
resourceItemService.updateResourceData(session, updated, id, ISystemsService.ActivityMasterSystemName);
```

## Configuration (environment variables)

| Variable | Purpose |
|---|---|
| `MONGO_ENABLED` | Force-enable the store (with discrete host/port) |
| `MONGO_URL` | MongoDB connection string (takes precedence), e.g. `mongodb://localhost:27017` |
| `MONGO_HOST` / `MONGO_PORT` | Discrete MongoDB host/port (default `127.0.0.1:27017`) |
| `MONGO_DATABASE` | MongoDB database name (default `activitymaster`) |
| `MONGO_USERNAME` / `MONGO_PASSWORD` / `MONGO_AUTH_SOURCE` | Optional MongoDB credentials |
| `RESOURCE_ITEM_JSON_TYPES` | Extra resource-item type names treated as JSON (comma-separated; default `JsonPacket`) |
| `RESOURCE_ITEM_JSON_COLLECTION` | Default MongoDB collection for JSON payloads (default `resourceitemdata_json`) |
| `RESOURCE_ITEM_JSON_COLLECTIONS` | Per-type collection routing, e.g. `InvoiceJson=invoices,ContractJson=contracts` |

Resolve these via `com.guicedee.client.Environment` — never `System.getenv`/`getProperty`.

## Testing with Testcontainers

Provision MongoDB with Testcontainers and bind a `MongoClient` under the same logical name
(`activityMaster`) as the default connection, so `ResourceItemJsonStore` resolves it transparently.
Configure it **purely from the container** (do **not** set `MONGO_*` env vars) so the production
`ActivityMasterMongoModule` stays disabled and there is exactly one `MongoClient` binding:

```java
public class MongoTestDBModule extends MongoModule<MongoTestDBModule>
        implements IGuiceModule<MongoTestDBModule> {

    private static final MongoDBContainer mongoContainer =
            new MongoDBContainer("mongo:7.0").withStartupTimeout(Duration.ofMinutes(2));
    static { mongoContainer.start(); }

    @Override
    protected MongoConnectionInfo getMongoConnectionInfo() {
        return new MongoConnectionInfo()
                .setName(ActivityMasterMongoModule.CONNECTION_NAME)   // "activityMaster"
                .setConnectionString(mongoContainer.getConnectionString())
                .setDatabaseName("activitymaster_test")
                .setDefaultConnection(true);
    }

    @Override public Integer sortOrder() { return 20; }
}
```

Register it alongside the PostgreSQL test module in the **test** `module-info.java`, and `requires
io.vertx.mongo.client`:

```java
provides IGuiceModule with PostgreSQLTestDBModule, MongoTestDBModule;
```

`ResourceItemJsonStore.isEnabled()` then returns `true` and JSON resource-item reads/writes go to the
container. The core `pom.xml` adds `io.vertx:vertx-mongo-client` (main) and the `testcontainers`
service (test). See `TestActivityMasterResourceItemJson` for coverage (store/fetch/criteria lookup,
update, partial field & child updates, named-collection lookup, and the fluent `ResourceItem` document
API).
