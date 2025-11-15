# Jacoco Coverage Rules

Purpose
- Enforce executable coverage gates for JVM projects across Maven and Gradle builds.
- Provide minimal, copy-paste safe configuration for unit (Surefire/test) and integration (Failsafe/IT) phases.
- Coordinate coverage enforcement with the Java TDD rules (80% instruction coverage default) and CI/CD pipelines.

Scope
- Applies to Java/Kotlin/JVM bytecode projects that rely on Jacoco 0.8.12+.
- Works with JUnit 5, TestNG, Spock, and KotlinTest as long as the JVM launchers attach the Jacoco agent.
- Aggregates coverage across module boundaries; host RULES.md can raise/lower gates only with documented justification.

---

## Baseline configuration

### Maven (Surefire + Failsafe + Jacoco)
```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.12</version>
      <executions>
        <!-- Attach agent before unit tests -->
        <execution>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
        </execution>
        <!-- Attach agent before integration tests -->
        <execution>
          <id>prepare-agent-it</id>
          <phase>pre-integration-test</phase>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
          <configuration>
            <destFile>${project.build.directory}/jacoco-it.exec</destFile>
          </configuration>
        </execution>
        <!-- Combine reports and run gate after verify -->
        <execution>
          <id>report-aggregate</id>
          <phase>verify</phase>
          <goals>
            <goal>report</goal>
            <goal>report-integration</goal>
            <goal>merge</goal>
            <goal>check</goal>
          </goals>
          <configuration>
            <dataFileIncludes>
              <dataFileInclude>${project.build.directory}/jacoco.exec</dataFileInclude>
              <dataFileInclude>${project.build.directory}/jacoco-it.exec</dataFileInclude>
            </dataFileIncludes>
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
  </plugins>
</build>
```
- Surefire must include `<argLine>@{surefireArgLine}</argLine>` to reuse Jacoco's JVM args.
- Failsafe runs after integration tests; keep `<goal>verify</goal>` so the `check` goal fails the build when coverage drops below the gate.

### Gradle (Kotlin DSL)
```kotlin
plugins {
  jacoco
}

jacoco {
  toolVersion = "0.8.12"
}

tasks.test {
  useJUnitPlatform()
  finalizedBy(tasks.jacocoTestReport)
}

tasks.register<JacocoReport>("jacocoAggregate") {
  dependsOn(subprojects.mapNotNull { it.tasks.findByName("test") })
  executionData.setFrom(fileTree(project.rootDir) {
    include("**/build/jacoco/test.exec", "**/build/jacoco/*.exec")
  })
  reports {
    xml.required.set(true)
    html.required.set(true)
  }
  sourceDirectories.setFrom(files(subprojects.flatMap {
    listOf(it.file("src/main/java"), it.file("src/main/kotlin"))
  }))
  classDirectories.setFrom(files(subprojects.flatMap {
    listOf(
      it.file("build/classes/java/main"),
      it.file("build/classes/kotlin/main")
    )
  }))
}

tasks.register<JacocoCoverageVerification>("jacocoVerifyAll") {
  dependsOn("jacocoAggregate")
  executionData(tasks.withType<Test>().map {
    it.extensions.getByType(JacocoTaskExtension::class).destinationFile
  })
  violationRules {
    rule {
      element = "BUNDLE"
      limit {
        counter = "INSTRUCTION"
        value = "COVEREDRATIO"
        minimum = "0.80".toBigDecimal()
      }
    }
  }
}
```
- Multi-module builds should register the aggregate tasks in the root project and wire CI to run `gradle clean test jacocoVerifyAll`.
- For single modules, reuse the simpler `jacocoTestReport` + `jacocoTestCoverageVerification` tasks.

---

## Coverage gates and policy
- Default gate: 80% instruction coverage at bundle level (matches Java TDD rules). Host RULES.md must document any deviations per module and provide rationale (legacy code, generated sources, etc.).
- Prefer bundle gates instead of class-level to protect architectural freedom; add class-level or package-level rules only when teams repeatedly miss critical paths.
- Always publish both XML (for Sonar/Quality Gate integration) and HTML (human review) outputs.
- Fail fast: Jacoco `check`/`jacocoVerifyAll` must run during CI `verify`/`build` jobs before packaging or deployment steps.

## Multi-module aggregation
- Maven: use `jacoco:merge` at the aggregator module, then `report`/`check` referencing `<modules>` outputs; keep exec files in `target/` per module to avoid collisions.
- Gradle: configure `executionData` to include `subprojects` test tasks. When some modules are Kotlin-only, add `src/main/kotlin` to `sourceDirectories`. Use filters (`exclude`) for generated code (e.g., `**/generated/**`, `**/*$Companion.class`).
- Always clean before aggregating to avoid stale `.exec` files; in CI run `mvn clean verify` or `gradle clean jacocoVerifyAll`.

## Integration and acceptance tests
- Maven Failsafe exec data must be merged into the final report; otherwise integration coverage is lost.
- Gradle: attach Jacoco to custom integration tasks via `tasks.withType<Test>().configureEach { extensions.configure(JacocoTaskExtension::class) { isIncludeNoLocationClasses = false } }` and include their exec files in `executionData`.
- For acceptance/UI tests run outside JVM, keep Jacoco limited to JVM services but document E2E gaps in RULES.md.

## CI/CD alignment
- GitHub Actions: add `actions/upload-artifact` for `target/site/jacoco` or `build/reports/jacoco` outputs; gate PRs by running `mvn -B clean verify` or `gradle -q clean jacocoVerifyAll`.
- Jenkins/GitLab/TeamCity: publish HTML reports as build artifacts and archive XML outputs for SonarQube or Codecov. Configure quality gates in the pipeline definition, not just locally.
- Enforce coverage before docker bake/publish steps; do not allow deployments with failing Jacoco gates.

## Exclusions and troubleshooting
- Generated sources (MapStruct, OpenAPI) can be excluded via `<excludes>` or `classDirectories.setFrom(classDirectories.files.map { fileTree(it) { exclude("**/generated/**") } })`. Document any exclusion rationale in RULES.md to keep traceability.
- Kotlin default methods and Lombok-generated code may appear as synthetic; keep `isIncludeNoLocationClasses = false` to avoid skewed coverage.
- If tests run on Java 21+ with JPMS, ensure Surefire includes `--add-exports`/`--add-opens` before Jacoco attaches; missing opens cause `ClassNotFoundException` inside the agent.

---

## See also
- Testing & Coverage index — ./README.md
- Terminology — ./GLOSSARY.md
- Java TDD rules — ../../language/java/tdd.md
- CI/CD provider guides — ../ci-cd/README.md
- RULES.md — Forward-only policy for coverage thresholds
