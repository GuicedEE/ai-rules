# Testing Strategy — GuicedEE Inject

Goals
- Validate scanning/SPI registration, injector assembly, logging/bootstrap behavior, and shutdown paths without coupling to host runtimes.

Recommended layers
- Unit: verify scanners (PackageContentsScanner/FileContentsScanner) and registry composition in isolation; use in-memory classpath fixtures/resources.
- SPI wiring: assert ServiceLoader discovery for modules/binders/configurators and dual registration (META-INF/services + module-info). Include JPMS layer tests when possible.
- Injector assembly: build minimal injectors with CRTP modules; confirm @InjectLogger injection and AOP interceptors activate.
- Job service: test virtual-thread executor sizing and shutdown hooks; ensure no leaked threads after tests.
- URL handler: smoke-test JRT URL resolution for module resources.
- Integration (optional): combine adapter modules (e.g., Vert.x) only in adapter-specific suites to keep core tests runtime-agnostic.

Tooling and policies
- Java 25 LTS, Maven Surefire/Failsafe; avoid adding extra build plugins in docs.
- Keep tests deterministic; avoid network/IO dependencies beyond local resources.
- Coverage of forward-only changes: when introducing/removing SPIs or configuration keys, add/adjust tests in the same change set and update release notes.

References
- Architecture flows for test scenarios: docs/architecture/sequence-runtime-injection.md, docs/architecture/sequence-spi-discovery.md, docs/architecture/sequence-logger-injection.md, docs/architecture/sequence-job-service.md
