# EntityAssist Reactive BDD (Topic Supplement)

Purpose
- Extend [BDD Architecture](rules/generative/architecture/bdd/README.md) for teams consuming the EntityAssist Reactive library.
- Ensure scenarios describe observable behaviors (Mutiny flows, QueryBuilder contracts, database interactions) without diving into implementation detail.

## Scenario Guidelines

| Aspect | Guidance |
| --- | --- |
| Actors | Service developer, GuicedEE runtime, DatabaseModule, PostgreSQL (or chosen driver). |
| Preconditions | JPMS module configured (`requires transitive com.entityassist`), DatabaseModule registered, `.env` toggles applied, Testcontainers or managed DB available. |
| Triggers | Entity creation/update/delete, query builder filters, transaction boundary, failure cases (exceptions, validation). |
| Outcomes | `Uni` completes successfully, emits expected entity data, or propagates domain/DB errors with no `null` results. |

## Scenario Templates

**Persist Flow**
```
Scenario: Persisting a valid CRTP entity
  Given a DatabaseModule is registered for tenant "alpha"
    And a RootEntity-derived object with required fields populated
  When the service calls entity.builder(MutinySession).persist()
  Then the builder should emit a Uni that completes successfully
    And the entity should no longer be marked fake
    And the entity should be retrievable via a query builder filter
```

**JPMS Guard**
```
Scenario: Missing JPMS add-reads flag
  Given a service module omits "--add-reads org.hibernate.orm.core=my.service.module"
  When Hibernate Reactive tries to access entities at runtime
  Then the Uni should emit a failure with IllegalAccessException
    And documentation should instruct to add the required compiler and surefire flags
```

**Transaction Failure**
```
Scenario: Transaction rollback when constraint fails
  Given a builder inside session.withTransaction
  When persist() violates a unique constraint
  Then the Uni should fail with a constraint error
    And the transaction should rollback without leaving partial data
```

## Practises
- Capture Given/When/Then in markdown tables or Gherkin; reference the architectural diagrams maintained for your project while ensuring the rules here stay the canonical source.
- Treat `.env.example` toggles and DatabaseModule overrides as “Given” preconditions; avoid referencing secret values explicitly.
- When scenarios evolve, update this topic (and related rules under `generative/data/entityassist/`) using forward-only edits so downstream teams inherit the same acceptance criteria.

## Query Builder Guidance
- Reference the query-builder flows exercised in the tests (see the TDD topic) when writing BDD scenarios. Focus on the fluent CRTP syntax: `builder().where(...).join(...).select()`. Scenarios should describe the observable outcomes (filter results, pagination, cache usage) rather than internal criteria structures.
- Example narrative snippets you can adapt into Given/When/Then:
  - *Given* a builder composed with `.where("tenantId", "alpha")` and `.orderByAsc("createdOn")`, *When* the query executes, *Then* the resulting `Uni<List<Entity>>` contains entities for tenant alpha sorted ascending by `createdOn`.
  - *Given* a builder using `.join("addresses").where("addresses.country", "ZA")`, *When* fetching results, *Then* only entities with an address in South Africa are returned.
- Ensure the narrative highlights that builders return `Uni` results and propagate Hibernate errors; acceptance tests should assert both success and error cases.

## References
- [EntityAssist Reactive Rules](./entity-assist-reactive-rules.md)
- [Glossary](./GLOSSARY.md)
- Related enterprise topics: `rules/generative/architecture/bdd/README.md`, `rules/generative/backend/vertx/README.md`, `rules/generative/backend/hibernate/README.md`.
