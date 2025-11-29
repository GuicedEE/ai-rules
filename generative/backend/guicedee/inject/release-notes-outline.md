# Release Notes Outline — GuicedEE Inject (Forward-Only)

Purpose
- Provide a template for documenting breaking forward-only changes to rules and SPI surfaces.

Sections to populate per release
- Summary: highlight breaking changes and new capabilities (e.g., new SPI types, removed providers, changes to scanning defaults).
- Compatibility: note minimum Java/Maven expectations (Java 25 LTS) and any JPMS module name updates.
- SPI changes: added/removed/renamed SPIs and required dual registration steps.
- Configuration changes: new or changed keys for scanning, logging, job service, or URL handler behavior.
- Adapter updates: optional Vert.x adapter versions and constraints; reaffirm core independence from Vert.x.
- Migration steps: actions for host projects (update ServiceLoader files/module-info, adjust allowlists/denylists, update logging config).
- References: link to docs/architecture/README.md, docs/PROMPT_REFERENCE.md, and topic rules (README.md) for context.
