# EntityAssist Reactive — Library Rules

These rules describe how to adopt the EntityAssist Reactive library inside downstream GuicedEE/Vert.x projects. They live entirely in the Rules Repository (`generative/data/entityassist/`) and must be treated as the standalone reference.

## 1. Purpose & Scope
- CRTP-based persistence layer for GuicedEE services on Vert.x 5 + Hibernate Reactive 7.
- Provides reusable base entities (`RootEntity`, `BaseEntity`, `DefaultEntity`), query builders (`QueryBuilderRoot`, `QueryBuilder`), converters, and service contracts.
- Ensures all persistence operations stay reactive (`Uni<T>`) and enforce JPMS access rules (no reflective hacks).

## 2. Stack Profile & Dependencies
| Layer | Selection | Notes |
| --- | --- | --- |
| Language | Java 25 LTS | JPMS enforced; add `requires transitive com.entityassist` to consumers. |
| Build | Maven | Use the same compiler/annotation-processor wiring described below. |
| Frameworks | GuicedEE Core + Persistence | Requires Guice modules + `IGuiceContext`. |
| Reactive | Vert.x 5, Hibernate Reactive 7, Mutiny | Provided via GuicedEE BOM. |
| Data | Vert.x reactive SQL drivers (pg by default) | No “SQL Client templates” scaffolding; configure per environment. |
| Structural | Lombok, Log4j2/JUL | Already configured with annotation processors. |
| CI/CD | GitHub Actions | Use `GuicedEE/Workflows/.github/workflows/projects.yml@master`. |

**Coordinates (BOM managed):**
`com.entityassist:entity-assist-reactive:2.0.0-SNAPSHOT` plus GuicedEE dependencies (`com.guicedee:guiced-vertx-persistence`, `com.guicedee:guice-injection`, `com.guicedee.services:hibernate-reactive`, `com.guicedee.services:scram`, `io.smallrye.reactive:mutiny`, `io.vertx:vertx-pg-client`, `jakarta.xml.bind:jakarta.xml.bind-api`, `org.glassfish.jaxb:jaxb-runtime`, `org.projectlombok:lombok`). Consumers inherit versions from the parent BOM; do not pin mismatched artifacts.

## 3. Module & Packages
```
com.entityassist
├── RootEntity / BaseEntity / DefaultEntity (CRTP foundations)
├── querybuilder
│   ├── QueryBuilderRoot (criteria utilities)
│   └── QueryBuilder (fluent CRUD/query builder)
├── services (IRootEntity, IQueryBuilder*, Guice contracts)
├── converters (JPA AttributeConverters for LocalDate/LocalDateTime)
├── enumerations / exceptions
└── module-info.java (exports + requires)
```

**Consumer requirements**
- Add `requires transitive com.entityassist;` to your JPMS module.
- Use `opens <your.entity.package> to org.hibernate.orm.core, com.google.guice, org.hibernate.validator, com.fasterxml.jackson.databind;` so Hibernate Reactive and Guice can inspect entities.
- Do not override `getEntityManager()`/`getEntityManagerStateless()`; instantiate builders via `entity.builder(session)` to reuse DI wiring.

## 4. Compiler, Annotation Processors & JPMS Flags
1. Add `org.hibernate.orm:hibernate-processor` to your compiler plugin alongside Lombok; keep version alignment with the GuicedEE BOM.
2. Keep compiler args: `--add-reads org.jboss.logging=org.hibernate.reactive` (compile scope) and Surefire `argLine` flags: `--add-reads org.hibernate.orm.core=<your.module.name>` plus `--add-reads org.jboss.logging=org.hibernate.reactive`.
3. Do not remove these when adding new processors or test profiles; extend them so Hibernate retains module access.
4. Tests must define a JPMS module (e.g., `module entity.assist.test`) with `opens com.<test package>` to `org.hibernate.orm.core`, `com.google.guice`, `org.junit.platform.commons`, `net.bytebuddy`, `com.entityassist`, and must `provide com.guicedee.guicedinjection.interfaces.IGuiceModule` with the `DatabaseModule` used during testing.

## 5. Database Modules & Environment
- Configure JDBC/reactive credentials through GuicedEE `DatabaseModule` subclasses (`@EntityManager`, `getConnectionBaseInfo`). Never rely on ad-hoc `.env` overrides for DB host/user/password.
- Provision **one `DatabaseModule` per target database** (e.g., Postgres OLTP, analytics replica). Each module can read environment variables at runtime when constructing `ConnectionBaseInfo` or use Hibernate Reactive 7 `persistence.xml` descriptors to provide static properties (user, password, host). `DatabaseModule` simply exposes a programmatic way to override those settings dynamically.
- `.env` keys should be consumed when the module builds `ConnectionBaseInfo` (e.g., `DB_URL`, `DB_USER`, `DB_PASS`). Keep `.env.example` limited to toggle/secret names and update the enterprise secrets guide when new keys are introduced.
- `PersistService`/`JtaPersistService` and `Mutiny.SessionFactory` are injectable via Guice (use `@Inject` + `@Named` or resolve via `IGuiceContext`). `Mutiny.Session`/`StatelessSession` themselves are *not* injectable; obtain them by calling `sessionFactory.withSession(...)` or `sessionFactory.withStatelessSession(...)`. In tests, retrieve the bindings programmatically (see integration tests) and remember to start/stop the `PersistService` around your scenarios before invoking builder flows.

## 6. Reactive Usage & API Rules
1. **CRTP Entities** — Always extend `RootEntity`/`BaseEntity` with the signature `<J extends RootEntity<J,Q,I>, Q extends QueryBuilderRoot<Q,J,I>, I extends Serializable>`. Do not introduce Lombok `@Builder`; fluent setters must return `(J)this`.
2. **Builders** — Obtain them via `entity.builder(session)` or `entity.builder(statelessSession)`. They configure joins, filters, and caches before executing Mutiny operations.
3. **Return Types** — `persist`, `update`, `delete`, `merge`, etc., always return `Uni<J>` (or the relevant type) and never return `null`. Hibernate Reactive exceptions propagate through the `Uni`; compose error handlers with Mutiny operators rather than wrapping exceptions inside the builder.
4. **Session Management** — Use `Mutiny.Session`/`Mutiny.StatelessSession` provided by Guice (`IGuiceContext`). Builders should not manually open JDBC connections.
5. **Transactions** — Drive via `withTransaction` and the query builder’s fluent API. Follow `rules/generative/backend/vertx/vertx-5-transaction-handling.md` and update docs if advanced patterns (e.g., retries) are required.

## 7. Testing & CI
- Baseline command: `mvn -B verify`. Integration tests must set `TEST_DB_CONTAINER_IMAGE` (or equivalent) and keep Surefire JPMS flags intact.
- The canonical implementation repository uses `GuicedEE/Workflows/.github/workflows/projects.yml@master` for its own CI/CD, but downstream consumers are free to run their preferred pipelines (GitHub Actions, GitLab, Jenkins, etc.) so long as they honor the testing and JPMS requirements in this ruleset.
- Add new tests under the JPMS structure noted above and document any extra dependencies alongside your project’s local testing guides.

## 8. Documentation & Glossary Alignment
- Glossary precedence: use this topic’s [Glossary](./GLOSSARY.md) first, then reference related glossaries (GuicedEE, Vert.x, Hibernate Reactive, Lombok, CI/CD) under `/rules/generative/**`.
- When modifying these rules, update the companion topic supplements (`README`, `Glossary`, `TDD`, `BDD`) to keep the Rules Repository consistent.

## 9. Forward-Only Policy
- Supersede sections with clearly dated updates rather than deleting history inside this directory.
- Any new rule must be backed by evidence from source code or configs and recorded within the Rules Repository.
