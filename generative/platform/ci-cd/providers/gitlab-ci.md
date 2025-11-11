# GitLab CI — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD using GitLab CI (build, test, package, deploy).
- Designed for docs-first prompts and quick adoption in monorepos and polyglot stacks.

When to use
- Projects hosted on GitLab (SaaS or self-managed) or mirrored with GitLab runners.
- Need for GitLab features (Merge Request pipelines, Environments, Protected variables, Approvals, Child/Parent/Multi-Project pipelines).

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers: GitHub Actions, Jenkins, TeamCity, Google Cloud Build, Azure Pipelines, AWS CodeBuild/CodePipeline (see siblings under providers/)

Key concepts (anchor wording)
- Pipeline
  - A set of stages (build, test, deploy) defined in .gitlab-ci.yml. Pipelines are triggered by events (push, merge_request, schedules) and run on GitLab Runners.
- Stage
  - A logical phase (e.g., build → test → deploy). Jobs in a stage are executed in parallel; stages are sequential.
- Job
  - A unit of work within a stage. Runs in a shell or Docker executor/context on a runner.
- Runner
  - The agent executing jobs. Shared (GitLab.com) or self-managed; configured with tags to target specific executors/images.
- Environment
  - A named deploy target (e.g., staging, production) with URL, protected access, approvals, and stop actions.
- Variable
  - Key/value pairs used in pipelines. Protected/masked variables for secrets, environment-scoped variables for deploys.
- Rules Workflow
  - The rules: / workflow rules define when pipelines and jobs run (replaces only/except with more control).

Minimal pipeline (build + test)

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test

variables:
  NODE_ENV: test

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/

build:
  stage: build
  image: node:20-alpine
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week
  rules:
    - if: $CI_PIPELINE_SOURCE == "push"

unit_tests:
  stage: test
  image: node:20-alpine
  needs: ["build"]
  script:
    - npm ci
    - npm test -- --ci
  artifacts:
    when: always
    paths:
      - coverage/
    reports:
      junit: junit.xml
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

Matrix-like strategy (dynamic child pipelines)
- GitLab doesn’t have a native matrix; emulate via child pipelines or parallel: matrix for some use cases.

Parallel jobs (simple)

```yaml
lint:
  stage: test
  image: node:20-alpine
  script: ["npm ci", "npm run lint"]
  parallel: 3
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

Child pipeline (generate from template for multiple packages)

```yaml
generate:child:
  stage: build
  trigger:
    include:
      - local: .gitlab/child-template.yml
    strategy: depend
  rules:
    - changes:
        - packages/*/*
```

Example child template

```yaml
# .gitlab/child-template.yml
stages: [ build, test ]
.build_package:
  image: node:20
  script:
    - npm ci
    - npm run build
  artifacts:
    paths: [ dist/ ]
  rules:
    - when: on_success

# Instantiate for each changed package via include rules or a generator job
```

Java/Maven example with caching

```yaml
maven_build:
  stage: build
  image: maven:3.9.9-eclipse-temurin-21
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .m2/repository
  script:
    - mvn -B -ntp verify
  artifacts:
    paths: [ target/ ]
```

Artifacts, caching, dependencies
- Artifacts: pass build outputs and reports to later stages using artifacts/reports and needs.
- Cache: maven/gradle/npm/yarn caches; do not cache compiled build outputs that cause corruption.
- needs: express job-to-job dependencies to optimize DAG and parallelism.

Environments, approvals, protected deployments

```yaml
deploy_prod:
  stage: deploy
  environment:
    name: production
    url: https://example.com
    on_stop: stop_prod
  script:
    - ./scripts/deploy.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  when: manual
  allow_failure: false
```

- Protect the environment and limit deploys to Maintainers; configure approvals in project settings (Merge Request approvals and/or environment-level protections).

Cloud OIDC federation (no long-lived secrets)
- GitLab supports OpenID Connect JWTs to assume roles in AWS/GCP/Azure.

AWS example with OIDC
```yaml
deploy_aws:
  stage: deploy
  image: amazon/aws-cli:2.13.15
  id_tokens:
    AWS_ID_TOKEN:
      aud: https://gitlab.com
  variables:
    AWS_REGION: us-east-1
  script:
    - aws configure set region $AWS_REGION
    - aws sts assume-role-with-web-identity \
        --role-arn arn:aws:iam::123456789012:role/GitLabOIDCRole \
        --role-session-name gitlab-ci \
        --web-identity-token $AWS_ID_TOKEN \
        --duration-seconds 3600 > creds.json
    - export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId creds.json)
    - export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey creds.json)
    - export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken creds.json)
    - aws s3 sync dist s3://my-bucket/app --delete
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

GCP example (Workload Identity Federation)
```yaml
deploy_gcp:
  stage: deploy
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:slim
  id_tokens:
    GCP_ID_TOKEN:
      aud: https://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/gitlab/providers/default
  script:
    - gcloud auth login --brief --cred-file=<(echo $GCP_ID_TOKEN) || true
    - gcloud run deploy my-service --image gcr.io/my-proj/app:latest --region us-central1
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

Azure example (federated credentials)
```yaml
deploy_azure:
  stage: deploy
  image: mcr.microsoft.com/azure-cli:2.62.0
  id_tokens:
    AZURE_ID_TOKEN:
      aud: api://AzureADTokenExchange
  variables:
    AZURE_TENANT_ID: $AZURE_TENANT_ID
    AZURE_CLIENT_ID: $AZURE_CLIENT_ID
    AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID
  script:
    - az login --service-principal -u $AZURE_CLIENT_ID --tenant $AZURE_TENANT_ID --federated-token $AZURE_ID_TOKEN
    - az webapp up --name myapp --runtime "JAVA:21-java21"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

Secrets and variables
- CI/CD Variables: configure in project/group; mark as masked/protected for secrets; can be environment-scoped.
- .gitlab-ci.yml should reference variables via $VAR; avoid committing secrets.
- For monorepos, consider child pipelines and group-level CI templates shared via include.

Rules vs only/except
- Prefer rules: for expressive conditions; migrate away from only/except where possible.
- workflow:rules at top-level to control pipeline creation for MRs vs pushes.

Monorepo strategies
- Use rules:changes to detect changed paths and spawn child pipelines per package.
- Use include/remote templates for shared logic across repos.
- Consider dynamic configuration with a generator job that writes .gitlab-ci-generated.yml and uses workflow:rules to include.

Concurrency and resource groups
- resource_group: serialize deployments to a single environment.
- interruptible: true to cancel superseded pipelines; also use auto-cancel settings in project config.

LLM interpretation guidance
- If “GitLab CI” is selected:
  - Create .gitlab-ci.yml with stages build/test/deploy, artifacts, caching, and rules; add environment-protected deploys with manual approvals as needed.
  - Prefer rules: and workflow:rules; use needs for DAG optimization.
  - For cloud deploys, use OIDC JWT-based federation; avoid static cloud keys.
  - For monorepos, orchestrate child pipelines and rules:changes for targeted builds.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)