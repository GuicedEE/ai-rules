# Configuration and Scanning — GuicedEE Inject

Purpose
- Document configuration surfaces for classpath scanning, SPI registration, logging/bootstrap tuning, job service sizing, and JRT URL handling.

Classpath scanning
- Package scanning: implement and register `PackageContentsScanner` to whitelist package prefixes. Favor explicit allowlists; avoid blanket root scans.
- File contents scanning: implement `FileContentsScanner` to register `FileMatchContentsProcessorWithContext` processors keyed by filename/path. Use for targeted metadata/config ingestion only.
- Inclusion/exclusion: expose configuration for jar/package allow/deny lists (e.g., `IGuiceScanJarInclusions/Exclusions`, `IGuiceScanModuleInclusions/Exclusions`, `IPathContentsScanner/RejectList`). Default to self-whitelisting; host apps extend via SPI.
- Ordering: scanners run before ServiceLoader module/binder discovery; avoid relying on scan order for correctness.

Logging bootstrap
- Configure via environment/system properties for log level/layout; keep defaults console-friendly. Log4JConfigurator SPI may extend appenders/layouts but must sanitize external inputs.
- Logger injection: ensure @InjectLogger is enabled through the TypeListener; avoid injecting into classes outside whitelisted modules when security is a concern.

Job service configuration
- Set virtual-thread pool sizes and polling intervals through configuration; choose safe defaults for server workloads. Provide shutdown timeouts and backoff strategies for polling tasks.
- Avoid blocking operations on event-loop threads when used alongside Vert.x adapters.

URL handler (JRT)
- Register the `java.net.spi.URLStreamHandlerProvider` via SPI/JPMS; handler should restrict to `jrt:` module resources and must not fetch remote content.

JPMS and ServiceLoader registration
- Always dual-register SPIs: `module-info.java` `uses` + `provides` and `META-INF/services/` entries to support both module path and classic classpath.
- Keep module names stable; document new services in CHANGELOG/RELEASE_NOTES when added or removed.

References
- Architecture diagrams and prompt reference: docs/architecture/README.md, docs/PROMPT_REFERENCE.md
