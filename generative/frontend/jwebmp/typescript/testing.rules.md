# Testing & Validation Rules

Scope
- Validate annotation discovery, configuration assembly, and render output without touching generated TS files.

Unit strategy
- Extend `AnnotationHelperTest` with fixtures that assert `AnnotationsMap` contents for components/directives/providers, including inheritance and ignore flags.
- Add focused tests for `splitComponentReferences()` to ensure import/provider tokens resolve correctly when modules/namespaces differ.
- Cover render helpers by snapshotting strings (in-memory) for hooks, fields, signals, and models; avoid filesystem writes.

Integration/lightweight
- Instantiate `AngularTypeScriptPostStartup` with a Vert.x test instance to confirm futures complete and maps populate; keep it off the event loop.
- Verify ServiceLoader registration via `META-INF/services` entries (module inclusion, configurators) aligns with `module-info.java`.

Static checks
- Enforce module boundaries and JSpecify nullness expectations; avoid widening nullability when mapping to TS.
- Logging assertions: ensure errors are logged with class names; debug logs capture counts of discovered artifacts.

CI expectations
- Maven: `mvn test` as baseline; keep tests isolated (no external services).
- GitHub Actions: use shared workflow defined in `.github/workflows/maven-package.yml`; ensure required secrets exist before enabling releases.

See also
- Index — `README.md`
- Runtime wiring — `scanning-runtime.rules.md`
- Configuration/rendering — `configuration-rendering.rules.md`
