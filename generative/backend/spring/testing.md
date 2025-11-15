# Spring (Boot MVC) — Testing (JUnit 5, MockMvc, Testcontainers)

Scope
- Testing strategy and patterns for non-reactive Spring Boot MVC services with JUnit Jupiter (JUnit 5).
- Emphasizes fast unit tests, focused slice tests (web/data), and realistic integration tests with Testcontainers (DB/brokers).
- Align with enterprise database and observability rules.

Testing goals
- Fast feedback locally (unit and slice tests).
- Realistic integration with production-like infra (containers) and real DB schemas (migrations).
- Deterministic tests with stable seeds, explicit timeouts, and no flakiness.

Recommended layers
- Unit tests — plain JUnit, no Spring; domain logic and utilities.
- Slice tests — @WebMvcTest for controllers, @DataJpaTest for repositories.
- Integration tests — @SpringBootTest with Testcontainers for DB/brokers; exercise migrations and security.
- Contract tests (optional) — producer/consumer contracts where integration complexity warrants.

Dependencies (typical)
- spring-boot-starter-test
- testcontainers: junit-jupiter, postgresql (and others as needed)
- spring-security-test (if using Spring Security)
- wiremock (optional) for HTTP stubs

Maven (snippets)
```xml
<!-- pom.xml — test dependencies -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.testcontainers</groupId>
  <artifactId>postgresql</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.testcontainers</groupId>
  <artifactId>junit-jupiter</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.springframework.security</groupId>
  <artifactId>spring-security-test</artifactId>
  <scope>test</scope>
</dependency>
```

Gradle (Kotlin DSL)
```kotlin
dependencies {
  testImplementation("org.springframework.boot:spring-boot-starter-test")
  testImplementation("org.testcontainers:postgresql")
  testImplementation("org.testcontainers:junit-jupiter")
  testImplementation("org.springframework.security:spring-security-test")
}
tasks.withType<Test> { useJUnitPlatform() }
```

Unit tests — pure JUnit
- No Spring context; test domain services and helpers in isolation.
- Mock collaborators with simple fakes or a mocking framework (e.g., Mockito) where necessary.
```java
// src/test/java/com/example/domain/EmailValidatorTest.java
package com.example.domain;

import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

class EmailValidatorTest {
  @Test
  void validEmail() {
    assertThat(EmailValidator.isValid("a@b.test")).isTrue();
  }
}
```

Web slice tests — @WebMvcTest
- Start only the web layer; use MockMvc for routing, validation, and serialization tests.
- Mock service layer collaborators.
- Include security test helpers if security is enabled.
```java
// src/test/java/com/example/app/user/UserControllerWebTest.java
package com.example.app.user;

import com.example.api.user.UserCreateRequest;
import com.example.domain.user.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerWebTest {

  @Autowired MockMvc mvc;
  @MockBean UserService service;

  @Test
  void create_returns201() throws Exception {
    var payload = "{\"email\":\"a@b.test\",\"name\":\"Alice\"}";
    when(service.create(new UserCreateRequest("a@b.test","Alice")))
        .thenReturn(new UserResponse(1L, "a@b.test", "Alice"));

    mvc.perform(post("/api/users")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isCreated())
      .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
      .andExpect(jsonPath("$.email").value("a@b.test"));
  }
}
```

Web slice with security (JWT)
- Use spring-security-test to simulate authentication with scopes/roles.
```java
// src/test/java/com/example/app/user/UserControllerSecurityTest.java
package com.example.app.user;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(UserController.class)
class UserControllerSecurityTest {

  @Autowired MockMvc mvc;

  @Test
  void requiresScope() throws Exception {
    mvc.perform(get("/api/users").with(jwt().authorities(() -> "SCOPE_read")))
       .andExpect(status().isOk());
  }
}
```

Data slice tests — @DataJpaTest
- Focus on repository logic; uses embedded DB by default, but prefer Testcontainers PostgreSQL for behavioral parity.
```java
// src/test/java/com/example/data/UserRepositoryDataTest.java
package com.example.data;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class UserRepositoryDataTest {

  @Autowired UserRepository repo;

  @Test
  void roundTrip() {
    var e = new UserEntity();
    e.setEmail("a@b.test");
    e.setName("Alice");
    repo.save(e);

    assertThat(repo.findByEmail("a@b.test")).isPresent();
  }
}
```

Integration tests — @SpringBootTest + Testcontainers
- Start the full app context and run against real infra (PostgreSQL, brokers).
- Apply real migrations (Flyway/Liquibase) at startup, not hbm2ddl in integration tests.

Reusable PostgreSQL container (Jupiter)
```java
// src/test/java/com/example/it/PostgresContainerConfig.java
package com.example.it;

import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
public abstract class PostgresContainerConfig {

  @Container
  static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16")
      .withDatabaseName("testdb")
      .withUsername("test")
      .withPassword("test");

  @DynamicPropertySource
  static void registerProps(DynamicPropertyRegistry r) {
    r.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    r.add("spring.datasource.username", POSTGRES::getUsername);
    r.add("spring.datasource.password", POSTGRES::getPassword);
  }
}
```

End-to-end test exercising DB and web
```java
// src/test/java/com/example/it/UserFlowIT.java
package com.example.it;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserFlowIT extends PostgresContainerConfig {

  @Test
  void createAndFetch() {
    var client = RestClient.create();
    var created = client.post()
        .uri("http://localhost:8080/api/users")
        .body("{\"email\":\"a@b.test\",\"name\":\"Alice\"}")
        .retrieve()
        .toEntity(String.class);
    assertThat(created.getStatusCode().is2xxSuccessful()).isTrue();
  }
}
```

Migrations in tests
- Prefer Flyway/Liquibase to build schema in tests. Disable hbm2ddl.auto in integration tests and rely on migrations.
- Clear test DB deterministically between tests (transactional rollback or truncate scripts).

Test data strategy
- Seed fixtures via migrations or test-specific SQL/data builders.
- Use stable identifiers and values; avoid time-based randomness unless explicitly asserted.

HTTP stubbing — WireMock (optional)
- Stub external HTTP dependencies to keep tests deterministic.
```java
// src/test/java/com/example/it/WireMockSupport.java
package com.example.it;

import com.github.tomakehurst.wiremock.WireMockServer;
import org.junit.jupiter.api.*;
import static com.github.tomakehurst.wiremock.client.WireMock.*;

class WireMockSupport {
  static WireMockServer wm;

  @BeforeAll
  static void start() {
    wm = new WireMockServer(18080);
    wm.start();
    wm.stubFor(get(urlEqualTo("/ext/health")).willReturn(aResponse().withStatus(200)));
  }

  @AfterAll
  static void stop() { wm.stop(); }
}
```

Performance and timeouts
- Set explicit timeouts on await calls (where applicable) and HTTP clients; fail fast on hangs.
- Mark slow integration tests with @Tag("integration") and configure build to run them separately if desired.

CI considerations
- Ensure Docker is available for Testcontainers (or use the Ryuk-less mode with reusable containers as policy allows).
- Publish test reports and coverage. Consider a daily job running full integration suite if local policy limits container usage on PRs.

Common pitfalls
- Flaky tests due to unseeded randomness, time dependency, or external calls without stubs.
- Using H2 for repository behavior that relies on PostgreSQL semantics — prefer Testcontainers Postgres.
- Overusing @SpringBootTest where @WebMvcTest or @DataJpaTest is sufficient.

Checklist
- Unit tests cover critical domain logic (no Spring).
- Controllers tested with MockMvc; validation and error envelopes verified.
- Repositories tested with @DataJpaTest; projections and queries verified.
- Integration tests use Testcontainers and real migrations.
- Security tests verify 401/403/permissions behavior.
- Deterministic seeds; no flaky external dependencies.

See also
- Topic index — ./README.md
- MVC REST & Validation — ./mvc-rest-validation.md
- Data JPA & Transactions — ./data-jpa-transactions.md
- Security (non-reactive) — ./security-mvc.md
- Database reference — ../../data/database/README.md
- Observability — ../../platform/observability/README.md