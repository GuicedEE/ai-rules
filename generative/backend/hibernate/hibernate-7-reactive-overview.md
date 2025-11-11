# Hibernate 7 Reactive (Modular Overview)

Start here for a high-level understanding of using Hibernate Reactive 7.x with Mutiny and Vert.x 5. This document is optimized for generative AI: quick starts, patterns, and links.

## When to use
- You need non-blocking persistence in a Vert.x-based application.
- You use Mutiny’s Uni/Multi types with Hibernate Reactive 7.x.
- You want JPMS-friendly setup without Spring/Quarkus.

## Key points
- Manage a singleton Mutiny.SessionFactory.
- Use withSession/withTransaction helpers; avoid manual transaction juggling.
- Chain operations using Uni; never block on futures in the reactive path.

## Minimal bootstrap
```java
import org.hibernate.reactive.mutiny.Mutiny;
import jakarta.persistence.Persistence;

Mutiny.SessionFactory sessionFactory = Persistence
  .createEntityManagerFactory("my-unit")
  .unwrap(Mutiny.SessionFactory.class);
```

## Typical patterns
- Create: `sf.withTransaction((s, tx) -> s.persist(entity))`
- Read: `sf.withSession(s -> s.find(MyEntity.class, id))`
- Update: `sf.withTransaction((s, tx) -> s.merge(entity))`
- Delete: `sf.withTransaction((s, tx) -> s.remove(entity))`

## See also
- Setup & Configuration — ./hibernate-7-reactive-setup.md
- SessionFactory — ./hibernate-7-reactive-session-factory.md
- Transactions — ./hibernate-7-reactive-transactions.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Testing (Testcontainers) — ./hibernate-7-reactive-testing.md
- Threading & Context — ./hibernate-7-reactive-threading.md
- Anti-Patterns — ./hibernate-7-reactive-antipatterns.md
- Topic Index — ./README.md
- Rules — ../../RULES.md#document-modularity-policy
