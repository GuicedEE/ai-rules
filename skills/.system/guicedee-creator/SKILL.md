---
name: guicedee-creator
description: Create new GuicedEE-ready Maven modules with enforced Maven 4 and JDK 25+ baselines, GuicedEE BOM import, and JPMS main/test module boundaries. Use when scaffolding a new module, generating initial `pom.xml` and `module-info.java` files, or validating that module/test packages are separated (`.test` suffix in tests).
---

# GuicedEE Creator

Create a new module with GuicedEE baseline constraints and validate them deterministically.

## Required Flow
1. Collect inputs: `groupId`, `artifactId`, `moduleName`, and base package.
2. Create Maven project structure with `src/main/java` and `src/test/java`.
3. Apply the baseline POM constraints from `references/guicedee-baseline.md`:
   - Maven wrapper pinned to Maven 4
   - Java release/source/target at 25 or higher
   - GuicedEE BOM import in `dependencyManagement`
   - Testing stack includes `org.junit.jupiter:junit-jupiter` (`test` scope), JUnit Jupiter `6.0.3+`, and Mockito
4. Create `module-info.java` for both main and test roots with explicit `requires`/`opens` directives:
   - Test module must `requires` JUnit Jupiter module(s) for the `junit-jupiter` dependency
   - Every test package must be opened to `org.junit.platform.commons`
   - Any package requiring injection must open to `com.google.guice`
   - Any DTO/JSON deserialization package must open to `com.fasterxml.jackson.databind`
   - Any package using Vert.x features must open to `com.guicedee.vertx`
   - Safe default: open each used package to all required runtime targets
5. Ensure package separation:
   - Test module defaults to `<moduleName>.test`
   - Test package names end in `.test`
   - No package is shared between main and test source sets
6. Create a bootstrap main class with:
   - `LogUtils.addHighlightedConsoleLogger(Level.DEBUG)`
   - `IGuiceContext.registerModule("<moduleName>")`
   - `IGuiceContext.instance().inject()`
7. If lifecycle/injection sequence customization is needed, implement lifecycle SPI classes:
   - `com.guicedee.client.services.lifecycle.IGuicePreStartup`
   - `com.guicedee.client.services.lifecycle.IGuiceModule`
   - `com.guicedee.client.services.lifecycle.IGuicePostStartup`
   - All lifecycle hooks implement `IDefaultService`; override `sortOrder()` to control execution order
8. Register every SPI implementation in both:
   - `src/main/java/module-info.java` (`provides ... with ...`)
   - `src/main/resources/META-INF/services/<spi-interface-fqcn>`
9. Run `scripts/verify_guicedee_baseline.py` before finishing.

## Non-Negotiable Constraints
- Maven 4 is required (enforce via wrapper + enforcer rule).
- JDK 25 minimum is required.
- BOM import must exist exactly as:
  - `<groupId>com.guicedee</groupId>`
  - `<artifactId>guicedee-bom</artifactId>`
  - `<type>pom</type>`
  - `<scope>import</scope>`
- `module-info.java` must exist in both:
  - `src/main/java/module-info.java`
  - `src/test/java/module-info.java`
- `pom.xml` must include:
  - `<groupId>org.junit.jupiter</groupId>`
  - `<artifactId>junit-jupiter</artifactId>`
  - `<scope>test</scope>`
- Test module must declare `requires` for JUnit Jupiter (for example `requires org.junit.jupiter.api;`).
- Every test package must include an `opens <package> to org.junit.platform.commons;` directive.
- Injection packages must `opens` to `com.google.guice`.
- DTO/JSON deserialization packages must `opens` to `com.fasterxml.jackson.databind`.
- Vert.x packages must `opens` to `com.guicedee.vertx`.
- Safe default for main module packages: open used packages to all required targets (`com.google.guice`, `com.fasterxml.jackson.databind`, `com.guicedee.vertx`).
- Safe default for test module packages: also include `org.junit.platform.commons`.
- A bootstrap `main()` class must exist in `src/main/java` and register the current module name.
- Lifecycle SPI implementations must be registered in both `module-info.java` and `META-INF/services`.
- Lifecycle SPI implementations must override `sortOrder()` (from `IDefaultService`).
- Testing baseline must include JUnit Jupiter `6.0.3+` and Mockito.
- Playwright is optional and should be added for browser/E2E automation use cases.
- Package names cannot be duplicated between main and test modules.
- Test packages must use `.test` suffix.

## Validation Command
```bash
python3 scripts/verify_guicedee_baseline.py --project-root .
```

## References
- `references/guicedee-baseline.md` - baseline snippets for `pom.xml`, wrapper, and module templates.
