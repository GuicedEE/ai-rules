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
).await().indefinitely();
```

### Find by ID

```java
sessionFactory.withSession(session ->
    new EntityClass()
        .builder(session)
        .find("test1")
        .get()                       // Uni<EntityClass>
).await().indefinitely();
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
        ).await().indefinitely();
    }
}
```

## Best Practices

- Always run in Vert.x context (event loop or worker)
- Prefer projections for read-heavy paths
- Use `setFirstResults()` / `setMaxResults()` for pagination
- Keep transactions short; chain `Uni` calls
- Bulk `delete()` requires filters — use `truncate()` for all rows
- Use stateless sessions for bulk inserts
- Validate entities before persistence with `validateEntity()`

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
