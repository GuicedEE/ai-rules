---
name: guicedee-installer
description: "Retrofit existing Maven modules to GuicedEE baseline standards: Maven 4 wrapper, JDK 25+, GuicedEE BOM import, and JPMS main/test module boundaries. Use when a project already exists and needs GuicedEE dependency management and compliant `module-info.java` plus `.test` package separation."
---

# GuicedEE Installer

Upgrade an existing module to the same baseline expected by `guicedee-creator`.

## Required Flow
1. Inspect current project state (`pom.xml`, wrapper files, source roots, module-info files).
2. Patch `pom.xml` to align with `references/retrofit-checklist.md`:
   - Java baseline set to 25+
   - GuicedEE BOM imported in `dependencyManagement`
   - Enforcer rules for Maven 4 and Java 25+
   - Testing baseline includes `org.junit.jupiter:junit-jupiter` (`test` scope), JUnit Jupiter `6.0.3+`, and Mockito
3. Ensure Maven wrapper points to Maven 4 (`.mvn/wrapper/maven-wrapper.properties`).
4. Create or repair:
   - `src/main/java/module-info.java`
   - `src/test/java/module-info.java`
   - ensure test module `requires` JUnit Jupiter module(s)
   - ensure every test package `opens ... to org.junit.platform.commons`
   - ensure packages requiring injection open to `com.google.guice`
   - ensure DTO/JSON deserialization packages open to `com.fasterxml.jackson.databind`
   - ensure Vert.x packages open to `com.guicedee.vertx`
   - safe default: open each used package to all required runtime targets
5. Create or repair bootstrap `main()` class with:
   - `LogUtils.addHighlightedConsoleLogger(Level.DEBUG)`
   - `IGuiceContext.registerModule("<mainModule>")`
   - `IGuiceContext.instance().inject()`
6. If lifecycle customization exists, ensure SPI implementations are correctly dual-registered:
   - `com.guicedee.client.services.lifecycle.IGuicePreStartup`
   - `com.guicedee.client.services.lifecycle.IGuiceModule`
   - `com.guicedee.client.services.lifecycle.IGuicePostStartup`
   - Ensure each implementation overrides `sortOrder()` (from `IDefaultService<J>`)
   - registrations required in both `module-info.java` and `src/main/resources/META-INF/services/*`
7. Apply package separation:
   - test module name defaults to `<mainModule>.test`
   - test package names end with `.test`
   - no duplicate package names between main and test source roots
8. Run creator validator when available:
   - `python3 ../guicedee-creator/scripts/verify_guicedee_baseline.py --project-root .`
   - If not installed side-by-side, apply the checklist manually.

## Migration Rules
- Prefer forward-only edits: change files to final target state in one pass.
- Do not keep old Java/Maven compatibility profiles when they conflict with Maven 4/JDK 25 baseline.
- Keep module/package naming deterministic to avoid split-package issues in JPMS tests.
- `pom.xml` must include `org.junit.jupiter:junit-jupiter` with `test` scope.
- Safe module rule: open used main packages to `com.google.guice`, `com.fasterxml.jackson.databind`, and `com.guicedee.vertx`; include `org.junit.platform.commons` for test packages.

## References
- `references/retrofit-checklist.md` - patch checklist and exact BOM snippet.
