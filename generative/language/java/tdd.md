# Java TDD (Language Override)

Purpose
- Provide Java-specific TDD rules that extend and override the Base TDD architecture.
- Precedence: Java TDD supersedes [Base TDD](rules/generative/architecture/tdd/README.md) for Java projects; framework-specific TDD (if present) supersedes this file.

Scope
- Applies to pure Java services, libraries, and frameworks under Java toolchains (Maven/Gradle, JPMS optional).
- Coordinates with topic rules (Lombok, MapStruct, Hibernate Reactive, Vert.x, GuicedEE) where tests touch their surfaces.

Precedence and Links
- Base TDD (general) → [TDD Architecture](rules/generative/architecture/tdd/README.md)
- Language override (this file) → Java-specific guidance (supersedes base where it conflicts)
- Framework overrides (if any) → Supersede both for framework concerns

Core TDD Workflow (inherits base)
- Red → Green → Refactor
- Prefer Outside-in for product/API features; Inside-out for algorithmic/core domain logic.
- Behavior-first tests; avoid specifying private internals.

Build Tooling (Maven/Gradle)
- Maven (Surefire/FailSafe/Jacoco) — minimal, example config
  ```xml
  <!-- surefire: unit tests -->
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
      <argLine>@{surefireArgLine}</argLine>
    </configuration>
  </plugin>

  <!-- failsafe: integration tests (IT*) -->
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <executions>
      <execution>
        <goals>
          <goal>integration-test</goal>
          <goal>verify</goal>
        </goals>
      </execution>
    </executions>
  </plugin>

  <!-- jacoco: coverage -->
  <plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <executions>
      <execution>
        <goals>
          <goal>prepare-agent</goal>
        </goals>
      </execution>
      <execution>
        <id>report</id>
        <phase>verify</phase>
        <goals>
          <goal>report</goal>
          <goal>check</goal>
        </goals>
        <configuration>
          <rules>
            <rule>
              <element>BUNDLE</element>
              <limits>
                <limit>
                  <counter>INSTRUCTION</counter>
                  <value>COVEREDRATIO</value>
                  <minimum>0.80</minimum>
                </limit>
              </limits>
            </rule>
          </rules>
        </configuration>
      </execution>
    </executions>
  </plugin>
  ```
- Gradle (JUnit Platform/Jacoco)
  ```kotlin
  // build.gradle.kts
  plugins {
    jacoco
  }

  tasks.test {
    useJUnitPlatform()
  }

  jacoco {
    toolVersion = "0.8.12"
  }
  tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
      xml.required.set(true)
      html.required.set(true)
    }
  }
  tasks.jacocoTestCoverageVerification {
    violationRules {
      rule {
        limit {
          counter = "INSTRUCTION"
          value = "COVEREDRATIO"
          minimum = "0.80".toBigDecimal()
        }
      }
    }
  }
  ```
- Deeper coverage rules and CI wiring: ../../platform/testing/jacoco.rules.md

Testing Libraries and Patterns
- Unit
  - JUnit 5 (Jupiter) for runner and lifecycle
  - AssertJ for fluent assertions
  - Mockito (or MockK in Kotlin) for boundary doubles
  - JsonUnit for JSON structure assertions
  - Hamcrest optional; prefer one assertion style per project (AssertJ recommended)
- Integration
  - Testcontainers (DBs, brokers)
  - WireMock for HTTP boundaries
  - Awaitility for async conditions
- Acceptance/E2E (API/UI)
  - Rest-Assured for HTTP API acceptance tests
  - Playwright (if UI present and applicable), driven from JVM or separate Node project
- Static checks alongside tests in CI:
  - Spotless/Formatter; Error Prone (Gradle/Maven); PMD/Checkstyle optional

TDD for Common Java Topics
- Lombok
  - Tests must compile against generated accessors; prefer behavior-focused assertions.
  - For CRTP fluent APIs, assert chaining behavior at public contract; don’t assert return type casts beyond public API types.
- MapStruct
  - Unit test mapper methods with representative DTO/entity data.
  - Use update-vs-create tests; verify @Context usage is respected for unrelated items/services.
- Hibernate Reactive 7
  - Integration tests should use Testcontainers for DB; avoid H2 for differences in dialect/behavior.
  - Use Mutiny/Uni in test scaffolding; avoid blocking; if awaiting, confine to test harness with explicit timeouts.
- Vert.x
  - Avoid blocking the event loop; use VertxTestContext and Awaitility patterns.
  - For web tests, run HttpServer in test lifecycle and hit routes via WebClient.
- GuicedEE
  - Boot minimal injector graph per test or per suite; keep module wiring explicit.
  - Test SPI lifecycles and module overrides with isolated injectors (no global static injection).

Module System (JPMS) Considerations
- Open packages to test engines and mocking libraries only in test scope:
  ```text
  // module-info.java (main)
  module com.example.app {
    // requires ...
    // exports ...
  }

  // In test runtime args (Maven Surefire/Failsafe)
  --add-opens com.example.app/com.example.internal=org.mockito
  --add-opens com.example.app/com.example.domain=org.junit.platform.commons
  ```
- Prefer test-time --add-opens over weakening module boundaries in production module-info.java.

Test Taxonomy and Naming
- Unit tests: src/test/java, suffix Test (Maven surefire default), class-per-UT or feature grouping.
- Integration tests: src/test/java or src/it/java; name with IT suffix (Failsafe default) or group via tags @Tag("it").
- Acceptance tests: separate module or profile; use tags @Tag("e2e") to run under specific CI stages.

Test Data and Isolation
- Unit: deterministic time (inject Clock), randomness (inject Random), and locale.
- Integration: per-test containers or reused container with isolated schemas; run migrations per test class when reproducibility demands it.
- Acceptance: seed known fixtures; keep seeds in test resources as text (SQL/JSON/CSV).

Outside-in Example (API-first)
1) Write failing acceptance test with Rest-Assured for POST /orders
2) Add failing integration test for repository/service boundary
3) Add failing unit tests for domain model invariants
4) Implement minimal code to green the tests in reverse order (unit → integration → acceptance)
5) Refactor keeping tests green; update coverage, docs and sequence diagrams

Inside-out Example (Algorithm/core)
1) Write failing unit tests for core algorithm edge cases
2) Implement minimal algorithm
3) Add integration test ensuring adapter boundary correct (e.g., DB read/write shape)
4) Refactor; add acceptance test confirming user-level behavior

Minimal Examples
- Unit (JUnit 5 + AssertJ)
  ```java
  @Test
  void findName_returnsName_whenEntityExists() {
    when(repo.findById(ID)).thenReturn(Optional.of(new Entity(ID, "name")));
    var actual = service.findName(ID);
    assertThat(actual).isEqualTo("name");
  }
  ```
- Integration (Testcontainers + Jdbc)
  ```java
  @Testcontainers
  class UserRepositoryIT {

    @Container
    static PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");

    @Test
    void persistsAndReadsUser() {
      // init datasource using pg.getJdbcUrl(), pg.getUsername(), pg.getPassword()
      // run migration
      // persist, then read & assert
    }
  }
  ```
- Acceptance (Rest-Assured)
  ```java
  @Test
  @Tag("e2e")
  void createOrder_returns201_andResourceLocation() {
    given().contentType("application/json")
      .body("{\"sku\":\"ABC\",\"qty\":2}")
    .when()
      .post("/orders")
    .then()
      .statusCode(201)
      .header("Location", matchesRegex(".*/orders/\\d+$"));
  }
  ```

CI Integration
- Maven pipeline
  - mvn -B -ntp spotless:apply verify
  - Profiles: -Punit, -Pintegration, -Pe2e to split stages (or use Surefire/Failsafe conventions)
- Gradle pipeline
  - gradle spotlessApply test jacocoTestReport jacocoTestCoverageVerification
  - Separate tasks for integration/e2e via sourceSets or tags

Coverage Policy and Mutation Testing
- Enforce Jacoco at 80% instruction coverage at bundle level; allow module-level exceptions documented in project RULES.md.
- Mutation testing (e.g., PIT) recommended for critical modules; run on schedule to avoid slowing CI on every push.

Traceability to Diagrams and Prompts
- Each L2/L3 component in C4 diagrams must map to:
  - Unit tests for core logic
  - Integration tests for adapters
  - Acceptance tests for key flows
- Sequence diagrams → acceptance test scripts (steps ↔ assertions).
- docs/PROMPT_REFERENCE.md must list test tools, coverage gates, and link to diagrams to seed future prompts.

LLM Interpretation Guidance (Java)
- Always author/update failing tests first, then request approval to proceed with implementation (stage-gated).
- Prefer public behavior assertions; avoid brittle internal detail checks.
- Choose Outside-in for user stories/API routes; Inside-out for core domain algorithms.
- Use DI-friendly design to make time/IO/random deterministic under test.
- For JPMS, use test-time --add-opens flags rather than weakening module boundaries.

Superseded Base Sections (clarifications)
- Coverage gates: This file fixes instruction coverage ≥ 80% (project RULES.md may override with rationale).
- Tooling specifics (JUnit 5, AssertJ, Mockito, Testcontainers, WireMock, Rest-Assured) supersede base generic tool mentions.

See Also
- Lombok rules — [README](rules/generative/backend/lombok/README.md)
- MapStruct rules — [README](rules/generative/backend/mapstruct/README.md)
- Hibernate Reactive rules — [README](rules/generative/backend/hibernate/README.md)
- Vert.x rules — [README](rules/generative/backend/vertx/README.md)
