# ☁️ Terraform Infrastructure & Deployment Rules

This guide defines the canonical Terraform expectations for deploying infrastructure and services in the AI Experiment platform.

---

## 📁 Directory Structure

```
terraform/
├── modules/
│   ├── app/
│   ├── keycloak/
│   ├── postgres/
│   └── vpc/
├── environments/
│   ├── dev/
│   ├── qe/
│   └── prod/
└── main.tf
```

---

## 🌐 Global Infrastructure Rules

### 🧠 Project Configuration

* Project ID: `za-ai-experiment`
* Region: `europe-west1`
* Domain Mapping: `gedmarc.co.za`
* CPU Boost: Enabled on all Cloud Run services
* Secrets: Managed via Google Secret Manager with IAM-bound access

### 📡 Networking

* VPC Connector: Single shared connector `za-ai-experiment-vpc-conn`
* Subnets: Only **one subnet** (multi-region avoided unless specified)
* Internal traffic should default to VPC where possible

### 🔐 Identity & IAM

* Each app has its own Cloud Run service account:
  `za-ai-experiment-<service>-sa@za-ai-experiment.iam.gserviceaccount.com`
* Keycloak's service account must have:

  * `roles/secretmanager.secretAccessor`
  * `roles/cloudsql.client`
* Cloud Build service account must exist explicitly:
  `za-ai-experiment@cloudbuild.gserviceaccount.com`

---

## 🧱 Module-Specific Expectations

### `modules/app`

* Deploys Cloud Run service per app
* Includes support for:

  * GCP managed SSL cert
  * CPU boost annotation
  * Domain mapping
* Can take in service-specific secrets and env vars

### `modules/keycloak`

* Based on pre-built container from Artifact Registry
* Must specify:

  * Database credentials (secret)
  * `--hostname=https://auth.gedmarc.co.za`
  * Token exchange + metrics/health features enabled
* Storage class: minimal

### `modules/postgres`

* Deploys shared Postgres 17 instance
* Two databases:

  * `keycloak`
  * `experiment` (shared app DB)
* SSL configuration uses `ssl_mode` instead of deprecated `require_ssl`
* 10GB size with auto-resize enabled

---

## 🔁 Service Deployment Process

1. Each `apps/<module>` must define its own Terraform entry under `terraform/modules/app`.
2. Deployments must:

   * Use pre-built JLink image (from GitHub Packages or Artifact Registry)
   * Reference only published artifacts
   * Use defined environment variables from `env-variables.md`
3. All apps must inject the VPC connector and IAM SA
4. Each app must declare its startup boost and optionally domain

---

## 🧪 Observability

* Tracing, logging, and metrics should default to **Google Cloud-native tools** (Cloud Monitoring, Cloud Trace)
* No external OTEL/Prometheus by default
* Future injection via env var if needed (`--otel-exporter-otlp-endpoint`)

---

## 🧭 Terraform Tips for Junie & AIs

* Always align secrets, domains, service names with current `.md` guides
* Generate valid IAM bindings for app SA
* Reference `jlink` images only — **no JARs** or generic Java images
* Respect GCP registry paths: `europe-west1-docker.pkg.dev/...`
* Handle secret access explicitly in Terraform
* Don't overgenerate subnets or VPCs unless requested
* Ensure `terraform apply` can be executed **idempotently**

---

✅ Once this structure is followed, all deployed apps and infrastructure will be clean, reproducible, and aligned with AI Experiment principles.
