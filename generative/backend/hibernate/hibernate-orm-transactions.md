# Hibernate ORM 6 — Transactions (Blocking JDBC)

Purpose
- Provide concise, modular guidance for transaction demarcation in classic Hibernate ORM/JPA on synchronous stacks.
- Complements ORM Overview, Setup, and EntityManager/Session docs — see [README.md](rules/generative/backend/hibernate/README.md).

When to use
- Blocking JDBC code paths (thread-per-request).
- JPA EntityManager/EntityTransaction or Hibernate Session/Transaction.
- Application servers or frameworks with JTA/@Transactional support (Jakarta EE, Spring), or standalone resource-local transactions.

Key Concepts (anchor wording)
- Transaction Boundary
  - The unit of atomic work (begin → work → commit/rollback). All changes within must succeed or roll back together.
- Resource-Local vs JTA
  - Resource-Local: App manages EntityTransaction directly (standalone apps).
  - JTA: Container/framework-managed (app servers, Spring); use declarative annotations or programmatic UserTransaction.
- Flush
  - Synchronizes persistence context state with DB within a transaction (auto at commit or explicit via flush()).
- Isolation and Locking
  - Govern visibility and concurrency. Use DB isolation defaults unless stricter levels are required. Use optimistic/pessimistic locks for conflict control.

Demarcation Patterns

Resource-Local (standalone)
```java
// JPA programmatic transaction (resource-local)
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();
try {
  tx.begin();

  Order o = new Order();
  o.setStatus("NEW");
  em.persist(o);

  tx.commit();
} catch (RuntimeException e) {
  if (tx.isActive()) tx.rollback();
  throw e;
} finally {
  em.close();
}
```

Hibernate Session API (native)
```java
try (Session session = sessionFactory.openSession()) {
  Transaction tx = session.beginTransaction();
  try {
    Order o = new Order();
    o.setStatus("NEW");
    session.persist(o);
    tx.commit();
  } catch (RuntimeException e) {
    tx.rollback();
    throw e;
  }
}
```

JTA (Jakarta EE, Spring) — Declarative
```java
// Jakarta EE / Spring (conceptual)
@Transactional // framework-managed
public void createOrder() {
  Order o = new Order();
  o.setStatus("NEW");
  em.persist(o);
}
```

JTA — Programmatic
```java
// Pseudocode for managed envs
@Inject UserTransaction utx;

public void createOrder() throws Exception {
  try {
    utx.begin();
    Order o = new Order();
    em.persist(o);
    utx.commit();
  } catch (Exception e) {
    utx.rollback();
    throw e;
  }
}
```

Propagations (declarative)
- REQUIRED (default): Joins current or creates a new transaction.
- REQUIRES_NEW: Suspends current and starts a new one (use sparingly).
- SUPPORTS/MANDATORY/NEVER: Align with framework semantics; keep consistent across services.

Flush Strategies
- Default auto-flush at commit.
- Explicit flush() to control timing when necessary (e.g., trigger DB constraints before subsequent operations). Use judiciously:
```java
em.persist(order);
em.flush(); // ensure order ID is generated before using it in a subsequent native call
```

Error Handling and Rollback
- Always rollback on failure; ensure try/finally patterns in programmatic demarcation.
- Handle ConstraintViolationException/DataIntegrityViolation exceptions to surface meaningful API errors.
- For checked exceptions in declarative transactions, configure rollback rules as needed (framework-specific).

Isolation & Locking

Optimistic Locking (@Version)
```java
@Entity
public class Account {
  @Id Long id;
  @Version long version; // incremented per update
  BigDecimal balance;
}
```
- Detects lost updates by version mismatch; throw OptimisticLockException to indicate concurrent modifications.

Pessimistic Locking (SELECT FOR UPDATE)
```java
Account a = em.find(Account.class, id, LockModeType.PESSIMISTIC_WRITE);
// perform updates under exclusive lock
```
- Use for critical sections where contention is expected; beware of deadlocks and reduced concurrency.

Transaction Scope Rules (best practices)
- Keep transactions short and focused on DB work.
- Avoid heavy computation, network calls, or blocking I/O inside a transaction.
- Prefer stateless service operations that translate API calls into a clear transaction per use-case.
- Do not hold locks while interacting with external systems (risk of deadlocks/timeouts).

Batch Operations
- For large imports, process in chunks:
  - Begin transaction per chunk, persist entities, flush/clear, commit, repeat.
  - Reduces memory pressure and persistence context growth.

Cross-Boundary Operations
- For messaging and DB changes, consider transactional outbox pattern rather than XA, to ensure reliable delivery without 2PC overhead.

Testing Transactions (Testcontainers)
```java
@Test
void createsOrder() {
  EntityManager em = emf.createEntityManager();
  EntityTransaction tx = em.getTransaction();
  try {
    tx.begin();
    Order o = new Order();
    o.setStatus("NEW");
    em.persist(o);
    tx.commit();

    Order persisted = em.find(Order.class, o.getId());
    assertNotNull(persisted);
  } finally {
    if (tx.isActive()) tx.rollback();
    em.close();
  }
}
```
- In integration tests, prefer rolling back or recreating schema between tests to avoid interference.

Anti-Patterns (summary)
- Long transactions performing non-DB work or remote calls.
- Catching exceptions but forgetting rollback.
- Relying on EAGER fetching leading to huge join trees within a transaction.
- Sharing EntityManager/Session across threads or requests.

LLM Interpretation Guidance
- Choose ORM transactions for blocking stacks. Do not mix with reactive flows.
- Always demarcate: begin → work → commit/rollback. Wrap in try/catch/finally.
- Keep transactions short. Use DTO projections/fetch joins for reads to avoid N+1 and reduce time-in-transaction.
- For concurrency: prefer optimistic locking; use pessimistic locks only when truly needed.
- When asked for “transaction wrapper,” produce a reusable utility with error handling and rollback guarantees.

See Also
- Overview — [hibernate-orm-overview.md](rules/generative/backend/hibernate/hibernate-orm-overview.md)
- Setup — [hibernate-orm-setup.md](rules/generative/backend/hibernate/hibernate-orm-setup.md)
- EntityManager/Session — [hibernate-orm-entitymanager-session.md](rules/generative/backend/hibernate/hibernate-orm-entitymanager-session.md)
- CRUD — [hibernate-orm-crud.md](rules/generative/backend/hibernate/hibernate-orm-crud.md)
- Caching — [hibernate-orm-caching.md](rules/generative/backend/hibernate/hibernate-orm-caching.md)
- Testing — [hibernate-orm-testing.md](rules/generative/backend/hibernate/hibernate-orm-testing.md)
- Anti-Patterns — [hibernate-orm-antipatterns.md](rules/generative/backend/hibernate/hibernate-orm-antipatterns.md)