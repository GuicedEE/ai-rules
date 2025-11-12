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

Java activation approaches (JWebMP)
- Goal: Initialize AG Charts Enterprise with a license key on the client without committing secrets.
- Pattern A — Inline runtime script via Page Configurator resource:
  - Contribute a small script that reads a server-exposed value and sets the global license key before charts initialize.

```text
// Example: LicenseInitializerConfigurator.java (illustrative)
@Singleton
public class LicenseInitializerConfigurator implements IPageConfigurator {

    // DO NOT hardcode the key. Fetch via your secret provider at runtime.
    private final SecretsProvider secrets; // your abstraction

    @Inject
    public LicenseInitializerConfigurator(SecretsProvider secrets) {
        this.secrets = secrets;
    }

    @Override
    public void configure(Page<?> page) {
        String agLicense = secrets.get("AG_CHARTS_ENTERPRISE_LICENSE_KEY");
        if (agLicense != null && !agLicense.isEmpty()) {
            Script<?> script = new Script<>()
                .add("// AG Charts Enterprise license init\n")
                .add("window.AG_CHARTS_LICENSE_KEY = '" + JsUtils.escapeJs(agLicense) + "';\n");
            page.add(script);
        }
    }
}
```

- Pattern B — Server templating to window-scoped config:
  - Expose a config object on `window` from a server-rendered script tag and let your chart components read it.

```text
// Example snippet in a configurator method (illustrative)
Script<?> config = new Script<>()
    .add("window.appConfig = window.appConfig || {};\n")
    .add("window.appConfig.agChartsEnterprise = { licenseKey: '" + JsUtils.escapeJs(agLicense) + "' };\n");
page.add(config);
```

Important
- Never store license keys in source control, example data, or logs.
- Prefer environment-based secrets (e.g., env vars, vault) surfaced at runtime.
- Validate in the generated Angular app that `ag-charts-enterprise` is present; the license initializer alone is insufficient without the dependency.
