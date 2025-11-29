# Configuration Rules — GuicedEE Vert.x Persistence

Scope: how persistence units, property readers, and connection metadata are defined before bootstrapping Hibernate Reactive 7 with GuicedEE.

## Overview
- Author persistence units in `persistence.xml` (JPMS-friendly) and keep descriptors under `src/main/resources/META-INF/`.
- Use CRTP-based builders for `ConnectionBaseInfo`/`CleanConnectionBaseInfo`; avoid Lombok `@Builder`. Return `(J)this` in setters with `@SuppressWarnings("unchecked")` as needed.
- Reference architecture diagrams: `../../../../../docs/architecture/c4-component-configuration.md` and `../../../../../docs/architecture/erd-connection-domain.md`.

## Property Readers
- Implement `IPropertiesConnectionInfoReader` and `IPropertiesEntityManagerReader` via ServiceLoader; keep classes under `src/main/java/com/guicedee/vertxpersistence/implementations/`.
- Readers must validate prefixes, reject unknown properties, and scrub secrets from logs (Log4j2 markers only).
- Merge config from MicroProfile/Jakarta Config + env vars per [`rules/generative/platform/secrets-config/env-variables.md`](../../../platform/secrets-config/env-variables.md).
- Default to `com.guicedee.services:<driver>` artifacts (e.g., `postgresql`) and declare JPMS requirements for drivers; do not shade drivers.

## Connection Metadata
- `ConnectionBaseInfo` carries JDBC URL, credentials, pool sizing, XA/reactive flags, and persistence unit name. `CleanConnectionBaseInfo` is the sanitized form for downstream reuse.
- Expose `toPooledDatasource()` only after all overrides are merged; never return partially populated objects.
- Persisted names must align with `@EntityManager` annotations in module subclasses to avoid mismatched bindings.

## Logging & Observability
- Annotate readers and modules with Lombok `@Log4j2`; follow emoji-rich log style already used in the codebase while keeping secrets redacted.
- Prefer structured log markers for boundary crossings (Config boundary, Reactive boundary) noted in `../../../../../docs/architecture/integration-trust-boundaries.md`.

## See also
- `bootstrapping.rules.md` for lifecycle wiring
- `reactive-session.rules.md` for `Mutiny.SessionFactory` exposure
- `ci-cd-and-secrets.rules.md` for CI/secrets requirements
- Topic glossary: `GLOSSARY.md`
