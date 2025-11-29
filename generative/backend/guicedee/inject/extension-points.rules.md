# Extension Points (SPI) — GuicedEE Inject

Purpose
- Describe SPI contracts and how to register extensions for scanning, module/binder composition, configuration, and lifecycle hooks.

Key SPI surfaces (examples)
- Scanners: `PackageContentsScanner`, `FileContentsScanner`, `IPathContentsScanner`, `IPathContentsRejectListScanner`, `IGuiceScanModuleInclusions/Exclusions`, `IGuiceScanJarInclusions/Exclusions`
- Modules and binders: `IGuiceModule`, `IGuiceProvider`, `IGuiceConfigurator`, `GuiceDefaultBinder`, `GuiceSiteBinder`
- Lifecycle: `IGuicePreStartup`, `IGuicePostStartup`, `IGuicePreDestroy`
- Jobs: `IJobServiceProvider`
- URL handler: `java.net.spi.URLStreamHandlerProvider` (JRT)

Registration rules
- Dual registration is mandatory: add `META-INF/services/<fqcn>` entries and mirror with `module-info.java provides ... with ...;` plus `uses` where relevant.
- Keep provider classes side-effect free on load; perform work in interface methods.
- Group related providers per module to keep classpath scanning predictable; avoid scattering singletons across many JARs.

Design constraints
- Fluent APIs use CRTP; avoid Lombok builders in extension APIs.
- JSpecify: annotate nullness where available; treat unannotated parameters as non-null by default.
- Forward-only: when retiring or replacing an SPI, update rules and release notes in the same change set; do not reintroduce deprecated providers.

Examples and contracts
- Provide minimal examples in host guides showing ServiceLoader files and JPMS snippets. Keep examples aligned with docs/architecture/sequence-spi-discovery.md.

References
- Glossary: ../../../../GLOSSARY.md (topic-first)
- Architecture flows: docs/architecture/sequence-spi-discovery.md, docs/architecture/c4-component-inject.md
