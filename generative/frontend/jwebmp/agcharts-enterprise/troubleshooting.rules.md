# Troubleshooting — AgCharts Enterprise Plugin

Symptoms and fixes
- Build missing dependency `ag-charts-enterprise`
  - Ensure the enterprise module is on the classpath and its Page Configurator is discovered.
  - Verify the generated Angular app `package.json` contains `ag-charts-enterprise`.
  - Check that `@TsDependency(name = "ag-charts-enterprise")` is present in the configurator.
- Enterprise features not available at runtime
  - Confirm license initialization as per AG Charts docs.
  - Clear caches and rebuild the Angular project to ensure the dependency is included.
- Conflicts with community plugin
  - Ensure the community plugin remains present; the enterprise plugin is additive.
  - Review dependency versions via the BOM to avoid mismatches.
- Bundle size concerns
  - Enable production builds and tree-shaking; import only the needed enterprise features when applicable.

Diagnostics
- Use verbose build logs to confirm dependency inclusion steps.
- In host projects, inspect the generated Angular workspace for dependency versions and presence.

See also
- Integration overview — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing — ./licensing-and-activation.rules.md
