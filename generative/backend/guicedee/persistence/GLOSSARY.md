# Glossary — GuicedEE Vert.x Persistence (Topic-First)

Authoritative glossary for persistence-specific terms. Host projects should link here and only copy enforced prompt-alignment names; all other definitions stay in this topic file.

## Precedence & Interpretation Guidance
- Topic-first: terms defined here override host `GLOSSARY.md`; host files should link back instead of duplicating.
- Align with related glossaries: `rules/generative/backend/guicedee/GLOSSARY.md`, `rules/generative/backend/hibernate/GLOSSARY.md`, `rules/generative/backend/lombok/GLOSSARY.md`, and CRTP rules (`rules/generative/backend/fluent-api/crtp.rules.md`).
- LLM guidance: keep class/package names verbatim; when prompting, specify persistence unit names and whether the context is bootstrap vs runtime to avoid ambiguous completions.

## Terms
- **DatabaseModule** — Abstract GuicedEE module that reads `persistence.xml`, merges properties via `IPropertiesEntityManagerReader`/`IPropertiesConnectionInfoReader`, and installs `JtaPersistModule` instances. Reference `../../../../../docs/architecture/sequence-persistence-bootstrap.md`.
- **JtaPersistModule / JtaPersistService** — Module/service pair that starts/stops `EntityManagerFactory` and unwraps `Mutiny.SessionFactory`. Logs lifecycle with Log4j2 emoji markers.
- **MutinySessionFactoryProvider** — Guice provider exposing reactive `Mutiny.SessionFactory`; must be the only provider consumed by Vert.x services. See `../../../../../docs/architecture/sequence-session-resolution.md`.
- **ConnectionBaseInfo / CleanConnectionBaseInfo** — Configuration holders for JDBC/driver metadata and sanitized derivatives; built via CRTP setters and populated by property readers.
- **IPropertiesConnectionInfoReader / IPropertiesEntityManagerReader** — ServiceLoader-driven hooks that transform config sources into final persistence properties; reject unknown prefixes and redact secrets.
- **VertxPersistenceModule / VertxServiceContributor** — Registry that keeps module-to-connection mappings and exposes Hibernate services to Vert.x for reactive usage.
