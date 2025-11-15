# Spring (Boot MVC) — Overview and Setup

Scope
- Non-reactive Spring Boot MVC (Servlet stack on Tomcat/Jetty/Undertow) for HTTP APIs and services.
- Aligns with Java LTS (prefer 21 or 25). For reactive stacks, route to Vert.x/Hibernate Reactive topics.

Version alignment
- Java LTS: prefer 21 or 25. See: ../../language/java/java-21.rules.md and ../../language/java/java-25.rules.md
- Spring Boot: 3.x family. Use Spring's dependency BOM (no ad-hoc version drift).
- Persistence: Spring Data JPA (Hibernate ORM). For reactive persistence see Hibernate 7 Reactive.

Recommended module layout
- api — contracts and DTOs (records)
- app — web adapter (controllers, exception mapping, configuration)
- domain — services, core business logic, ports
- data — repositories and ORM entities
- bootstrap — application entrypoint, wiring, runners
- test-support — fixtures, base test utilities (optional)

Minimum dependencies (typical)
- spring-boot-starter-web (MVC)
- spring-boot-starter-validation (Bean Validation)
- spring-boot-starter-data-jpa (JPA/Hibernate)
- spring-boot-starter-security (if authz/authn needed)
- spring-boot-starter-actuator (ops endpoints)
- Database driver (e.g., postgresql)
- MapStruct (DTO mapping), Lombok (boilerplate reduction)
- Optional addons: springdoc-openapi, micrometer-registry-prometheus, micrometer-tracing, OTel exporters

Maven — POM template (Java 21+)
```xml
<!-- pom.xml -->
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>${spring-boot.version}</version>
    <relativePath/> <!-- lookup parent from repository -->
  </parent>

  <groupId>com.example</groupId>
  <artifactId>demo</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>demo</name>
  <description>Spring Boot MVC service</description>

  <properties>
    <java.version>21</java.version>
    <spring-boot.version>3.3.0</spring-boot.version>
    <mapstruct.version>1.6.2</mapstruct.version>
    <lombok-mapstruct-binding.version>0.2.0</lombok-mapstruct-binding.version>
  </properties>

  <dependencies>
    <!-- Core -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <!-- Security (optional) -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <!-- Actuator -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>

    <!-- Database -->
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>

    <!-- Mapping -->
    <dependency>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct</artifactId>
      <version>${mapstruct.version}</version>
    </dependency>
    <dependency>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct-processor</artifactId>
      <version>${mapstruct.version}</version>
      <scope>provided</scope>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok-mapstruct-binding</artifactId>
      <version>${lombok-mapstruct-binding.version}</version>
      <scope>provided</scope>
    </dependency>

    <!-- OpenAPI (optional) -->
    <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
      <version>2.6.0</version>
      <scope>runtime</scope>
    </dependency>

    <!-- Observability (optional) -->
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>

    <!-- Testing -->
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
  </dependencies>

  <build>
    <plugins>
      <!-- Build layered jar and image metadata -->
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <layers>
            <enabled>true</enabled>
          </layers>
        </configuration>
      </plugin>

      <!-- Java toolchain and annotation processors -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <configuration>
          <release>${java.version}</release>
          <annotationProcessorPaths>
            <path>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
            </path>
            <path>
              <groupId>org.mapstruct</groupId>
              <artifactId>mapstruct-processor</artifactId>
              <version>${mapstruct.version}</version>
            </path>
            <path>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok-mapstruct-binding</artifactId>
              <version>${lombok-mapstruct-binding.version}</version>
            </path>
          </annotationProcessorPaths>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

Gradle — build.gradle.kts template (Java 21+)
```kotlin
plugins {
  id("org.springframework.boot") version "3.3.0"
  id("io.spring.dependency-management") version "1.1.6"
  java
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(21))
  }
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-web")
  implementation("org.springframework.boot:spring-boot-starter-validation")
  implementation("org.springframework.boot:spring-boot-starter-data-jpa")
  implementation("org.springframework.boot:spring-boot-starter-actuator")
  implementation("org.mapstruct:mapstruct:1.6.2")

  compileOnly("org.projectlombok:lombok")
  annotationProcessor("org.projectlombok:lombok")
  annotationProcessor("org.mapstruct:mapstruct-processor:1.6.2")
  annotationProcessor("org.projectlombok:lombok-mapstruct-binding:0.2.0")

  runtimeOnly("org.postgresql:postgresql")

  // optional
  runtimeOnly("io.micrometer:micrometer-registry-prometheus")
  runtimeOnly("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.0")

  testImplementation("org.springframework.boot:spring-boot-starter-test")
  testImplementation("org.testcontainers:postgresql")
  testImplementation("org.testcontainers:junit-jupiter")
}

tasks.withType<Test> {
  useJUnitPlatform()
}
```

Starter code skeleton

Application
```java
// src/main/java/com/example/DemoApplication.java
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }
}
```

DTO (record) and Controller
```java
// src/main/java/com/example/api/GreetingDto.java
package com.example.api;

public record GreetingDto(String message) {}
```

```java
// src/main/java/com/example/app/GreetingController.java
package com.example.app;

import com.example.api.GreetingDto;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
class GreetingController {

  @GetMapping("/api/greet")
  ResponseEntity<GreetingDto> greet(@RequestParam @NotBlank String name) {
    return ResponseEntity.ok(new GreetingDto("Hello, " + name));
  }
}
```

Entity, Repository, and Service
```java
// src/main/java/com/example/data/UserEntity.java
package com.example.data;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class UserEntity {
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Version
  private long version;

  @Column(nullable = false, unique = true)
  private String email;

  // getters/setters omitted for brevity
}
```

```java
// src/main/java/com/example/data/UserRepository.java
package com.example.data;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {
  Optional<UserEntity> findByEmail(String email);
}
```

```java
// src/main/java/com/example/domain/UserService.java
package com.example.domain;

import com.example.data.UserEntity;
import com.example.data.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {
  private final UserRepository repo;
  public UserService(UserRepository repo) { this.repo = repo; }

  @Transactional(readOnly = true)
  public boolean emailExists(String email) {
    return repo.findByEmail(email).isPresent();
  }
}
```

Configuration — application.yml (skeleton)
```yaml
# src/main/resources/application.yml
server:
  port: 8080

spring:
  application:
    name: demo
  datasource:
    url: jdbc:postgresql://localhost:5432/demo
    username: demo
    password: demo
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate.format_sql: true
      hibernate.jdbc.time_zone: UTC
  profiles:
    active: dev

management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,prometheus"
  endpoint:
    health:
      probes:
        enabled: true
```

Profiles files
- application-dev.yml — overrides for local development (H2 optional for quick local only; prefer Testcontainers for tests).
- application-prod.yml — production endpoints, pool sizes, actuator exposure locked down.

Actuator
- Include health, liveness, readiness checks for DB and external dependencies.
- See: ../../platform/observability/README.md

Database migrations (choose one)
- Flyway: org.flywaydb:flyway-core
- Liquibase: org.liquibase:liquibase-core
- Author forward-only migrations and gate deploys on success. See: ../../data/database/README.md

OpenAPI (springdoc)
- Dependency: org.springdoc:springdoc-openapi-starter-webmvc-ui
- Default UI path /swagger-ui/index.html; restrict access by profile or security rules in production.
- Provider posture: Enterprise default provider is Swagger, with MicroProfile health endpoints preferred by default. Springdoc is supported for Spring Boot services. See cross‑stack rules: ../../platform/observability/openapi.md
- Document DTO constraints and error payloads. See: ./openapi-springdoc.md

Testing strategy (high level)
- Unit tests for domain logic.
- Web slice tests via MockMvc for controllers.
- Integration tests with Testcontainers (DB/brokers) and real migrations.
- See: ./testing.md

Packaging
- Fat jar: mvn -DskipTests package
- Buildpacks (recommended):
  - Maven: mvn spring-boot:build-image
  - Gradle: ./gradlew bootBuildImage
- Dockerfile (optional) — layered jar:
```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
EXPOSE 8080
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
```

Run
- Maven: mvn spring-boot:run
- Gradle: ./gradlew bootRun
- Jar: java -jar target/demo-0.0.1-SNAPSHOT.jar

Next steps (topic modules)
- Configuration & Profiles — ./configuration-profiles.md
- MVC REST & Validation — ./mvc-rest-validation.md
- Data JPA & Transactions — ./data-jpa-transactions.md
- Security (non-reactive) — ./security-mvc.md
- Actuator & Observability — ./actuator-observability.md
- Addons: OpenAPI — ./openapi-springdoc.md
- Addons: Testing — ./testing.md
- Addons: Caching — ./caching.md
- Addons: Scheduling & Async — ./scheduling-async.md
- Addons: Batch — ./batch.md
- Addons: Mail — ./mail.md
- Addons: Messaging — ./messaging.md
- Addons: Database migrations — ./database-migrations.md
- Packaging & Deployment — ./packaging-deployment.md

Cross-links
- Security & Auth (OIDC, providers) — ../../platform/security-auth/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Observability — ../../platform/observability/README.md
- Database reference — ../../data/database/README.md
- Java LTS rules — ../../language/java/README.md