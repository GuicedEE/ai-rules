# Java BDD (Language Override)

Purpose
- Provide Java-specific BDD rules that extend and override the Base BDD architecture.
- Precedence: Java BDD supersedes [Base BDD](rules/generative/architecture/bdd/README.md) for Java projects; framework-specific BDD (if present) supersedes this file.

Scope
- Applies to JVM services, libraries, and applications built with Maven/Gradle (JPMS optional).
- Coordinates with topic rules (Hibernate Reactive, Vert.x, GuicedEE, MapStruct, Lombok) where acceptance scenarios exercise those surfaces.

Precedence and Links
- Base BDD (general) → [BDD Architecture](rules/generative/architecture/bdd/README.md)
- Language override (this file) → Java specifics (supersedes base where it conflicts)
- Framework overrides (if any) → Supersede both for framework concerns

Core BDD Workflow (inherits base)
- Discovery → Formulation → Automation
  - Discovery: collaborate on examples with domain language from the Glossary.
  - Formulation: express scenarios in Gherkin (Given/When/Then) as executable specs.
  - Automation: bind step definitions (glue) and run continuously under CI.
- BDD acceptance drives outside-in design; TDD drives unit/integration beneath. Both are complementary.

Project Structure (suggested)
- src/test/resources/features/… — Gherkin feature files grouped by domain/feature
- src/test/java/com/example/bdd/glue/… — step definitions (glue)
- src/test/java/com/example/bdd/support/… — support code (page/service objects, clients, fixtures)
- src/test/java/com/example/bdd/hooks/… — hooks (Before/After) for env setup/teardown
- test artifacts (reports): target/cucumber-*.json, target/cucumber-report/** (Maven) or build/reports/** (Gradle)

Maven Setup (JUnit Platform + Cucumber-JVM)
```xml
<!-- pom.xml (snippets) -->
<dependencies>
  <!-- Cucumber & JUnit Platform -->
  <dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-java</artifactId>
    <version>7.15.0</version>
    <scope>test</scope>
  </dependency>
  <dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-junit-platform-engine</artifactId>
    <version>7.15.0</version>
    <scope>test</scope>
  </dependency>

  <!-- Assertions & HTTP (optional, recommended) -->
  <dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <version>3.26.0</version>
    <scope>test</scope>
  </dependency>
  <dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <version>5.5.0</version>
    <scope>test</scope>
  </dependency>

  <!-- Testcontainers & WireMock (for integration as needed) -->
  <dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>1.20.3</version>
    <scope>test</scope>
  </dependency>
  <dependency>
    <groupId>org.wiremock</groupId>
    <artifactId>wiremock-standalone</artifactId>
    <version>3.9.1</version>
    <scope>test</scope>
  </dependency>
</dependencies>

<build>
  <plugins>
    <!-- Surefire: unit & cucumber on JUnit Platform -->
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-surefire-plugin</artifactId>
      <version>3.2.5</version>
      <configuration>
        <includes>
          <include>**/*Test.java</include>
          <include>**/*Tests.java</include>
          <include>**/*IT.java</include>
        </includes>
        <!-- Enable JUnit Platform -->
        <useModulePath>false</useModulePath>
      </configuration>
    </plugin>

    <!-- Failsafe (optional): for long-running e2e suites -->
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-failsafe-plugin</artifactId>
      <version>3.2.5</version>
      <executions>
        <execution>
          <goals>
            <goal>integration-test</goal>
            <goal>verify</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

Gradle Setup (Kotlin DSL snippet)
```kotlin
// build.gradle.kts
dependencies {
  testImplementation(platform("org.junit:junit-bom:5.11.0"))
  testImplementation("io.cucumber:cucumber-java:7.15.0")
  testImplementation("io.cucumber:cucumber-junit-platform-engine:7.15.0")
  testImplementation("org.assertj:assertj-core:3.26.0")
  testImplementation("io.rest-assured:rest-assured:5.5.0")
  testImplementation("org.testcontainers:junit-jupiter:1.20.3")
  testImplementation("org.wiremock:wiremock-standalone:3.9.1")
}

tasks.test {
  useJUnitPlatform()
  systemProperty("cucumber.execution.parallel.enabled", "true")
  // Optionally pass glue/features via system properties
}
```

JUnit Platform Cucumber Entry (no JUnit4 runner required)
```java
// src/test/java/com/example/bdd/CucumberRunner.java
import org.junit.platform.suite.api.*;

@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@ConfigurationParameter(key = "cucumber.glue", value = "com.example.bdd.glue,com.example.bdd.hooks")
@ConfigurationParameter(key = "cucumber.plugin", value = "pretty, summary, json:target/cucumber.json, html:target/cucumber-report.html")
public class CucumberRunner {}
```

Step Definitions (glue) examples

API acceptance — Rest-Assured
```java
// src/test/java/com/example/bdd/glue/OrdersApiSteps.java
import io.cucumber.java.en.*;
import static io.restassured.RestAssured.given;
import static org.assertj.core.api.Assertions.assertThat;
import io.restassured.response.Response;

public class OrdersApiSteps {
  private Response res;

  @When("I create an order with sku {string} and qty {int}")
  public void createOrder(String sku, int qty) {
    res = given().contentType("application/json")
      .body("{\"sku\":\"" + sku + "\",\"qty\":" + qty + "}")
      .post("/api/orders");
  }

  @Then("the response status should be {int}")
  public void verifyStatus(int status) {
    assertThat(res.getStatusCode()).isEqualTo(status);
  }
}
```

Service/DB integration — Testcontainers (PostgreSQL)
```java
// src/test/java/com/example/bdd/hooks/ContainersHook.java
import io.cucumber.java.BeforeAll;
import org.testcontainers.containers.PostgreSQLContainer;

public class ContainersHook {
  static PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");

  @BeforeAll
  public static void beforeAll() {
    pg.start();
    System.setProperty("DB_URL", pg.getJdbcUrl());
    System.setProperty("DB_USER", pg.getUsername());
    System.setProperty("DB_PASS", pg.getPassword());
    // run migrations if needed
  }
}
```

Glue Conventions
- Keep step phrases domain-oriented and non-technical; reuse across features.
- Extract support code (HTTP clients, page objects, data builders) to support/ packages; do not leak app internals into step code.
- Prefer immutable fixtures and typed builders; keep test data sources diffable (JSON/YAML/SQL in test resources).

Tagging and Traceability
- Use tags to connect specs with architecture and domains:
  - @api, @ui, @critical
  - @route:/orders/new
  - @domain:Orders
  - @sequence:orders-create (maps to docs/architecture/sequence-orders-create.md)
- Maintain tag→file mapping in docs/PROMPT_REFERENCE.md to seed future prompts.

JPMS Considerations
- Prefer keeping module boundaries strict; open packages for test engines via runtime flags rather than weakening production module-info.
- For Cucumber on JPMS, ensure test runtime opens glue packages as needed (e.g., surefire argLine with --add-opens).

Reporting and CI
- Publish cucumber JSON and HTML artifacts (target/cucumber.json, target/cucumber-report.html).
- Fail build on undefined/pending steps.
- Suggested order (pipeline):
  1) Lint/Static checks
  2) Unit tests
  3) Integration tests (containers/mocks)
  4) BDD acceptance (Cucumber)
  5) Coverage and report publishing
- Living documentation: host cucumber HTML + link to diagrams and feature sources.

Interplay with TDD
- BDD scenarios define acceptance behavior; beneath, write TDD unit/integration tests (red→green→refactor) to support steps.
- Keep acceptance fast and deterministic; push complexity down to unit/integration.

LLM Interpretation Guidance (Java BDD)
- At Stage 1/2, author/adjust Gherkin feature(s) and STOP for approval before step code.
- Implement glue in small increments; keep steps reusable and domain-named.
- Choose minimal scope:
  - API-only features → HTTP client glue + assertions
  - UI flows → Playwright (Node) or Selenium (JVM) glue; prefer Playwright if organizationally allowed
- Prefer contract-level verification (HTTP status/headers/body JSON shape; UI visible outcomes); do not assert private internals.

Superseded Base Sections (clarifications)
- Tooling specifics (Cucumber-JVM, Rest-Assured, Testcontainers, WireMock) supersede generic tool lists in Base BDD for Java projects.
- Reporting paths and pipeline ordering as above supersede base where applicable.

See Also
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- Java TDD — [tdd.md](rules/generative/language/java/tdd.md)
- Hibernate Reactive — [README](rules/generative/backend/hibernate/README.md)
- Vert.x — [README](rules/generative/backend/vertx/README.md)
- GuicedEE — [README](rules/generative/backend/guicedee/README.md)