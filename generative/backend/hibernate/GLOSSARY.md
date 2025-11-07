# Hibernate Glossary (ORM and Reactive, Topic-first)

Purpose
- Topic-first glossary for Hibernate across classic ORM (blocking JDBC) and Hibernate 7 Reactive (Mutiny/Vert.x).
- Precedence: within the Hibernate topic, this glossary overrides root terms. Per-approach modular docs (ORM vs Reactive) provide specifics; choose exactly one approach per code path.
- Audience: developers and AI systems generating or reviewing persistence logic and documentation.

Routing (index and modules)
- Topic index — [README.md](rules/generative/backend/hibernate/README.md)
- ORM (blocking):
  - Overview — [hibernate-orm-overview.md](rules/generative/backend/hibernate/hibernate-orm-overview.md)
  - Setup — [hibernate-orm-setup.md](rules/generative/backend/hibernate/hibernate-orm-setup.md)
  - EntityManager/Session & SessionFactory — [hibernate-orm-entitymanager-session.md](rules/generative/backend/hibernate/hibernate-orm-entitymanager-session.md)
  - Transactions — [hibernate-orm-transactions.md](rules/generative/backend/hibernate/hibernate-orm-transactions.md)
  - CRUD — [hibernate-orm-crud.md](rules/generative/backend/hibernate/hibernate-orm-crud.md)
  - Caching — hibernate-orm-caching.md (if present)
  - Testing — hibernate-orm-testing.md (if present)
  - Anti-Patterns — hibernate-orm-antipatterns.md (if present)
  - Upgrade — hibernate-orm-upgrade.md (if present)
- Reactive (non-blocking):
  - Overview — [hibernate-7-reactive-overview.md](rules/generative/backend/hibernate/hibernate-7-reactive-overview.md)
  - Setup — [hibernate-7-reactive-setup.md](rules/generative/backend/hibernate/hibernate-7-reactive-setup.md)
  - SessionFactory — [hibernate-7-reactive-session-factory.md](rules/generative/backend/hibernate/hibernate-7-reactive-session-factory.md)
  - Transactions — [hibernate-7-reactive-transactions.md](rules/generative/backend/hibernate/hibernate-7-reactive-transactions.md)
  - CRUD — [hibernate-7-reactive-crud.md](rules/generative/backend/hibernate/hibernate-7-reactive-crud.md)
  - Threading — [hibernate-7-reactive-threading.md](rules/generative/backend/hibernate/hibernate-7-reactive-threading.md)
  - Testing — [hibernate-7-reactive-testing.md](rules/generative/backend/hibernate/hibernate-7-reactive-testing.md)
  - Anti-Patterns — [hibernate-7-reactive-antipatterns.md](rules/generative/backend/hibernate/hibernate-7-reactive-antipatterns.md)
  - Upgrade — [hibernate-7-reactive-upgrade.md](rules/generative/backend/hibernate/hibernate-7-reactive-upgrade.md)

Policy and Precedence
- Choose ORM for blocking, JDBC-based stacks (thread-per-request) and Reactive for non-blocking stacks (event-loop based). Do not mix both in the same transaction path.
- JPMS posture and PostgreSQL driver policy: prefer GuicedEE Services artifacts for JPMS; do not shade drivers in host projects.

Core Concepts (anchor wording)
- Persistence Context (1st-level cache)
  - Tracks managed entities and identity within a Session/EntityManager (ORM) or Reactive Session. Scope is per unit-of-work; not thread-safe.
- Session / EntityManager
  - Per-unit-of-work API (Hibernate Session or JPA EntityManager). Open per request/use-case, close deterministically. Not thread-safe.
- SessionFactory / EntityManagerFactory
  - Application-wide factory (thread-safe). Create once and reuse; dispose on shutdown.
- Transaction
  - ORM (blocking): JTA or resource-local; begin → work → commit/rollback. Reactive: non-blocking, compose within Uni chains.
- Flush
  - Synchronizes in-memory changes with the DB in an active transaction (auto at commit; explicit when needed).
- Fetch Strategy (Lazy/Eager), Fetch Join, N+1
  - Default to LAZY; use explicit fetch joins or DTO projections to avoid N+1 and excessive joins.
- DTO Projection
  - Read-only result mapping for API payloads; reduces loading full aggregates and improves performance.
- Connection Pool
  - ORM: JDBC pool (e.g., HikariCP) sized for workload. Reactive: non-blocking pool tuned for event-loop concurrency.
- Concurrency Control
  - Prefer optimistic locking via @Version; use pessimistic locks sparingly for hot rows/critical sections.
- Backpressure (Reactive)
  - Bound streaming with pagination/limits; avoid unbounded Multi.

Design Principles
- ORM (blocking): Keep transactions short; avoid long-running, non-DB work inside transactions; prefer projections and fetch joins; avoid global/shared EM/Session.
- Reactive (non-blocking): No blocking calls in reactive flows; compose Uni chains; short-lived sessions; explicit transaction helpers; explicit fetching.

Testing Principles
- Use Testcontainers for DB parity; avoid H2 for reactive behavior tests.
- ORM: transactional tests with rollback or schema cleanup. Reactive: await only in tests with explicit timeouts; non-blocking patterns in harness.

Anti-Patterns (summary)
- ORM: EAGER everywhere, long transactions, shared EM/Session across threads, relying on hbm2ddl.auto in prod.
- Reactive: Blocking calls (future.get/sleep/JDBC), sharing reactive Session across requests, implicit lazy loads in latency-sensitive paths, mixing blocking and non-blocking DB clients in the same flow.

LLM Interpretation Guidance
- When asked to implement persistence:
  - Decide ORM vs Reactive based on stack; route to the corresponding modular docs.
  - For ORM: show EM/Session lifecycle per unit-of-work; explicit transactions; DTOs/fetch joins for reads.
  - For Reactive: use Uni composition; explicit reactive transactions; no blocking; explicit fetch plans/projections.
- When generating tests:
  - Prefer Testcontainers; seed deterministically (migrations/fixtures). Await only in tests (reactive) with timeouts.

Observability
- Correlation IDs across DB calls; metrics for latency, errors, and pool utilization; alerts for timeouts/slow queries.

Anchor Terms (canonical)
- Persistence Context, EntityManager/Session, EntityManagerFactory/SessionFactory, Transaction (JTA/Resource-Local/Reactive), Flush, Lazy/Eager Fetch, Fetch Join, N+1 Selects, DTO Projection, Connection Pool, Optimistic/Pessimistic Locking, Backpressure (Reactive), Testcontainers.

Compliance
- Follow modular rules linked above. Document deviations in host RULES.md with rationale and links.
