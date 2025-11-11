# Hibernate ORM 6 — CRUD Patterns (Blocking JDBC)

Purpose
- Concise, modular guidance for common create/read/update/delete patterns using classic Hibernate ORM/JPA on synchronous stacks.
- Complements ORM Overview, Setup, EntityManager/Session, and Transactions — see [README.md](rules/generative/backend/hibernate/README.md).

When to use
- JDBC-based, thread-per-request applications using JPA EntityManager or Hibernate Session.
- Do not mix with Hibernate Reactive in the same code path.

Create (persist)
```java
// JPA
User u = new User();
u.setName("Jane");
em.persist(u); // becomes managed (1st-level cache), id assigned on flush/commit
```

Read (find/projection)
```java
// Find by id
User u = em.find(User.class, id); // returns null if not found

// JPQL
List<User> active = em.createQuery(
  "select u from User u where u.active = true", User.class
).getResultList();

// DTO projection (read-only)
record UserRow(Long id, String name) {}
List<UserRow> rows = em.createQuery(
  "select new com.example.UserRow(u.id, u.name) from User u", UserRow.class
).getResultList();
```

Update (managed vs detached)
```java
// Managed (within EM/Session scope)
User u = em.find(User.class, id);
u.setName("Updated"); // dirty-checking on flush/commit

// Detached -> merge
User detached = // from previous context
User managed = em.merge(detached); // returns managed copy tracked by persistence context
```

Delete (remove)
```java
User u = em.find(User.class, id);
if (u != null) em.remove(u);
```

Queries and Pagination
```java
List<Order> page = em.createQuery(
  "select o from Order o where o.status = :s order by o.created desc",
  Order.class
).setParameter("s", "NEW")
 .setFirstResult(0)
 .setMaxResults(50)
 .getResultList();
```

Fetch Strategies and N+1 Avoidance
- Prefer LAZY on associations. Use fetch joins when you need graphs:
```java
// Fetch join to avoid N+1
List<Order> orders = em.createQuery(
  "select o from Order o join fetch o.items where o.customer.id = :id",
  Order.class
).setParameter("id", customerId)
 .getResultList();
```
- For read-only payloads, prefer DTO projections to skip loading full aggregates.

Batch Inserts/Updates
- Use chunked transactions and periodic flush/clear for large imports:
```java
for (int i = 0; i < items.size(); i++) {
  em.persist(items.get(i));
  if (i % 100 == 0) {
    em.flush();
    em.clear();
  }
}
```

Optimistic Locking (@Version)
```java
@Entity
class Account {
  @Id Long id;
  @Version long version;
  BigDecimal balance;
}
```
- Detects lost updates on commit; handle OptimisticLockException with retries where appropriate.

Pessimistic Locking (with care)
```java
Order o = em.find(Order.class, id, LockModeType.PESSIMISTIC_WRITE);
// update under DB lock; beware of deadlocks/timeouts
```

Native SQL and Stored Procedures
- Use carefully; prefer JPQL for portability and entity mapping consistency.
```java
List<Object[]> rows = em.createNativeQuery("select id, name from users where active = true").getResultList();
```

Read-only Transactions and Hints
- For read-heavy queries, mark transactions as read-only (framework-level hint) and prefer projections.

Validation
- Jakarta Validation runs on persist/merge when a provider is present; surface violations at API boundaries.

Anti-Patterns (summary)
- Loading entire graphs unintentionally (EAGER everywhere).
- Long-lived persistence contexts that grow without clear/flush.
- Business logic mutating detached entities unpredictably outside transactions.

LLM Interpretation Guidance
- Choose ORM CRUD for blocking stacks; keep transactions short and scoped to DB work.
- Prefer projections and fetch joins to reduce memory and avoid N+1.
- Use @Version for concurrency; lock pessimistically only when necessary.

See Also
- Overview — [hibernate-orm-overview.md](rules/generative/backend/hibernate/hibernate-orm-overview.md)
- Setup — [hibernate-orm-setup.md](rules/generative/backend/hibernate/hibernate-orm-setup.md)
- EntityManager/Session — [hibernate-orm-entitymanager-session.md](rules/generative/backend/hibernate/hibernate-orm-entitymanager-session.md)
- Transactions — [hibernate-orm-transactions.md](rules/generative/backend/hibernate/hibernate-orm-transactions.md)
- Caching — [hibernate-orm-caching.md](rules/generative/backend/hibernate/hibernate-orm-caching.md)
- Testing — [hibernate-orm-testing.md](rules/generative/backend/hibernate/hibernate-orm-testing.md)
- Anti-Patterns — [hibernate-orm-antipatterns.md](rules/generative/backend/hibernate/hibernate-orm-antipatterns.md)