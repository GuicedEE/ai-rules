# GitHub Actions — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD with GitHub Actions (build, test, package, deploy).
- Designed for docs-first prompts and quick adoption in monorepos and polyglot stacks.

When to use
- Projects hosted on GitHub or mirrored to GitHub with Actions-enabled runners.
- Need for tight GitHub integration (Checks, PR annotations, Environments, OIDC to cloud).

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Providers: GitLab CI, Jenkins, TeamCity, Google Cloud Build, Azure Pipelines, AWS CodeBuild/CodePipeline (see provider pages under the same directory)

Key concepts (anchor wording)
- Workflow
  - A YAML-defined CI/CD pipeline triggered by events (push, pull_request, workflow_dispatch, schedule).
- Job
  - A unit of work running on a runner (ubuntu-latest/windows-latest/macos-latest or self-hosted). Jobs run in parallel by default.
- Step
  - A shell command or an action invoked within a job.
- Runner
  - The agent/machine executing jobs. Hosted (GitHub-hosted) or self-hosted with labels.
- Environment
  - Named deploy target with protection rules, reviewers, and environment secrets.
- OIDC Federation
  - GitHub-to-cloud trust (AWS/GCP/Azure) without long-lived secrets (recommended for deployments).

Minimal workflow (build + test)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-test:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install deps
        run: npm ci

      - name: Unit tests
        run: npm test -- --ci

      - name: Upload coverage
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/
```

Matrix builds (polyglot, multi-OS)

```yaml
jobs:
  unit:
    strategy:
      fail-fast: false
      matrix:
        os: [ ubuntu-latest, windows-latest ]
        node: [ 18, 20 ]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: ${{ matrix.node }}, cache: npm }
      - run: npm ci
      - run: npm run test:ci
```

Java toolchain with caching

```yaml
# Maven example
- uses: actions/setup-java@v4
  with:
    distribution: temurin
    java-version: 21
    cache: maven
- run: mvn -B -ntp verify
```

Artifacts, caching, path filters
- Artifacts: actions/upload-artifact for reports, coverage, build outputs.
- Cache: cache npm/maven/gradle to speed builds; avoid caching build outputs that risk corruption.
- Path filters: limit workflows via on:push.paths / pull_request.paths or use dorny/paths-filter to target subprojects in monorepos.

Environments and approvals (deploy gates)

```yaml
jobs:
  deploy:
    needs: build-test
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: ./scripts/deploy.sh
```

- Configure environment protection rules and required reviewers in repository settings.

OIDC deployments (cloud without secrets)
- AWS: configure a role with trust policy for GitHub OIDC; use aws-actions/configure-aws-credentials@v4.
- GCP: workload identity federation via google-github-actions/auth@v2.
- Azure: federated credentials and azure/login@v1.

Examples (cloud OIDC)

```yaml
# AWS OIDC
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GHADeployRole
    aws-region: us-east-1
- run: aws s3 sync dist s3://my-bucket/app --delete
```

```yaml
# GCP OIDC
- id: auth
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/github/providers/my-provider
    service_account: deployer@my-project.iam.gserviceaccount.com
- uses: google-github-actions/setup-gcloud@v2
- run: gcloud run deploy my-service --image gcr.io/my-project/image:tag --region us-central1
```

```yaml
# Azure OIDC
- uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
- run: az webapp up --name myapp --runtime "NODE:20-lts"
```

Secrets and variables
- Repository/Org secrets: encrypted; access via ${{ secrets.NAME }}.
- Environment secrets: scoped to environment; require approvals when protected.
- Vars: non-secret configuration via ${{ vars.NAME }}.

Monorepo strategies
- Use paths filters to build only changed packages.
- Consider composite actions for shared steps and reuse across repos.
- Generate matrix dynamically (e.g., via a list of affected workspaces).

Concurrency and locking

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

- Prevent overlapping runs on the same branch; optional for deploy jobs as well.

LLM interpretation guidance
- If “GitHub Actions” provider is selected in prompts:
  - Add .github/workflows/ci.yml with build/test stages and artifacts.
  - Add deployment workflows per environment with environment protection and OIDC auth.
  - Use caching for language toolchains; upload coverage and test reports.
  - In monorepos, configure paths filtering and matrix builds for changed modules.
- For secrets and cloud deploys:
  - Prefer OIDC federation over static keys. Document required IAM roles and repository/environment settings.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)