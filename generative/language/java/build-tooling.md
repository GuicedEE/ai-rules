# Java Build Tooling — Maven & Gradle

Centralized, version-agnostic build configuration for Java projects targeting LTS baselines (17, 21, 25). Use these snippets to keep language rule files lean and point to this document from version-specific guides.

---

Toolchains and compiler — Gradle (Kotlin DSL)

Set the Java toolchain and release flag. Choose 17, 21, or 25 consistently across build, run, and test.

Example — Java 17
```kotlin
plugins {
  java
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(17))
  }
}

tasks.withType<JavaCompile>().configureEach {
  options.release.set(17)
  options.compilerArgs.addAll(listOf(
    "-Xlint:all",
    "-Werror"
  ))
}
```

Example — Java 21
```kotlin
plugins {
  java
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(21))
  }
}

tasks.withType<JavaCompile>().configureEach {
  options.release.set(21)
  options.compilerArgs.addAll(listOf(
    "-Xlint:all",
    "-Werror"
  ))
}
```

Example — Java 25
```kotlin
plugins {
  java
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(25))
  }
}

tasks.withType<JavaCompile>().configureEach {
  options.release.set(25)
  options.compilerArgs.addAll(listOf(
    "-Xlint:all",
    "-Werror"
  ))
}
```

---

Toolchains and compiler — Maven

Use maven-compiler-plugin with the appropriate release. Prefer aligning this with CI runner JDK via toolchains.xml.

pom.xml
```xml
<build>
  <pluginManagement>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.13.0</version>
        <configuration>
          <!-- Set to 17, 21, or 25 -->
          <release>21</release>
          <compilerArgs>
            <arg>-Xlint:all</arg>
            <arg>-Werror</arg>
          </compilerArgs>
        </configuration>
      </plugin>
    </plugins>
  </pluginManagement>
</build>
```

~/.m2/toolchains.xml
```xml
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <!-- Set to 17, 21, or 25 -->
      <version>21</version>
      <vendor>*</vendor>
    </provides>
    <configuration>
      <jdkHome>/path/to/jdk-21</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
```

Notes
- Default to GA features only; avoid preview/incubator features unless explicitly justified and consistently enabled across build, run, and test.
- Enforce -Werror to keep warnings from creeping into CI.
- Align CI agents to the same JDK toolchain used locally to avoid accidental downgrades.

---

Formatting — consistent code style in CI

Gradle Spotless
```kotlin
plugins {

}


```


---

Testing — runners and configuration

Gradle (JUnit Platform)
```kotlin
dependencies {
  testImplementation("org.junit.jupiter:junit-jupiter:5.11.3")
  testImplementation("org.assertj:assertj-core:3.26.3")
  // testImplementation("org.testcontainers:junit-jupiter:1.20.2")
}

tasks.test {
  useJUnitPlatform()
}
```

Maven Surefire
```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-surefire-plugin</artifactId>
  <version>3.5.0</version>
  <configuration>
    <useModulePath>true</useModulePath>
  </configuration>
</plugin>
```

---

Related topics
- Language rules — Java 17: ../java/java-17.rules.md
- Language rules — Java 21: ../java/java-21.rules.md
- Language rules — Java 25: ../java/java-25.rules.md
- Nullness contracts (JSpecify): ../../backend/jspecify/jspecify.rules.md
- JSpecify examples: ../../backend/jspecify/examples.md