# AWS CodeBuild / CodePipeline — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD on AWS using CodeBuild for builds/tests and CodePipeline for orchestration (source → build → test → deploy).
- Designed for docs-first prompts and quick adoption in polyglot/monorepo environments.

When to use
- Teams standardizing on AWS-native CI/CD with tight IAM, VPC, and artifacts integration (S3/ECR/CodeArtifact/Parameter Store/Secrets Manager).
- Need for managed builders (CodeBuild), pipeline orchestration (CodePipeline), and optional CodeDeploy/CloudFormation/SAM/CDK integrations.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers: GitHub Actions, GitLab CI, Jenkins, TeamCity, Google Cloud Build, Azure Pipelines (see siblings under providers/)

Key concepts (anchor wording)
- CodeBuild Project
  - Managed build environment defined by environment image, compute type, VPC config (optional), IAM role, and buildspec.yml (pipeline steps).
- buildspec.yml
  - YAML that defines phases (install, pre_build, build, post_build), env vars, reports, artifacts, cache, and secondary artifacts.
- CodePipeline
  - Pipeline definition with Stages and Actions (Source/Build/Deploy/Test/Invoke). Orchestrates CodeBuild projects and deploy actions (e.g., CloudFormation/CodeDeploy/Lambda).
- Artifacts
  - Build outputs stored in S3 or Docker images pushed to ECR; CodePipeline moves artifacts between stages.
- IAM Roles & OIDC
  - Roles assumed by CodeBuild/CodePipeline for AWS access. Prefer OIDC federation from source providers (GitHub/GitLab) to avoid long-lived credentials for trigger webhooks or cross-account access.
- Environments & Approvals
  - Manual approvals and stage-level gates via CodePipeline; use separate stages for dev/staging/prod with approver lists.

Minimal buildspec.yml (Node)

```yaml
# buildspec.yml
version: 0.2

env:
  variables:
    CI: "true"
phases:
  install:
    runtime-versions:
      nodejs: 20
    commands:
      - npm ci
  build:
    commands:
      - npm test -- --ci
      - npm run build
artifacts:
  files:
    - "dist/**/*"
  discard-paths: no
cache:
  paths:
    - "node_modules/**/*"
```

Java/Maven example

```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      java: corretto21
  build:
    commands:
      - mvn -B -ntp verify
artifacts:
  files:
    - "**/target/*.jar"
reports:
  junit_reports:
    files:
      - "**/surefire-reports/*.xml"
    file-format: JUNITXML
```

Docker image build & push to ECR

```yaml
version: 0.2
env:
  variables:
    REPOSITORY_URI: "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/apps/web"
phases:
  pre_build:
    commands:
      - aws --version
      - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
      - IMAGE_TAG=${CODEBUILD_RESOLVED_SOURCE_VERSION:0:7}
  build:
    commands:
      - docker build -t $REPOSITORY_URI:$IMAGE_TAG .
      - docker push $REPOSITORY_URI:$IMAGE_TAG
artifacts:
  files:
    - imagedefinitions.json
  discard-paths: yes
```

CodePipeline structure (high level)
- Stages:
  1) Source: GitHub/GitLab/CodeCommit or S3 zip source
  2) Build: CodeBuild action (buildspec.yml)
  3) Test: Optional CodeBuild test stage or Lambda invoke stage
  4) Deploy: CloudFormation/CodeDeploy/ECS/EKS/Lambda deployment actions
  5) Approval: Manual approval action before production

Example pipeline (CloudFormation deployment, CDK synthesized)
- Use CDK/CloudFormation template as an artifact from build stage and a Deploy action to apply stack updates.

Monorepo strategies
- Multiple CodeBuild projects (service-a, service-b) and a CodePipeline with parallel build actions keyed by path filters handled in buildspec or via separate sources.
- Use “secondary sources/artifacts” in CodeBuild to assemble per-service outputs.
- Consider a generator CodeBuild project that detects changed services and triggers corresponding build projects via StartBuild API.

Secrets and configuration
- Prefer AWS Secrets Manager / Parameter Store for runtime secrets.
- Inject build-time secrets via CodeBuild environment variables (parameter-store / secrets-manager references) rather than plaintext.
- For npm/publishing, pull tokens from Secrets Manager into env and write .npmrc on the fly.

VPC and networking
- Attach CodeBuild to VPC subnets/security groups for private ECR/DB access; configure endpoints and routing properly.
- Use VPC endpoints for S3/ECR/STS to avoid public egress where required.

Approvals and environments
- Add ManualApproval actions in CodePipeline before prod; restrict IAM on approval and deploy roles.
- For ECS/EKS rollouts, use separate deploy stages with blue/green/canary where supported (CodeDeploy for ECS, or progressive rollouts via third-party tools).

Cross-account deployments
- Use CodePipeline/CodeBuild roles with STS AssumeRole into target accounts (deployment accounts). Maintain least-privilege policies and explicit trust relationships.

Triggers
- Use CodePipeline’s source integrations (GitHub/GitLab webhook via connection, CodeStar Connections) to avoid polling.
- For PR/MR pipelines, create separate pipelines or dynamic behavior in CodeBuild based on event vars.

Reports and artifacts
- CodeBuild supports test reports (JUnit). Upload coverage artifacts to S3. Export CloudWatch Logs and metrics to CloudWatch/CloudWatch Dashboards.

Caching & performance
- Use local cache modes (SOURCE/Docker layer/custom) to accelerate builds.
- Prefer smaller base images and multi-stage Docker builds to reduce push/pull times.

LLM interpretation guidance
- If “AWS CodeBuild/CodePipeline” is selected:
  - Create a buildspec.yml that builds/tests/packages artifacts or pushes images to ECR.
  - Provide a CodePipeline design (Source → Build → Deploy) with manual approval for prod; include IAM role notes and least privilege.
  - Configure secrets from Secrets Manager/Parameter Store; avoid plaintext.
  - For monorepos, create multiple CodeBuild projects or a generator stage; use secondary artifacts to separate deliverables.
  - Use OIDC/CodeStar Connections for source integration and secure cloud access; avoid long-lived keys.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)