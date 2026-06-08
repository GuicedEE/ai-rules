---
name: guicedee-cloud-app
description: "Scaffold or audit a multi-module GuicedEE cloud application: a pure aggregator/parent POM, a dedicated BOM submodule that imports upstream GuicedEE/JWebMP/ActivityMaster BOMs, one or more feature service modules that merge GuicedEE modules (service-registry, rest, health, openapi, telemetry, metrics) via module-info requires, and a local observability stack (OpenTelemetry Collector, Tempo, Loki, Prometheus, Grafana, Keycloak) wired through docker-compose. Use when creating a new GuicedEE cloud/microservice project from scratch, laying out the root/parent/BOM Maven topology, adding a new service module to an existing platform, wiring telemetry/metrics/health into a deployable service, or standing up the local observability backend."
metadata:
  short-description: Multi-module GuicedEE cloud application structure
---

# GuicedEE Cloud Application

Lay out a **deployable, observable GuicedEE platform** as a Maven multi-module
project. This skill owns the *project-level* topology (aggregator → BOM → service
modules → observability). For scaffolding a single module's `pom.xml` +
`module-info.java`, defer to **`guicedee-creator`**; for retrofitting an existing
module, use **`guicedee-installer`**.

## Canonical Structure

```
<platform>/                      aggregator + parent POM (packaging: pom)
├── pom.xml                      groupId:artifactId = <group>:platform
├── bom/                         BOM submodule (own git repo / submodule)
│   └── pom.xml                  imports upstream BOMs, owns ALL versions
├── <service-a>/                 feature service module (packaging: jar)
│   ├── pom.xml                  parent = platform; deps are version-less
│   └── src/main/java/
│       ├── module-info.java     requires the GuicedEE feature modules
│       ├── <App>.java           main() → IGuiceContext.instance().inject()
│       ├── <PlatformConfig>.java @TelemetryOptions + @MetricsOptions
│   │   ├── rest/                @Path resources (@Trace/@Counted/@Timed)
│   │   └── health/              @Readiness / @Liveness HealthCheck beans
├── <service-a>-jlink/           jlink image module (packaging: jlink)
│   └── pom.xml                  depends on <service-a>; maven-jlink-plugin
├── Dockerfile                   copies the jlink image; runs bin/<launcher>
├── observability/               collector + backends config (mounted by compose)
│   ├── otel-collector-config.yaml
│   ├── tempo.yaml  loki.yaml  prometheus.yml
│   └── grafana/provisioning/{datasources,dashboards}/
├── keycloak/import/             realm *.json auto-imported on startup
├── docker-compose.yml           Keycloak + OTel + Tempo/Loki/Prometheus/Grafana
├── mvnw / mvnw.cmd              Maven 4 wrapper
└── <app>.p12                    TLS keystore (HTTPS_KEYSTORE)
```

## Three POM Layers (non-negotiable)

1. **Aggregator + parent** (`pom.xml`, packaging `pom`): lists `<modules>`,
   imports the **BOM** in `dependencyManagement`, pins compiler to JDK 25, and
   runs `maven-enforcer-plugin` requiring **Maven `[4.0.0-rc-5,)`** and **Java `[25,)`**.
   It declares **no versions on dependencies** — only the BOM import.
2. **BOM** (`bom/pom.xml`, packaging `pom`): the *only* place upstream versions
   live. It imports `com.guicedee:guicedee-bom`, `com.jwebmp:jwebmp-bom`,
   `com.activity-master:activity-master-bom`, and `com.guicedee:tests-bom` (scope
   `import`, type `pom`). Consuming modules never declare versions directly.
3. **Service module** (`<svc>/pom.xml`, packaging `jar`): `<parent>` is the
   platform POM; dependencies are **version-less** (resolved by the BOM). Each
   GuicedEE feature is one `com.guicedee:<artifact>` dependency.

See `references/cloud-app-templates.md` for complete, copy-ready POM, docker-compose,
and Java templates.

## Required Flow

1. **Decide the layout.** Confirm aggregator `groupId`/`artifactId` (commonly
   `*:platform`), the BOM artifact id, and the first service module name.
2. **Aggregator/parent POM** — packaging `pom`, `<modules>` listing `bom` first
   then each service, BOM import in `dependencyManagement`, JDK 25 compiler
   props, enforcer (Maven 4 + Java 25). Add the Maven 4 wrapper (`mvnw`/`mvnw.cmd`).
3. **BOM submodule** — packaging `pom`, import the upstream BOMs and keep a single
   `<properties>` block of upstream versions (`guicedee.version`, `jwebmp.version`,
   `activitymaster.version`). Add shared `<dependencies>` (e.g. lombok `provided`,
   `junit-jupiter` test) here so every module inherits them.
4. **Service module(s)** — use **`guicedee-creator`** to scaffold each module
   (`pom.xml` + main/test `module-info.java` + bootstrap `main()`), then add the
   feature dependencies (version-less). Merge features by *requiring* their JPMS
   modules — adding the dependency + `requires` is all that's needed; each module
   self-registers its lifecycle hooks. See the merge matrix below.
5. **Platform config class** — one scanned class carrying `@TelemetryOptions` and
   `@MetricsOptions` (see `guicedee-telemetry`, `guicedee-metrics`). Point
   `otlpEndpoint` at the collector (base URL `http://localhost:4318`).
6. **Observability stack** — drop the `observability/` config files and
   `docker-compose.yml`; `docker compose up -d` brings up Keycloak + OTel
   Collector + Tempo + Loki + Prometheus + Grafana with datasources pre-provisioned.
7. **Run** — `docker compose up -d`, then run the service on the host; traces →
   Tempo, logs → Loki, metrics → Prometheus, all visible in Grafana Explore.

## Feature Merge Matrix

Add the dependency **and** the `requires` to fuse a capability into a service.
All are activated purely by being on the module path — no wiring code.

| Capability | Maven artifact (`com.guicedee:`) | `requires` module | Skill |
|---|---|---|---|
| Named service registry | `service-registry` | `com.guicedee.service.registry` | `guicedee-service-registry` |
| Automatic discovery (K8s/SRV resolver) | `service-discovery` | `com.guicedee.vertx.servicediscovery` | `guicedee-service-registry` |
| Self-registration + cloud autoconfig | `runtime-autoconfigure` | `com.guicedee.runtime.autoconfigure` | `guicedee-service-registry` |
| Jakarta REST on Vert.x | `rest` | `com.guicedee.rest` | `guicedee-rest` |
| Health probes | `health` | `com.guicedee.health` | `guicedee-health` |
| OpenAPI + Swagger | `openapi` | `com.guicedee.modules.services.openapi` ⚠ shaded name | `guicedee-openapi` |
| Tracing/logs (OTel) | `guiced-telemetry` | `com.guicedee.telemetry` | `guicedee-telemetry` |
| Metrics + Prometheus | `metrics` | `com.guicedee.metrics` (+ `com.codahale.metrics` for `@Counted`/`@Timed`) | `guicedee-metrics` |
| Reactive web server | transitive via the above | `com.guicedee.vertx` | `guicedee-web` |

> Many feature modules pull the Vert.x web server transitively (e.g. `health`).
> Booting the Guice context starts the HTTP server and mounts every merged
> feature's routes (`/registry/*`, `/health/*`, `/openapi.json`, `/metrics`).

> **Service-to-service discovery is automatic — don't hand-list peers.** With
> `service-registry` + `runtime-autoconfigure` + `service-discovery`, each service
> self-registers and peers resolve by name (Vert.x K8s/SRV resolver + DNS-suffix
> construction). Reserve `@RegisteredService` for genuinely external endpoints, and
> never build a custom `IServiceRegistryProvider` just to enumerate your own
> services. See `guicedee-service-registry` → *Automatic Discovery*.

> ⚠ **Shaded module names.** A few GuicedEE features ship as *shaded JPMS
> service modules* whose module name differs from the obvious one. `openapi`'s
> real module is **`com.guicedee.modules.services.openapi`**, **not**
> `com.guicedee.openapi` — `requires com.guicedee.openapi` compiles against the
> wrong (transitive) module and then fails jlink/boot-layer resolution. When a
> `requires` won't resolve, inspect the jar's actual `module-info`
> (`jar --describe-module --file <jar>`) and require that name. See
> `guicedee-jpms-shade`.

## Bootstrap & Runtime Config

The service `main()` registers its module for slim scanning and starts the
context; server behaviour is driven by env vars / system properties:

```java
LogUtils.addHighlightedConsoleLogger(Level.INFO);
IGuiceContext.registerModule("<module.name>");
System.setProperty("HTTP_ENABLED", "false");      // disable plain HTTP
System.setProperty("HTTPS_ENABLED", "true");
System.setProperty("HTTPS_KEYSTORE", "app.p12");  // PKCS#12 keystore on disk
// Enable a full scan BEFORE inject() — off by default; no built-in configurator
// turns it on. Without this, annotation discovery (REST @Path, @RegisteredService,
// OpenAPI) finds nothing (e.g. "registry initialized with 0 services").
IGuiceContext.instance().getConfig()
    .setClasspathScanning(true).setAnnotationScanning(true)
    .setMethodInfo(true).setFieldInfo(true);
IGuiceContext.instance().inject();                // boots Vert.x + all features
```

Prefer `Environment.getSystemPropertyOrEnvironment(name, default)` for secrets
(e.g. `HTTPS_KEYSTORE_PASSWORD`). See `guicedee-web` for HTTP/HTTPS options and
`guicedee-config` for `@ConfigProperty`.

> **Scan-graph caching (optional).** ClassGraph can serialise the scan and rebuild
> it, so later boots skip scanning: save `getScanResult().toJSON()` after `inject()`
> (gate behind a flag), and on boot — only if the file exists — `ScanResult.fromJSON`,
> `GuiceContext.instance().setScanResult(...)`, then `getConfig().setClasspathScanning(false).setPathScanning(false)`
> before `inject()` so the cached graph is reused. See `guicedee-inject`
> (`references/classpath-scanning.md`).

> **Tests boot the same singleton.** Tests that call `inject()` directly must enable
> scanning in `@BeforeAll` exactly as `main()` does — the first boot in the JVM wins.

## Observability Stack (docker-compose)

The local backend is a single OTLP ingress fanning out to per-signal stores:

```
service (@TelemetryOptions otlpEndpoint=http://localhost:4318)
        │ OTLP HTTP (4318) / gRPC (4317)
        ▼
   otel-collector ──▶ tempo   (traces,  query API :3200)
                 ├──▶ loki    (logs,    :3100)
                 └──▶ prometheus (metrics, :9090)  ◀── scrapes collector :8889
        Keycloak (:8080 OIDC, :9000 health/metrics) + Postgres
                                  │
                               grafana (:3000, anonymous Admin, datasources pre-provisioned)
```

Key conventions captured in `references/cloud-app-templates.md`:
- Collector exposes `4317` (gRPC) + `4318` (HTTP) and a Prometheus exporter on `8889`.
- `@TelemetryOptions.otlpEndpoint` is a **base** URL; the telemetry module appends
  `/v1/traces` and `/v1/logs` (see `guicedee-telemetry`).
- Grafana runs anonymous-Admin with datasources/dashboards auto-provisioned from
  `observability/grafana/provisioning/`.
- Drop realm exports into `keycloak/import/`; Keycloak loads them via `--import-realm`.

## Packaging & Deployment (jlink + Docker)

Package a service as a **self-contained custom runtime image** with a dedicated
**`packaging: jlink`** module — never hand-assemble a JRE + a loose module path
of jars. The `maven-jlink-plugin` links the JDK modules **and** the application
module plus every (fully modular) GuicedEE runtime dependency into one image
with a baked-in launcher; there are **no separate jars** to ship.

```
<service-a>-jlink/pom.xml   →  packaging=jlink
  depends on  <service-a>   (the plugin resolves the whole module graph from it)
  maven-jlink-plugin <launcher><name>=<app.module>/<MainClass></launcher>
  → target/maven-jlink/default/   (bin/<name>, lib/modules, conf, release …)
```

Minimal jlink module POM (see `references/dockerfile-jlink.md` for the full file):

```xml
<artifactId><svc>-jlink</artifactId>
<packaging>jlink</packaging>
<dependencies>
  <dependency><groupId><group></groupId><artifactId><svc></artifactId>
    <version>${project.version}</version></dependency>
</dependencies>
<build><plugins>
  <plugin>
    <artifactId>maven-jlink-plugin</artifactId>
    <version>3.1.0</version>
    <extensions>true</extensions>
    <configuration>
      <noHeaderFiles>true</noHeaderFiles><noManPages>true</noManPages>
      <stripDebug>true</stripDebug><compress>2</compress>
      <launcher><name>=<app.module>/<MainClass></launcher>
    </configuration>
    <dependencies>            <!-- ASM matching the JDK 25 class-file version -->
      <dependency><groupId>org.ow2.asm</groupId><artifactId>asm</artifactId>
        <version>9.10.1</version></dependency>
    </dependencies>
  </plugin>
  <plugin><artifactId>maven-deploy-plugin</artifactId>
    <configuration><skip>true</skip></configuration></plugin>   <!-- never published -->
</plugins></build>
```

The Dockerfile just **copies the linked image and runs its launcher** — no
`java --module-path`, no `--add-modules`:

```dockerfile
# build the reactor on the Alpine (musl) JDK so the linked runtime is musl-native
FROM eclipse-temurin:25-jdk-alpine AS build
# … install Maven 4, COPY ., mvn -DskipTests clean package …

FROM alpine:3.21 AS runtime
RUN apk add --no-cache ca-certificates libstdc++
COPY --from=build /src/<svc>-jlink/target/maven-jlink/default /opt/app
ENTRYPOINT ["/opt/app/bin/<name>"]
```

Rules:
- **Build the jlink module on the same libc as the final image.** Link on
  `eclipse-temurin:25-jdk-alpine` (musl) for an `alpine` runtime; a glibc-linked
  image crashes on Alpine with `ld-linux … not found`.
- The image is **self-contained** — copy `target/maven-jlink/default` whole and
  invoke `bin/<launcher>`. Do not copy a `jre/` + `modules/` jar path (that's the
  obsolete hand-rolled approach).
- jlink requires a **fully modular** graph. If a dependency is an automatic
  module, jlink fails — shade it first (`guicedee-jpms-shade`) or correct the
  `requires` to its real (possibly shaded) module name.
- Keep the runtime image minimal: `ca-certificates` (outbound TLS) + `libstdc++`
  (JVM C++ runtime on musl), non-root user, supply secrets at run time.

## Non-Negotiable Constraints

- **Three layers stay separate**: aggregator/parent (pom), BOM (pom), services (jar).
- The **BOM is the only place versions live**; service modules declare dependencies
  **without `<version>`**.
- Aggregator enforces **Maven 4** and **JDK 25+** via `maven-enforcer-plugin`;
  ship the **Maven 4 wrapper**.
- List `bom` **first** in `<modules>` so its version resolves for siblings.
- Each service merges features by **dependency + `requires`** only; never hand-wire
  lifecycle — modules self-register.
- Package for deployment with a dedicated **`packaging: jlink`** module
  (`target/maven-jlink/default`); the Dockerfile copies that image and runs its
  baked-in launcher — **no loose jars, no `--module-path`/`--add-modules`**.
- A service has exactly one scanned **`@TelemetryOptions`/`@MetricsOptions`** config
  class; keep metric names verbatim with `absolute = true`.
- Use a `modelVersion`/POM schema matching the installed Maven 4 (e.g. `4.1.0`).

## References

- `references/cloud-app-templates.md` — copy-ready aggregator POM, BOM POM, service
  POM, `module-info.java`, `PlatformConfig`, bootstrap `main()`, and the full
  `docker-compose.yml` + observability layout.
- `references/dockerfile-jlink.md` — the `packaging: jlink` module POM and the
  multi-stage Alpine Dockerfile that copies the linked image and runs its launcher.
