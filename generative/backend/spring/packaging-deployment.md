# Spring (Boot MVC) — Packaging and Deployment

Scope
- Non-reactive Spring Boot MVC service packaging for production: JARs, layered images, buildpacks, Dockerfiles, JVM memory, configuration, probes, graceful shutdown, K8s deployment posture, and supply-chain controls.
- Aligns with enterprise platform guides:
  - CI/CD — ../../platform/ci-cd/README.md
  - Secrets & Config — ../../platform/secrets-config/README.md
  - Observability — ../../platform/observability/README.md

Goals
- Reproducible builds with SBOM and image provenance.
- Fast startup, predictable memory, and graceful shutdown.
- Immutable images; externalized configuration via env/secret stores.
- Secure defaults (non-root, read-only FS where possible).

Build outputs
- Executable fat JAR (Spring Boot “jar”) with layered metadata.
- OCI image via buildpacks (recommended) or Dockerfile (custom, when needed).
- Publish artifacts to a registry with content trust (signing) per organization policy.

JAR build (Maven/Gradle)
- Maven: mvn -DskipTests package
- Gradle: ./gradlew bootJar

Layered image (Buildpacks, recommended)
- Benefits: zero Dockerfile maintenance, reproducible layers, SBOM, CVE scans.
- Maven:
```bash
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=registry.example.com/acme/demo:1.0.0
```
- Gradle:
```bash
./gradlew bootBuildImage --imageName=registry.example.com/acme/demo:1.0.0
```

Custom Dockerfile (when needed)
- Use JRE-only base; run as non-root; minimal layers; rely on Boot layered JAR.
```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar
# Create non-root user (numeric UID/GID for K8s)
RUN addgroup --system --gid 1001 app && adduser --system --uid 1001 --ingroup app app
USER 1001:1001
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom"
EXPOSE 8080
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
```

JVM memory and GC
- Prefer container-aware flags:
  - -XX:MaxRAMPercentage=70–80
  - -XX:+UseG1GC (default on many JDKs) or Shenandoah/ZGC if policy allows and warranted.
- Set TZ and locale explicitly if needed (ENV TZ=UTC).

Externalized configuration
- All environment-specific values via env variables or mounted files (secrets/config maps). Never bake environment secrets into images.
- Property resolution examples:
  - SERVER_PORT ← SERVER_PORT
  - spring.datasource.* via env (SPRING_DATASOURCE_URL, etc.)
- See: ../../platform/secrets-config/README.md

Ports and context path
- Default server.port=8080; prefer standard internal ports and map externally via ingress/gateway.
- Disable unnecessary endpoints; follow actuator exposure policy in production.

Health checks and probes
- Provide readiness and liveness endpoints via Actuator:
  - /actuator/health, /actuator/ready, /actuator/live
- Keep checks fast and cached when required. See: ./actuator-observability.md

Graceful shutdown
- Ensure graceful shutdown so rolling deploys do not drop requests:
```yaml
# application.yml
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```

Kubernetes deployment posture
- Key manifest facets (illustrative; apply organization standards via Helm/Kustomize):

Deployment (snippet)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      securityContext:
        runAsUser: 1001
        runAsGroup: 1001
        runAsNonRoot: true
      containers:
        - name: app
          image: registry.example.com/acme/demo:1.0.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: JAVA_OPTS
              value: "-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
            - name: SPRING_PROFILES_ACTIVE
              value: "prod"
            - name: MANAGEMENT_SERVER_PORT
              value: "8081"
          readinessProbe:
            httpGet:
              path: /actuator/ready
              port: 8081
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 6
          livenessProbe:
            httpGet:
              path: /actuator/live
              port: 8081
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 2
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1"
              memory: "1Gi"
          volumeMounts:
            - name: config
              mountPath: /config # if using files for config
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: demo-config
```

Service (snippet)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  selector:
    app: demo
  ports:
    - name: http
      port: 80
      targetPort: 8080
```

Ingress (snippet)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
spec:
  rules:
    - host: demo.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo
                port:
                  number: 80
```

Security posture
- Run as non-root; set read-only root FS where possible; mount tmpfs for /tmp if needed.
- Restrict outbound egress where policy allows; only permit required hostnames/ports.
- Lock down actuator endpoints; expose only probes unauthenticated, others require auth or are disabled.

Logging
- Log to stdout/stderr only (12-factor). Use JSON logs with correlation IDs per observability policy.
- No sensitive data in logs; scrub credentials and tokens.

SBOM and signing
- Generate SBOM (CycloneDX or SPDX) via build tools; attach to image or publish as artifact.
- Sign images (cosign/sigstore) and enforce verification in CI/CD and cluster admission policies.

CI/CD
- Build → test (unit/slice/integration) → package → image → scan → sign → push → deploy.
- Promote artifacts across environments using immutable tags (semantic version + git SHA).
- Reference: ../../platform/ci-cd/README.md and provider-specific docs under providers/.

Rollouts
- RollingUpdate strategy by default; ensure readiness gates traffic before scaling down old pods.
- Blue/green or canary via service mesh or gateway where policy requires progressive delivery.
- Use PodDisruptionBudget to keep minimum available pods during maintenance.

Configuration at runtime
- Prefer env variables; optionally mount config files for complex configurations.
- Use Spring Config import if organization mandates central config servers (spring.config.import).
- Feature flags via properties (feature.*) and @ConditionalOnProperty wiring.

Database and migrations
- Run migrations (Flyway/Liquibase) as an init container or during app startup as per team policy.
- Ensure readiness probe only passes after migrations complete successfully.
- Reference: ./database-migrations.md

Caching and messaging
- Size thread pools and caches per container limits; observe cache hit rates and GC pressure.
- External brokers (Kafka/RabbitMQ) endpoints configured via env; credentials via secrets.
- Reference: ./caching.md and ./messaging.md

Runtime tuning checklist
- JVM memory flags configured; no OOMKill under steady load (verify via load tests).
- Graceful shutdown timeouts allow in-flight completion.
- Readiness gates traffic; liveness not too strict to avoid premature restarts.
- Resource requests/limits set; autoscaling policies defined where applicable.
- Secrets mounted via secret stores; configuration immutable per environment.

Validation checklist
- Build reproducible images (buildpacks or Dockerfile) with SBOM.
- Image runs as non-root; minimal privileges; read-only FS if possible.
- Probes configured; /actuator/ready and /actuator/live working.
- Observability exporters active; metrics and traces present.
- CI pipeline signs images and enforces vulnerability thresholds before deploy.

See also
- Topic index — ./README.md
- Overview & setup — ./overview-setup.md
- Actuator & observability — ./actuator-observability.md
- Security (non-reactive) — ./security-mvc.md
- CI/CD — ../../platform/ci-cd/README.md
- Secrets & Config — ../../platform/secrets-config/README.md