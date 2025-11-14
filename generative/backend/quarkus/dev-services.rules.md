# Quarkus Dev Services Rules

Purpose
- Provide deterministic local/test environments using Quarkus Dev Services for DBs, Kafka, Keycloak, etc.

## General policy
- Enable Dev Services only for `%dev` and `%test`; disable in `%prod`.
- Document expected containers (images, ports) in host README and harness docs.

## Databases
```
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=app
quarkus.datasource.password=app
quarkus.datasource.devservices.image-name=postgres:16
quarkus.datasource.devservices.init-script-path=import.sql
```
- Prefer version-pinned images; avoid `latest`.
- For multi-DB setups, use named datasources with `quarkus.datasource."audit".*` and enable Dev Services per datasource.

## Messaging
- Enable Kafka Dev Services via `quarkus.kafka.devservices.enabled=true`; set `port=9092` only if necessary.
- When using Reactive Messaging, configure channel properties separate from Dev Services toggles.

## Identity/keycloak
- `quarkus.oidc.devservices.enabled=true` spins up Keycloak. Provide realm export under `src/test/resources` and reference via `quarkus.oidc.devservices.realm-path`.

## Test resources
- For custom requirements, implement `QuarkusTestResourceLifecycleManager` to manage containers (Testcontainers). Register via `@QuarkusTestResource`.
- Clean up containers to prevent port leaks in CI.

## CI alignment
- Document required Docker privileges. For CI systems without Docker, fall back to managed services (Testcontainers + remote DB) and skip Dev Services.

## See also
- Topic index — ./README.md
- Testing rules — ./testing.rules.md
- Secrets & Config — ../../platform/secrets-config/README.md
