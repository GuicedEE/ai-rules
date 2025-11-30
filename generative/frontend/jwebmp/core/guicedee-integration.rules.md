# GuicedEE Integration Rules

Overview
- Guice bindings live in `com.jwebmp.core.implementations.*` and are declared via JPMS `provides` entries plus service files under `src/main/resources/META-INF/services`.
- `JWebMPServicesBindings` binds `IPage` to `Page` and exposes provider sets for configurators and render hooks using `IGuiceContext.getLoader(...)`.
- `JWebMPPreStartup` registers `JWebMPJacksonModule` with the shared `ObjectMapper` on startup (Vert.x execution).
- `JWebMPModuleInclusions` ensures `com.jwebmp.core` packages are included during Guice scanning.

Integration Steps
1) Add the artifact coordinate to host apps: `com.jwebmp.core:jwebmp-core:2.0.0-SNAPSHOT` (align with BOMs in `pom.xml`).
2) Keep JPMS consistent: retain `uses` entries for `IPageConfigurator`, `IPage`, `IRegularExpressions`, `Render*` hooks, and `IOn*` event services; add `exports/opens` only when new packages need reflection by Guice/Jackson.
3) Register additional providers through `META-INF/services` rather than manual injector bindings; `JWebMPServicesBindings` surfaces them as singleton sets.
4) Vert.x bridge: rely on `com.guicedee.vertx` and the GuicedEE Vert.x pre-startup hook; avoid direct Vert.x bootstrap in this module.

Patterns & Guardrails
- Providers must be safe to load in ServiceLoader context (no heavy static init); use Guice scopes for expensive resources.
- Keep `sortOrder()` in `IGuicePreStartup` implementations explicit to control startup ordering (current value: `15`).
- Do not shade dependencies (e.g., Vert.x, PostgreSQL drivers per policy); prefer GuicedEE services artifacts.
- Maintain forward-only bindings; replace outdated bindings instead of adding legacy aliases.

See also
- Topic index: ./README.md
- Architecture diagrams: docs/architecture/c4-container.md, docs/architecture/sequence-event.md (host repository)
- Enterprise rules: ../../backend/guicedee/README.md, ../../backend/guicedee/client/README.md, ../../backend/guicedee/web/README.md, ../../backend/guicedee/vertx/README.md
