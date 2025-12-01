# Scanning & Runtime Wiring Rules

Purpose
- Ensure Ng* metadata is discovered and processed at startup without blocking Guice/Vert.x, keeping module boundaries and logging aligned with project policies.

Startup flow
- `AngularClientModule` and `AngularTypeScriptClientModuleInclusion` register the library for scan; keep them exported in `module-info.java` alongside annotation packages.
- `AngularTypeScriptPostStartup` implements `IGuicePostStartup` and invokes `AnnotationHelper.startup()` via Vert.x `executeBlocking`; never run scans on event-loop threads.
- `GuicedConfig` enables classpath/annotation/field/method info; avoid disabling scan flags unless tests explicitly mock them.

ClassGraph usage
- Do not hardcode package lists; rely on ClassGraph defaults plus GuicedEE configuration to find annotated classes.
- When filtering classes, prefer annotation presence over naming conventions; respect inheritance flags (e.g., parent vs. self) to avoid duplicate Ng entries.
- `AnnotationsMap` is the canonical store for scan results; mutate it via provided helpers instead of ad-hoc collections.

Logging & errors
- Use Lombok `@Log4j2` for any new logging; do not mix logging APIs.
- Surface scan failures as errors with class names; recover by continuing other classes to avoid halting the pipeline.
- Keep stack traces in debug logs; default logs should summarize counts of components/directives/providers discovered.

Performance & threading
- Leave scan execution in Vert.x blocking workers; if new blocking work is added, wrap it in `executeBlocking`.
- Avoid file-system writes during scanning; build outputs should be produced only by downstream render/composition steps.

Module boundaries
- Update `module-info.java` exports/opens only with justification; ensure ServiceLoader files under `META-INF/services/` stay synchronized with bindings.
- Generated TS should never be stored inside the module; emit strings for downstream builders instead.

See also
- Index — `README.md`
- Annotations — `annotations.rules.md`
- Configuration/rendering — `configuration-rendering.rules.md`
- Testing — `testing.rules.md`
