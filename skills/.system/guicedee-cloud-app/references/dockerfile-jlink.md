# jlink Runtime Image + Docker Packaging

Copy-ready templates for packaging a GuicedEE cloud service as a **self-contained
jlink runtime image** and shipping it in a minimal Alpine container. Replace the
`<placeholders>`:

| Placeholder | Meaning | Example |
|---|---|---|
| `<group>` | platform groupId | `world.ne1` |
| `<svc>` | service artifactId | `service-registry` |
| `<app.module>` | service JPMS module name | `world.ne1.serviceregistry` |
| `<MainClass>` | fully-qualified main class | `world.ne1.serviceregistry.ServiceRegistryApplication` |
| `<name>` | jlink launcher name | `serviceregistry` |
| `<keystore>` | PKCS#12 TLS keystore | `ne1.world.p12` |

---

## 1. jlink module POM (`<svc>-jlink/pom.xml`)

A dedicated module with **`packaging: jlink`**. Its single dependency is the
service module; the `maven-jlink-plugin` resolves the entire (modular) graph from
it and links a complete runtime image into `target/maven-jlink/default`.

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

    <artifactId><svc>-jlink</artifactId>
    <packaging>jlink</packaging>

    <name><svc> — jlink Runtime Image</name>
    <description>
        Self-contained custom runtime image for the <svc> application. The
        maven-jlink-plugin links the application module and all of its (fully
        modular) GuicedEE runtime dependencies into a single image with a
        baked-in launcher. The Dockerfile copies the image and runs bin/<name>.
    </description>

    <dependencies>
        <!-- The application module; the jlink plugin resolves the full module
             graph (app + all transitive runtime modules) from this single dep. -->
        <dependency>
            <groupId><group></groupId>
            <artifactId><svc></artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jlink-plugin</artifactId>
                <version>3.1.0</version>
                <extensions>true</extensions>
                <configuration>
                    <noHeaderFiles>true</noHeaderFiles>
                    <noManPages>true</noManPages>
                    <stripDebug>true</stripDebug>
                    <verbose>true</verbose>
                    <compress>2</compress>
                    <launcher><name>=<app.module>/<MainClass></launcher>
                </configuration>
                <dependencies>
                    <!-- ASM matching the JDK 25 class-file version used while linking -->
                    <dependency>
                        <groupId>org.ow2.asm</groupId>
                        <artifactId>asm</artifactId>
                        <version>9.10.1</version>
                    </dependency>
                </dependencies>
            </plugin>

            <!-- This is a runtime image, never published to a repository -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <configuration>
                    <skip>true</skip>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

Register it in the aggregator `<modules>` (after `bom` and the service it links):

```xml
<modules>
    <module>bom</module>
    <module><svc></module>
    <module><svc>-jlink</module>
</modules>
```

### Output

`mvn -pl <svc>-jlink -am package` produces a complete, self-contained image:

```
<svc>-jlink/target/maven-jlink/default/
├── bin/<name>          ← launcher (no java args needed)
├── bin/<name>.bat      ← Windows launcher
├── lib/modules         ← JDK + app + all dependency modules, linked
├── conf/  legal/  include/
└── release
```

There are **no loose jars** and **no separate module path** — everything is in
`lib/modules`. Run locally with `./target/maven-jlink/default/bin/<name>`.

---

## 2. Dockerfile (multi-stage, Alpine, musl-linked)

Build the reactor on the **Alpine (musl) JDK** so the linked runtime is
musl-native, then copy the jlink image into a minimal Alpine and run the launcher.

```dockerfile
# syntax=docker/dockerfile:1.7

# -----------------------------------------------------------------------------
# Stage 1: build the reactor (produces the jlink image)
# -----------------------------------------------------------------------------
FROM eclipse-temurin:25-jdk-alpine AS build

ARG MAVEN_VERSION=4.0.0-rc-5
ARG MAVEN_URL=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.zip

# Install Maven 4 (the wrapper uses distributionType=only-script).
ADD ${MAVEN_URL} /tmp/maven.zip
RUN cd /opt && jar xf /tmp/maven.zip && rm /tmp/maven.zip \
    && ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn

WORKDIR /src
COPY . .

# The <svc>-jlink module links the self-contained image at
# target/maven-jlink/default. BuildKit cache mount keeps repeat builds fast.
RUN --mount=type=cache,target=/root/.m2/repository \
    mvn -B -ntp -DskipTests clean package

# -----------------------------------------------------------------------------
# Stage 2: minimal runtime image
# -----------------------------------------------------------------------------
FROM alpine:3.21 AS runtime

# ca-certificates: outbound TLS (OTLP exporter, external services).
# libstdc++: the C++ runtime the JVM links against on Alpine (musl).
RUN apk add --no-cache ca-certificates libstdc++

# Copy the self-contained jlink image verbatim — custom JRE + all modules +
# the bin/<name> launcher. Nothing else is required to run.
COPY --from=build /src/<svc>-jlink/target/maven-jlink/default /opt/app

# TLS keystore referenced by main() (HTTPS_KEYSTORE), resolved from the workdir.
COPY <keystore> /app/<keystore>

ENV PATH="/opt/app/bin:${PATH}" \
    JAVA_HOME="/opt/app" \
    JAVA_TOOL_OPTIONS="-Djava.awt.headless=true -XX:MaxRAMPercentage=75.0" \
    HTTPS_PORT=8443 \
    TELEMETRY_OTLP_ENDPOINT=http://localhost:4318 \
    ENVIRONMENT=development
# HTTPS_KEYSTORE_PASSWORD must be supplied at runtime (-e or env_file).

RUN adduser -S -D -H -u 10001 -h /app appuser \
 && mkdir -p /app && chown -R appuser:appuser /app
USER appuser
WORKDIR /app

EXPOSE 8443

# The full module graph is already linked into the image — just run the launcher.
ENTRYPOINT ["/opt/app/bin/<name>"]
```

### `.dockerignore`

```
target/
**/target/
.git/
logs/
*.log
.idea/
```

---

## 3. docker-compose app service (optional)

Add the service alongside the observability stack so traces/logs/metrics flow to
the collector:

```yaml
  <svc>:
    build:
      context: .
      dockerfile: Dockerfile
    networks: [ observability-net ]
    depends_on: [ otel-collector ]
    environment:
      TELEMETRY_OTLP_ENDPOINT: http://otel-collector:4318
      HTTPS_PORT: "8443"
      ENVIRONMENT: development
    env_file: .env          # HTTPS_KEYSTORE_PASSWORD=...
    ports:
      - "8443:8443"
```

---

## 4. Build & run

```bash
# Standalone (BuildKit enables the .m2 cache mount)
DOCKER_BUILDKIT=1 docker build -t <group>/<svc> .
docker run --rm -p 8443:8443 -e HTTPS_KEYSTORE_PASSWORD=<pw> <group>/<svc>

# Or with the full local stack
docker compose up -d --build
```

The service serves HTTPS on `https://localhost:8443` (`/registry/*`,
`/health/{live,ready}`, `/openapi.json`, `/metrics`). Self-signed cert → use
`curl -k` or a browser exception.

---

## Gotchas

- **libc must match.** Link the jlink image on `eclipse-temurin:25-jdk-alpine`
  (musl) for an `alpine` runtime. A glibc-linked image fails on Alpine with
  `Error loading shared library ld-linux-*.so … not found`.
- **Fully modular graph required.** jlink cannot link automatic modules. If
  linking fails, shade the offending jar into a JPMS service module
  (`guicedee-jpms-shade`) or fix the `requires` to its real module name.
- **Shaded module names.** `openapi` resolves as
  `com.guicedee.modules.services.openapi` (not `com.guicedee.openapi`). Verify any
  failing `requires` with `jar --describe-module --file <jar>`.
- **Self-contained image.** Copy `target/maven-jlink/default` whole and run
  `bin/<name>`; never reconstruct a `jre/` + `modules/` jar path or launch with
  `java --module-path … --add-modules ALL-MODULE-PATH` — that's obsolete.
- **ASM plugin dependency.** Pin `org.ow2.asm:asm` on the jlink plugin to a
  version that understands the JDK 25 class-file format, or linking errors on
  newer bytecode.

