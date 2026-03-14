# ActivityMaster Configuration Reference

Complete reference for environment variables, configuration files, and deployment settings.

## Environment Variables

### Database Configuration

```bash
# PostgreSQL Connection
DATABASE_URL=postgresql://localhost:5432/activitymaster
DATABASE_USERNAME=activitymaster
DATABASE_PASSWORD=secret
DATABASE_SCHEMA=public
DATABASE_POOL_SIZE=20
DATABASE_IDLE_TIMEOUT=600000
DATABASE_MAX_LIFETIME=1800000

# Connection Pool
QUARKUS_DATASOURCE_REACTIVE_MAX_SIZE=20
QUARKUS_DATASOURCE_REACTIVE_IDLE_TIMEOUT=PT10M
```

### HTTP Server Configuration

```bash
# Server Settings
QUARKUS_HTTP_PORT=8080
QUARKUS_HTTP_HOST=0.0.0.0
QUARKUS_HTTP_CORS=true
QUARKUS_HTTP_CORS_ORIGINS=http://localhost:3000,https://app.example.com

# SSL/TLS
QUARKUS_HTTP_SSL_PORT=8443
QUARKUS_HTTP_SSL_CERTIFICATE_FILE=/path/to/cert.pem
QUARKUS_HTTP_SSL_CERTIFICATE_KEY_FILE=/path/to/key.pem
```

### Vert.x Configuration

```bash
# Event Loop
QUARKUS_VERTX_EVENT_LOOPS_SIZE=8
QUARKUS_VERTX_WORKER_POOL_SIZE=20
QUARKUS_VERTX_INTERNAL_BLOCKING_POOL_SIZE=20

# Clustering
QUARKUS_VERTX_CLUSTER_HOST=192.168.1.10
QUARKUS_VERTX_CLUSTER_PORT=5701
QUARKUS_VERTX_CLUSTER_PUBLIC_HOST=api.example.com
```

### Security Configuration

```bash
# JWT Settings
QUARKUS_SMALLRYE_JWT_ENABLED=true
MP_JWT_VERIFY_PUBLICKEY_LOCATION=/path/to/public.key
MP_JWT_VERIFY_ISSUER=https://auth.example.com
SMALLRYE_JWT_SIGN_KEY_LOCATION=/path/to/private.key

# Security Token
SECURITY_TOKEN_EXPIRY_SECONDS=3600
SECURITY_TOKEN_REFRESH_ENABLED=true

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://app.example.com
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization
```

### Feature Module Toggles

```bash
# Module Enablement
ACTIVITYMASTER_CONVERSATIONS_ENABLED=true
ACTIVITYMASTER_DOCUMENTS_ENABLED=true
ACTIVITYMASTER_PAYMENTS_ENABLED=false
ACTIVITYMASTER_FORUMS_ENABLED=true
ACTIVITYMASTER_MAIL_ENABLED=true
ACTIVITYMASTER_NOTIFICATIONS_ENABLED=true
ACTIVITYMASTER_WALLET_ENABLED=false
ACTIVITYMASTER_REALTOR_ENABLED=false
```

### External Services

```bash
# Email/SMTP
MAIL_SMTP_HOST=smtp.gmail.com
MAIL_SMTP_PORT=587
MAIL_SMTP_USERNAME=noreply@example.com
MAIL_SMTP_PASSWORD=secret
MAIL_SMTP_TLS_ENABLED=true
MAIL_FROM_ADDRESS=noreply@example.com
MAIL_FROM_NAME=ActivityMaster

# File Storage
FILE_STORAGE_PROVIDER=S3
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=secret
AWS_S3_BUCKET=activitymaster-files
AWS_S3_REGION=us-east-1

# Azure Blob (Alternative)
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...
AZURE_STORAGE_CONTAINER=activitymaster-files

# Image Processing
IMAGE_MAX_SIZE_MB=10
IMAGE_THUMBNAIL_WIDTH=200
IMAGE_THUMBNAIL_HEIGHT=200
IMAGE_OPTIMIZE_QUALITY=85
IMAGE_ALLOWED_FORMATS=jpg,png,webp,gif
```

### Payment Providers

```bash
# Stripe
STRIPE_API_KEY=sk_test_XXXXXXXXXXXXXXXXXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXXXX
STRIPE_CURRENCY=USD

# PayPal
PAYPAL_CLIENT_ID=XXXXXXXXXXXXXXXXXXXX
PAYPAL_CLIENT_SECRET=XXXXXXXXXXXXXXXXXXXX
PAYPAL_MODE=sandbox
```

### Geography & Geocoding

```bash
# Google Maps API
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
GEOCODING_PROVIDER=GOOGLE

# OpenStreetMap (Alternative)
NOMINATIM_BASE_URL=https://nominatim.openstreetmap.org
```

### Notifications

```bash
# Firebase Cloud Messaging (Push Notifications)
FCM_SERVER_KEY=XXXXXXXXXXXXXXXXXXXX
FCM_SENDER_ID=123456789012

# Twilio (SMS)
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+15551234567
```

### Logging & Monitoring

```bash
# Logging Levels
QUARKUS_LOG_LEVEL=INFO
QUARKUS_LOG_CATEGORY_COM_ACTIVITYMASTER_LEVEL=DEBUG
QUARKUS_LOG_CONSOLE_JSON=true

# Health Checks
QUARKUS_HEALTH_EXTENSIONS_ENABLED=true
QUARKUS_SMALLRYE_HEALTH_ROOT_PATH=/health

# Metrics
QUARKUS_MICROMETER_ENABLED=true
QUARKUS_MICROMETER_EXPORT_PROMETHEUS_ENABLED=true
QUARKUS_MICROMETER_EXPORT_PROMETHEUS_PATH=/metrics
```

### Caching

```bash
# Redis Cache
QUARKUS_REDIS_HOSTS=redis://localhost:6379
QUARKUS_REDIS_PASSWORD=secret
QUARKUS_REDIS_DATABASE=0
QUARKUS_CACHE_REDIS_ENABLED=true

# Cache TTL
CACHE_ENTERPRISE_TTL_SECONDS=300
CACHE_ADDRESS_TTL_SECONDS=600
CACHE_EVENTS_TTL_SECONDS=120
```

---

## Application Properties (application.properties)

### Core Settings

```properties
# Application
quarkus.application.name=ActivityMaster
quarkus.application.version=1.0.0

# Hibernate
quarkus.hibernate-orm.database.generation=validate
quarkus.hibernate-orm.log.sql=false
quarkus.hibernate-orm.sql-load-script=no-file
quarkus.hibernate-orm.packages=com.activitymaster.core.entities

# Flyway Migrations
quarkus.flyway.migrate-at-start=true
quarkus.flyway.locations=classpath:db/migration
quarkus.flyway.baseline-on-migrate=true
quarkus.flyway.baseline-version=1.0.0
```

### Development Profile (application-dev.properties)

```properties
# Development Mode
quarkus.dev.instrumentation=true
quarkus.log.level=DEBUG
quarkus.hibernate-orm.log.sql=true

# Live Reload
quarkus.live-reload.instrumentation=true

# Dev Services
quarkus.devservices.enabled=true
quarkus.datasource.devservices.enabled=true
```

### Production Profile (application-prod.properties)

```properties
# Production Mode
quarkus.log.level=INFO
quarkus.hibernate-orm.log.sql=false

# Optimizations
quarkus.native.additional-build-args=-H:+ReportExceptionStackTraces,--initialize-at-run-time=io.vertx

# Security
quarkus.http.ssl.certificate.files=/etc/ssl/certs/cert.pem
quarkus.http.ssl.certificate.key-files=/etc/ssl/private/key.pem
```

### Test Profile (application-test.properties)

```properties
# Test Configuration
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=test
quarkus.datasource.password=test
quarkus.hibernate-orm.database.generation=drop-and-create

# Testcontainers
quarkus.datasource.devservices.enabled=true
quarkus.datasource.devservices.image-name=postgres:16
```

---

## Docker Configuration

### Dockerfile

```dockerfile
FROM registry.access.redhat.com/ubi8/openjdk-17:1.14

ENV LANGUAGE='en_US:en'

# Application JAR
COPY --chown=185 target/quarkus-app/lib/ /deployments/lib/
COPY --chown=185 target/quarkus-app/*.jar /deployments/
COPY --chown=185 target/quarkus-app/app/ /deployments/app/
COPY --chown=185 target/quarkus-app/quarkus/ /deployments/quarkus/

# Expose ports
EXPOSE 8080
EXPOSE 8443

USER 185
ENV JAVA_OPTS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  activitymaster:
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgresql://postgres:5432/activitymaster
      DATABASE_USERNAME: activitymaster
      DATABASE_PASSWORD: secret
      QUARKUS_PROFILE: prod
    depends_on:
      - postgres
      - redis
    networks:
      - activitymaster-network

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: activitymaster
      POSTGRES_USER: activitymaster
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - activitymaster-network

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass secret
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - activitymaster-network

volumes:
  postgres-data:
  redis-data:

networks:
  activitymaster-network:
    driver: bridge
```

---

## Kubernetes Configuration

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: activitymaster
  labels:
    app: activitymaster
spec:
  replicas: 3
  selector:
    matchLabels:
      app: activitymaster
  template:
    metadata:
      labels:
        app: activitymaster
    spec:
      containers:
      - name: activitymaster
        image: activitymaster:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: activitymaster-secrets
              key: database-url
        - name: DATABASE_USERNAME
          valueFrom:
            secretKeyRef:
              name: activitymaster-secrets
              key: database-username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: activitymaster-secrets
              key: database-password
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: activitymaster-service
spec:
  selector:
    app: activitymaster
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

### configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: activitymaster-config
data:
  QUARKUS_HTTP_CORS: "true"
  QUARKUS_HTTP_CORS_ORIGINS: "https://app.example.com"
  ACTIVITYMASTER_CONVERSATIONS_ENABLED: "true"
  ACTIVITYMASTER_DOCUMENTS_ENABLED: "true"
  CACHE_ENTERPRISE_TTL_SECONDS: "300"
```

### secrets.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: activitymaster-secrets
type: Opaque
stringData:
  database-url: postgresql://postgres.default.svc.cluster.local:5432/activitymaster
  database-username: activitymaster
  database-password: supersecret
  jwt-private-key: |
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
```

---

## Database Migrations (Flyway)

### Migration File Structure

```
src/main/resources/db/migration/
├── V1.0.0__Initial_schema.sql
├── V1.1.0__Add_conversations_module.sql
├── V1.2.0__Add_documents_module.sql
├── V1.3.0__Add_payments_module.sql
└── V2.0.0__Major_refactoring.sql
```

### Example Migration (V1.0.0__Initial_schema.sql)

```sql
-- Enterprises (Core FSDM)
CREATE TABLE enterprises (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    enterprise_type VARCHAR(100),
    active_flag VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    parent_enterprise_id VARCHAR(255) REFERENCES enterprises(id)
);

CREATE INDEX idx_enterprises_active_flag ON enterprises(active_flag);
CREATE INDEX idx_enterprises_parent ON enterprises(parent_enterprise_id);

-- Addresses (Core FSDM)
CREATE TABLE addresses (
    id VARCHAR(255) PRIMARY KEY,
    street_line_1 VARCHAR(255),
    street_line_2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address_type VARCHAR(50),
    active_flag VARCHAR(20) NOT NULL DEFAULT 'Active',
    enterprise_id VARCHAR(255) REFERENCES enterprises(id)
);

CREATE INDEX idx_addresses_enterprise ON addresses(enterprise_id);
CREATE INDEX idx_addresses_postal_code ON addresses(postal_code);
CREATE INDEX idx_addresses_coords ON addresses USING GIST (
    ll_to_earth(latitude, longitude)
);

-- Events (Core FSDM)
CREATE TABLE events (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(100),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    location VARCHAR(255),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule VARCHAR(255),
    active_flag VARCHAR(20) NOT NULL DEFAULT 'Active',
    enterprise_id VARCHAR(255) REFERENCES enterprises(id)
);

CREATE INDEX idx_events_enterprise ON events(enterprise_id);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_events_type ON events(event_type);
```

---

## CI/CD Configuration

### GitHub Actions (.github/workflows/deploy.yml)

```yaml
name: Deploy ActivityMaster

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Build with Maven
      run: mvn clean package -DskipTests

    - name: Run Tests
      run: mvn test

    - name: Build Docker Image
      run: docker build -t activitymaster:${{ github.sha }} .

    - name: Push to Registry
      run: |
        docker tag activitymaster:${{ github.sha }} registry.example.com/activitymaster:latest
        docker push registry.example.com/activitymaster:latest

    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/activitymaster \
          activitymaster=registry.example.com/activitymaster:latest
```

---

## Configuration Best Practices

### 1. Secrets Management

```bash
# Never commit secrets to version control
# Use environment variables or secret managers

# AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id activitymaster/prod

# Vault
vault kv get secret/activitymaster/prod
```

### 2. Environment-Specific Configs

```java
@ApplicationScoped
public class ConfigProvider {
    @ConfigProperty(name = "activitymaster.environment", defaultValue = "dev")
    String environment;

    public boolean isProduction() {
        return "prod".equals(environment);
    }
}
```

### 3. Feature Flags

```java
@ApplicationScoped
public class FeatureFlags {
    @ConfigProperty(name = "activitymaster.conversations.enabled", defaultValue = "true")
    boolean conversationsEnabled;

    public boolean isConversationsEnabled() {
        return conversationsEnabled;
    }
}
```

### 4. Configuration Validation

```java
@ApplicationScoped
@Startup
public class ConfigValidator {
    @ConfigProperty(name = "database.url")
    String dbUrl;

    void onStart(@Observes StartupEvent ev) {
        if (dbUrl == null || dbUrl.isBlank()) {
            throw new IllegalStateException("DATABASE_URL is required");
        }
    }
}
```

### 5. Dynamic Configuration Reload

```java
@ApplicationScoped
public class DynamicConfig {
    private final Map<String, String> config = new ConcurrentHashMap<>();

    @Scheduled(every = "60s")
    void reloadConfig() {
        // Reload from external source (Redis, ConfigMap, etc.)
        config.put("feature.new", fetchFromRedis("feature.new"));
    }
}
```
