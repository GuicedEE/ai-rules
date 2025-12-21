# Testing Rules — Activity Master Cerial

Test scope
- Cover installer flows (types/classifications/events) with Mutiny session + Activity Master token using Testcontainers Postgres.
- Verify COM port registration flows with mocked jSerialComm or controlled test hardware; ensure classification writes are ordered and idempotent.
- Exercise timed sender behaviors without auto-start for scanner ports; assert no blocking on Vert.x event loop.

Tools and frameworks
- Use Java Micro Harness and JUnit 5; enable Jacoco per `rules/generative/platform/testing/jacoco.rules.md`.
- Prefer Testcontainers Postgres image configured via env vars (DB_URL/USER/PASS or container mapping).
- Use Mutiny reactive testing patterns (await().atMost()) and avoid Thread.sleep in tests.

Fixtures
- Provide SQL seeds for Activity Master schema when running in isolation; keep under src/test/resources.
- Register Guice modules for test context (e.g., DB modules) and ensure META-INF/services entries exist in test resources for SPI discovery.

CI alignment
- Ensure GitHub Actions workflows install JDK 25 and run `mvn -B -ntp test`.
- Cache submodules and Maven dependencies; keep JPMS module-info on test classpath (use `--add-modules ALL-MODULE-PATH` if needed).
