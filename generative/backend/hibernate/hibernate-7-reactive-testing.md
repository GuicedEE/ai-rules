# Hibernate 7 Reactive — Testing (Testcontainers) (Modular Overview)

Use this entry when prompts reference integration tests, Testcontainers, and bootstrapping a reactive SessionFactory in tests.

## Quick start (PostgreSQL)
```java
import org.testcontainers.containers.PostgreSQLContainer;
import org.hibernate.reactive.mutiny.Mutiny;
import jakarta.persistence.Persistence;

PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");
pg.start();

System.setProperty("jakarta.persistence.jdbc.url", pg.getJdbcUrl());
System.setProperty("jakarta.persistence.jdbc.user", pg.getUsername());
System.setProperty("jakarta.persistence.jdbc.password", pg.getPassword());

Mutiny.SessionFactory sf = Persistence
  .createEntityManagerFactory("test-unit")
  .unwrap(Mutiny.SessionFactory.class);
```

## Patterns and guidance
- Prefer real DB engines (Postgres/MySQL) instead of H2 for behavioral fidelity.
- Use `sf.withTransaction(...)` in test setup/teardown; avoid manual begin/commit.
- Avoid blocking; if you must await, limit to test edges (e.g., `Uni.await().indefinitely()` in assertions).
- Clean up: `pg.stop()` and dispose of SessionFactory on suite shutdown.

## See also
- Setup & Configuration — ./hibernate-7-reactive-setup.md
- Transactions — ./hibernate-7-reactive-transactions.md
- Topic Index — ./README.md
