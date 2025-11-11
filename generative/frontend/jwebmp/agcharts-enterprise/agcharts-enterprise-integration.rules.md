# AgCharts Enterprise Integration — Rules

Overview
- This module extends the community AgCharts plugin to activate AG Charts Enterprise features in JWebMP applications.
- It mirrors the model used by WebAwesomePro extending WebAwesome and FullCalendarPro extending FullCalendar.

Usage patterns
- Add Maven dependency: com.jwebmp.plugins:agcharts-enterprise:${version} (version via BOM recommended).
- Keep community plugin dependency present: com.jwebmp.plugins:agcharts.
- Use charts as normal through JWebMP; enterprise features become available on the client when the Page Configurator includes the TypeScript dependency for `ag-charts-enterprise`.

Minimal example
- Server-side (Java/JWebMP): continue to construct charts as with the community plugin; no API change required for basic usage.
- Ensure the Page Configurator from this module is on the classpath (auto-discovery via Java ServiceLoader and JWebMP conventions).

Configuration
- TypeScript dependency: `ag-charts-enterprise` is pulled in by the Page Configurator using @TsDependency.
- Angular peer dependencies: community plugin typically includes `ag-charts-community` and `ag-charts-angular`; this enterprise plugin complements them.

Performance/constraints
- Do not bundle or edit generated TS; rely on the build to include dependencies.
- Enterprise features may increase bundle size; tree-shake when possible.
- Licensing is required per AG Charts Enterprise terms; see licensing-and-activation.rules.md.

See also
- Page Configurator — ./page-configurator.rules.md
- Licensing — ./licensing-and-activation.rules.md
- Usage examples — ./usage-examples.rules.md
- Troubleshooting — ./troubleshooting.rules.md
- Angular index — ../../../language/angular/README.md
