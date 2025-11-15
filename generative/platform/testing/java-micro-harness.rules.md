# Java Micro Harness Rules

Purpose
- Provide a repeatable, code-first integration harness for JVM services so features can be verified without booting the full platform.
- Offer a modular pattern that spins up only the adapters (HTTP, messaging, persistence) required for a test scenario while keeping coverage and quality gates intact.
- Standardize how projects seed data, wire fake boundaries, and expose diagnostics so CI can run smoke, contract, and regression suites deterministically.

Scope
- Applies to Java 17+ services (Spring, Vert.x, GuicedEE, bare JAX-RS) that need lightweight end-to-end verification.
- Harness lives in the repository (e.g., `harness/` module) and reuses production modules via dependency injection; no separate repos.
- Works alongside [Jacoco](./jacoco.rules.md) and [SonarQube](./sonarqube.rules.md); harness tests must contribute to the same coverage and quality gates.

---

## Architecture and module layout
```
root
├── app/ (production modules)
│   ├── service-core
│   └── service-api
├── harness/
│   ├── harness-app (main entry + DI wiring)
│   └── harness-tests (JUnit/Testcontainers specs)
└── sonar-project.properties
```
Guidelines
- Keep harness modules in the same multi-module build; share version catalogs/dependency BOMs.
- `harness-app` exposes a `main` class that boots only the adapters needed for tests (e.g., embedded Netty, in-memory broker, Testcontainers DB).
- `harness-tests` depends on `harness-app` + production modules and provides orchestrated flows (API calls, event injection, assertions).
- Provide a `HarnessContext` object that centralizes ports, credentials, and feature toggles to avoid ad-hoc system properties.

## Build setup

### Maven
```xml
<modules>
  <module>app/service-core</module>
  <module>app/service-api</module>
  <module>harness/harness-app</module>
  <module>harness/harness-tests</module>
</modules>
```
Key plugin wiring (parent POM):
- `maven-surefire-plugin` executes unit tests in each module.
- `maven-failsafe-plugin` runs harness suites (`*HarnessIT`) inside `harness-tests` during `verify`.
- `jacoco-maven-plugin` merges coverage from both production and harness modules; reference `harness/harness-tests/target/site/jacoco/jacoco.xml` in SonarQube properties.

Example harness-test profile snippet:
```xml
<profile>
  <id>harness</id>
  <activation>
    <property>
      <name>harness</name>
    </property>
  </activation>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-failsafe-plugin</artifactId>
        <executions>
          <execution>
            <goals>
              <goal>integration-test</goal>
              <goal>verify</goal>
            </goals>
            <configuration>
              <includes>
                <include>**/*HarnessIT.java</include>
              </includes>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</profile>
```

### Gradle
- Model harness as separate modules (`:harness:app`, `:harness:tests`).
- Apply the `java-test-fixtures` plugin if harness needs to expose reusable stubs.
- Register custom Gradle tasks:
```kotlin
tasks.register<Test>("harnessTest") {
  description = "Runs Java Micro Harness integration suites"
  group = LifecycleBasePlugin.VERIFICATION_GROUP
  dependsOn(":harness:tests:test")
}

tasks.named("check").configure {
  dependsOn("harnessTest")
}
```
- Extend Jacoco aggregation to include harness modules:
```kotlin
subprojects {
  tasks.withType<Test>().configureEach {
    extensions.configure(JacocoTaskExtension::class) {
      isIncludeNoLocationClasses = false
    }
  }
}
```
- Publish harness coverage to the same XML files consumed by Sonar (`build/reports/jacoco/harnessTest/jacocoTestReport.xml`).

---

## Harness design principles

1. **Deterministic environments**
   - Use Testcontainers or in-memory doubles (H2, LocalStack, Fake SMTP) so harness runs locally and in CI without extra setup.
   - Bootstrap fixtures via Flyway/Liquibase for DB schemas, seed queue topics via harness utilities, and document assumptions in RULES.md.

2. **Isolation from production configuration**
   - Never reuse production secrets; harness should load `.env.harness` or `application-harness.yaml` with disposable credentials.
   - Keep feature flags explicit (e.g., `HARNESS_FEATURES=payments,notifications`).

3. **Fast feedback**
   - Keep suites under 5 minutes; shard scenarios using JUnit 5 tags (`@Tag("smoke")`, `@Tag("regression")`).
   - Run `smoke` tag on every PR; full harness nightly or before release.

4. **Observability hooks**
   - Route harness logs to `build/harness-logs`; attach artifacts in CI.
   - Expose `/health` or custom diagnostics on ephemeral ports (document in HarnessContext) for troubleshooting.

5. **Contract verification**
   - Embed Pact/contract verifiers where applicable. For example, run consumer contract tests in harness before publishing to Pact Broker.

---

## Example HarnessContext
```java
public record HarnessContext(
    URI baseUrl,
    int kafkaPort,
    String adminToken,
    Clock clock
) {
  static HarnessContext fromEnv() {
    var base = URI.create(System.getenv().getOrDefault("HARNESS_BASE_URL", "http://localhost:8181"));
    var kafka = Integer.parseInt(System.getenv().getOrDefault("HARNESS_KAFKA_PORT", "9093"));
    var token = System.getenv().getOrDefault("HARNESS_ADMIN_TOKEN", "local-token");
    return new HarnessContext(base, kafka, token, Clock.systemUTC());
  }
}
```
Usage in tests:
```java
@Harness
class CreateOrderHarnessIT {
  static HarnessContext ctx;

  @BeforeAll
  static void setup() {
    ctx = HarnessContext.fromEnv();
  }

  @Test
  void createsOrderViaRestEndpoint() {
    var request = new CreateOrderRequest("widget", 5);
    var response = httpClient(ctx).post("/orders", request, ctx.adminToken());
    assertThat(response.status()).isEqualTo(201);
    assertThat(response.body().id()).isNotBlank();
  }
}
```

---

## CI/CD alignment
- Add a dedicated harness job/stage (e.g., `mvn -B -Pharness clean verify` or `./gradlew harnessTest`) before deploy stages.
- Upload harness logs, coverage, and contract results as build artifacts.
- Fail the pipeline when harness suites fail or when harness coverage drags Jacoco/Sonar below thresholds.

## Documentation requirements
- Reference this rules file from project RULES.md and IMPLEMENTATION.md; describe when harness tests run and what environments they simulate.
- Provide runbooks for harness troubleshooting (timeouts, container startup failures, data reset procedures).
- Keep `README-harness.md` (optional) in the harness folder describing commands, env vars, and sample flows.

---

## See also
- Testing & Coverage index — ./README.md
- Glossary — ./GLOSSARY.md
- Jacoco coverage rules — ./jacoco.rules.md
- SonarQube rules — ./sonarqube.rules.md
- Architecture: TDD base rules — ../../architecture/tdd/README.md
