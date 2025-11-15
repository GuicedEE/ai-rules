# TeamCity — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD with JetBrains TeamCity (build, test, package, deploy) using UI or Kotlin DSL (preferred).
- Designed for docs-first prompts and quick adoption in polyglot/monorepo environments with on‑prem or cloud agents.

When to use
- Self-managed CI with powerful agent orchestration, build chains, snapshot dependencies, and Kotlin DSL configuration as code.
- Need for flexible VCS triggers (GitHub/GitLab/Azure), Pull/Merge Request checks, and parameterized pipelines.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers (see siblings under providers/): GitHub Actions, GitLab CI, Jenkins, Google Cloud Build, Azure Pipelines, AWS CodeBuild/CodePipeline

Key concepts (anchor wording)
- Project / Build Configuration
  - TeamCity organizes builds into Projects with one or more Build Configurations (pipelines).
- VCS Root
  - The SCM connection (Git URL + auth) attached to build configurations; enables change detection and checkout rules.
- Triggers
  - Rules to start builds (VCS trigger, schedule, finish build trigger for chain orchestration).
- Build Steps
  - Commands or tool runners (e.g., Command Line, Maven, Gradle, npm, Docker). Steps run on agents.
- Parameters
  - Key/value parameters for builds (Configuration, Environment, System). Support secure parameters for secrets.
- Snapshot & Artifact Dependencies
  - Build chain orchestration; Snapshot dependencies enforce consistent VCS state and order; Artifact dependencies pass build outputs.
- Agents
  - Machines that execute builds. Requirements/constraints target specific tools/OS/labels. Agents can be cloud/ephemeral.

Kotlin DSL (configuration as code)
- Recommended for versioning pipelines alongside code. The example below shows a simple Node pipeline with build + test.

settings.kts (basic)
```kotlin
import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.projectFeatures.githubIssues
import jetbrains.buildServer.configs.kotlin.vcs.GitVcsRoot
import jetbrains.buildServer.configs.kotlin.v2019_2.Project
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs

version = "2023.11"

project {
    description = "Example project with build & test"
    params {
        param("env.NODE_ENV", "test")
    }

    val vcsRoot = GitVcsRoot {
        id("Example_Vcs")
        name = "example-repo"
        url = "https://github.com/org/repo.git"
        branch = "refs/heads/main"
        branchSpec = "+:refs/heads/*"
        authMethod = password {
            userName = "token"
            password = "credentialsJSON:***" // TeamCity secure credential reference
        }
    }
    vcsRoot(vcsRoot)

    buildType(Build)
    buildType(Test)

    features {
        githubIssues {
            id = "PROJECT_GitHubIssues"
            displayName = "GitHub"
            repositoryURL = "https://github.com/org/repo"
        }
    }
}

object Build : BuildType({
    name = "Build"
    description = "Install and build"

    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }

    params {
        param("env.CI", "1")
    }

    steps {
        script {
            name = "Node 20 + npm ci"
            scriptContent = """
                set -e
                node -v || curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
                export PATH="$HOME/.fnm:$PATH"
                fnm use 20
                npm ci
                npm run build
            """.trimIndent()
        }
    }

    artifactRules = "dist => dist"

    triggers {
        vcs {
            // Build on default branch and PRs; refine with branchFilter if necessary
            branchFilter = """
                +:refs/heads/*
                +:refs/pull/*
            """.trimIndent()
        }
    }

    requirements {
        // Require Linux agent with Docker label, for example
        equals("teamcity.agent.jvm.os.name", "Linux")
        contains("teamcity.agent.name", "docker")
    }
})

object Test : BuildType({
    name = "Test"
    description = "Run unit tests and publish reports"

    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }

    steps {
        script {
            name = "Unit tests"
            scriptContent = """
                set -e
                node -v || curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
                export PATH="$HOME/.fnm:$PATH"
                fnm use 20
                npm ci
                npm test -- --ci --reporter=junit --reporter-options "output=junit.xml"
            """.trimIndent()
        }
    }

    artifactRules = """
        coverage => coverage
        junit.xml
    """.trimIndent()

    dependencies {
        snapshot(Build) {
            // ensures consistent revision
            onDependencyFailure = FailureAction.FAIL_TO_START
            onDependencyCancel = FailureAction.CANCEL
        }
        artifacts(Build) {
            artifactRules = "dist => dist"
            cleanDestination = true
        }
    }

    requirements {
        equals("teamcity.agent.jvm.os.name", "Linux")
    }
})
```

Monorepo strategies
- Multiple Build Configurations per subproject (service-a, web-ui, lib-x), guarded by checkout rules or parameters.
- Use Kotlin DSL to detect changes and trigger child builds selectively:
  - VCS checkout rules: exclude/ include folders per build.
  - Parameters + build steps with when logic (or dedicated configs).
- Composite build types (Build Chain) to orchestrate parallel subprojects and aggregate results.

Artifacts, caching, and dependencies
- Artifact dependencies pass outputs between configs (e.g., “dist/”).
- Use build cache directories via parameters pointing to language/tool caches (e.g., ~/.m2, ~/.npm).
- Keep caches per-branch or per-commit to avoid corruption.

Triggers & branch filters
- VCS trigger with branchFilter to include/exclude refs.
- Pull Request integrations via JetBrains GitHub/GitLab plugins or webhook-based checks.
- Schedule triggers for nightly builds/CRON.

Parameters & secrets
- Configuration / System / Environment parameters drive pipeline behavior.
- Secure parameters (password/credentials) stored in TeamCity and referenced in DSL/scripts:
  - “credentialsJSON:…” or %secure:PARAM_NAME% style.
- Avoid echoing secrets; use masked params and environment injection.

Agents & requirements
- Label agents with capabilities (docker, maven, jdk21, node20).
- Set requirements to route jobs to suitable agents:
  - equals("teamcity.agent.jvm.os.name", "Linux")
  - contains("teamcity.agent.name", "k8s")
- For containerized steps, consider Docker wrapper scripts or Kubernetes agent integration (TeamCity cloud profiles).

Build chains & snapshot dependencies
- Build chain orchestrates order (Build → Test → Integration → Deploy).
- Snapshot dependencies ensure consistent VCS revision across the chain.
- Artifact dependencies pass build outputs; enable “clean destination” to avoid stale artifacts.

Deployments & approvals
- Use dedicated Deploy build configs with manual/approval triggers (or feature branches → staging).
- Environment tagging via parameters (ENV=staging/production) and protected parameters.
- Promote artifacts from previous builds (no rebuild) to ensure repeatability.

Cloud credentials (ephemeral recommended)
- AWS: AssumeRole via STS, provision via temporary credentials from a broker or OIDC/SAML integration in the agent.
- GCP: ADC via workload identity on GKE agents, or short-lived SA key injection (rotate frequently).
- Azure: Service Principal + federated credentials or injected OIDC token.

Quality gates and reports
- Publish JUnit (XML) and coverage as artifacts; integrate with report tabs.
- SonarQube: use scanner step and fail build on gate failure.

LLM interpretation guidance
- If “TeamCity” is selected:
  - Provide Kotlin DSL “settings.kts” with Projects and Build Configurations for build/test (and deploy if requested).
  - Configure VCS Root, VCS triggers, snapshot + artifact dependencies for a simple build chain.
  - Add agent requirements/labels and parameters for environment/secret handling.
  - For monorepos, create multiple Build Configs with checkout rules and compose a Build Chain; surface artifacts and reports.
  - Prefer ephemeral cloud auth (assume-role / workload identity) over long-lived static credentials.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)