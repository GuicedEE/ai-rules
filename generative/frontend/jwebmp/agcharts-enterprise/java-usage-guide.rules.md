# Java Usage Guide — AgCharts Enterprise with JWebMP (Java only)

Purpose
- Provide a concrete, Java-only walkthrough for using AG Charts Enterprise via this JWebMP plugin. No manual Angular or TypeScript edits are required.
- Before using these steps, load `docs/PROMPT_REFERENCE.md` to ensure the architecture diagrams and policy selections are pinned for prompts/agents.

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
- Angular Boot Import References ensure proper module imports: `AgChartsEnterpriseModule` from `ag-charts-enterprise` and `AgChartsModule` from `ag-charts-angular`.
- At build time, the generated Angular workspace should include `ag-charts-enterprise` and `ag-charts-angular` in package.json.

3) Create a chart in Java

#### Basic Column Chart
```java
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

#### Hierarchical Series (v2.0.0+)

Sankey Flow Chart
```java
public class ProcessFlowChart<J extends ProcessFlowChart<J>> extends Div<J> {
    public ProcessFlowChart() {
        AgSankeyChart<?> chart = new AgSankeyChart<>("process-flow")
            .setSourceKey("from")
            .setTargetKey("to")
            .setValueKey("amount")
            .setData(List.of(
                Map.of("from", "Sales", "to", "Processing", "amount", 120),
                Map.of("from", "Processing", "to", "Fulfillment", "amount", 100),
                Map.of("from", "Fulfillment", "to", "Delivery", "amount", 95)
            ))
            .setNodeFill("#2ca02c")
            .setNodePaddingTop(10)
            .setNodePaddingRight(10)
            .setNodePaddingBottom(10)
            .setNodePaddingLeft(10);
        add(chart);
    }
}
```

Treemap Hierarchy
```java
public class OrgChartTreemap<J extends OrgChartTreemap<J>> extends Div<J> {
    public OrgChartTreemap() {
        AgTreemapChart<?> chart = new AgTreemapChart<>("org-treemap")
            .setLabelKey("name")
            .setSecondaryLabelKey("department")
            .setValueKey("headcount")
            .setColorKey("performance")
            .setData(List.of(
                Map.of("name", "Engineering", "department", "Tech", "headcount", 50, "performance", 85),
                Map.of("name", "Sales", "department", "Revenue", "headcount", 30, "performance", 72)
            ))
            .setColorScale("viridis")
            .setColorDomain(100.0);
        add(chart);
    }
}
```

Sunburst Circular Hierarchy
```java
public class HierarchySunburst<J extends HierarchySunburst<J>> extends Div<J> {
    public HierarchySunburst() {
        AgSunburstChart<?> chart = new AgSunburstChart<>("hierarchy")
            .setLabelKey("name")
            .setValueKey("value")
            .setColorKey("metric")
            .setData(List.of(
                Map.of("name", "Root", "value", 1000, "metric", 50),
                Map.of("name", "Branch A", "value", 600, "metric", 65)
            ))
            .setColorScale("plasma");
        add(chart);
    }
}
```

Chord Relationship Network
```java
public class RelationshipChord<J extends RelationshipChord<J>> extends Div<J> {
    public RelationshipChord() {
        AgChordChart<?> chart = new AgChordChart<>("relationships")
            .setSourceKey("source")
            .setTargetKey("target")
            .setValueKey("strength")
            .setData(List.of(
                Map.of("source", "Node A", "target", "Node B", "strength", 50),
                Map.of("source", "Node B", "target", "Node C", "strength", 35),
                Map.of("source", "Node C", "target", "Node A", "strength", 42)
            ))
            .setNodePaddingAngle(5);
        add(chart);
    }
}
```

Funnel Conversion Pipeline
```java
public class SalesFunnel<J extends SalesFunnel<J>> extends Div<J> {
    public SalesFunnel() {
        AgFunnelChart<?> chart = new AgFunnelChart<>("sales-funnel")
            .setLabelKey("stage")
            .setValueKey("count")
            .setData(List.of(
                Map.of("stage", "Awareness", "count", 1000),
                Map.of("stage", "Interest", "count", 700),
                Map.of("stage", "Decision", "count", 400),
                Map.of("stage", "Purchase", "count", 100)
            ))
            .setOrientation("vertical");
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
