# terraform-security-scanner: Tools

Read this reference when working on the topics below. Commands run from the skill directory.

- [Security Scanning Tools](#security-scanning-tools)
- [CI/CD Integration](#cicd-integration)

## Security Scanning Tools

### 1. tfsec

**Install**:
```bash
# macOS
brew install tfsec

# Linux
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Windows
choco install tfsec
```

**Run**:
```bash
tfsec .
```

**Common Checks**:
- AWS001: S3 bucket encryption
- AZU001: Storage account encryption
- GCP001: Compute instance encryption
- And 1000+ more rules

### 2. Checkov

**Install**:
```bash
pip install checkov
```

**Run**:
```bash
checkov -d .
```

**Features**:
- 1000+ built-in policies
- Custom policy support
- SARIF output for CI/CD
- Graph-based scanning

### 3. Terrascan

**Install**:
```bash
# macOS
brew install terrascan

# Linux/Windows
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
tar -xf terrascan.tar.gz
```

**Run**:
```bash
terrascan scan
```

**Policies**:
- CIS benchmarks
- NIST framework
- PCI DSS
- HIPAA
- Custom OPA policies

### 4. Snyk

**Install**:
```bash
npm install -g snyk
```

**Run**:
```bash
snyk iac test
```

**Features**:
- Vulnerability database
- Fix suggestions
- CI/CD integration
- Dependency scanning

## CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan

on:
  push:
    paths:
      - '**.tf'
  pull_request:
    paths:
      - '**.tf'

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          soft_fail: false

      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: checkov-results.sarif

      - name: Upload results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: checkov-results.sarif
```

### Azure DevOps

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - '**.tf'

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: CmdLine@2
  displayName: 'Install tfsec'
  inputs:
    script: |
      curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

- task: CmdLine@2
  displayName: 'Run Security Scan'
  inputs:
    script: |
      tfsec . --format junit > tfsec-results.xml

- task: PublishTestResults@2
  displayName: 'Publish Security Results'
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: 'tfsec-results.xml'
```

