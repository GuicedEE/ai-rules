# 🏗️ Orchestration Implementation for The AI Experiment

## 🎯 Objective

Implement the orchestration mechanics for infrastructure, deployment pipelines, module coordination, and observability—ensuring that `apps/*` modules (both frontend and backend) are reproducible, scalable, and integrated with monitoring from Day 1.

---

## 📦 Terraform Modules & Targets

### Directory Structure

```
infra/
├── environments/
│   ├── dev/
│   ├── qe/
│   └── prod/
├── modules/
│   ├── gcp_cloud_run/
│   ├── gcp_iam/
│   ├── gcp_sql_postgres/
│   ├── gcp_monitoring/
│   ├── gcp_networking/
│   └── keycloak/
└── main.tf, variables.tf, outputs.tf
```

### Execution

* `terraform plan -var-file=environments/dev/dev.tfvars`
* `terraform apply` will:

  * Provision DB with auto users
  * Deploy GCP IAM & Cloud Run per app
  * Configure VPC connector + NAT
  * Import or create Keycloak realm
  * Wire logging & monitoring

### Special Flags

* Observability endpoints excluded from auth (marked with `google_cloud_run_service_iam_member.allow_public`)
* Trace export wired via `google_monitoring_monitored_project`

---

## 🔁 CI/CD Workflows (GitHub Actions)

### Shared Workflows

* `.github/workflows/shared-tests.yml`
* `.github/workflows/deploy-module.yml`
* `.github/workflows/tag-version.yml`

### Key Concepts

* PRs to `dev`, `qe`, `main` trigger full test + scan
* Tags trigger release notes and GitHub Pages update
* `mvn release:prepare perform` invoked via matrix
* Commit marker `ci:autoversion` blocks looped re-triggers

---

## 🔒 Secrets & Environments

* Managed in GitHub Actions + GCP Secret Manager
* Includes:

  * `KEYCLOAK_ADMIN`, `GCP_DEPLOYER`, `DB_PASSWORD`
  * Environment-specific Firebase/Keycloak client IDs
  * SonarQube tokens
* `env.sh` or `.envrc` generated for local testing automation

---

## 📈 Observability Implementation

### Prometheus Metrics

* `/prometheus` endpoint (via Vert.x Micrometer backend)
* Push or scrape configured via GCP managed Prometheus agent
* `prometheus.yml` mapped via Terraform in `gcp_monitoring` module

### Tracing

* Vert.x `OpenTelemetry` integration configured via system props
* `resource.labels.project_id`, `service.name`, `service.version` embedded
* Local development uses human-readable logger formatting
* Cloud logs structured JSON (`structuredFields`) for GCP ingestion

### Health + Liveness

* Vert.x Health handler exposed on `/health`
* `/health` returns per-resource status (Keycloak, DB, Redis \[if added])
* `/info` displays module name, version, git commit ID

### Alerting (Optional Extension)

* `alert_policies.tf` maps health and error rate thresholds
* PubSub or email on degraded modules

---

## ✅ Final Notes

* Observability endpoints remain **public** to allow scraping without auth headers
* Terraform-controlled IAM guarantees controlled surface exposure
* Developer onboarding uses `.envrc` + `ng serve` or `docker-compose` per microservice
* Logs, traces, and metrics are unified via GCP-native tooling

---
