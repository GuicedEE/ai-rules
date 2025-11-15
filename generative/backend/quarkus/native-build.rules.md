# Quarkus Native Build & Packaging Rules

Purpose
- Standardize native executable builds with GraalVM/mandrel for Quarkus services.

## Tooling
- Use Quarkus recommended container build: `-Dquarkus.native.container-build=true` with `quay.io/quarkus/ubi-quarkus-native-image:23.1-java21`.
- Ensure CI agents have Docker/podman availability before enabling container build.

## Build commands
- Maven: `mvn -B clean package -Dquarkus.package.type=native`.
- Gradle: `./gradlew clean build -Dquarkus.package.type=native`.
- Use profiles (e.g., `-Pnative`) so default pipelines stay JVM-first.

## Configuration
- Limit reflection by annotating DTOs/entities with `@RegisterForReflection` only when required.
- Configure native image resources via `application.properties` (`quarkus.native.resources.includes=*.yaml`).
- Keep heap/resource limits documented; set `quarkus.native.native-image-xmx=4g` for CI if needed.

## Testing native binaries
- Run smoke tests with `quarkus.native-image-test` goal or `@QuarkusIntegrationTest` which boots the produced binary.
- Record results separately from JVM tests; both must stay green before deploy.

## Observability and security
- Confirm `tls`/`oidc` dependencies are compatible with native builds; include `quarkus-oidc` substitution classes if necessary.

## Deployment
- Containerize native binaries using distroless base (ubi-minimal). Update IMPLEMENTATION.md with image tags and publish strategy.

## See also
- Topic index — ./README.md
- Testing — ./testing.rules.md
- Core rules — ./core.rules.md
