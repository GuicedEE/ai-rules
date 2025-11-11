# Hibernate ORM 6 — Overview (Blocking JDBC)

Purpose
- Provide a concise, modular overview of classic Hibernate ORM (JPA/Session API) for synchronous, JDBC-based applications.
- Complements Hibernate Reactive docs. Choose exactly one approach per code path: ORM (blocking) or Reactive (non-blocking).

When to use
- Synchronous stacks (e.g., standard Jakarta EE/Spring/GuicedEE blocking flows).
- JDBC drivers, connection pools (HikariCP), and thread-per-request servers.

Related index
- Topic index — [README.md](rules/generative/backend/hibernate/README.md)

Key Concepts (anchor wording)
- EntityManager/Session
  - The per-unit-of-work API that manages entity lifecycle and the persistence context (1st-level cache).
- SessionFactory/EntityManagerFactory
  - Application-wide, heavy object; create once and reuse. Thread-safe.
- Persistence Context (1st-level cache)
  - Tracks managed entities and their identity within a Session/EntityManager scope.
- Transaction (JTA/Resource-Local)
  - Boundaries for atomic changes; required for write operations. JTA in app servers; resource-local for standalone apps.
- Flush
  - Synchronizes in-memory changes with the database within an active transaction.
- Fetch Types: LAZY vs EAGER
  - Default to LAZY; EAGER may cause unexpected joins and N+1 issues.
- N+1 Selects
  - Anti-pattern caused by lazy collection access in loops; fix via fetch joins or batch fetch.

Typical Architecture
- SessionFactory created at application startup.
- Per-request:
  - Open Session/EntityManager
  - Begin transaction
  - Perform CRUD operations
  - Commit/rollback
  - Close Session/EntityManager

Quick Start (JPA-style, resource-local transaction)

```java
// Entity
@Entity
@Table(name = "users")
public class User {
  @Id @GeneratedValue
  private Long id;
  private String name;
  // getters/setters
}
```

```java
// Bootstrap (JPA)
EntityManagerFactory emf = Persistence.createEntityManagerFactory("appPU");

// Per request
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();

try {
  tx.begin();
  User u = new User();
  u.setName("Jane");
  em.persist(u);
  tx.commit();
} catch (RuntimeException e) {
  if (tx.isActive()) tx.rollback();
  throw e;
} finally {
  em.close();
}
```

Session API (native Hibernate)

```java
SessionFactory sf = new Configuration().configure().buildSessionFactory();

try (Session session = sf.openSession()) {
  Transaction tx = session.beginTransaction();
  User u = new User();
  u.setName("Jane");
  session.persist(u);
  tx.commit();
}
```

Fetch and N+1 Avoidance
- Prefer JPQL fetch joins for read-heavy paths:

```java
// Fetch join example
List<Order> orders = em.createQuery(
  "select o from Order o join fetch o.items where o.customer.id = :id",
  Order.class
).setParameter("id", customerId)
 .getResultList();
```

DTO Projections (read-only, faster)
- Avoid loading whole graphs when only a subset of fields is necessary:

```java
record OrderSummary(Long id, String status, BigDecimal total) {}

List<OrderSummary> summaries = em.createQuery(
  "select new com.example.OrderSummary(o.id, o.status, o.total) from Order o",
  OrderSummary.class
).getResultList();
```

Transactions
- Required for writes; optional for pure reads (depends on isolation and consistency needs).
- In GuicedEE/Spring/Jakarta EE, use @Transactional or the equivalent declarative mechanism.

Concurrency and Connection Pooling
- Use a reliable pool (HikariCP) and tune min/max sizes per workload and DB limits.
- Keep transactions short; do not hold connections idle.

Caching
- 1st-level cache (persistence context) is always on per Session/EM.
- 2nd-level cache can be enabled for read-mostly entities; requires careful invalidation strategy.

Validation and Lifecycle
- Bean Validation (Jakarta Validation) integrates with persist/merge.
- Entity lifecycle callbacks (e.g., @PrePersist, @PostLoad) for cross-cutting behavior.

Testing (high-level)
- Use Testcontainers for DB parity.
- Boot a SessionFactory/EMF once per suite; clean schemas between tests.
- Prefer transactional tests rolling back on completion to isolate state.

Anti-Patterns (summary)
- Long transactions holding connections while doing non-DB work.
- EAGER fetching across the board; unbounded graphs.
- Shared EntityManager/Session across threads; EM/Session is not thread-safe.
- LazyInitializationException from using detached lazy proxies outside a transaction.

LLM Interpretation Guidance
- Choose ORM docs for synchronous JDBC stacks. Do not mix reactive code paths with ORM transactions.
- Use DTO projections and fetch joins to avoid N+1. Keep transactions short and explicit.
- Avoid leaking EM/Session beyond method/class boundaries; inject factories and open per-use scopes.

See Also
- Setup — [hibernate-orm-setup.md](rules/generative/backend/hibernate/hibernate-orm-setup.md)
- Transactions — [hibernate-orm-transactions.md](rules/generative/backend/hibernate/hibernate-orm-transactions.md)
- CRUD — [hibernate-orm-crud.md](rules/generative/backend/hibernate/hibernate-orm-crud.md)
- Caching — [hibernate-orm-caching.md](rules/generative/backend/hibernate/hibernate-orm-caching.md)
- Testing — [hibernate-orm-testing.md](rules/generative/backend/hibernate/hibernate-orm-testing.md)
- Anti-Patterns — [hibernate-orm-antipatterns.md](rules/generative/backend/hibernate/hibernate-orm-antipatterns.md)