---
name: entityassist
description: CRTP-first reactive persistence toolkit for GuicedEE services. Provides fluent entity and query-builder DSL on top of Vert.x 5, Hibernate Reactive 7, and Mutiny with PostgreSQL support. Features type-safe queries, reactive CRUD with Uni, dot-notation path filters, pagination, aggregates, joins, bulk operations, and stateless sessions. Use when working with reactive persistence, Hibernate Reactive, building entities and repositories, writing queries, or implementing non-blocking database operations in GuicedEE applications.
metadata:
  short-description: Reactive persistence with Hibernate Reactive and Mutiny
---

# EntityAssist Reactive

CRTP-first reactive persistence toolkit for GuicedEE services with Hibernate Reactive 7 and Mutiny.

## Core Features

- **CRTP-shaped entities** — `BaseEntity<J, Q, I>` with self-referencing fluent setters
- **Fluent query builder DSL** — Composable `where()`, `or()`, `orderBy()`, `groupBy()`, `join()`
- **Reactive CRUD with Mutiny** — All operations return `Uni<T>`
- **Dot-notation path filters** — `where("roles.name", Equals, "ADMIN")`
- **Pagination** — `setFirstResults()` / `setMaxResults()`
- **Aggregate projections** — `selectMin()`, `selectMax()`, `selectSum()`, `selectAverage()`, `selectCount()`
- **Join support** — INNER, LEFT, RIGHT joins with on-clause builders
- **Common Table Expressions** — Fluent `with()` / `withRecursiveHierarchy()` CTEs (Hibernate 7)
- **Bulk operations** — Criteria delete and update with safety guards
- **Stateless sessions** — High-throughput bulk operations
- **Bean Validation** — `validateEntity()` returns constraint violations

## Quick Start

### Define a CRTP Entity

```java
@Entity
@Accessors(chain = true)
@Table(name = "entity_class")
public class EntityClass
        extends BaseEntity<EntityClass, EntityClass.EntityClassQueryBuilder, String> {

    @Id
    @Column(name = "id", nullable = false)
    @Getter @Setter
    private String id;

    @Column(name = "name")
    @Getter @Setter
    private String name;

    @Override
    public String getId() { return id; }

    @Override
    public EntityClass setId(String id) {
        this.id = id;
        return this;
    }

    public static class EntityClassQueryBuilder
            extends QueryBuilder<EntityClassQueryBuilder, EntityClass, String> {

        @Override
        public boolean isIdGenerated() {
            return false;
        }
    }
}
```

### Entity with Relationships

```java
@Entity
@Accessors(chain = true)
@Table(name = "entity_class_two")
public class EntityClassTwo
        extends BaseEntity<EntityClassTwo, EntityClassTwo.EntityClassTwoQueryBuilder, String> {

    @Id
    @Getter @Setter
    private String id;

    @Column(name = "value")
    @Getter @Setter
    private Integer value;

    @ManyToOne
    @JoinColumn(name = "entity_class_id")
    @Getter @Setter
    private EntityClass entityClass;

    @Override
    public String getId() { return id; }

    @Override
    public EntityClassTwo setId(String id) {
        this.id = id;
        return this;
    }

    public static class EntityClassTwoQueryBuilder
            extends QueryBuilder<EntityClassTwoQueryBuilder, EntityClassTwo, String> {

        @Override
        public boolean isIdGenerated() {
            return false;
        }
    }
}
```

## Type Hierarchy

```
IRootEntity                      IQueryBuilderRoot
  └─ IDefaultEntity                └─ IDefaultQueryBuilder
      └─ IBaseEntity                   └─ IQueryBuilder
          ↑                                ↑
 RootEntity<J,Q,I>              QueryBuilderRoot<J,E,I>
   └─ DefaultEntity<J,Q,I>       └─ DefaultQueryBuilder<J,E,I>
       └─ BaseEntity<J,Q,I>          └─ QueryBuilder<J,E,I>
           ↑                              ↑
    Your Entity                    Your QueryBuilder
```

Every entity binds to its query builder via CRTP generics.

## Query Builder DSL

### Persist (Create)

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .persist(entity)
    )
).replaceWithVoid();
```

### Find by ID

```java
sessionFactory.withSession(session ->
    new EntityClass()
        .builder(session)
        .find("test1")
        .get()                       // Uni<EntityClass>
);
```

### Where / Or / OrderBy

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .or(qb.getAttribute("name"), Operand.Equals, "Bob")
        .orderBy(qb.getAttribute("name"), OrderByType.ASC)
        .setMaxResults(50)
        .getAll();                   // Uni<List<EntityClass>>
});
```

### Dot-Notation Path Filters

Traverse relationships without explicit joins:

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClassTwo().builder(session);
    return qb
        .where("entityClass.name", Operand.Equals, "Parent Entity")
        .where("value", Operand.GreaterThan, 10)
        .getAll();
});
```

`where(String path, ...)` splits the path on `.` and walks `path.get(segment)` for each segment
(`WhereExpression.buildPath`), creating the implicit joins. The filter is applied entirely inside the
single criteria query.

> **Reactive gotcha — filter on a joined column instead of resolving the related entity.**
> In a reactive (Hibernate Reactive / Mutiny) codebase you must **never** resolve a related entity
> synchronously just to use it in a `where(...)`. Calling another `find(...)` returns a `Uni`, and
> casting that `Uni` to the entity type throws `ClassCastException` at runtime
> (`UniOnItemTransformToUni cannot be cast to <Entity>`); awaiting/blocking it on the event loop is
> equally forbidden. Filter on the join path instead:
> ```java
> // ❌ BAD — blocks/casts a Uni to an entity to use it in where(...)
> ClassificationDataConcept dc = (ClassificationDataConcept) service.find(em, concept, system); // Uni!
> builder.where(Classification_.concept, Operand.Equals, dc);
>
> // ✅ GOOD — fully non-blocking: filter on the joined column directly
> builder.where("concept.name", Operand.Equals, concept.classificationValue());
> ```
> When the join key has a stable natural value (here the concept's persisted `name` equals
> `EnterpriseClassificationDataConcepts.classificationValue()`), the dot-notation filter is exactly
> equivalent to the entity-equality filter and stays on the reactive pipeline. This pattern fixed a
> real `ClassCastException` in `ClassificationQueryBuilder.withConcept`.

### Pagination

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .orderBy(qb.getAttribute("name"), OrderByType.ASC)
        .setFirstResults(0)
        .setMaxResults(20)
        .getAll();
});
```

### Count

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .getCount();                 // Uni<Long>
});
```

### Aggregate Projections

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClassTwo().builder(session);
    return qb
        .selectMax(qb.getAttribute("value"))
        .get(Integer.class);         // Uni<Integer>
});
```

Available aggregates:
- `selectMin()`
- `selectMax()`
- `selectSum()`
- `selectSumAsDouble()`
- `selectSumAsLong()`
- `selectAverage()`
- `selectCount()`
- `selectCountDistinct()`
- `selectColumn()`

### Joins

```java
sessionFactory.withSession(session -> {
    var parent = new EntityClass().builder(session);
    var child = new EntityClassTwo().builder(session);
    return child
        .join(child.getAttribute("entityClass"), parent, JoinType.INNER)
        .where(parent.getAttribute("name"), Operand.Equals, "Parent Entity")
        .getAll();
});
```

### Common Table Expressions (CTEs)

CTEs compose in the same fluent builder pattern. A CTE is described by a normal
builder (its `where(...)` filters), registered with `with(...)`, and the outer
query is constrained to the CTE's rows via an `id IN (SELECT id FROM cte)`
predicate — so results are **real managed entities** and the entire DSL
(`where`, `orderBy`, `groupBy`, projections, `getAll`, `getCount`) keeps working.

> Requires Hibernate ORM 7 (the builder uses `HibernateCriteriaBuilder` /
> `JpaCriteriaQuery` under the hood). In this Hibernate version a CTE is
> materialised as a tuple, so EntityAssist projects the entity `@Id` into the CTE
> and filters the outer entity query by membership rather than re-rooting it.

#### Non-recursive CTE

```java
sessionFactory.withSession(session -> {
    // CTE body — just another builder with its own filters
    var activeOnly = new EntityClass().builder(session)
            .where("description", Operand.Equals, "ACTIVE");

    // Outer entity query constrained by the CTE, then filtered normally
    return new EntityClass().builder(session)
            .with("active_entities", activeOnly)   // WITH active_entities AS (SELECT id ...)
            .where("name", Operand.Like, "A%")
            .getAll();                             // Uni<List<EntityClass>>
});
```

Generated SQL:

```sql
WITH active_entities (active_entities_id) AS (
    SELECT e.id FROM entity_class e WHERE e.description = ?
)
SELECT m.* FROM entity_class m
WHERE m.id IN (SELECT active_entities_id FROM active_entities)
  AND m.name LIKE ?
```

#### Recursive CTE (adjacency-list hierarchy)

`withRecursiveHierarchy(name, anchor, parentAttribute)` walks a self-referencing
hierarchy and returns the anchor row plus every descendant. `parentAttribute` is
the self-referencing attribute holding the parent identifier (a scalar FK column;
dot-paths such as `"parent.id"` are supported for associations).

```java
@Entity
@Table(name = "category_node")
public class CategoryNode
        extends BaseEntity<CategoryNode, CategoryNode.CategoryNodeQueryBuilder, String> {
    @Id private String id;
    private String name;
    @Column(name = "parent_id") private String parentId;   // self-reference
    // getters/setters + builder ...
}
```

```java
sessionFactory.withSession(session -> {
    var anchor = new CategoryNode().builder(session)
            .where("id", Operand.Equals, "1");           // start at node 1

    return new CategoryNode().builder(session)
            .withRecursiveHierarchy("subtree", anchor, "parentId")
            .getAll();                                   // node 1 + all descendants
});
```

Generated SQL:

```sql
WITH RECURSIVE subtree (subtree_id) AS (
    SELECT e.id FROM category_node e WHERE e.id = ?          -- anchor member
    UNION ALL
    SELECT c.id FROM category_node c, subtree                -- recursive member
    WHERE c.parent_id = subtree.subtree_id
)
SELECT m.* FROM category_node m
WHERE m.id IN (SELECT subtree_id FROM subtree)
```

#### Low-level recursive CTE

For non-hierarchy recursion, `withRecursive(name, anchor, recursiveProducer, unionAll)`
exposes Hibernate's recursive member directly as
`Function<JpaCteCriteria<Object>, AbstractQuery<Object>>` (the CTE projects the
entity id; `unionAll = false` switches to `UNION DISTINCT`).

**Notes:**
- Call `with(...)` / `withRecursiveHierarchy(...)` once per CTE; multiple CTEs accumulate.
- A unique CTE name is generated when `name` is `null`/blank.
- The CTE body builder must target the same entity type as the outer builder.
- The entity must expose a single `@Id` field.

#### Recursion over a link / join table (not just self-FK adjacency)

`withRecursiveHierarchy(...)` only fits an **adjacency list on one entity** (a self-referencing FK:
`child.parent_id = tree.id`). When the hierarchy is stored in a **separate link table** — a
`many-to-many` / association entity such as `ParentXChild(parentId, childId)` — `withRecursiveHierarchy`
**cannot** express it (its recursive member always re-roots on the same entity). Use the low-level
`withRecursive(...)` instead: its `recursiveProducer` is **raw Hibernate criteria**, so the recursive
member may root on a *different* mapped entity (the link table) and project a column back as the outer
entity's id.

Requirements / shape:
- The **outer** builder and the **anchor** builder are rooted on the target entity `E` (the CTE
  projects `E`'s `@Id`, and the outer query is trimmed by `id IN (SELECT … FROM cte)`).
- The **link table must be a mapped EntityAssist entity** (it needs a query builder / metamodel).
- The recursive member selects the link column that yields the next `E` id (e.g.
  `select x.parentId from ParentXChild x, cte a where x.childId = a.<cteIdAlias>` + any edge filters),
  aliased to the CTE id alias and typed as `E`'s id type.

```java
// Climb a parent/child hierarchy stored in a link table (childId → parentId), seeded from an anchor.
var anchor = new SecurityToken().builder(session)
        .where("securityToken", Operand.InList, tokenStrings)
        .where("enterpriseId", Operand.Equals, enterpriseId);

return new SecurityToken().builder(session)
        .withRecursive("applicable", anchor, cteRef -> {
            var cb        = (HibernateCriteriaBuilder) builder.getCriteriaBuilder();
            var recursive = cb.createQuery(UUID.class);
            var x         = recursive.from(SecurityTokenXSecurityToken.class);  // the LINK entity
            var a         = recursive.from(cteRef);
            var parentId  = x.get("parentSecurityTokenId");
            parentId.alias("applicable_id");
            recursive.select(parentId);
            recursive.where(cb.and(
                    cb.equal(x.get("childSecurityTokenId"), a.get("applicable_id")),
                    /* edge filters: enterprise, SCD in-range, active-flag visible … */));
            return recursive;
        }, /* unionAll */ false)            // UNION DISTINCT dedupes diamond hierarchies
        .getAll();                          // every SecurityToken reachable by climbing parents
```

**Why this matters (CTE fusion).** Because the climb constrains a *real* `E` builder via
`id IN (SELECT … FROM cte)`, it composes with the rest of the DSL in the **same statement** — so a
recursive expansion and a downstream membership/security trim (e.g. an `id IN (readableIds)` /
`canRead(...)` filter) run as **one CTE-backed query** instead of: native recursive query → collect a
`Set<UUID>` → second `IN (…)` query. It is also fully portable (no vendor SQL string) and goes through
Hibernate Reactive, which **auto-flushes before the query** — removing any "pin `:now` to a logical
clock because the native query doesn't flush" visibility workarounds. Trade-off: the `recursiveProducer`
is raw criteria (more verbose than fluent `where(...)`), so the win is portability + composition/fusion,
not fewer lines.

### Bulk Delete

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx -> {
        var qb = new EntityClass().builder(session);
        return qb
            .where(qb.getAttribute("name"), Operand.Equals, "obsolete")
            .delete();               // Uni<Integer> — rows affected
    })
);
```

**Safety guard:** Bulk `delete()` requires at least one filter. Use `truncate()` to remove all rows.

### Entity Delete

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .delete(entity)        // Uni<EntityClass>
    )
);
```

### Update (Merge)

```java
entity.setName("Updated Name");
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .update()              // Uni<EntityClass>
    )
);
```

### Stateless Sessions

For high-throughput bulk operations:

```java
sessionFactory.withStatelessSession(session ->
    entity.builder(session)           // uses Mutiny.StatelessSession
          .persist(entity)
);
```

**Bulk-insert pattern (resolve-once + one stateless transaction).** When securing/post-processing many just-created rows, do NOT loop a per-row operation that re-resolves shared references and round-trips for every row. Resolve the shared values **once** on the live session, then write all rows in a single `withStatelessTransaction` so the persistence context never grows and inserts can be JDBC-batched:

```java
// ❌ BAD — per row: N × (re-resolve shared refs + find + persist) round-trips
for (var row : rows) row.createSecurity(session, ...).await()...;

// ✅ GOOD — resolve shared refs once, batch all inserts in ONE stateless tx
return resolveSharedRefs(session, system)                 // 1 pass on the live session
    .chain(refs -> sessionFactory.withStatelessTransaction(st -> {
        Uni<Long> chain = Uni.createFrom().item(0L);
        for (var row : rows)
            chain = chain.chain(n -> row.persistDerived(st, refs).map(k -> n + k));
        return chain;                                     // pure inserts, no growing context
    }));
```

For just-created rows skip any per-row existence gate entirely (the caller already knows they are new); only use a `count == 0` gate when the pass must be idempotent over a whole table (re-installs).

## Transactions with Mutiny

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        new EntityClass().builder(session)
            .persist(new EntityClass().setId("b1").setName("Bob"))
            .chain(() ->
                new EntityClass().builder(session)
                    .find("b1")
                    .get()
            )
            .invoke(found -> log.info("Created and retrieved: {}", found.getName()))
    )
);
```

## Configuration

### Database Module

Create a `DatabaseModule` subclass annotated with `@EntityManager`:

```java
@EntityManager(value = "entityAssistReactive", defaultEm = true)
public class EntityAssistReactiveDBModule
        extends DatabaseModule<EntityAssistReactiveDBModule>
        implements IGuiceModule<EntityAssistReactiveDBModule> {

    @Override
    protected String getPersistenceUnitName() {
        return "entityAssistReactive";
    }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(
            PersistenceUnitDescriptor unit, Properties filteredProperties) {
        PostgresConnectionBaseInfo connectionInfo = new PostgresConnectionBaseInfo();
        connectionInfo.setServerName("localhost");
        connectionInfo.setPort("5432");
        connectionInfo.setDatabaseName("mydb");
        connectionInfo.setUsername(System.getenv("DB_USER"));
        connectionInfo.setPassword(System.getenv("DB_PASSWORD"));
        connectionInfo.setDefaultConnection(true);
        connectionInfo.setReactive(true);
        return connectionInfo;
    }

    @Override
    protected String getJndiMapping() {
        return "jdbc:entityAssistReactive";
    }
}
```

### JPMS Registration

```java
module my.app {
    requires com.entityassist;
    requires com.guicedee.persistence;

    opens my.app.entities to org.hibernate.orm.core, com.google.guice, com.entityassist;

    provides com.guicedee.client.services.lifecycle.IGuiceModule
        with my.app.MyDatabaseModule;
}
```

### Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `DB_HOST` | Database hostname | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | — |
| `DB_USER` | Database username | — |
| `DB_PASSWORD` | Database password | — |
| `ENVIRONMENT` | Runtime environment | `dev` |

## Operands

See [references/operands.md](references/operands.md) for complete list.

Common operands:
- `Equals`, `NotEquals`
- `Like`, `NotLike`
- `LessThan`, `LessThanEqualTo`
- `GreaterThan`, `GreaterThanEqualTo`
- `Null`, `NotNull`
- `InList`, `NotInList`

## Key Classes

**Entities:**
- `RootEntity<J,Q,I>` — Root CRTP entity with `builder()`, `persist()`, `update()`
- `DefaultEntity<J,Q,I>` — Intermediate extension point
- `BaseEntity<J,Q,I>` — Primary superclass for user entities

**Query Builders:**
- `QueryBuilderRoot<J,E,I>` — Root builder with session management
- `DefaultQueryBuilder<J,E,I>` — Fluent DSL methods
- `QueryBuilder<J,E,I>` — Primary superclass for user builders

**Expressions:**
- `WhereExpression` — Single `where` predicate
- `GroupedExpression` — AND/OR predicate grouping
- `JoinExpression` — Join definition
- `CteExpression` — Common Table Expression definition (name, body builder, recursion)
- `SelectExpression` — Column selection with aggregates
- `OrderByExpression` — Column + direction
- `GroupByExpression` — Column grouping

## ActiveFlag Lifecycle Enum

Rich status model with ranged queries:

```java
public enum ActiveFlag {
    Unknown,
    Deleted,
    Active,
    Permanent
}
```

Helpers:
- `getActiveRange()` — Active to Permanent
- `getVisibleRangeAndUp()` — Active and above
- And more status range helpers

## Converters

Built-in JPA attribute converters:
- `LocalDateAttributeConverter` — `LocalDate` ↔ `java.sql.Date`
- `LocalDateTimeAttributeConverter` — `LocalDateTime` ↔ `java.sql.Timestamp`
- `LocalDateTimestampAttributeConverter` — `LocalDate` ↔ `java.sql.Timestamp`

## Testing with Testcontainers

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class EntityAssistReactiveTest {

    private Mutiny.SessionFactory sessionFactory;

    @BeforeAll
    public void setup() {
        IGuiceContext.instance();
        JtaPersistService ps = (JtaPersistService) IGuiceContext.get(
            Key.get(PersistService.class, Names.named("entityAssistReactive")));
        ps.start();

        sessionFactory = IGuiceContext.get(
            Key.get(Mutiny.SessionFactory.class, Names.named("entityAssistReactive")));
    }

    @Test
    void roundTrip() {
        EntityClass entity = new EntityClass()
            .setId("test1")
            .setName("Test Entity");

        sessionFactory.withSession(session ->
            session.withTransaction(tx ->
                entity.builder(session).persist(entity)
            ).chain(() ->
                new EntityClass().builder(session)
                    .find("test1").get()
            ).invoke(found -> {
                assertNotNull(found);
                assertEquals("test1", found.getId());
            })
        ).replaceWithVoid();
    }
}
```

## Best Practices

- Never use `await().indefinitely()` in service flows; return `Uni` and keep composition with `chain(...)` / `invoke(...)`
- Always run in Vert.x context (event loop or worker)
- Prefer projections for read-heavy paths
- Use `setFirstResults()` / `setMaxResults()` for pagination
- Keep transactions short; chain `Uni` calls
- Bulk `delete()` requires filters — use `truncate()` for all rows
- Use stateless sessions for bulk inserts
- Validate entities before persistence with `validateEntity()`
- **Filter associations with a JOIN in the WHERE clause, not `session.fetch()`.** To *restrict* a result set
  by a related row, add the join/predicate to the builder (`where(...)`, dot-notation path filters, or the
  domain helpers like `withConcept(...)` / `withEnterprise(...)` / `inActiveRange()`). Reserve
  `session.fetch(...)` for *loading* a lazy association you actually need to read — never to filter on the
  heap. The join keeps the predicate in a single SQL statement, avoids materialising unneeded rows, and
  sidesteps lazy-init hazards on the reactive session.

  ```java
  // ✅ Good — predicate pushed into SQL via a join on the WHERE clause
  var qb = new Classification().builder(session);
  return qb.where(qb.getAttribute("concepts.name"), Operand.Equals, conceptName)
           .inActiveRange()
           .getCount();                         // existence check, no rows materialised

  // ❌ Bad — fetch the association then filter in Java
  return entityService.find(session, id)
      .chain(e -> session.fetch(e.getConcepts()))
      .map(concepts -> concepts.stream().anyMatch(...));
  ```
- **Prefer `getCount()` over `get()` + null-check** for existence tests — it avoids selecting and hydrating a
  full entity just to discover whether a row exists.
- **Operate on the caller's `Mutiny.Session`.** Library/builder code must accept and use the session/transaction
  it is handed; never open a nested session (e.g. a second `withSession`/`withTransaction`) inside a method that
  already received one. Nesting sessions on the same Vert.x context triggers `HR000069` (wrong-thread) and
  "Illegal pop()" errors and violates one-action-per-session. Establish the unit of work at the entry point.

## JPMS Module

```java
module com.entityassist {
    requires transitive com.guicedee.persistence;
    requires transitive jakarta.persistence;
    requires transitive org.hibernate.reactive;
    requires transitive io.smallrye.mutiny;

    exports com.entityassist.entities;
    exports com.entityassist.querybuilder;
    exports com.entityassist.enumerations;

    opens com.entityassist.entities to org.hibernate.orm.core, com.google.guice;
}
```

### Required JVM module flags (runtime / jlink)

Hibernate ORM core reflectively reaches into EntityAssist's classes when bootstrapping
the metamodel, but `org.hibernate.orm.core` does not (and must not) statically
`requires com.entityassist`. The reverse read edge therefore has to be added at launch
time. Add this flag to the application launcher (and to any `jlink`
`--add-reads`/launcher options, surefire `argLine`, and IDE run configs):

```
--add-reads
org.hibernate.orm.core=com.entityassist
```

Without it, metamodel/attribute resolution for EntityAssist entities fails at runtime
with an `IllegalAccessError` / `does not read` module error. This edge belongs to
EntityAssist (it is required by *any* application that persists EntityAssist entities),
independent of which downstream domain (e.g. ActivityMaster) is in use.

## Installation

```xml
<dependency>
  <groupId>com.entityassist</groupId>
  <artifactId>entity-assist-reactive</artifactId>
</dependency>
```

## Module Graph

```
com.entityassist
 ├── com.guicedee.persistence
 ├── com.guicedee.client
 ├── jakarta.persistence
 ├── org.hibernate.reactive
 ├── org.hibernate.orm.core
 ├── io.smallrye.mutiny
 ├── io.vertx.sql.client.pg
 └── jakarta.xml.bind
```

## References

- Module: `com.entityassist`
- Hibernate Reactive: 7.x
- Mutiny: 1.x
- Vert.x: 5.x
- Java: 25+
- License: Apache 2.0
