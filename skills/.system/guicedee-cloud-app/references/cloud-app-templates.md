# Cloud App Templates

Copy-ready templates for a multi-module GuicedEE cloud application. Placeholders:
`<group>` (e.g. `world.ne1`), `<platform>` artifactId (e.g. `platform`),
`<svc>` service artifactId (e.g. `service-registry`), `<module.name>` JPMS name
(e.g. `world.ne1.serviceregistry`).

## Table of Contents
- [1. Aggregator / parent POM](#1-aggregator--parent-pom)
- [2. BOM POM](#2-bom-pom)
- [3. Service module POM](#3-service-module-pom)
- [4. Service module-info.java](#4-service-module-infojava)
- [5. PlatformConfig (telemetry + metrics)](#5-platformconfig-telemetry--metrics)
- [6. Bootstrap main()](#6-bootstrap-main)
- [7. REST resource + readiness check](#7-rest-resource--readiness-check)
- [8. docker-compose.yml](#8-docker-composeyml)
- [9. Observability files layout](#9-observability-files-layout)

---

## 1. Aggregator / parent POM

`<platform>/pom.xml` — packaging `pom`, lists modules (bom first), imports the BOM,
pins JDK 25, enforces Maven 4 + Java 25. No dependency versions here.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.1.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.1.0 http://maven.apache.org/xsd/maven-4.1.0.xsd">
    <modelVersion>4.1.0</modelVersion>

    <groupId><group></groupId>
    <artifactId>platform</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <modules>
        <module>bom</module>          <!-- MUST be first: resolves versions for siblings -->
        <module><svc></module>
    </modules>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.release>25</maven.compiler.release>
        <maven.compiler.source>25</maven.compiler.source>
        <maven.compiler.target>25</maven.compiler.target>
        <ne1-bom.version>1.0.0-SNAPSHOT</ne1-bom.version>
        <maven-enforcer-plugin.version>3.6.2</maven-enforcer-plugin.version>
        <maven-compiler-plugin.version>3.14.1</maven-compiler-plugin.version>
        <maven-surefire-plugin.version>3.5.4</maven-surefire-plugin.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId><group></groupId>
                <artifactId>bom</artifactId>
                <version>${ne1-bom.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>${maven-compiler-plugin.version}</version>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-surefire-plugin</artifactId>
                    <version>${maven-surefire-plugin.version}</version>
                </plugin>
            </plugins>
        </pluginManagement>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-enforcer-plugin</artifactId>
                <version>${maven-enforcer-plugin.version}</version>
                <executions>
                    <execution>
                        <id>enforce-baseline</id>
                        <goals><goal>enforce</goal></goals>
                        <configuration>
                            <rules>
                                <requireMavenVersion><version>[4.0.0-rc-5,)</version></requireMavenVersion>
                                <requireJavaVersion><version>[25,)</version></requireJavaVersion>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## 2. BOM POM

`<platform>/bom/pom.xml` — packaging `pom`, the **only** place upstream versions
live. Often a git submodule of its own. Shared dependencies declared here are
inherited by every consuming module.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.1.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.1.0 http://maven.apache.org/xsd/maven-4.1.0.xsd">
    <modelVersion>4.1.0</modelVersion>

    <groupId><group></groupId>
    <artifactId>bom</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <properties>
        <guicedee.version>2.1.1-SNAPSHOT</guicedee.version>
        <activitymaster.version>3.0.0-SNAPSHOT</activitymaster.version>
        <jwebmp.version>2.0.3-SNAPSHOT</jwebmp.version>
    </properties>

    <!-- Inherited by every module -->
    <dependencies>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.guicedee</groupId>
                <artifactId>guicedee-bom</artifactId>
                <version>${guicedee.version}</version>
                <type>pom</type><scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.jwebmp</groupId>
                <artifactId>jwebmp-bom</artifactId>
                <version>${jwebmp.version}</version>
                <type>pom</type><scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.activity-master</groupId>
                <artifactId>activity-master-bom</artifactId>
                <version>${activitymaster.version}</version>
                <type>pom</type><scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.guicedee</groupId>
                <artifactId>tests-bom</artifactId>
                <version>${guicedee.version}</version>
                <type>pom</type><scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

---

## 3. Service module POM

`<platform>/<svc>/pom.xml` — packaging `jar`, parent is the platform POM,
dependencies are **version-less**. One feature = one `com.guicedee:<artifact>`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.1.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.1.0 http://maven.apache.org/xsd/maven-4.1.0.xsd">
    <modelVersion>4.1.0</modelVersion>

    <parent>
        <groupId><group></groupId>
        <artifactId>platform</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId><svc></artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <dependency><groupId>com.guicedee</groupId><artifactId>service-registry</artifactId></dependency>
        <dependency><groupId>com.guicedee</groupId><artifactId>health</artifactId></dependency>
        <dependency><groupId>com.guicedee</groupId><artifactId>openapi</artifactId></dependency>
        <dependency><groupId>com.guicedee</groupId><artifactId>rest</artifactId></dependency>
        <dependency><groupId>com.guicedee</groupId><artifactId>guiced-telemetry</artifactId></dependency>
        <dependency><groupId>com.guicedee</groupId><artifactId>metrics</artifactId></dependency>

        <dependency><groupId>org.junit.jupiter</groupId><artifactId>junit-jupiter</artifactId><scope>test</scope></dependency>
        <dependency><groupId>org.mockito</groupId><artifactId>mockito-junit-jupiter</artifactId><scope>test</scope></dependency>
    </dependencies>
</project>
```

---

## 4. Service module-info.java

`requires transitive` for features whose types appear in your public API; plain
`requires` otherwise. Open injected/JSON/REST packages to the right targets.
`@Counted`/`@Timed` require `com.codahale.metrics`.

```java
module <module.name> {
    requires transitive com.guicedee.service.registry;
    requires transitive com.guicedee.health;     // brings microprofile.health transitively
    requires transitive com.guicedee.openapi;     // serves /openapi.json + /openapi.yaml
    requires transitive com.guicedee.rest;        // brings jakarta.ws.rs transitively
    requires transitive com.guicedee.telemetry;   // @Trace / @TelemetryOptions
    requires transitive com.guicedee.metrics;     // @MetricsOptions + /metrics endpoint
    requires com.codahale.metrics;                // @Counted / @Timed + MetricRegistry

    requires com.guicedee.client;
    requires org.apache.logging.log4j;

    opens <module.name>            to com.google.guice, com.guicedee.vertx, com.fasterxml.jackson.databind;
    opens <module.name>.rest       to com.google.guice, com.guicedee.rest, com.fasterxml.jackson.databind;
    opens <module.name>.health     to com.google.guice;

    exports <module.name>;
    // Export the metered package to the test module to drive resources directly:
    exports <module.name>.rest to <module.name>.test;
}
```

---

## 5. PlatformConfig (telemetry + metrics)

One scanned class. `otlpEndpoint` is a **base** URL (telemetry module appends
`/v1/traces` and `/v1/logs`). Use `${ENV:default}` placeholders.

```java
import com.guicedee.metrics.MetricsOptions;
import com.guicedee.telemetry.TelemetryOptions;

@TelemetryOptions(
        serviceName = "<svc>",
        otlpEndpoint = "${TELEMETRY_OTLP_ENDPOINT:http://localhost:4318}",
        serviceVersion = "${TELEMETRY_SERVICE_VERSION:1.0.0}",
        deploymentEnvironment = "${ENVIRONMENT:development}",
        exportLogs = true,
        configureLogs = true)
@MetricsOptions(
        enabled = true,
        jmxEnabled = true,
        baseName = "<svc_snake>",
        prometheus = @MetricsOptions.PrometheusOptions(enabled = true, endpoint = "/metrics"))
public class PlatformConfig { }
```

---

## 6. Bootstrap main()

```java
import com.guicedee.client.Environment;
import com.guicedee.client.IGuiceContext;
import com.guicedee.client.utils.LogUtils;
import org.apache.logging.log4j.Level;

public class <App> {
    public static void main(String[] args) {
        LogUtils.addHighlightedConsoleLogger(Level.INFO);
        IGuiceContext.registerModule("<module.name>");
        System.setProperty("HTTP_ENABLED", "false");
        System.setProperty("HTTPS_ENABLED", "true");
        System.setProperty("HTTPS_KEYSTORE", "app.p12");
        IGuiceContext.instance().inject();   // boots Vert.x web server + all features
    }
}
```

---

## 7. REST resource + readiness check

```java
@Path("/registry")
public class RegistryResource {
    @GET @Path("/{name}/url") @Produces(MediaType.TEXT_PLAIN)
    @Trace("registry-resolve-url")
    @Counted(name = "ne1_registry_url_requests_total", absolute = true, description = "url lookups")
    @Timed(name = "ne1_registry_url_seconds", absolute = true, description = "url lookup duration")
    public String url(@PathParam("name") String name) {
        return ServiceRegistry.url(name);
    }
}
```

```java
@Readiness
public class RegistryReadinessCheck implements HealthCheck {
    @Override public HealthCheckResponse call() {
        return HealthCheckResponse.named("<svc>").up()
                .withData("component", "<svc>").build();
    }
}
```

---

## 8. docker-compose.yml

Keycloak (+Postgres) + OTel Collector + Tempo/Loki/Prometheus + Grafana. The app
runs on the host and points `@TelemetryOptions.otlpEndpoint` at
`http://localhost:4318`.

```yaml
services:
  keycloak-db:
    image: postgres:18-alpine
    environment: { POSTGRES_DB: keycloak, POSTGRES_USER: keycloak, POSTGRES_PASSWORD: keycloak }
    volumes: [ "keycloak-db-data:/var/lib/postgresql" ]
    healthcheck: { test: ["CMD-SHELL","pg_isready -U keycloak -d keycloak"], interval: 10s, timeout: 5s, retries: 5 }
    networks: [ keycloak-net ]

  keycloak:
    image: quay.io/keycloak/keycloak:26.6.3
    command: start-dev --import-realm
    depends_on: { keycloak-db: { condition: service_healthy } }
    environment:
      KC_BOOTSTRAP_ADMIN_USERNAME: admin
      KC_BOOTSTRAP_ADMIN_PASSWORD: admin
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak
      KC_HTTP_ENABLED: "true"
      KC_HOSTNAME_STRICT: "false"
      KC_HEALTH_ENABLED: "true"
      KC_METRICS_ENABLED: "true"
    ports: [ "8080:8080", "9000:9000" ]
    volumes: [ "./keycloak/import:/opt/keycloak/data/import:ro" ]
    networks: [ keycloak-net ]

  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.115.1
    command: ["--config=/etc/otelcol/config.yaml"]
    volumes: [ "./observability/otel-collector-config.yaml:/etc/otelcol/config.yaml:ro" ]
    ports: [ "4317:4317", "4318:4318", "8889:8889" ]   # gRPC, HTTP, Prometheus exporter
    depends_on: [ tempo, loki, prometheus ]
    networks: [ observability-net ]

  tempo:
    image: grafana/tempo:2.7.1
    command: ["-config.file=/etc/tempo/tempo.yaml"]
    volumes: [ "./observability/tempo.yaml:/etc/tempo/tempo.yaml:ro", "tempo-data:/var/tempo" ]
    ports: [ "3200:3200" ]
    networks: [ observability-net ]

  loki:
    image: grafana/loki:3.4.1
    command: ["-config.file=/etc/loki/loki.yaml"]
    volumes: [ "./observability/loki.yaml:/etc/loki/loki.yaml:ro", "loki-data:/loki" ]
    ports: [ "3100:3100" ]
    networks: [ observability-net ]

  prometheus:
    image: prom/prometheus:v3.1.0
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.enable-remote-write-receiver"
      - "--enable-feature=exemplar-storage"
    volumes: [ "./observability/prometheus.yml:/etc/prometheus/prometheus.yml:ro", "prometheus-data:/prometheus" ]
    ports: [ "9090:9090" ]
    networks: [ observability-net ]

  grafana:
    image: grafana/grafana:11.5.1
    environment:
      GF_AUTH_ANONYMOUS_ENABLED: "true"
      GF_AUTH_ANONYMOUS_ORG_ROLE: "Admin"
      GF_AUTH_DISABLE_LOGIN_FORM: "true"
      GF_FEATURE_TOGGLES_ENABLE: "traceqlEditor traceToMetrics"
    volumes: [ "./observability/grafana/provisioning:/etc/grafana/provisioning:ro", "grafana-data:/var/lib/grafana" ]
    ports: [ "3000:3000" ]
    depends_on: [ prometheus, tempo, loki ]
    networks: [ observability-net ]

volumes: { keycloak-db-data: , tempo-data: , loki-data: , prometheus-data: , grafana-data: }
networks: { keycloak-net: { driver: bridge }, observability-net: { driver: bridge } }
```

---

## 9. Observability files layout

```
observability/
├── otel-collector-config.yaml   receivers(otlp) → exporters(otlp/tempo, loki, prometheus :8889)
├── tempo.yaml                   traces store, query API :3200
├── loki.yaml                    log store :3100
├── prometheus.yml               scrape otel-collector :8889 (+ app /metrics)
└── grafana/provisioning/
    ├── datasources/datasources.yaml   Tempo + Loki + Prometheus pre-wired
    └── dashboards/dashboards.yaml      auto-load *.json dashboards
keycloak/import/                  drop realm *.json here (loaded via --import-realm)
```

Endpoints once running:
- App: `https://localhost:8443` (HTTPS) — `/registry/*`, `/health/{live,ready}`,
  `/openapi.json`, `/openapi.yaml`, `/swagger/`, `/metrics`.
- Grafana `http://localhost:3000` (anonymous Admin) → Explore: Tempo / Loki / Prometheus.
- Keycloak `http://localhost:8080` (admin/admin); OIDC issuer `/realms/<realm>`.

