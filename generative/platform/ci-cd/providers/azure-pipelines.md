# Azure Pipelines — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD using Azure DevOps Pipelines (YAML multi-stage pipelines for build, test, package, deploy).
- Optimized for docs-first prompts and fast adoption in polyglot/monorepo repositories.

When to use
- Projects hosted in Azure DevOps (Repos) or external Git providers connected to Azure Pipelines.
- Need for multi-stage YAML, Environments with approvals/checks, Service Connections, Variable Groups, and federated (OIDC) cloud auth.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers: GitHub Actions, GitLab CI, Jenkins, TeamCity, Google Cloud Build, AWS CodeBuild/CodePipeline (see siblings under providers/)

Key concepts (anchor wording)
- Pipeline (YAML)
  - azure-pipelines.yml defines a pipeline with triggers, resources, variables, stages/jobs/steps, and templates.
- Stage
  - Logical phase (Build → Test → Deploy). Stages may depend on previous stages and can target Environments.
- Job
  - Unit of work executed on an agent (vmImage: ubuntu-latest/windows-latest/macos-latest or self-hosted). Jobs run in parallel by default within a stage.
- Step
  - A script or a task (task: NodeTool@0, Maven@4, etc.) within a job.
- Agent Pool
  - Where jobs run. Microsoft-hosted pools or self-hosted pools for custom environments.
- Variable / Variable Group
  - Variables in pipeline; Variable Groups (in Library) for shared configuration; Key Vault-backed groups for secrets at runtime.
- Service Connection
  - Credential abstraction for external systems (Azure RM, GCP, AWS, Docker registries); can be scoped and require approvals.
- Environment
  - Named deployment target with approval gates, checks, and audit.

Minimal YAML (build + test Node)

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include: [ main ]
pr:
  branches:
    include: [ main ]

pool:
  vmImage: ubuntu-latest

variables:
  NODE_VERSION: '20'
  CI: 'true'

stages:
- stage: Build
  jobs:
  - job: build_test
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '$(NODE_VERSION)'
    - script: npm ci
      displayName: Install deps
    - script: npm test -- --ci
      displayName: Unit tests
    - script: npm run build
      displayName: Build app
    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: 'dist'
        ArtifactName: 'dist'
        publishLocation: 'Container'
```

Matrix-style strategy (multi-OS, multi-version)

```yaml
stages:
- stage: Matrix
  jobs:
  - job: test_matrix
    strategy:
      matrix:
        linux_node18:
          image: ubuntu-latest
          node: 18
        linux_node20:
          image: ubuntu-latest
          node: 20
        windows_node20:
          image: windows-latest
          node: 20
    pool:
      vmImage: $(image)
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '$(node)'
    - script: npm ci
    - script: npm run test:ci
```

Java/Maven example with caching

```yaml
stages:
- stage: Build
  jobs:
  - job: maven_build
    pool: { vmImage: ubuntu-latest }
    steps:
    - task: Maven@4
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'verify'
        options: '-B -ntp'
        mavenOptions: '-Xmx1024m'
        publishJUnitResults: true
        testResultsFiles: '**/surefire-reports/*.xml'
```

Artifacts, caching, repository path filters
- Artifacts: PublishBuildArtifacts task for build outputs, coverage, reports.
- Caching: Use Cache task (CacheBeta@1) or built-in caching in certain tasks; avoid caching compiled outputs that corrupt builds.
- Path filters: Use trigger/pr include/exclude paths for monorepos to scope pipeline runs.

Multi-stage deploy with Environments and approvals

```yaml
stages:
- stage: Build
  jobs:
  - job: build
    steps:
    - script: npm ci && npm run build
    - task: PublishBuildArtifacts@1
      inputs: { PathtoPublish: 'dist', ArtifactName: 'dist' }

- stage: Deploy_Staging
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: deploy_staging
    environment: 'staging'  # Configure approvals/checks in DevOps Environments
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: dist
          - script: ./scripts/deploy.sh staging

- stage: Deploy_Prod
  dependsOn: Deploy_Staging
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: deploy_prod
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: dist
          - script: ./scripts/deploy.sh production
```

Templates (DRY pipelines)

```yaml
# azure-pipelines.yml (root)
stages:
- template: ci/build.yml
  parameters:
    nodeVersion: 20
- template: deploy/deploy-env.yml
  parameters:
    environmentName: 'staging'
```

```yaml
# ci/build.yml
parameters:
  - name: nodeVersion
    type: number
    default: 20

stages:
- stage: Build
  jobs:
  - job: build
    pool: { vmImage: ubuntu-latest }
    steps:
    - task: NodeTool@0
      inputs: { versionSpec: '${{ parameters.nodeVersion }}' }
    - script: npm ci && npm test -- --ci && npm run build
    - task: PublishBuildArtifacts@1
      inputs: { PathtoPublish: 'dist', ArtifactName: 'dist' }
```

Variables, Variable Groups, Key Vault
- Variables: inline or pipeline variables (secret: true for sensitive values).
- Variable Groups: define in Library; link to pipelines; Key Vault-backed groups recommended for auto-rotation and auditing.
- Reference: variables: - group: MySharedVars; then use $(MyVar) in steps.

Service Connections and federated cloud auth
- Azure: Service connection (Azure Resource Manager) with Federated Credentials (OIDC) to avoid client secret storage.
- AWS: Service connection (AWS) with role assumption via OIDC or short-lived keys.
- GCP: Service connection (GCP) for Workload Identity Federation or short-lived SA tokens.

Examples: Azure federated login and deploy

```yaml
steps:
- task: AzureCLI@2
  inputs:
    azureSubscription: 'AzureRM-ServiceConnection' # with federated credentials
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az webapp up --name myapp --runtime "NODE:20-lts" --resource-group rg-web
```

AWS deploy with OIDC role (via service connection)

```yaml
steps:
- task: AWSShellScript@1
  inputs:
    awsCredentials: 'AwsServiceConnection'
    regionName: 'us-east-1'
    scriptType: 'inline'
    inlineScript: |
      aws s3 sync dist s3://my-bucket/app --delete
```

GCP deploy (Cloud Run)

```yaml
steps:
- task: Bash@3
  inputs:
    targetType: inline
    script: |
      gcloud auth login --cred-file="${GOOGLE_APPLICATION_CREDENTIALS}" || true
      gcloud run deploy web --image us-docker.pkg.dev/$PROJECT_ID/apps/web:$(Build.SourceVersion) --region us-central1
```

Monorepo strategies
- Multiple pipelines per directory or one root pipeline with path filters and templates.
- Use resources.repositories if referencing shared templates across repos.
- Use stages per service (service-a, web-app), guarded by condition and path filters.

Concurrency & approvals
- Use Environments with required approvals and checks for gated deployments.
- Use “lockBehavior” and checks to serialize deployments per environment (or use custom scripts/tokens).

Observability
- Publish test results and coverage as artifacts; add report tabs if using Extensions (e.g., SonarCloud).
- Integrate with Branch Policies to enforce pipeline success before PR merges.

LLM interpretation guidance
- If “Azure Pipelines” is selected:
  - Create azure-pipelines.yml with multi-stage pipeline (Build/Test/Deploy), publish artifacts, and Environments for each deploy stage with approvals/checks.
  - Use templates to DRY logic; add path filters for monorepos.
  - Prefer federated credentials (Service Connections with OIDC) over long-lived secrets.
  - For Java/Node stacks, add caching/tool setup tasks; for container builds, use Docker or ACR tasks and deploy to Web Apps/AKS/Functions/Container Apps as required.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)