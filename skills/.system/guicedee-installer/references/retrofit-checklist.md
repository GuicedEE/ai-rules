# GuicedEE retrofit checklist

Use this checklist when converting an existing project to GuicedEE baseline.

## 1) Maven and Java baseline
- Ensure `.mvn/wrapper/maven-wrapper.properties` exists and points to Maven 4 (`apache-maven-4` in distribution URL).
- Ensure Java baseline is 25 or higher:
  - `maven.compiler.release`
  - `maven.compiler.source`
  - `maven.compiler.target`
- Add enforcer rules:
  - `requireMavenVersion` with `[4,)`
  - `requireJavaVersion` with `[25,)`

## 2) GuicedEE BOM import
Add under `dependencyManagement`:

```xml
<dependency>
    <groupId>com.guicedee</groupId>
    <artifactId>guicedee-bom</artifactId>
    <version>${guicedee.version}</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

## 3) Testing baseline
- Ensure JUnit Jupiter is `6.0.3` or higher.
- Ensure `org.junit.jupiter:junit-jupiter` exists with `test` scope.
- Ensure Mockito integration is present for unit/integration tests.
- Add Playwright only if browser/E2E tests are required.

Example:

```xml
<properties>
    <junit.jupiter.version>6.0.3</junit.jupiter.version>
    <mockito.version>5.12.0</mockito.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>${junit.jupiter.version}</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-junit-jupiter</artifactId>
        <version>${mockito.version}</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## 4) JPMS module descriptors
- `src/main/java/module-info.java`: must exist and declare main module.
- `src/test/java/module-info.java`: must exist and default to `<mainModule>.test`.
- Test module must include `requires` for JUnit Jupiter modules (for example `requires org.junit.jupiter.api;`).
- Every test package must include `opens <package> to org.junit.platform.commons;`.
- Packages requiring injection must include `opens <package> to com.google.guice;`.
- Packages with DTO/JSON deserialization objects must include `opens <package> to com.fasterxml.jackson.databind;`.
- Packages using Vert.x features must include `opens <package> to com.guicedee.vertx;`.
- Safe default: open each used package to all required runtime targets.

## 5) Bootstrap main class
- Ensure a `main()` entrypoint exists in `src/main/java` and includes:
  - `LogUtils.addHighlightedConsoleLogger(Level.DEBUG)`
  - `IGuiceContext.registerModule("<mainModule>")`
  - `IGuiceContext.instance().inject()`
- Ensure `<mainModule>` passed to `registerModule` matches main `module-info.java`.

## 6) Lifecycle SPI registration
If any implementation class uses these interfaces:
- `com.guicedee.client.services.lifecycle.IGuicePreStartup`
- `com.guicedee.client.services.lifecycle.IGuiceModule`
- `com.guicedee.client.services.lifecycle.IGuicePostStartup`

Then each implementation must be declared in both:
- `src/main/java/module-info.java` via `provides ... with ...`
- `src/main/resources/META-INF/services/<spi-interface-fqcn>` with implementation FQCN lines
- each implementation must override `sortOrder()` from `IDefaultService`

Behavior reminders:
- `IGuicePreStartup` runs before module injection; Vert.x 5 is available.
- `IGuiceModule` contributes sorted module loading; cyclic loading exits (`Cannot call injector while loading injector`).
- `IGuicePostStartup` runs by `sortOrder`; duplicate `sortOrder` runs in parallel on Vert.x.

## 7) Package isolation rules
- No package names may be shared between `src/main/java` and `src/test/java`.
- Test packages must end with `.test`.
- Rename test packages if required, then update imports and module `exports/opens` directives.
- Safe module rule for migrated projects:
  - main packages can be opened to `com.google.guice`, `com.fasterxml.jackson.databind`, and `com.guicedee.vertx` together
  - test packages should also include `org.junit.platform.commons`

## 8) Final validation
If `guicedee-creator` skill is installed beside this skill, run:

```bash
python3 ../guicedee-creator/scripts/verify_guicedee_baseline.py --project-root .
```
