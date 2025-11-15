# Hibernate ORM 6 — EntityManager/Session & SessionFactory

Purpose
- Define the per-unit-of-work APIs (EntityManager/Session) and the application-wide factories (EntityManagerFactory/SessionFactory) for synchronous JDBC stacks.
- Complements the ORM Overview and Setup entries — see [README.md](rules/generative/backend/hibernate/README.md).

When to use
- Classic, blocking ORM usage (JPA or native Hibernate) with JDBC drivers and a connection pool.
- Do not mix with Hibernate Reactive in the same code path.

Key Concepts (anchor wording)
- EntityManager (JPA) / Session (Hibernate)
  - Per-unit-of-work context that manages the persistence context (1st-level cache).
  - Not thread-safe. Open per request or per use-case, then close deterministically.
- EntityManagerFactory (JPA) / SessionFactory (Hibernate)
  - Heavy, application-wide factory. Thread-safe. Create once and reuse.
  - Configure at app startup; dispose on shutdown.
- Persistence Context (1st-level cache)
  - Scoped to EM/Session; ensures object identity and tracks changes.
- Flush
  - Synchronizes in-memory changes with the database within an active transaction.
  - Happens at commit or when explicitly requested.

Lifecycle Patterns

Per-request (typical blocking server)
```java
// JPA
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();
try {
  tx.begin();
  // work
  tx.commit();
} catch (RuntimeException e) {
  if (tx.isActive()) tx.rollback();
  throw e;
} finally {
  em.close();
}
```

Per-use-case (service method)
```java
// Hibernate native Session
try (Session session = sessionFactory.openSession()) {
  Transaction tx = session.beginTransaction();
  // work
  tx.commit();
}
```

Obtaining Factories

JPA EntityManagerFactory
```java
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

EntityManagerFactory emf = Persistence.createEntityManagerFactory("appPU"); // from persistence.xml
```

Hibernate SessionFactory
```java
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

Configuration cfg = new Configuration().configure(); // hibernate.cfg.xml
SessionFactory sessionFactory = cfg.buildSessionFactory();
```

Working with Entities

Persist (new entity)
```java
User u = new User();
u.setName("Jane");
em.persist(u); // managed in persistence context
```

Find/Load (existing entity)
```java
User u = em.find(User.class, id);     // returns null if not found
User proxy = em.getReference(User.class, id); // lazy proxy; may throw on access if not found
```

Merge (detached → managed)
```java
User detached = // from previous context
User managed = em.merge(detached);
```

Remove (delete)
```java
User u = em.find(User.class, id);
if (u != null) em.remove(u);
```

Queries and Projections

Typed Query (JPQL)
```java
List<User> users = em.createQuery("select u from User u where u.active = true", User.class)
                     .getResultList();
```

DTO Projection (read-only)
```java
record UserRow(Long id, String name) {}
List<UserRow> rows = em.createQuery(
  "select new com.example.UserRow(u.id, u.name) from User u",
  UserRow.class
).getResultList();
```

Fetch Strategies and N+1

Prefer fetch joins for read-heavy graphs
```java
List<Order> orders = em.createQuery(
  "select o from Order o join fetch o.items where o.customer.id = :id",
  Order.class
).setParameter("id", customerId)
 .getResultList();
```

Avoid N+1 (lazy collection in loops)
- Use fetch joins or batch fetch (Hibernate-specific config) to minimize round trips.

Transactions

Resource-local (standalone)
```java
EntityTransaction tx = em.getTransaction();
tx.begin();
// work
tx.commit();
```

JTA (managed, e.g., Jakarta EE/Spring)
- Use @Transactional or container-managed transactions; the framework opens/closes EM and demarcates transactions.

Flush Behavior
- Auto-flush at commit; can call `em.flush()` for precise control (use sparingly).
- Be mindful of persistence context size; clear when necessary for large, staged operations.

Caching

1st-level cache (persistence context)
- Always on, per EM/Session. Ensures identity and tracks changes.

2nd-level cache (optional)
- Enable intentionally for read-mostly entities. Require cache provider and invalidation strategy.
- Cache only coherent, low-churn aggregates and reference data.

Best Practices
- Use DTO projections for read-only API payloads to avoid loading whole graphs.
- Keep transactions short and scoped to DB work; do not hold connections idle.
- Avoid EAGER on large associations; prefer LAZY + fetch joins or dedicated queries.
- Do not leak EntityManager/Session across threads or store it statically.
- Validate entities via Jakarta Validation; handle violations at API/service boundaries.

Anti-Patterns (summary)
- Long transactions spanning non-DB operations.
- Global/shared EntityManager/Session (not thread-safe).
- Overuse of EAGER fetching creating unbounded joins.
- Reliance on hbm2ddl.auto=create/update in production (prefer migrations).

LLM Interpretation Guidance
- Choose this ORM document for blocking stacks. Do not combine with Reactive flows.
- Maintain per-unit-of-work EM/Session lifecycles; inject factories and open per-use scopes.
- For performance, prefer fetch joins and projections; keep transactions short.

See Also
- Overview — [hibernate-orm-overview.md](rules/generative/backend/hibernate/hibernate-orm-overview.md)
- Setup — [hibernate-orm-setup.md](rules/generative/backend/hibernate/hibernate-orm-setup.md)
- Transactions — [hibernate-orm-transactions.md](rules/generative/backend/hibernate/hibernate-orm-transactions.md)
- CRUD — [hibernate-orm-crud.md](rules/generative/backend/hibernate/hibernate-orm-crud.md)
- Caching — [hibernate-orm-caching.md](rules/generative/backend/hibernate/hibernate-orm-caching.md)
- Testing — [hibernate-orm-testing.md](rules/generative/backend/hibernate/hibernate-orm-testing.md)
- Anti-Patterns — [hibernate-orm-antipatterns.md](rules/generative/backend/hibernate/hibernate-orm-antipatterns.md)