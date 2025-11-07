# Hibernate Topic Index (ORM and Reactive)

This directory contains standards and guides for both classic Hibernate ORM (blocking) and Hibernate Reactive 7.x (Mutiny + Vert.x 5). Use this index to navigate to the appropriate modular documents. Choose ORM when your project uses EntityManager/Session with blocking JDBC; choose Reactive when your stack is non-blocking and references Mutiny Session/SessionFactory and Uni/Multi composition.

Conventions
- Topic-first, modular files optimized for AI reading.
- ORM and Reactive documents are separate; pick exactly one approach per code path.
- JPMS-aware guidance and Testcontainers-based testing are provided where applicable.

---

## Hibernate ORM 6 Topic Index (Blocking)

Start here for traditional JPA/Hibernate usage backed by JDBC. Applies to synchronous stacks (e.g., Spring/Jakarta EE/GuicedEE blocking flows).

- Overview — ./hibernate-orm-overview.md
- Setup & Configuration — ./hibernate-orm-setup.md
- EntityManager/Session & SessionFactory — ./hibernate-orm-entitymanager-session.md
- Transactions — ./hibernate-orm-transactions.md
- CRUD Patterns — ./hibernate-orm-crud.md
- Caching (1st/2nd Level) — ./hibernate-orm-caching.md
- Testing (Testcontainers) — ./hibernate-orm-testing.md
- Anti-Patterns — ./hibernate-orm-antipatterns.md
- Upgrade Notes — ./hibernate-orm-upgrade.md

---

## Hibernate 7 Reactive Topic Index (Non-Blocking, Mutiny)

Choose this when your host project specifies Hibernate Reactive 7 or when prompts reference Mutiny.Session/SessionFactory, Uni chaining, or non-blocking persistence.

- Overview — ./hibernate-7-reactive-overview.md
- Setup & Configuration — ./hibernate-7-reactive-setup.md
- SessionFactory — ./hibernate-7-reactive-session-factory.md
- Transactions — ./hibernate-7-reactive-transactions.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Testing (Testcontainers) — ./hibernate-7-reactive-testing.md
- Threading & Context — ./hibernate-7-reactive-threading.md
- Anti-Patterns — ./hibernate-7-reactive-antipatterns.md
- Upgrade Notes — ./hibernate-7-reactive-upgrade.md

---

Notes
- Document Modularity Policy: modular entries replace monolithic deep-dives.
- Each modular page includes quick starts, patterns, and links back to this index and RULES.md.
- JPMS and PostgreSQL driver policy: prefer GuicedEE Services artifacts for JPMS compatibility; do not shade drivers in host projects.
