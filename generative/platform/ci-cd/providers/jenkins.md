# Jenkins — CI/CD Provider Topic

Purpose
- Modular guidance for implementing CI/CD with Jenkins (build, test, package, deploy), suitable for controller/agent or controller-only setups.
- Designed for docs-first prompts and quick adoption in polyglot/monorepo environments.

When to use
- On-prem or self-managed CI with flexible plugins and bespoke agents (Windows/Linux/macOS/Docker-in-Docker/Kubernetes).
- Need for pipeline-as-code (Jenkinsfile), multi-branch pipelines, shared libraries, and fine-grained credential/secret scoping.

Routing
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Other providers (see siblings under providers/): GitHub Actions, GitLab CI, TeamCity, Google Cloud Build, Azure Pipelines, AWS CodeBuild/CodePipeline

Key concepts (anchor wording)
- Controller/Agent
  - Controller schedules and orchestrates work; Agents (nodes) execute jobs. Labels target specific OS/CPU/arch/capabilities.
- Pipeline (Declarative/Scripted)
  - Pipeline-as-code in Jenkinsfile; Declarative recommended for readability, Scripted for complex flows.
- Multibranch
  - Discovers branches/PRs (SCM) and builds each with its Jenkinsfile; essential for monorepos and branch policy enforcement.
- Shared Library
  - Reusable steps/vars/classes versioned in SCM (global or folder-scope).
- Credentials
  - Managed secrets (Username/Password, Secret Text, SSH Key, Certificates). Consumed via credentials() binding or environment injection.
- Folder/Folder-level Configuration
  - Scopes authorization, credentials, and defaults to subsets of jobs.

Minimal Declarative Jenkinsfile (Node + Maven examples)

```groovy
// Jenkinsfile (declarative, Node example)
pipeline {
  agent { label 'linux && docker' }
  options {
    timeout(time: 30, unit: 'MINUTES')
    durabilityHint('PERFORMANCE_OPTIMIZED')
  }
  triggers { pollSCM('@daily') } // or GitHub/GitLab webhooks recommended
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Setup Node') {
      steps {
        sh 'node -v || curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell; export PATH="$HOME/.fnm:$PATH"; fnm use 20'
        sh 'npm ci'
      }
    }
    stage('Unit Tests') {
      steps { sh 'npm test -- --ci' }
      post {
        always {
          junit 'junit.xml' // if produced
          archiveArtifacts artifacts: 'coverage/**', allowEmptyArchive: true
        }
      }
    }
    stage('Build') {
      steps { sh 'npm run build' }
      post {
        success { archiveArtifacts artifacts: 'dist/**', fingerprint: true }
      }
    }
  }
}
```

```groovy
// Jenkinsfile (declarative, Maven example)
pipeline {
  agent { label 'linux && maven && jdk21' }
  tools { jdk 'jdk-21' }
  options { timeout(time: 45, unit: 'MINUTES') }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build & Test') { steps { sh 'mvn -B -ntp verify' } }
  }
  post {
    always {
      junit '**/target/surefire-reports/*.xml'
      archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
    }
  }
}
```

Parallel stages (matrix-like)

```groovy
pipeline {
  agent none
  stages {
    stage('Matrix') {
      parallel {
        stage('Node 18') {
          agent { label 'linux' }
          steps { sh 'nvm use 18 && npm ci && npm test -- --ci' }
        }
        stage('Node 20') {
          agent { label 'linux' }
          steps { sh 'nvm use 20 && npm ci && npm test -- --ci' }
        }
      }
    }
  }
}
```

Docker/Kubernetes agents
- Docker agent per stage:
```groovy
pipeline {
  agent none
  stages {
    stage('Test in Docker') {
      agent { docker { image 'node:20-alpine'; args '-u root:root' } }
      steps { sh 'npm ci && npm test -- --ci' }
    }
  }
}
```

- Kubernetes agent (with Jenkins Kubernetes plugin):
```groovy
pipeline {
  agent {
    kubernetes {
      label 'k8s-agent'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: node:20
      command: ['cat']
      tty: true
"""
    }
  }
  stages {
    stage('Test') { steps { container('node') { sh 'npm ci && npm test -- --ci' } } }
  }
}
```

Credentials and secrets
- Use withCredentials for binding:
```groovy
withCredentials([string(credentialsId: 'NPM_TOKEN', variable: 'NPM_TOKEN')]) {
  sh 'npm config set //registry.npmjs.org/:_authToken="$NPM_TOKEN"'
  sh 'npm publish'
}
```

- For cloud deploys, prefer ephemeral credentials:
  - AWS: AssumeRole via STS (aws sts assume-role) acquired through OIDC/SAML or short-lived access keys.
  - GCP: Workload Identity (GKE), or service account key injection (avoid long-lived JSON keys; rotate frequently).
  - Azure: Service Principal federated credentials or OIDC token exchange.

PR/MR checks and quality gates
- Report JUnit, coverage, linting as build status; use Quality Gate (SonarQube plugin) if applicable.
- Use GitHub/GitLab integrations for checks; rely on webhooks instead of pollSCM where possible.

Monorepo strategies
- Multibranch pipelines per project directory (use path filters) or a single Jenkinsfile with staged/path-driven logic.
- Use shared libraries for common steps: vars/ci.groovy invoking language-specific builds.
- Use “when { changeset '**/path/**' }” to guard stages based on affected paths:
```groovy
stage('Build service-a') {
  when { changeset "**/services/service-a/**" }
  steps { sh 'cd services/service-a && mvn -B -ntp verify' }
}
```

Concurrency and locking
- throttle/concurrency options via “options” or Lockable Resources plugin to serialize deployments per environment.

LLM interpretation guidance
- If “Jenkins” is selected:
  - Create a Jenkinsfile with declarative pipeline covering checkout, build, test, artifacts, and environment-protected deploys.
  - For agents, choose Docker-in-Docker or Kubernetes where suitable; otherwise label self-hosted nodes.
  - Integrate with PR/MR checks and publish JUnit/coverage. Use credentials binding; prefer ephemeral cloud auth (OIDC/SAML) over long-lived keys.
  - For monorepos, use multibranch and shared libraries; guard stages by changesets.

See also
- CI/CD index — [README.md](rules/generative/platform/ci-cd/README.md)
- Security & Auth — [README.md](rules/generative/platform/security-auth/README.md)
- Secrets & Env — [README.md](rules/generative/platform/secrets-config/README.md)
- Observability — [README.md](rules/generative/platform/observability/README.md)