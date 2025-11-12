# Java Usage Guide — AgCharts Enterprise with JWebMP (Java only)

Purpose
- Provide a concrete, Java-only walkthrough for using AG Charts Enterprise via this JWebMP plugin. No manual Angular or TypeScript edits are required.

Prerequisites
- Dependencies in your host app:
  - com.jwebmp.plugins:agcharts (community)
  - com.jwebmp.plugins:agcharts-enterprise (this module)
- Prefer the JWebMP BOM for version alignment.
- Ensure the plugin is on the classpath so its Page Configurator is discovered.

1) Add Maven dependencies (example)
```text
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.jwebmp</groupId>
      <artifactId>jwebmp-bom</artifactId>
      <version>${jwebmp.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
  
</dependencyManagement>
<dependencies>
  <dependency>
    <groupId>com.jwebmp.plugins</groupId>
    <artifactId>agcharts</artifactId>
  </dependency>
  <dependency>
    <groupId>com.jwebmp.plugins</groupId>
    <artifactId>agcharts-enterprise</artifactId>
  </dependency>
</dependencies>
```

2) Verify Page Configurator discovery
- The enterprise plugin contributes a Page Configurator that declares the NPM dependency: `ag-charts-enterprise` via `@TsDependency`.
- At build, the generated Angular workspace should include `ag-charts-enterprise` in package.json.

3) Create a chart in Java
```text
public class RevenueChart<J extends RevenueChart<J>> extends Div<J> {
    public RevenueChart() {
        AgChartComponent<?> chart = new AgChartComponent<>()
            .withTitle("Revenue by Quarter")
            .withOption("series[0].type", "column")
            .withOption("series[0].xKey", "quarter")
            .withOption("series[0].yKey", "revenue")
            .withLegendShown(true)
            .withData(List.of(
                Map.of("quarter", "Q1", "revenue", 120_000),
                Map.of("quarter", "Q2", 150_000),
                Map.of("quarter", "Q3", 170_000),
                Map.of("quarter", "Q4", 190_000)
            ));
        add(chart);
    }
}
```

4) Optional: Combine charts with AG Grid Enterprise
- For dashboards, pair the JWebMP AG Grid plugin with charts. Use grid selection events to update charts (and vice versa) via shared context ids or app events.
- Keep shared keys stable (e.g., region, productId) across grid rows and chart series data.

5) Licensing and activation
- AG Charts Enterprise requires a license key. Do not commit secrets.
- Initialize on the client using a small server-injected script (see Licensing & Activation doc). Example pattern:
```text
// In a Page Configurator implementation — illustrative only
String agLicense = secrets.get("AG_CHARTS_ENTERPRISE_LICENSE_KEY");
if (agLicense != null && !agLicense.isEmpty()) {
    page.add(new Script<>()
        .add("window.AG_CHARTS_LICENSE_KEY='" + JsUtils.escapeJs(agLicense) + "';\n"));
}
```

6) Validation checklist
- Build includes `ag-charts-enterprise` in generated Angular app.
- No errors from missing peer deps (community charts and angular bridge remain from the community plugin).
- Enterprise-only features (e.g., treemap, waterfall, navigator) render correctly.

References
- Integration — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Licensing & Activation — ./licensing-and-activation.rules.md
- Usage Examples — ./usage-examples.rules.md
- Glossary — ./GLOSSARY.md
