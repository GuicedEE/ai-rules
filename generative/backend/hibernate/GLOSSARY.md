# Hibernate Reactive Glossary (Topic-first)

Purpose
- Topic-first glossary for Hibernate 7 Reactive usage in JVM projects.
- Precedence: this glossary overrides the root glossary for the Hibernate topic and minimizes duplication by linking to modular rules in this directory.
- Audience: developers and AI systems generating or reviewing code and docs that use Hibernate Reactive with Mutiny APIs.

Scope
- Focuses on Hibernate 7 Reactive (Mutiny API) for relational databases.
- Assumes non-blocking/reactive application stacks (e.g., Vert.x 5, GuicedEE reactive functions).
- Coordinates with JPMS, Testcontainers, and repository-specific policies.

Version and Routing
- Primary references live in:
  - [hibernate-7-reactive-overview.md](rules/generative/backend/hibernate/hibernate-7-reactive-overview.md)
  - [hibernate-7-reactive-setup.md](rules/generative/backend/hibernate/hibernate-7-reactive-setup.md)
  - [hibernate-7-reactive-session-factory.md](rules/generative/backend/hibernate/hibernate-7-reactive-session-factory.md)
  - [hibernate-7-reactive-transactions.md](rules/generative/backend/hibernate/hibernate-7-reactive-transactions.md)
  - [hibernate-7-reactive-crud.md](rules/generative/backend/hibernate/hibernate-7-reactive-crud.md)
  - [hibernate-7-reactive-threading.md](rules/generative/backend/hibernate/hibernate-7-reactive-threading.md)
  - [hibernate-7-reactive-testing.md](rules/generative/backend/hibernate/hibernate-7-reactive-testing.md)
  - [hibernate-7-reactive-antipatterns.md](rules/generative/backend/hibernate/hibernate-7-reactive-antipatterns.md)
  - [hibernate-7-reactive-upgrade.md](rules/generative/backend/hibernate/hibernate-7-reactive-upgrade.md)
  - Index: [README.md](rules/generative/backend/hibernate/README.md)

Precedence and Policy
- Topic-first precedence: this glossary governs Hibernate terms and expectations for its scope and supersedes generic language or persistence glossaries.
- JPMS posture and PostgreSQL driver policy: prefer GuicedEE Services artifacts and do not shade the driver in host projects (see details in repository rules and backend services policies).

Core Concepts (anchor wording)
- Reactive Persistence Context
  - A non-blocking variant of the persistence context. It maintains entity identity and tracks changes within the scope of a reactive session, deferring writes to flush/transaction boundaries.
- SessionFactory (Reactive)
  - A singleton, lazily-created factory for reactive sessions. Must be configured once per application; thread-safe; should be lifecycle-managed by the DI container or app bootstrap.
- Reactive Session
  - A lightweight, non-thread-safe unit that tracks entities during operations. Do not share across threads or requests. Obtain within a reactive flow and keep lifetime minimal.
- Transaction (Reactive)
  - Non-blocking unit of work that ensures atomicity. Use framework-provided helpers to wrap operations; on failure, automatic rollback is expected.
- Mutiny Uni
  - A lazy, single-result reactive type. Compose chains for DB interactions without blocking; subscribe or await only in test harnesses with explicit timeouts.
- Mutiny Multi
  - A lazy, multi-result reactive type for streaming results. Use cautiously for large data sets; apply operators to bound memory.
- Flush
  - Synchronizes in-memory entity changes with the database within the current transaction. In reactive, flush is non-blocking and occurs explicitly or at defined points by the framework.
- Dirty Checking
  - Hibernate detects entity state changes automatically and computes SQL updates. In reactive, semantics are analogous but non-blocking; avoid mutating detached objects unpredictably.
- Fetch Strategy: Lazy vs Eager
  - Lazy: defers loading associations; Eager: loads associations immediately. Reactive design favors explicit fetch joins or structured queries to avoid N+1 and unpredictable IO.
- N+1 Selects
  - Anti-pattern where loading a collection triggers one query per element. Prevent with explicit fetch joins, batch fetching, or DTO projections.
- DTO Projection
  - Selecting custom row shapes (not entities) for read-only flows; avoids entity tracking overhead and often reduces queries.
- Connection Pool (Reactive)
  - The underlying pool for non-blocking connections; must be tuned for event-loop concurrency. Ensure pool sizing aligns with the number of concurrent reactive operations without blocking.
- Backpressure (Concept)
  - The strategy to handle fast producers and slow consumers. While Mutiny supports it at an operator level, design endpoints to bound data (paging/limits) to avoid memory pressure.

Design Principles
- Non-Blocking Semantics
  - Never invoke blocking APIs in reactive flows (e.g., do not call future.get(), Thread.sleep()). All database IO must flow through reactive APIs and composition.
- Composition over Awaiting
  - Compose Uni chains instead of awaiting results in production code. Only tests may await with timeouts for convenience.
- Transaction Boundaries
  - Wrap related operations in a single, explicit reactive transaction. Define clear begin → operations → commit/rollback paths; manage resources deterministically.
- Deterministic Sessions
  - Keep sessions short-lived and tied to a flow. Do not cache or reuse across unrelated requests or threads.
- Explicit Fetching
  - Avoid accidental eager cascades. Use fetch joins or projections intentionally; prefer reads that match UI/API use cases.

Testing Principles
- Containers over In-Memory
  - Prefer Testcontainers for relational DBs. Avoid H2 for reactive behavior parity.
- Reactive Test Patterns
  - Keep tests non-blocking; if awaiting, limit to the test harness and set explicit timeouts. Use transaction helpers for setup/teardown data.
- Deterministic Data
  - Seed fixtures through migrations or seed scripts. Isolate per-test schemas/containers as needed to avoid cross-test interference.

Anti-Patterns (summary)
- Blocking calls in reactive flows (future.get(), sleep, JDBC usage in reactive code paths).
- Sharing a reactive Session across threads or requests.
- Implicit lazy loads in latency-sensitive paths causing unexpected N+1.
- Mixed blocking and non-blocking DB clients in the same transaction flow.
- Relying on detached entities with side effects instead of clear read→modify→write flows.

LLM Interpretation Guidance
- When generating Hibernate Reactive code:
  - Use Uni chains for CRUD and compose operations within explicit transactions.
  - Keep session lifetime scoped to the reactive flow; no static singletons of sessions.
  - Favor explicit fetch plans or DTO projections to avoid N+1 queries.
  - Do not use blocking constructs; if an external API forces blocking, isolate it in executeBlocking-style helpers outside the reactive DB path (and document the trade-offs).
- When writing tests:
  - Prefer Testcontainers; avoid H2. Seed via migrations or scripts. Await only in tests with clear timeouts.
- When documenting:
  - Route to the modular files listed above; do not duplicate definitions from this glossary; link to the relevant rule page and keep glossary terms consistent with anchors here.

Performance and Concurrency Guidelines
- Pool Sizing
  - Size reactive connection pools based on expected concurrent operations. Avoid saturating event loops with excessive synchronous work.
- Batching and Streaming
  - Use Multi for controlled streaming; bound result sets via pagination and use database-side limits to avoid application memory growth.
- Caching
  - Evaluate reactive-compatible caching strategies; ensure that caches do not introduce blocking calls into reactive paths.

JPMS and Dependencies
- Module Design
  - Export only necessary packages; keep internals encapsulated. Prefer test-time opens (e.g., surefire argLine) instead of weakening production module-info.
- PostgreSQL Driver Policy
  - In JPMS contexts, prefer the enterprise services distribution and declare explicit requires entries in module descriptors. Avoid shaded drivers in host projects.

Observability
- Correlation
  - Propagate request identifiers through reactive chains. Ensure logs include correlation IDs across DB calls.
- Metrics
  - Record latencies, error rates, and pool utilization. Alert on timeouts and slow queries.

Migration & Upgrade Notes
- See:
  - [hibernate-7-reactive-upgrade.md](rules/generative/backend/hibernate/hibernate-7-reactive-upgrade.md)

Frequently Used Patterns (brief)
- Create/Update
  - Build entity in-memory, start transaction, persist/merge within one reactive session, and commit. For updates, load entity or projection then apply changes in a safe path.
- Read
  - Use explicit queries with projections for read-heavy paths; avoid accidental loading of large graphs.
- Transactions
  - Use helper methods to enforce transaction boundaries and handle rollback on failures consistently.

Related Topics
- Vert.x 5 reactive client usage and event loop rules (see repository’s Vert.x rules and reactive transaction patterns).
- Mapping libraries for DTO transformations (e.g., MapStruct) to isolate entity models from API payloads.

Anchor Terms (canonical)
- Reactive Persistence Context, SessionFactory (Reactive), Reactive Session, Reactive Transaction, Mutiny Uni, Mutiny Multi, Flush, Dirty Checking, Lazy/Eager Fetch, Fetch Join, N+1 Selects, DTO Projection, Connection Pool (Reactive), Backpressure, Testcontainers (Reactive), Non-Blocking Semantics, Composition over Awaiting, Deterministic Sessions.

Compliance
- Follow the modular rules linked above for implementations.
- Respect this glossary’s precedence for terminology.
- Document any deviations in project RULES.md with rationale and links to the superseded sections.
