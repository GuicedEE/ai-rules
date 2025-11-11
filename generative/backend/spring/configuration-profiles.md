# Spring (Boot MVC) — Configuration and Profiles

Scope
- Non-reactive Spring Boot MVC configuration strategy across environments (dev/test/stage/prod), with typed configuration properties, profile activation, secrets handling, and conditional wiring.
- Aligns with enterprise secrets/config and observability rules.

Key goals
- Deterministic configuration layering
- Typed, validated configuration objects
- Clear environment separation via profiles
- Zero secrets in VCS; externalize sensitive values
- Safe actuator exposure by environment

Configuration files and layering
- Baseline file: application.yml (or .properties)
- Profile overlays: application-dev.yml, application-test.yml, application-prod.yml
- Local developer overrides (optional, untracked): application-local.yml, or use environment variables
- Precedence (higher wins) typical order:
  1) Command-line args (--server.port=9090)
  2) OS environment variables (SPRING_APPLICATION_JSON, ENV)
  3) application-{profile}.yml (active profiles)
  4) application.yml
  5) Defaults in @ConfigurationProperties classes

Profile activation
- Activate profiles via:
  - spring.profiles.active=dev (env var SPRING_PROFILES_ACTIVE)
  - Command-line: --spring.profiles.active=dev
  - YAML "spring.profiles" sections or profile-specific files
- Keep code branches by profile minimal; prefer config separation. Use @Profile as a last resort for beans that differ per environment.

application.yml structure (example)
```yaml
spring:
  application:
    name: demo
  datasource:
    url: jdbc:postgresql://localhost:5432/demo
    username: ${DB_USER:demo}
    password: ${DB_PASS:demo}
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate.jdbc.time_zone: UTC
      hibernate.format_sql: true

server:
  port: 8080
  shutdown: graceful

management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,prometheus"
  endpoint:
    health:
      probes:
        enabled: true

demo:
  http:
    client:
      base-url: https://api.example.com
      timeout:
        connect-ms: 500
        read-ms: 2000
```

application-prod.yml (overlay example)
```yaml
server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,prometheus"
  server:
    port: 8081
  endpoint:
    health:
      show-details: when_authorized

logging:
  level:
    root: INFO
    org.springframework.web: INFO
    com.example: INFO

demo:
  http:
    client:
      base-url: https://api.example.com
      timeout:
        connect-ms: 250
        read-ms: 1500
```

Environment variables mapping
- Convert property keys to uppercase and replace punctuation with underscores:
  - demo.http.client.timeout.read-ms → DEMO_HTTP_CLIENT_TIMEOUT_READ_MS
  - server.port → SERVER_PORT
- For arrays/lists use indexed syntax in env: SPRING_DATASOURCE_URLS_0=..., or prefer YAML/properties.

Typed configuration properties
- Define a record/class annotated with @ConfigurationProperties; validate with Bean Validation.
- Register via @EnableConfigurationProperties or @ConfigurationPropertiesScan.

Example typed properties (record)
```java
// com.example.config.DemoHttpClientProperties.java
package com.example.config;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "demo.http.client")
public record DemoHttpClientProperties(
    @NotBlank String baseUrl,
    Timeout timeout
) {
  public static record Timeout(
      @Min(1) int connectMs,
      @Min(1) int readMs
  ) {}
}
```

Configuration registration (auto-scan)
```java
// com.example.app.AppConfig.java
package com.example.app;

import com.example.config.DemoHttpClientProperties;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationPropertiesScan(basePackageClasses = DemoHttpClientProperties.class)
class AppConfig {}
```

Using the properties
```java
// com.example.app.HttpClientFactory.java
package com.example.app;

import com.example.config.DemoHttpClientProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class HttpClientFactory {

  @Bean
  okhttp3.OkHttpClient okHttpClient(DemoHttpClientProperties cfg) {
    return new okhttp3.OkHttpClient.Builder()
        .connectTimeout(java.time.Duration.ofMillis(cfg.timeout().connectMs()))
        .readTimeout(java.time.Duration.ofMillis(cfg.timeout().readMs()))
        .build();
  }
}
```

Profile-based beans and conditions
- Use @Profile("dev") for dev-only beans (e.g., in-memory stubs). Prefer externalized configuration.
- Use @ConditionalOnProperty for feature toggles:
```java
// com.example.feature.FeatureConfig.java
package com.example.feature;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class FeatureConfig {

  @Bean
  @ConditionalOnProperty(prefix = "feature.x", name = "enabled", havingValue = "true", matchIfMissing = false)
  MyFeatureService myFeatureService() {
    return new MyFeatureService();
  }
}
```

Secrets and sensitive config
- Never commit secrets. Supply via environment variables, secret stores, or mounted files.
- Reference enterprise guidance:
  - Secrets & Config — ../../platform/secrets-config/README.md
  - Security policy — ../../platform/secrets-config/security.md
- Redact sensitive keys in logs; avoid exposing them via /actuator/env.

Actuator and config exposure
- Enable configprops for visibility into typed properties but restrict to trusted environments/users.
- Example (prod): expose health, metrics, prometheus; keep env/configprops behind auth or disabled.
- Cross-link observability: ../../platform/observability/README.md

Logging configuration
- Use application.yml for common logging levels; keep prod INFO with targeted DEBUG for troubleshooting.
- For JSON logs, configure Logback encoder and include correlation IDs (trace/span if tracing is enabled).

Testing configuration
- Override properties in tests with @TestPropertySource or @SpringBootTest(properties="k=v").
- For Testcontainers, programmatically set spring.datasource.* and wait until readiness.
- Keep tests deterministic: set fixed ports for wiremock; seed known data through migrations or fixtures.

Example test override
```java
// com.example.SomeTest.java
package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
    "demo.http.client.base-url=http://localhost:18080",
    "demo.http.client.timeout.connect-ms=100",
    "demo.http.client.timeout.read-ms=200"
})
class SomeTest {
  @Test void contextStarts() {}
}
```

Feature flags
- Centralize feature toggles under feature.* prefix. Document default behaviors and rollout plan.
- Use @ConditionalOnProperty and surface status via a lightweight /internal/flags endpoint (secured) if needed.

Reference checklist
- Profiles defined (dev/test/prod), activation documented
- Typed properties with validation and metadata
- Secrets externalized; no sensitive defaults in repos
- Actuator exposure appropriate per environment
- Logging and tracing configured predictably per profile
- Tests override configuration deterministically

See also
- Topic index — ./README.md
- Overview & setup — ./overview-setup.md
- Security (non-reactive) — ./security-mvc.md
- Actuator & observability — ./actuator-observability.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Observability — ../../platform/observability/README.md