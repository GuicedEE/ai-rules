# Licensing & Activation — AgCharts Enterprise

Overview
- AG Charts Enterprise requires a valid license. This plugin does not embed or manage licenses; it only enables enterprise features by wiring the client dependency.

Usage patterns
- Obtain a license from AG Grid/AG Charts per their terms.
- Provide the license key in your application according to AG Charts Enterprise documentation (typically via client-side initialization code). Do not commit license keys to source control.

Configuration
- Ensure `ag-charts-enterprise` is present in the generated Angular app so that license APIs are available.
- For server-driven initialization, surface configuration values via your standard secrets/config provider; do not hardcode.

Constraints
- Respect vendor licensing. This repository must not contain license keys or circumvention instructions.

See also
- Integration overview — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Troubleshooting — ./troubleshooting.rules.md
