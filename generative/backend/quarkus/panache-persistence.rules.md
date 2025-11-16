# Quarkus Persistence (Hibernate ORM / Panache) Rules

Purpose
- Provide standardized persistence guidance for Quarkus services using Hibernate ORM with Panache.

## ORM setup
- Use `quarkus-hibernate-orm-panache` for active record style or `quarkus-hibernate-orm` + repositories for repository style; pick one per module.
- Configure datasource via `%prod.quarkus.datasource.jdbc.url=${JDBC_URL}` and `%test`/`%dev` overrides (Dev Services or Testcontainers).
- Enable Flyway or Liquibase for schema control; disable `quarkus.hibernate-orm.database.generation` outside dev.

## Entity design
- Prefer records or immutable DTOs at API boundary; keep entities package-private.
- Use Panache repositories:
```java
@ApplicationScoped
public class OrderRepository implements PanacheRepository<OrderEntity> {
  public Uni<List<OrderEntity>> findPending() {
    return list("status","PENDING");
  }
}
```
- When using Kotlin, prefer Panache Kotlin extension `PanacheRepositoryBase`.

## Transactions & reactive
- For reactive persistence, use `quarkus-hibernate-reactive-panache` + Mutiny `Uni`/`Multi`.
- Annotate service methods with `@Transactional` (imperative) or `@WithTransaction` (reactive) and avoid mixing blocking/non-blocking APIs.

## Testing persistence
- Use Dev Services or Testcontainers for `%test` profile; never rely on H2 for Postgres/MySQL behavior.
- Reset schema per test class when data coupling exists; document in Harness README.

## Observability
- Enable SQL logging only in `%dev` via `quarkus.hibernate-orm.log.sql=true`.
- Export metrics: `quarkus.datasource.metrics.enabled=true` and use Micrometer exporters.

## See also
- Topic index — ./README.md
- Reactive messaging rules — ./reactive-messaging.rules.md (if using outbox/eventing)
- Testing — ./testing.rules.md
- Data topic (database/) for cross-cutting DB policies
