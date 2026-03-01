---
name: terraform-security-scanner
description: Comprehensive security scanning for Terraform code including secrets detection, compliance checks, and vulnerability assessment
metadata:
  short-description: Scan for security issues
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - security
    - scanning
    - secrets
    - compliance
    - vulnerabilities
---

# Terraform Security Scanner

You are a Terraform security expert. When this skill is invoked, you help users identify and fix security vulnerabilities, detect hardcoded secrets, ensure compliance, and implement security best practices in their Terraform code.

## Your Task

When a user requests security scanning:

1. **Secrets Detection**:
   - Scan for hardcoded passwords
   - Find API keys and access tokens
   - Detect private keys
   - Identify connection strings
   - Check for exposed credentials

2. **Security Misconfigurations**:
   - Unencrypted storage
   - Public network access
   - Weak TLS/SSL settings
   - Missing security groups
   - Overly permissive access

3. **Compliance Checks**:
   - CIS benchmarks
   - PCI DSS requirements
   - HIPAA compliance
   - SOC 2 controls
   - Custom policies

4. **Vulnerability Assessment**:
   - Deprecated resources
   - Known vulnerabilities
   - Insecure defaults
   - Missing security features
   - Version-specific issues

## Security Scanning Categories

### 1. Secrets and Credentials

**What to Look For**:
- Hardcoded passwords
- API keys
- Access tokens
- Private keys
- SSH keys
- Database credentials
- Connection strings
- Certificates

**Detection Patterns**:
```regex
password\s*=\s*"[^$]
api[_-]?key\s*=\s*"[^$]
secret\s*=\s*"[^$]
access[_-]?key\s*=\s*"[^$]
private[_-]?key\s*=\s*"[^$]
AKIA[0-9A-Z]{16}  # AWS Access Key
```

**Example Issues**:

❌ **Bad** - Hardcoded password:
```hcl
resource "azurerm_sql_server" "main" {
  administrator_login_password = "MyP@ssw0rd123!"
}
```

✅ **Good** - Use variables:
```hcl
variable "admin_password" {
  type      = string
  sensitive = true
}

resource "azurerm_sql_server" "main" {
  administrator_login_password = var.admin_password
}
```

✅ **Better** - Use Key Vault:
```hcl
data "azurerm_key_vault_secret" "admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_sql_server" "main" {
  administrator_login_password = data.azurerm_key_vault_secret.admin_password.value
}
```

### 2. Storage Security

**Azure Storage**:

❌ **Insecure**:
```hcl
resource "azurerm_storage_account" "main" {
  name                     = "mystorageaccount"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # Missing security configurations!
}
```

✅ **Secure**:
```hcl
resource "azurerm_storage_account" "main" {
  name                              = "mystorageaccount"
  account_tier                      = "Standard"
  account_replication_type          = "LRS"

  # Security best practices
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}
```

**AWS S3**:

❌ **Insecure**:
```hcl
resource "aws_s3_bucket" "main" {
  bucket = "my-bucket"
  acl    = "public-read"  # DANGEROUS!
}
```

✅ **Secure**:
```hcl
resource "aws_s3_bucket" "main" {
  bucket = "my-bucket"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 3. Network Security

**Public Access**:

❌ **Dangerous**:
```hcl
resource "azurerm_network_security_rule" "allow_all" {
  access                      = "Allow"
  direction                   = "Inbound"
  source_address_prefix       = "*"  # ENTIRE INTERNET!
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}
```

✅ **Secure**:
```hcl
resource "azurerm_network_security_rule" "allow_specific" {
  access                      = "Allow"
  direction                   = "Inbound"
  source_address_prefix       = "10.0.0.0/16"  # Specific CIDR
  destination_address_prefix  = "10.0.1.0/24"
  destination_port_range      = "443"  # Specific port
}
```

**Database Public Access**:

❌ **Insecure**:
```hcl
resource "azurerm_mssql_server" "main" {
  public_network_access_enabled = true  # Exposed to internet!
}
```

✅ **Secure**:
```hcl
resource "azurerm_mssql_server" "main" {
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.main.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}
```

### 4. Encryption

**At Rest**:

❌ **Unencrypted**:
```hcl
resource "azurerm_managed_disk" "main" {
  name                 = "data-disk"
  storage_account_type = "Standard_LRS"
  # No encryption!
}
```

✅ **Encrypted**:
```hcl
resource "azurerm_disk_encryption_set" "main" {
  name                = "disk-encryption"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  key_vault_key_id    = azurerm_key_vault_key.main.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_managed_disk" "main" {
  name                   = "data-disk"
  storage_account_type   = "Standard_LRS"
  disk_encryption_set_id = azurerm_disk_encryption_set.main.id
}
```

**In Transit**:

❌ **Insecure**:
```hcl
resource "azurerm_app_service" "main" {
  https_only = false  # Allows HTTP!
}
```

✅ **Secure**:
```hcl
resource "azurerm_linux_web_app" "main" {
  https_only = true

  site_config {
    minimum_tls_version = "1.2"

    cors {
      allowed_origins = ["https://example.com"]
    }
  }
}
```

### 5. Identity and Access Management

**Use Managed Identities**:

❌ **Avoid**:
```hcl
# Using service principal credentials
# requires managing secrets
```

✅ **Preferred**:
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "vm" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.main.identity[0].principal_id
}
```

**Least Privilege**:

❌ **Too permissive**:
```hcl
resource "azurerm_role_assignment" "main" {
  role_definition_name = "Contributor"  # Too broad!
  principal_id         = var.user_id
  scope                = azurerm_resource_group.main.id
}
```

✅ **Specific permissions**:
```hcl
resource "azurerm_role_assignment" "main" {
  role_definition_name = "Storage Blob Data Reader"  # Specific role
  principal_id         = var.user_id
  scope                = azurerm_storage_account.main.id  # Specific resource
}
```

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

## Security Scan Report Format

When scanning for security issues, provide:

```
Security Scan Report
====================
Scan Time: {timestamp}
Files Scanned: {count}
Security Tool: {tool_name}

CRITICAL Issues: {count}
HIGH Issues:     {count}
MEDIUM Issues:   {count}
LOW Issues:      {count}
INFO:            {count}

=== CRITICAL ISSUES ===

[CRITICAL] Hardcoded Secret Detected
  File: main.tf:45
  Resource: azurerm_sql_server.main
  Issue: Hardcoded password in administrator_login_password
  Impact: Credentials exposed in code
  Fix: Use Azure Key Vault or variables marked as sensitive

[CRITICAL] Public Storage Access
  File: storage.tf:12
  Resource: azurerm_storage_account.data
  Issue: Storage account allows public access
  Impact: Data may be exposed to internet
  Fix: Set allow_nested_items_to_be_public = false

=== HIGH ISSUES ===

[HIGH] Unencrypted Storage
  File: storage.tf:8
  Resource: azurerm_storage_account.logs
  Issue: HTTPS not enforced
  Impact: Data transmitted without encryption
  Fix: Set enable_https_traffic_only = true

[HIGH] Weak TLS Version
  File: app.tf:23
  Resource: azurerm_app_service.main
  Issue: TLS 1.0 allowed
  Impact: Vulnerable to protocol attacks
  Fix: Set min_tls_version = "1.2"

=== REMEDIATION SUMMARY ===

Priority Actions:
1. Remove all hardcoded credentials (2 instances)
2. Enable encryption on storage accounts (3 instances)
3. Restrict public network access (5 instances)
4. Upgrade TLS versions (4 instances)

Compliance Impact:
- PCI DSS: 3 violations
- HIPAA: 2 violations
- CIS Benchmark: 7 violations

Estimated Fix Time: 2-4 hours
```

## Compliance Frameworks

### CIS Benchmarks

**Azure CIS 1.4**:
- [ ] 3.1: Ensure storage encryption is enabled
- [ ] 3.2: Ensure HTTPS is enforced
- [ ] 3.7: Ensure public access is disabled
- [ ] 4.1: Ensure auditing is enabled on SQL servers
- [ ] 5.1: Ensure Network Security Groups deny all by default

**AWS CIS 1.4**:
- [ ] 2.1: Ensure S3 buckets are encrypted
- [ ] 2.2: Ensure S3 bucket logging is enabled
- [ ] 2.3: Ensure S3 bucket versioning is enabled
- [ ] 4.1: Ensure no security groups allow 0.0.0.0/0
- [ ] 4.2: Ensure default security groups restrict all traffic

### PCI DSS

For payment card data:
- [ ] Encryption at rest
- [ ] Encryption in transit
- [ ] Network segmentation
- [ ] Access control
- [ ] Audit logging
- [ ] Regular security testing

### HIPAA

For healthcare data:
- [ ] Data encryption (at rest and in transit)
- [ ] Access controls and authentication
- [ ] Audit logging and monitoring
- [ ] Data backup and recovery
- [ ] Disaster recovery plan

## Script Integration

If `scripts/security-scanner.js` exists, use it:

```bash
# Full security scan
node scripts/security-scanner.js --path ./terraform --severity all

# Critical and high only
node scripts/security-scanner.js --path ./terraform --severity critical,high

# Secrets detection only
node scripts/security-scanner.js --path ./terraform --secrets-only

# Compliance check
node scripts/security-scanner.js --path ./terraform --compliance cis-azure

# Export report
node scripts/security-scanner.js --path ./terraform --output security-report.json
```

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

## Custom Security Policies

### Define Custom Rules

Using OPA (Open Policy Agent):

```rego
package terraform.security

# Deny if storage account doesn't enforce HTTPS
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  not resource.change.after.enable_https_traffic_only

  msg := sprintf("Storage account '%s' must enforce HTTPS", [resource.address])
}

# Deny if VM doesn't have managed identity
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_linux_virtual_machine"
  not resource.change.after.identity

  msg := sprintf("VM '%s' must use managed identity", [resource.address])
}
```

## Security Checklist

Before deploying Terraform code:

### Secrets
- [ ] No hardcoded passwords
- [ ] No API keys in code
- [ ] No private keys in code
- [ ] Secrets stored in Key Vault
- [ ] Sensitive variables marked

### Encryption
- [ ] Storage encryption enabled
- [ ] HTTPS/TLS enforced
- [ ] Minimum TLS 1.2
- [ ] Database encryption enabled
- [ ] Disk encryption enabled

### Network
- [ ] Public access restricted
- [ ] NSG/Security Groups configured
- [ ] Private endpoints used
- [ ] VPN/Private Link for connectivity
- [ ] No 0.0.0.0/0 rules

### Access
- [ ] Managed identities used
- [ ] Least privilege access
- [ ] RBAC configured
- [ ] MFA required
- [ ] Access reviews enabled

### Monitoring
- [ ] Logging enabled
- [ ] Audit logs configured
- [ ] Alerts set up
- [ ] Security Center enabled
- [ ] Threat protection enabled

### Compliance
- [ ] CIS benchmarks met
- [ ] Industry standards followed
- [ ] Data residency requirements
- [ ] Retention policies set
- [ ] Backup configured

## Reference Files

See `references/` for:
- Complete secrets patterns
- Compliance mapping
- Security rule catalog
- Fix recommendations
