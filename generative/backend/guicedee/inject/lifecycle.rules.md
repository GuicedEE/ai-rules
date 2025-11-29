# Lifecycle and Boot — GuicedEE Inject

Purpose
- Define how host projects assemble and run GuicedEE Inject: scanning → SPI discovery → registry assembly → Guice injector creation → runtime services (logging, jobs, URL handler) → shutdown.

Phases
- Discovery order: PackageContentsScanner → FileContentsScanner → ServiceLoader SPIs (modules, binders, configurators) → registry composition → Guice injector creation.
- JPMS: `module-info.java` must `uses` scanner and lifecycle SPIs and `provides` implementations. Mirror providers in `META-INF/services/` for classpath/classic loading.
- Injector creation: `GuiceContext` (or equivalent bootstrap) pulls registry results, applies CRTP-configured modules, and creates the injector with AOP enabled.
- Logging setup: Log4j2 bootstrap occurs before injector use; @InjectLogger TypeListener/MembersInjector binds after injector creation.
- Job service: Virtual-thread pools and polling executors start post-injector; ensure shutdown hooks register at bootstrap.
- URL handler: JRT `URLStreamHandlerProvider` is registered via SPI before host code resolves `jrt:` URLs.

Runtime rules
- Keep adapters optional: Vert.x integration should be loaded only when adapter artifacts are present; do not hard-require Vert.x in core boot.
- Avoid side-effects in static initializers; perform registration in SPI implementations or boot hooks.
- Shutdown: ensure PreDestroy lifecycle SPIs run and job executors/Vert.x adapters shut down gracefully.

References
- Architecture flows: docs/architecture/sequence-runtime-injection.md, docs/architecture/sequence-spi-discovery.md, docs/architecture/sequence-logger-injection.md, docs/architecture/sequence-job-service.md
- Component map: docs/architecture/c4-component-inject.md
