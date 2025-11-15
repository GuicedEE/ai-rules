# Quarkus Testing Rules

Purpose
- Align Quarkus testing strategy with Java TDD, Testing & Coverage topics, and harness guidance.

## Unit tests
- Use JUnit 5 with `@QuarkusTest` for CDI-aware tests.
- Mock boundary services using `@InjectMock` or Quarkus Mock extensions.
- Keep pure unit tests (no CDI) as plain JUnit classes for speed.

## Integration tests
- Use `@QuarkusIntegrationTest` for black-box tests that start the application as a native executable or JVM runner.
- Tag tests with `@Tag("smoke")`, `@Tag("regression")` and configure Maven Surefire/Failsafe accordingly.
- Combine with Dev Services or harness modules to bring up dependencies.

## Test resources
- Implement `QuarkusTestResourceLifecycleManager` for Testcontainers; register via `@QuarkusTestResource` at class or global level.
- Avoid sharing mutable state between tests; prefer per-test container instances or clean resets.

## Coverage & quality gates
- Jacoco: include `quarkus-jacoco` extension or configure Surefire `@{surefireArgLine}` to capture coverage.
- Ensure `harness` modules contribute to coverage per Testing & Coverage topic.
- Upload reports to SonarQube referencing new Quarkus modules.

## CLI commands
- Provide npm/Gradle tasks: `mvn -B clean test`, `mvn -B verify -Dquarkus.test.profile=test`. Document in README.

## See also
- Topic index — ./README.md
- Testing & Coverage — ../../platform/testing/README.md
- Java Micro Harness — ../../platform/testing/java-micro-harness.rules.md
- Dev Services — ./dev-services.rules.md
