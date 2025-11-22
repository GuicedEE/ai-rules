# EntityAssist Reactive Glossary (Topic)

Precedence
- Topic glossary > downstream project `GLOSSARY.md` > enterprise root `rules/GLOSSARY.md`.
- Load this file whenever prompting about EntityAssistReactive so terms remain consistent across Pact → Rules → Guides → Implementation.

## Canonical Terms
| Term | Definition / Guidance |
| --- | --- |
| **CRTP Entity** | Any domain class extending `RootEntity`/`BaseEntity` with `<J extends RootEntity<J,Q,I>, Q extends QueryBuilderRoot<Q,J,I>, I extends Serializable>`. Must expose fluent setters returning `(J)this`; Lombok `@Builder` is not allowed. |
| **QueryBuilderRoot / QueryBuilder** | Fluent criteria builders that obtain Mutiny sessions via `IGuiceContext`, compose predicates/joins/cache hints, and always return `Uni<?>` (never `null`). Exceptions from Hibernate Reactive propagate through the `Uni`. |
| **DatabaseModule** | GuicedEE module annotated with `@EntityManager` that supplies `ConnectionBaseInfo` (host, port, credentials) and flags `setReactive(true)`. Every environment (dev/qe/prod/tests) registers its own module rather than relying on `.env` toggles. |
| **Mutiny Session Boundary** | Trust boundary where `Mutiny.Session` or `Mutiny.StatelessSession` is injected into builders. All persistence and transaction orchestration happens through this boundary; manual JDBC handles are disallowed. |
| **Mutiny Session Sequencing** | Mutiny `Session` operations must execute sequentially on the same thread/event-loop; do not run update/persist flows in parallel on a single session or Vert.x will raise `IllegalStateException: pop()`. Always chain operations (`session.withSession(...)`, `session.withStatelessSession(...)`, `session.withTransaction(...)`) rather than invoking them concurrently, and pass the session explicitly (first parameter in CRTP builders) to ensure intent is clear. Annotation-based `@Transactional` boundaries are not supported—use the fluent Mutiny APIs to bracket work. |
| **JPMS Access Flags** | Required compiler/Surefire arguments (`--add-reads org.jboss.logging=org.hibernate.reactive`, `--add-reads org.hibernate.orm.core=<module>`) plus `opens` statements for entity/test packages. Without them Hibernate Reactive cannot reflectively inspect entities. |
| **Documentation Loop** | Follow the standard forward-only chain defined in the Rules Repository (Pact → Glossary → Rules → Guides → Implementation → Architecture). Any change to this topic must be mirrored through that sequence for downstream adopters. |

## Interpretation Notes
- Terminology around “drivers” refers to Vert.x reactive SQL clients (Pg default). There is no support for the separate “SQL Client templates” docs.
- “Forward-only” means supersede prior guidance with dated sections; never delete history without recording rationale.
- When referencing environment variables, cite `.env.example` + `rules/generative/platform/secrets-config/env-variables.md`; database credentials always come from `DatabaseModule` implementations.
