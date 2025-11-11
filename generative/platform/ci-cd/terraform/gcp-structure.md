# ☁️ GCP Infrastructure Plan for The AI Experiment (Expanded)

> Follows Pact Principle 5: "Design platform boundaries with high signal, context-carrying clarity and testable expectations."

---

## 🧱 Terraform Structure Overview

```bash
infrastructure/
├── modules/
│   ├── core/                  # VPC, subnets, DNS, NAT, firewall, IAM
│   ├── security/              # Cloud Armor, policies, service account bindings
│   ├── observability/         # Monitoring, logging, metrics, alerts
│   ├── apps/                  # Cloud Run + Build + Storage + Secrets + SQL
│   └── dns/                   # Internal + external zone definitions
├── environments/
│   ├── dev/
│   ├── qe/
│   └── prod/
├── backend/                  # Terraform state configuration
└── README.md
```

---

## 🌐 Networking and Zoning

* **Regions**: Primary in `europe-west1`, failover in `us-central1`
* **Zoning**: Services distributed across 2–3 zones per region
* **Subnets**:

  * `frontend-subnet`: Public-facing apps (Cloud Run)
  * `backend-subnet`: Internal services (Cloud Run internal / Cloud SQL)
  * `data-subnet`: Private IP ranges for databases
  * `ops-subnet`: GCP infra, NAT, logging agents, etc.
* **DNS**: Internal DNS via Cloud DNS zone `ai-internal`

---

## 🔥 Firewalls and Security

* **Default policy**: Deny-all with explicit allow rules
* **Cloud Armor**:

  * SQL Injection protection
  * IP whitelist/blacklist by region (e.g., only `ZA`, `EU`)
  * Rate limiting for public endpoints (e.g. `/auth`)
  * Custom rule sets per service (apply via label selector)
* **Firewall Logging**: Enabled for all rules

---

## 🔐 IAM and Identity

* **Service Accounts**:

  * One per backend/frontend module
  * Least-privilege IAM bindings (defined per module)
  * Cloud Build execution accounts for CI/CD pipelines
* **CI/CD Roles**:

  * Read-only state for dev environments
  * Write with approval for prod
* **Integration**:

  * Support for Keycloak OIDC with workload identity federation

---

## 🧪 Observability: Logging, Monitoring, Alerts, and Secrets

### 📊 Logging

* **Cloud Logging**:

  * Enabled for all services
  * Human-readable format for local
  * Structured JSON format for cloud

* **Log Sinks**:

  * Export to **GCS** for archival with 30-day TTL
  * Export to **BigQuery** for audit and analytics
  * Export to **Pub/Sub** for real-time pipeline triggers

* **Retention Policies**:

  * Default: 30 days (GCS), 90 days (BigQuery), configurable per env

* **Log-based Metrics**:

  * Exceptions, auth failures, retry attempts, resource usage

* **Logging Exports Configuration**:

  * Custom sinks for error and usage logs per environment
  * Filters scoped to project and severity
  * Exported to audit bucket and downstream tools

### 📈 Metrics & Monitoring

* **Cloud Monitoring Dashboards**:

  * CPU, Memory, Request Count, Error Rate per Cloud Run service
  * PostgreSQL metrics: connections, query throughput, cache hit ratio
  * GCS, Cloud Build, container registry freshness

* **Prometheus Integration**:

  * Vert.x exposes `/metrics` (Prometheus format)
  * Managed Prometheus enabled via Terraform module
  * Metrics scraping rules scoped per service and namespace
  * Labels include: `app`, `env`, `region`, `instance`

* **Terraform Setup**:

  * Service: `google_monitoring_monitored_project`
  * Exporters: OpenTelemetry or Vert.x native
  * Dashboards: Defined via `google_monitoring_dashboard` modules

### 🚨 Alerting

* **Log-based Alerts**:

  * Triggers on severity levels or message pattern (e.g. 5xx, login failed)

* **Uptime Checks**:

  * Synthetic probes to `/health`, `/auth`, `/docs`, `/metrics`

* **Budget Alerts**:

  * Project-level budgets with alert thresholds (e.g. 50%, 80%, 95%)

* **Notification Channels**:

  * Email groups (devops@, alerts@)
  * Slack integrations via webhook
  * Optional: SMS escalation or PagerDuty

---

## 🔐 Secret Management and Rotation

* **Secret Manager Usage**:

  * All sensitive keys and credentials stored in Secret Manager
  * Module-specific and environment-aware naming convention
    `projects/[PROJECT_ID]/secrets/[MODULE]-[ENV]-[KEY_NAME]`
  * Access via IAM roles and workload identity federation

* **Rotation Strategies**:

  * JWT and service-to-service keys: rotated every 7–30 days via Cloud Scheduler + Cloud Functions
  * Database credentials: rotated every 90 days, triggered by merge approval into protected branches
  * TTL enforced per version, old versions disabled after grace period (e.g., 7 days)

* **Auditing & Alerts**:

  * Rotation failure alerts via Pub/Sub → Slack/email escalation
  * Logging for every read/write access to secrets

* **Environment Variable & Secret Documentation**:

  * Shared reference at `orchestration/env-variables.md`
  * Per-app overrides in `apps/<app>/rules/env-variables.md`
  * All secrets injected via CI/CD or Secret Manager; `.env.example` provided for local use

---

## 📤 Cloud Run and Build

* Services deployed via GitHub Actions
* Each backend module: max 2 instances
* Each frontend: 1 fixed instance + CDN
* Envs: `dev`, `qe`, `main` branches auto-deploy

---

## 📂 Databases

* PostgreSQL 17

  * Private IP, IAM-auth only
  * Automated daily backups (7-day retention)
* H2 removed for test use — test containers only
* Flyway/Liquibase not modular: skipped in favor of Hibernate schema tools

---

## 🔁 State and Automation

* **Remote state** stored in GCS
* Terraform CI/CD:

  * PR: `terraform plan`
* Approved merge: `terraform apply`
* Incorporates and validates required environment variables and secrets for each module
* Fails fast on missing or misconfigured variables using `terraform validate` and custom input variable checks
* Locking and concurrency via GCS bucket
* Scanned via `tfsec` or `checkov`

---

## 🚥 Endpoints

| Path            | Access | Purpose                             |
| --------------- | ------ | ----------------------------------- |
| `/health`       | Public | Microprofile health & Vert.x health |
| `/metrics`      | Public | Prometheus-formatted metrics        |
| `/info`         | Public | Basic service metadata              |
| `/openapi.yaml` | Public | Swagger spec per module             |
| `/docs`         | Public | Swagger UI                          |

---

✅ This structure brings us close to enterprise-grade orchestration with Terraform, GCP, and our event-driven AI system.
