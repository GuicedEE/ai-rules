# SonarQube Quality Gate Rules

Purpose
- Standardize SonarQube configuration for repositories that enforce quality gates alongside coverage (Jacoco) and static analysis tasks.
- Ensure every project keeps a checked-in `sonar-project.properties` file (default scanner filename) with module-aware settings.
- Require CI builds (Maven/Gradle) to reference the properties file explicitly so the same configuration is applied locally and in pipelines.

Scope
- Applies to JVM-first repositories (Java/Kotlin) and polyglot repos where SonarQube scans Java bindings; extend with language-specific sections as needed.
- Covers both single-module and multi-module builds using Maven or Gradle plus SonarScanner CLI.

---

## Baseline configuration — `sonar-project.properties`

Create `sonar-project.properties` at the repo root and commit it. Sample single-module file:
```properties
sonar.projectKey=acme-orders
sonar.projectName=Acme Orders
sonar.projectVersion=1.0.0
sonar.sourceEncoding=UTF-8
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.junit.reportPaths=target/surefire-reports
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.exclusions=**/generated/**
```
Key rules:
- `sonar.sources` / `sonar.tests` must reference real paths relative to repo root.
- Always set `sonar.java.binaries` to your compiled output (`target/classes`, `build/classes/java/main`).
- Align coverage reports with Jacoco XML output (see ./jacoco.rules.md); do not rely on legacy `.exec` ingestion.
- Keep exclusions minimal and justified; list them here and echo the rationale in RULES.md.

## Multi-module setup

Multi-module repositories must list all modules in the properties file using `sonar.modules`. Each module block declares its own sources, tests, binaries, and coverage outputs.
```properties
sonar.projectKey=acme-platform
sonar.projectName=Acme Platform
sonar.modules=core,api

core.sonar.projectBaseDir=services/core
core.sonar.sources=src/main/java
core.sonar.tests=src/test/java
core.sonar.java.binaries=build/classes/java/main
core.sonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml

api.sonar.projectBaseDir=services/api
api.sonar.sources=src/main/java
api.sonar.tests=src/test/java
api.sonar.java.binaries=target/classes
api.sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
```
Notes:
- `sonar.modules` entries must match folder layout; avoid wildcard modules.
- When modules mix build tools (Gradle + Maven), specify the correct `sonar.java.binaries`/coverage path per module.
- Use consistent naming for modules between SonarQube and CI dashboards so gates map back to subprojects.

## Build integration — referencing the properties file

Always tell the scanner which properties file to use, even though `sonar-project.properties` is the default. This prevents CI environments from falling back to ad-hoc settings.

### Maven
```bash
mvn -B clean verify sonar:sonar -Dproject.settings=sonar-project.properties
```
- Keep the Sonar Maven plugin (`org.sonarsource.scanner.maven:sonar-maven-plugin`) in `<pluginManagement>` and inherit it in aggregator POMs.
- Run after tests/coverage so Jacoco XML exists before Sonar uploads.

### Gradle
```kotlin
// build.gradle.kts (root)
plugins {
  id("org.sonarqube") version "5.1.0.4882"
}

sonarqube {
  properties {
    property("sonar.projectSettings", "sonar-project.properties")
  }
}
```
Pipeline command:
```bash
./gradlew clean test jacocoTestReport sonarqube -Dsonar.projectSettings=sonar-project.properties
```
- Aggregate Jacoco reports before the `sonarqube` task (see ./jacoco.rules.md) so XML paths referenced in the properties file exist.

### SonarScanner CLI
```bash
sonar-scanner -Dproject.settings=sonar-project.properties -Dsonar.login=$SONAR_TOKEN
```
- Use CLI for projects without Maven/Gradle builds (e.g., polyglot repos). Still commit the same properties file.

## Quality gate enforcement
- Set the desired gate in SonarQube (e.g., default + branch protections). Builds must fail when SonarQube reports a gate failure.
- In GitHub Actions/GitLab/Jenkins, block merges if the Sonar Quality Gate webhook returns `FAILED`. Use official integrations (build breaker plugin) where available.
- Keep `sonar.pullrequest.*` properties in the same file or supply them via CI env vars when scanning PRs.

## Artifacts, secrets, and security
- Store tokens (`SONAR_TOKEN`) in CI secret stores; never commit them.
- Do not commit scanner logs; rely on CI artifacts.
- When sharing Sonar dashboards, link back to RULES.md sections describing coverage and quality policies.

---

## See also
- Testing & Coverage index — ./README.md
- Terminology — ./GLOSSARY.md
- Jacoco coverage rules — ./jacoco.rules.md
- CI/CD providers — ../ci-cd/README.md
- RULES.md — Forward-only policy; Document Modularity Policy
