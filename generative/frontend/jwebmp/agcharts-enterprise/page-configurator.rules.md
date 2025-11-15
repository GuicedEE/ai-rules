# Page Configurator — AgCharts Enterprise

Overview
- The plugin provides an auto-discovered Page Configurator that ensures `ag-charts-enterprise` is available to the Angular build when this module is on the classpath.
- Discovery uses JWebMP/GuicedEE conventions (ServiceLoader). No manual wiring is required in typical applications.

TypeScript dependency wiring
- Use `@TsDependency(name = "ag-charts-enterprise")` within the configurator to pull the NPM package into the generated Angular project.
- This plugin uses `@NgBootImportReference` to import AG Charts Enterprise modules: `AgChartsEnterprise` from `ag-charts-enterprise` and `AgChartsModule` from `ag-charts-angular`.
- The enterprise plugin complements the community plugin dependencies; it does not replace them.
- Do not edit generated TS; all dependency inclusion is declarative via annotations and build-time processing.

Ordering and coexistence
- The enterprise configurator should be independent and additive. It must not conflict with the community configurator.
- If using feature flags in host projects, gate the enterprise configurator via standard JWebMP configuration mechanisms.

Validation checklist
- Module on classpath? The configurator must be discoverable at runtime/build time.
- Dependency present? Confirm `package.json` in the generated Angular app includes `ag-charts-enterprise`.
- Build succeeds? If not, see troubleshooting.

See also
- Integration overview — ./agcharts-enterprise-integration.rules.md
- Troubleshooting — ./troubleshooting.rules.md
