# Quarkus Core Rules

Purpose
- Establish baseline conventions for Quarkus 3.x services (project layout, extensions, configuration profiles).
- Ensure build tooling, dev mode, and configuration align with the Rules Repository standards.

## Versions and tooling
- Target Quarkus 3.10+ (Jakarta EE 10, Java 21 baseline). Document any deviation in project RULES.md.
- Supported build tools:
  - Maven with `io.quarkus.platform:quarkus-bom:3.10.*`
  - Gradle using the Quarkus Gradle plugin `id("io.quarkus") version "3.10."
- Pin Java toolchains via `maven-toolchains.xml` or Gradle `java.toolchain` (see language/java/build-tooling.md).

## Project structure
```
service/
├── src/
│   ├── main/java
│   ├── main/resources
│   └── test/java
├── src/main/resources/application.properties
├── pom.xml or build.gradle.kts
└── .env/.env.sample
```
- Keep shared modules (DTOs, clients) in `/modules/*` to prevent bloated service roots.
- Use Quarkus configuration profiles: `%dev.`, `%test.`, `%prod.`. Never overload `application.properties` with environment-specific values; use secrets managers per platform rules.

## Extension management
- Import BOM and declare extensions without versions:
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>io.quarkus.platform</groupId>
      <artifactId>quarkus-bom</artifactId>
      <version>3.10.0</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```
- Only add extensions required for the service (RESTEasy Reactive, SmallRye Reactive Messaging, Hibernate ORM). Remove unused ones to shorten native builds.

## Dev mode and continuous testing
- Use `mvn quarkus:dev` or `./gradlew quarkusDev` for local feedback.
- Enable continuous testing with `quarkus.test.continuous-testing=enabled` in `%dev` profile.
- Document dev services expectations (databases, Kafka) in README-harness or Dev Services rule.

## Configuration standards
- Keep secrets in `application.properties` as `${ENV_VAR:default}` placeholders; never commit real values.
- Use `quarkus.log.category."com.example".level=INFO` to tune logging per package (tie into backend/logging rules).
- Align metrics and health endpoints with Observability topic (expose `/q/health`, `/q/metrics`).

## Packaging
- Default output via `mvn clean package -Dquarkus.package.type=fast-jar` or Gradle equivalent.
- For container images, prefer Quarkus Jib or Dockerfiles with distroless base; document image strategy in IMPLEMENTATION.md.

## See also
- Topic index — ./README.md
- Native build rules — ./native-build.rules.md
- Dev Services — ./dev-services.rules.md
- Secrets & Config — ../../platform/secrets-config/README.md
