# Testing and Validation Rules

Scope: Validation strategy for Activity Master client flows, builders, and token cache.

Test coverage
- Cover system/enterprise bootstrap paths (loadSystems/loadUpdates/runScript) using sequence diagrams at ../../../../../docs/architecture/sequence-system-load.md and ../../../../../docs/architecture/sequence-system-token.md as the test oracles.
- Validate CRTP builders with generics-focused tests to ensure fluent chaining returns `(J)` and preserves type safety.
- Exercise token cache hit/miss, invalidation, and concurrency behaviors with deterministic token providers.

TDD and fixtures
- Prefer TDD for new surfaces: write failing tests that pin the desired builder/service contract before implementing the code; keep coverage near interfaces in src/main/java/com/guicedee/activitymaster/fsdm/client/services.
- Bootstrap a deterministic enterprise once per suite using a `@BeforeAll` hook that runs on a Vert.x-friendly test harness; create the enterprise via IEnterpriseService/ActivityMasterConfiguration and seed token cache fakes to avoid network calls.
- When using @BeforeAll, reuse the seeded enterprise ID and system name across tests to avoid flakiness; isolate cache state per test via targeted invalidation hooks from ./token-cache.rules.md.

Example pattern (real tokens/DB)
- Use a class-level JUnit 5 fixture with `@TestInstance(PER_CLASS)` and `@TestMethodOrder` to keep a single Mutiny SessionFactory alive and avoid re-authentication churn.
- In `@BeforeAll`, set the application enterprise name, bootstrap Guice (`IGuiceContext.instance()`), fetch the named SessionFactory, and run a transactional install:
  - Get or create the enterprise via `IEnterpriseService.getEnterprise`, recover with `createNewEnterprise` + `startNewEnterprise`.
  - Get or create the Activity Master system via `ISystemsService.getActivityMaster`, recover with `create`.
  - Run `startNewEnterprise` idempotently after creation to ensure activation.
- Keep operations non-blocking and Vert.x-friendly: chain Mutiny `Uni` calls, avoid synchronous waits inside the session, and bound `.await()` with timeouts at the outermost level only.
- Structure tests to assert preconditions (e.g., expect `NoResultException` before create) and idempotency (calling create twice yields no duplicate). Reuse helper methods to fetch the system once per transaction.

Tooling
- Use Jacoco and BrowserStack per ../../../platform/testing/README.md; align with Java Micro Harness patterns for reactive testing when applicable.
- For persistence flows, align test fixtures with ../../../backend/hibernate/hibernate-7-reactive.md and avoid blocking Vert.x event loop threads.

Observability and CI
- Emit structured logs (Log4j2) and surface health probes for test environments per ../../../platform/observability/README.md.
- Mirror CI secrets and env vars described in ../../../platform/secrets-config/env-variables.md; never embed credentials in fixtures.
- Record validation steps and outcomes in IMPLEMENTATION.md to keep PACT + RULES + GUIDES + docs/architecture/* loops closed.
