# Octopus Deploy — CI/CD Provider Topic

Purpose
- Modular guidance for implementing delivery with Octopus Deploy (create releases, promote across environments, run runbooks).
- Designed to pair with a build system (GitHub Actions, GitLab CI, Jenkins, TeamCity, Azure Pipelines, GCB). Builds produce artifacts and call Octopus to create/deploy releases.

When to use
- You want opinionated release orchestration, environment scoping, approvals/gates, multi-tenant deployment, runbooks, and variable scoping separate from build.
- You prefer “build once, deploy many,” promoting a single immutable package through Dev → Test → Prod via a Lifecycle.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers: GitHub Actions, GitLab CI, Jenkins, TeamCity, Google Cloud Build, Azure Pipelines, AWS CodeBuild/CodePipeline

Core concepts (anchor wording)
- Space
  - A logical partition for projects, environments, and library sets (multi-team or multi-product separation).
- Project
  - A deployable application with a Deployment Process (steps), Variables, and a Versioning strategy. Can enable Config as Code.
- Environment & Lifecycle
  - Environments (Dev/Test/Prod/…) and a Lifecycle governing promotion order and gates.
- Targets & Workers
  - Targets are deployment endpoints (e.g., Kubernetes cluster, Windows server, Azure Web App). Workers execute scripts/steps; worker pools share capacity.
- Variables & Library Variable Sets
  - Scoped variables (by environment/tenant/target). Library sets are shared across projects.
- Tenants & Channels
  - Tenants provide multi-customer scoping. Channels support parallel release lines (e.g., stable vs beta).
- Packages & Feeds
  - Versioned artifacts (NuGet, Docker, generic) in built-in or external feeds (e.g., Artifactory, ECR/ACR/Artifact Registry).
- Runbooks
  - Operational automation (e.g., DB maintenance, feature toggles) separate from “deploy release,” with permissions and scheduling.

Octopus Config as Code (OCL)
- Store the Project’s process/variables in Git alongside application code.
- Enables PR-based review of deployment process changes; Octopus UI commits back to Git.
- Folder structure: .octopus/ with OCL files (project, process, variables). The UI syncs state with the branch selected for the project.

Typical pipeline flow
1) Build system compiles/tests and produces a package (e.g., app.1.2.3.nupkg or app:1.2.3 docker image).
2) Build system pushes artifact to a feed (Octopus built-in feed or external) and/or Docker registry.
3) Build system creates a release in Octopus referencing the package version and deploys to the first environment (Dev).
4) Approvals/gates/promotions to Test/Prod handled by Octopus (manual steps, windows).
5) Optional runbooks invoked for operational tasks.

CLI and API
- Octopus CLI (octo) provides push/create/deploy commands. The REST API covers all features for automation.

Octo CLI usage (typical)
```bash
# Push package (NuGet or generic zip)
octo push \
  --server "$OCTO_URL" \
  --apiKey "$OCTO_API_KEY" \
  --package "dist/app.1.2.3.zip" \
  --overwrite-mode OverwriteExisting

# Create a release
octo create-release \
  --server "$OCTO_URL" \
  --apiKey "$OCTO_API_KEY" \
  --project "My Project" \
  --releaseNumber "1.2.3" \
  --packageVersion "1.2.3" \
  --channel "Stable"

# Deploy a release
octo deploy-release \
  --server "$OCTO_URL" \
  --apiKey "$OCTO_API_KEY" \
  --project "My Project" \
  --releaseNumber "1.2.3" \
  --environment "Development" \
  --progress \
  --waitForDeployment
```

Docker image releases
- Use image reference in Octopus step templates (e.g., Deploy Container to Kubernetes) and set package version to the image tag.
- Build pipeline pushes image to the registry; Octopus step pulls by tag, optionally with registry credentials stored as sensitive variables.

Variables and scoping
- Maintain non-secret configuration as variables scoped per environment/tenant/target.
- Use sensitive variables for secrets; integrate with external secret stores if possible (Key Vault/Secrets Manager/SM).
- Library Variable Sets store shared keys (e.g., endpoints/feature flags) for re-use. Reference them from projects.

Multi-tenant deployments
- Define tenants and tag environments. Variables can be tenant-scoped (e.g., per-customer hostname).
- Deploy releases per-tenant or to tenant groups. Useful for SaaS with many isolated customers.

Channels
- Separate prerelease from stable. Configure rules for package version pre-release tags (e.g., -beta).
- Build pipeline selects channel on create-release; Octopus applies appropriate steps/variables.

Runbooks
- Author scripts to perform ops tasks:
  - Cache warm-up, scheduled cleanups, maintenance toggles, targeted restarts.
- Permissions and approvals can differ from deployments. Invoke from CI as needed:

```bash
octo run-runbook \
  --server "$OCTO_URL" --apiKey "$OCTO_API_KEY" \
  --project "My Project" \
  --runbook "Warm Up" \
  --environment "Staging" \
  --variables "Key=Value"
```

Approvals & guided failover
- Use manual intervention steps in a lifecycle stage to gate production promotion.
- Use guided failure mode for better remediation in long orchestration runs.

GitHub Actions example integration
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: [ 'v*.*.*' ]
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: npm ci && npm run build

      - name: Package
        run: zip -r dist/app.$GITHUB_REF_NAME.zip dist

      - name: Install Octopus CLI
        uses: OctopusDeploy/install-octopus-cli-action@v3

      - name: Push package
        run: |
          octo push \
            --server ${{ secrets.OCTO_URL }} \
            --apiKey ${{ secrets.OCTO_API_KEY }} \
            --package dist/app.${{ github.ref_name }}.zip \
            --overwrite-mode OverwriteExisting

      - name: Create release
        run: |
          octo create-release \
            --server ${{ secrets.OCTO_URL }} \
            --apiKey ${{ secrets.OCTO_API_KEY }} \
            --project "My Project" \
            --releaseNumber "${{ github.ref_name }}" \
            --packageVersion "${{ github.ref_name }}"

      - name: Deploy to Dev
        run: |
          octo deploy-release \
            --server ${{ secrets.OCTO_URL }} \
            --apiKey ${{ secrets.OCTO_API_KEY }} \
            --project "My Project" \
            --releaseNumber "${{ github.ref_name }}" \
            --environment "Development" \
            --progress --waitForDeployment
```

GitLab CI example integration
```yaml
stages: [ build, release ]
variables:
  OCTO_URL: $OCTO_URL
  OCTO_API_KEY: $OCTO_API_KEY

release:
  stage: release
  image: alpine:3.20
  script:
    - apk add --no-cache curl unzip
    - curl -L https://github.com/OctopusDeploy/OctopusCLI/releases/latest/download/octo-linux-x64.tar.gz | tar xz
    - ./octo push --server "$OCTO_URL" --apiKey "$OCTO_API_KEY" --package "dist/app.${CI_COMMIT_TAG}.zip" --overwrite-mode OverwriteExisting
    - ./octo create-release --server "$OCTO_URL" --apiKey "$OCTO_API_KEY" --project "My Project" --releaseNumber "${CI_COMMIT_TAG}" --packageVersion "${CI_COMMIT_TAG}"
    - ./octo deploy-release --server "$OCTO_URL" --apiKey "$OCTO_API_KEY" --project "My Project" --releaseNumber "${CI_COMMIT_TAG}" --environment "Development" --progress --waitForDeployment
  rules:
    - if: $CI_COMMIT_TAG
```

Best practices
- Build once, promote many: don’t rebuild per environment; keep release artifacts immutable.
- Use Lifecycles and Channels to codify promotion policy. Use approvals for Prod gates.
- Prefer Config as Code so deployment process changes are reviewed alongside app changes.
- Keep secrets in Octopus (sensitive variables) or external vault, not in pipeline logs.
- For Kubernetes: use Octopus Kubernetes target with namespaces per environment, and scoping via variables.

Monorepo strategies
- One Octopus Project per service, or a unified “release orchestration” project that deploys multiple packages.
- Use variables to select which services to deploy per release; or leverage Project Triggers/Subscriptions for fine control.

LLM interpretation guidance
- If “Octopus Deploy” is selected:
  - In the chosen CI provider pipeline, add steps to push the package artifact, create the Octopus release, and deploy to the first environment.
  - Provide octo CLI installation and minimal commands. Parameterize server URL and API key via secrets.
  - Link the Octopus Project, Lifecycle, Environments, and Variables in documentation; recommend Config as Code.
  - For container workloads, push image to registry; configure Octopus steps to deploy by image tag.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)