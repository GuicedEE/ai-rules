---
name: entityassist
description: "Build EntityAssist CRTP entities and reactive query DSLs, including CRUD, joins, aggregates, transactions, and stateless sessions."
metadata:
  short-description: Reactive persistence with Hibernate Reactive and Mutiny
---

# EntityAssist Reactive

CRTP-first reactive persistence toolkit for GuicedEE services with Hibernate Reactive 7 and Mutiny.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Entities](references/guide-entities.md): Quick Start; ActiveFlag Lifecycle Enum; Converters.
- [Queries](references/guide-queries.md): Query Builder DSL; Operands.
- [Configuration](references/guide-configuration.md): Configuration; JPMS Module; Installation; Module Graph.
- [Testing](references/guide-testing.md): Testing with Testcontainers.

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

## References

- Module: `com.entityassist`
- Hibernate Reactive: 7.x
- Mutiny: 1.x
- Vert.x: 5.x
- Java: 25+
- License: Apache 2.0
