# Glossary — AgCharts Enterprise (JWebMP Plugin)

Purpose
- Minimal authoritative glossary for this plugin. Host projects should copy only enforced aligned names and link back to this glossary.

Terms
- AgCharts Community: The free/community edition of AG Charts used by the base JWebMP AgCharts plugin.
- AgCharts Enterprise: The paid edition providing additional chart types and features; enabled via this plugin.
- Page Configurator: An auto-discovered JWebMP component that contributes frontend dependencies and settings, including TypeScript libs via annotations.
- @TsDependency: Annotation used to declare a TypeScript/NPM dependency (e.g., name = "ag-charts-enterprise").
- CRTP (Curiously Recurring Template Pattern): Fluent API pattern used across JWebMP/GuicedEE where setters return (J)this.

LLM guidance
- Do not propose edits to generated artifacts (TS/HTML/site bundles); treat them as read-only.
- Prefer JWebMP components over inline HTML strings.
- Respect Forward-Only change policy.

Links
- Plugin rules index — ./README.md
- Angular language rules index — ../../../language/angular/README.md
