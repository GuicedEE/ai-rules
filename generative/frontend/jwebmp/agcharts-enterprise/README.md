# AgCharts Enterprise — JWebMP Plugin Rules Index

Use this index when generating or maintaining documentation and code related to the AgCharts Enterprise JWebMP plugin. These rules are docs-first and forward-only. Do not modify generated artifacts (TS/HTML/site bundles).

What this covers
- Integration of AG Charts Enterprise on top of the community AgCharts plugin
- Page Configurator wiring and TypeScript dependency inclusion (@TsDependency for `ag-charts-enterprise`)
- Licensing and activation notes
- Usage examples (CRTP-aligned)
- Troubleshooting and diagnostics

Quick links
- Plugin overview and integration — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing & Activation — ./licensing-and-activation.rules.md
- Java Usage Guide (Java-only) — ./java-usage-guide.rules.md
- Usage Examples (CRTP) — ./usage-examples.rules.md
- Troubleshooting — ./troubleshooting.rules.md
- Glossary — ./GLOSSARY.md

Cross-links
- JWebMP topic index — ../README.md
- Frontend category index — ../../README.md
- Angular language rules index — ../../../language/angular/README.md

Policies
- Fluent API Strategy: CRTP (return (J)this from fluent setters)
- Follow RULES.md sections 4, 5, Document Modularity Policy, and 6 (Forward-Only Change Policy)
- Do not generate or reference separate TS/HTML components for missing views; render from Java components
