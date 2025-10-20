# 🧩 Shared Orchestration Environment Variables

This document defines **project-wide environment variables** to be used across all modules and Cloud Run services in the `ai-experiment` platform. These variables are injected via Terraform, GitHub Actions, and/or container startup configurations.

---

## 🌍 Scope Levels

| Scope        | Description                            | Example Key                     |
| ------------ | -------------------------------------- | ------------------------------- |
| Organization | Available globally across all projects | `ORG_NAME`, `ORG_SUPPORT_EMAIL` |
| Project      | Specific to a GCP project deployment   | `GCP_PROJECT_ID`, `GCP_REGION`  |
| Application  | App/module-specific values             | `DB_URL`, `AUTH_TOKEN_SECRET`   |

---

## 🔑 Authentication

| Key                    | Description                              | Example                                                                                    |
| ---------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------ |
| `OAUTH2_ISSUER_URL`    | Issuer base URL                          | `https://auth.gedmarc.co.za`                                                               |
| `OAUTH2_REALM`         | OAuth2 realm name                        | `ai-experiment`                                                                            |
| `OAUTH2_CLIENT_ID`     | Public client ID                         | `shell-ui`                                                                                 |
| `OAUTH2_CLIENT_SECRET` | Optional secret for confidential clients | `***`                                                                                      |
| `JWKS_URI`             | JWKS discovery URL                       | `https://auth.gedmarc.co.za/realms/ai-experiment/protocol/openid-connect/certs`            |
| `INTROSPECTION_URL`    | Token validation endpoint (optional)     | `https://auth.gedmarc.co.za/realms/ai-experiment/protocol/openid-connect/token/introspect` |
| `AUTH_ADMIN_USER`      | Default admin username                   | `admin`                                                                                    |
| `AUTH_ADMIN_PASS`      | Default admin password                   | `***`                                                                                      |

---

## 🛰️ Cloud Events

| Key                  | Description                   | Example                        |
| -------------------- | ----------------------------- | ------------------------------ |
| `CLOUDEVENTS_FORMAT` | Enforce event encoding format | `application/cloudevents+json` |
| `CLOUDEVENTS_TRACE`  | Enable trace extensions       | `true`                         |

---

## 🧠 Observability / Tracing (GCP Native)

| Key                | Description                                 | Example                           |
| ------------------ | ------------------------------------------- | --------------------------------- |
| `TRACING_ENABLED`  | Toggle tracing                              | `true`                            |
| `GCP_TRACE_EXPORT` | Use Google Cloud Trace (enabled by default) | `true`                            |
| `LOGGING_BACKEND`  | Should be set to GCP-native logging stack   | `cloud-logging`                   |
| `METRICS_EXPORT`   | Use Google Cloud Monitoring                 | `enabled`                         |
| `SERVICE_NAME`     | Auto-injected by each microservice          | `calc-basic`, `wallet-core`, etc. |

> ℹ️ No external OpenTelemetry, Prometheus, or collector agents are required. All observability is expected to be **native to GCP**, with Terraform provisioning the appropriate IAM, APIs, and service bindings.

---

## 📦 Runtime Configuration

| Key                 | Description                                    | Example                               |
| ------------------- | ---------------------------------------------- | ------------------------------------- |
| `PORT`              | Application port inside container              | `8080`                                |
| `STARTUP_CPU_BOOST` | GCP Cold start boost (injected via annotation) | `true`                                |
| `REGION`            | GCP region                                     | `europe-west1`                        |
| `ENVIRONMENT`       | Current environment                            | `dev`, `qe`, `prod`                   |
| `BASE_URL`          | Base public URL (used for redirects)           | `https://gedmarc.co.za/ai-experiment` |

---

## 📂 Database

| Variable             | Purpose                       | Scope       |
| -------------------- | ----------------------------- | ----------- |
| `DB_URL`             | JDBC or reactive URL          | Application |
| `DB_USER`            | Database username             | Secret      |
| `DB_PASS`            | Database password             | Secret      |
| `DB_POOL_SIZE`       | Initial DB pool configuration | Application |
| `PG_PASSWORD_SECRET` | Terraform secret key name     | Project     |

---

## 🧪 Testing

| Variable                  | Purpose                                     | Scope       |
| ------------------------- | ------------------------------------------- | ----------- |
| `TEST_DB_CONTAINER_IMAGE` | Postgres image for Testcontainers           | Application |
| `ENABLE_DEBUG_LOGS`       | Enables verbose logging                     | Application |
| `SKIP_INTEGRATION_TESTS`  | Used to conditionally run full system tests | Project     |

---

## 🔐 Secrets and Tokens

All secrets below should be provisioned using:

* GitHub Actions environments
* GCP Secret Manager (referenced via Terraform)

| Secret Key                   | Description                     |
| ---------------------------- | ------------------------------- |
| `KEYCLOAK_ADMIN_PASSWORD`    | Admin login for Keycloak        |
| `POSTGRES_KEYCLOAK_PASSWORD` | Password for Keycloak DB schema |
| `POSTGRES_APP_PASSWORD`      | App-level PostgreSQL password   |
| `JWT_TEST_TOKEN`             | Dev-only pre-issued JWT         |

---

## ✅ Rules

* Where possible, environment variable types and required presence should be validated via runtime schema enforcement (e.g., Vert.x ConfigRetriever JSON schema validation or custom startup checks).

* All keys must be prefixed consistently (`JWT_`, `POSTGRES_`, `OAUTH2_`, etc.)

* Terraform must be the canonical source of truth for variable injection

* Dev defaults should be supplied for local `.env` usage

* GitHub Actions will mount secrets as environment variables at runtime

* Dockerfile `ENV` values can be overridden by container runtime injection (Cloud Run or `docker-compose`)

* Public-facing services must validate tokens via `JWKS_URI` or `INTROSPECTION_URL`

* `.env.example` must **always** match `.env` keys

* Terraform modules should validate required secrets via input variables

* GitHub Actions must consume secrets from repository/environment scope

* Cloud Build substitutions (`_VAR_NAME`) must be defined per trigger

* Docker Compose should pull from `.env` or inline `env_file:` reference

---

Ready for Terraform and GitHub Actions template injection 🛠️
