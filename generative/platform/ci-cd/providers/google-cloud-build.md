# Google Cloud Build — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD with Google Cloud Build (GCB) using cloudbuild.yaml pipelines (build, test, package, deploy).
- Designed for docs-first prompts and fast adoption across GCP services (Artifact Registry/GCR, Cloud Run, GKE, Cloud Functions, Cloud Deploy).

When to use
- Projects hosted on any Git provider with GCB Triggers (GitHub/GitLab/Cloud Source Repos) or manual invocations via gcloud.
- Prefer fully managed, serverless CI on GCP with tight IAM/Secret Manager integration and Workload Identity Federation (OIDC) for GitHub/GitLab.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers: GitHub Actions, GitLab CI, Jenkins, TeamCity, Azure Pipelines, AWS CodeBuild/CodePipeline (see siblings under providers/)

Key concepts (anchor wording)
- cloudbuild.yaml
  - Pipeline definition (steps, images, entrypoints, args, env, timeouts, artifacts, substitutions).
- Trigger
  - Source-based pipeline invocation (GitHub/GitLab/CSR). Supports regex branch filters, config file path overrides, substitutions, and PR triggers.
- Worker Pool
  - Regional dedicated pools (optional) for private networking, performance isolation, and custom machine types; otherwise use default managed workers.
- Artifacts
  - Build outputs (e.g., Docker images pushed to Artifact Registry) and optional tar archives to Cloud Storage.
- Substitutions
  - Parameterize pipelines with variables (_FOO) injected at trigger time.
- Secret Manager / KMS
  - Secure secret injection via kmsKeyName or Secret Manager; prefer Secret Manager for rotation and IAM auditing.
- IAM and OIDC
  - Cloud Build service account for build-time permissions; OIDC federation for external source providers (GitHub/GitLab) to avoid long-lived credentials.

Minimal pipeline (Node build + test)

```yaml
# cloudbuild.yaml
timeout: "1200s" # 20 minutes
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: "E2_HIGHCPU_8"

steps:
  - id: "Install"
    name: "gcr.io/cloud-builders/npm"
    args: ["ci"]

  - id: "Unit tests"
    name: "gcr.io/cloud-builders/npm"
    args: ["test", "--", "--ci"]

  - id: "Build"
    name: "gcr.io/cloud-builders/npm"
    args: ["run", "build"]

artifacts:
  objects:
    location: "gs://$PROJECT_ID-build-artifacts/$REPO_NAME/$SHORT_SHA/"
    paths: ["dist/**", "coverage/**"]
```

Build and push container to Artifact Registry

```yaml
steps:
  - id: "Build image"
    name: "gcr.io/cloud-builders/docker"
    args: ["build", "-t", "us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA", "."]
  - id: "Push image"
    name: "gcr.io/cloud-builders/docker"
    args: ["push", "us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA"]

images:
  - "us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA"
```

Deploy to Cloud Run

```yaml
steps:
  - id: "Deploy Cloud Run"
    name: "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
    entrypoint: gcloud
    args:
      [
        "run","deploy","web",
        "--image","us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA",
        "--region","us-central1",
        "--platform","managed",
        "--allow-unauthenticated"
      ]
```

Use substitutions and environments

```yaml
substitutions:
  _REGION: "us-central1"
  _SERVICE: "web"

steps:
  - id: "Deploy"
    name: "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
    entrypoint: gcloud
    args:
      [
        "run","deploy","${_SERVICE}",
        "--image","us-docker.pkg.dev/$PROJECT_ID/apps/${_SERVICE}:$SHORT_SHA",
        "--region","${_REGION}"
      ]
```

Triggers (GitHub/GitLab/CSR)
- Configure a trigger to:
  - Watch specific branches or PRs
  - Use repository root or alternate config path (e.g., ci/cloudbuild.pr.yaml)
  - Provide substitutions per environment (e.g., _REGION, _SERVICE)
  - Apply regex filters to target microservices in a monorepo (via config path or filter logic)

Monorepo strategies
- Multiple cloudbuild.yaml files under service directories (e.g., services/service-a/cloudbuild.yaml)
- Use a root dispatch cloudbuild that conditionally includes sub-builds via gcloud builds submit with dir filtering (invoked from a generator step)
- Provide trigger-level path filters (available for GitHub app triggers) to limit pipeline to changed paths

Kaniko or Buildpacks (Dockerless build)
- Use gcr.io/kaniko-project/executor for rootless image builds without Docker-in-Docker
- Use Google Cloud Buildpacks (pack) for opinionated image builds from source (Java/Node/Python/Go)

Kaniko example

```yaml
steps:
  - id: "Kaniko build"
    name: "gcr.io/kaniko-project/executor:latest"
    args:
      [
        "--destination=us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA",
        "--context=.",
        "--cache=true"
      ]
```

Secrets (Secret Manager) and environment
- Use Secret Manager and build-time access via Cloud Build SA IAM bindings

Example: inject NPM token

```yaml
availableSecrets:
  secretManager:
    - versionName: "projects/$PROJECT_NUMBER/secrets/NPM_TOKEN/versions/latest"
      env: "NPM_TOKEN"

steps:
  - id: "npm publish"
    name: "gcr.io/cloud-builders/npm"
    entrypoint: "bash"
    args:
      - "-c"
      - |
        echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
        npm publish
```

GKE deploy (kubectl)

```yaml
steps:
  - id: "Auth GKE"
    name: "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
    entrypoint: bash
    args:
      - -c
      - |
        gcloud container clusters get-credentials $GKE_CLUSTER --region $GKE_REGION --project $PROJECT_ID
        kubectl set image deployment/web web=us-docker.pkg.dev/$PROJECT_ID/apps/web:$SHORT_SHA
        kubectl rollout status deployment/web
```

Cloud Deploy (progressive delivery)
- Define a Cloud Deploy pipeline for staged rollouts; Cloud Build can invoke deploy targets for canary/blue-green
- Prefer Cloud Deploy for promotion/approvals rather than ad-hoc gcloud imperatives in build steps

Worker Pools and networking
- Use Private Pools for private network access (e.g., to private Artifact Registry/GKE control planes)
- Assign egress rules via VPC-SC and firewall when needed

Caching and performance
- Leverage Docker layer cache via Kaniko and Artifact Registry cache
- Use appropriate machine types for builds (E2, N2) and reduce container image sizes for faster pulls

Observability and logs
- CLOUD_LOGGING_ONLY to centralize logs
- Cloud Build insights for durations and failures; export metrics to Cloud Monitoring

IAM and least privilege
- Cloud Build service account needs roles to:
  - Read sources and write to Artifact Registry/GCS
  - Deploy to Cloud Run/GKE/Cloud Functions as required
- Avoid Owner/Editor; use granular roles (e.g., run.admin, artifactregistry.writer)

LLM interpretation guidance
- If “Google Cloud Build” is selected:
  - Create cloudbuild.yaml with build/test and optional container build + deploy steps; add substitutions for region/service.
  - Configure Triggers for push/PR with path filters or separate configs for PR vs main.
  - Prefer Artifact Registry over legacy GCR; use Kaniko/Buildpacks for Dockerless builds.
  - Inject secrets from Secret Manager; avoid plaintext. Use Cloud Deploy for progressive promotions.
  - In monorepos, provide per-service cloudbuild.yaml or a dispatch/generator approach; add trigger filters by path.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)