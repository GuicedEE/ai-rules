# Spring (Boot MVC) — Database Migrations (Flyway/Liquibase)

Scope
- Forward-only, automated schema migrations for non-reactive Spring Boot MVC services using Flyway or Liquibase.
- Covers versioning policy, naming, structure, Spring Boot wiring, zero-downtime patterns, data backfills, validations, CI gates, and testing with Testcontainers.

Select one tool
- Choose exactly one migration tool per service/repo (Flyway or Liquibase). Do not mix.
- Prefer Flyway for simple SQL-first migrations; prefer Liquibase for XML/YAML/JSON changelog orchestration or team-wide standardization needs.

Core principles
- Forward-only migrations; never rewrite history of applied migrations.
- Immutable artifacts in VCS; checksum drift must fail fast.
- App startup or CI should fail on migration errors.
- No hbm2ddl in production; rely on migrations exclusively.
- Backwards/forwards compatibility during deploy windows; favor expand/contract.

Dependencies (choose one)
- Flyway: org.flywaydb:flyway-core (+ org.flywaydb:flyway-database-postgresql for new driver packages)
- Liquibase: org.liquibase:liquibase-core

Spring Boot configuration (Flyway)
```yaml
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
    table: flyway_schema_history
    placeholders:
      app_user: ${DB_MIGRATIONS_USER:app_migrator}
```

Spring Boot configuration (Liquibase)
```yaml
spring:
  liquibase:
    enabled: true
    change-log: classpath:db/changelog/db.changelog-master.yaml
    contexts: ${LIQUIBASE_CONTEXTS:}
```

Directory structure (Flyway)
- Location: src/main/resources/db/migration
- Versioned SQL naming: V1__init.sql, V2__add_user_email_index.sql
- Repeatable migrations (idempotent): R__refresh_materialized_views.sql (optional pattern)

Directory structure (Liquibase)
- Master changelog: src/main/resources/db/changelog/db.changelog-master.yaml
- Versioned includes: db.changelog-0001.yaml, db.changelog-0002.yaml
- Split per bounded context or feature where sensible

Versioning and naming
- Increment sequential versions for Flyway (V1, V2, …). For Liquibase, prefer timestamp-based ids or sequence plus descriptive names.
- Use lower-kebab description terms: add-user-email-unique-constraint
- Keep one concern per migration; small, reviewable diffs.

Example Flyway SQL (PostgreSQL)
```sql
-- V3__add_user_email_unique_constraint.sql
ALTER TABLE users
  ADD CONSTRAINT uk_users_email UNIQUE (email);
```

Example Liquibase YAML
```yaml
# db/changelog/db.changelog-0003.yaml
databaseChangeLog:
  - changeSet:
      id: 0003-add-user-email-unique
      author: team
      changes:
        - addUniqueConstraint:
            tableName: users
            columnNames: email
            constraintName: uk_users_email
```

Zero-downtime (expand/contract)
- Expand: add nullable columns, new tables, or optional structures first; deploy app that writes both/reads fallback.
- Backfill: populate data in batches with idempotent scripts or background jobs.
- Contract: only after app is no longer depending on old shape (drop columns/constraints in a later migration).

Backfills and long operations
- Avoid long locks and table rewrites during peak traffic:
  - Use concurrent index creation where supported (PostgreSQL: CREATE INDEX CONCURRENTLY).
  - Break large updates into chunks with limited transaction sizes.
  - Move heavy transforms outside migrations into controlled jobs with checkpoints.
- Ensure backfills are idempotent and restartable.

Transactional boundaries
- Keep DDL within safe transactional semantics per DB:
  - PostgreSQL: many DDL operations are transactional; concurrent index creation cannot run inside a transaction block (use appropriate Flyway/Liquibase directives).
- For Liquibase, use runInTransaction: false on operations requiring it.

Roll-forward strategy
- If a migration fails in production, prefer generating a follow-up fix migration; do not edit applied scripts.
- Only revert with explicit down migrations if enforced by policy and if the tool and DB semantics guarantee safety (often discouraged). Prefer forward fixes.

Application startup posture
- Fail fast on migration errors; app should not start if schema is incompatible.
- In k8s, consider init containers to run migrations before app deployment (team policy).
- For blue/green or rolling deploys, ensure new app version is compatible with both pre- and post-migration schema during rollout.

Test strategy (integration)
- Use Testcontainers to start a real PostgreSQL and apply migrations at test startup.
- Disable hbm2ddl auto; use validate to ensure ORM matches schema.
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
```

JUnit + Testcontainers example (Flyway)
```java
// src/test/java/com/example/it/FlywayIntegrationTest.java
package com.example.it;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class FlywayIntegrationTest {
  @Test
  void contextLoads_andMigrationsApplied() {
    // If Flyway runs at startup, reaching here validates migrations ran OK
  }
}
```

CI gates
- Run migrations against a disposable DB for each PR (Testcontainers in CI or ephemeral DB).
- Validate checksums; fail on drift.
- Optional: diff prod vs generated schema using schema-diff tools to catch unintended changes.
- For OpenAPI-first workflows, align schema changes with contract versions and changelogs.

Operational safeguards
- Always run backups or have PITR configured before applying destructive migrations.
- Announce and schedule migrations that can impact performance; observe DB metrics during rollout.
- Tag release artifacts with migration versions for traceability.

Hibernate ORM alignment
- Keep spring.jpa.open-in-view=false to enforce service-layer transactions and avoid lazy loads in views.
- Model @Version for optimistic locking; update migrations to include version columns when introducing concurrency controls.
- Prefer explicit column types and constraints to match domain invariants; do not rely on provider defaults.

Policy checklist
- One tool (Flyway or Liquibase) selected and wired.
- Migrations are forward-only and immutable; review process documented.
- Expand/contract strategy applied; destructive changes separated and scheduled.
- App startup/CI fails fast on migration errors.
- Integration tests run real migrations via Testcontainers.
- Backups and observability in place for migration windows.

See also
- Spring topic index — ./README.md
- Data JPA & Transactions — ./data-jpa-transactions.md
- Database reference — ../../data/database/README.md
- Testing — ./testing.md
- Observability — ../../platform/observability/README.md