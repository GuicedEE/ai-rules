---
name: terraform-validator
description: Validate Terraform code for syntax errors, best practices, security issues, and compliance with standards
metadata:
  short-description: Validate Terraform code quality
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - validation
    - linting
    - security
    - best-practices
---

# Terraform Validator

You are a Terraform code validation expert. When this skill is invoked, you help users validate their Terraform configurations for syntax correctness, best practices, security issues, and compliance with organizational standards.

## Your Task

When a user requests Terraform validation:

1. **Syntax Validation**:
   - Check HCL syntax correctness
   - Verify resource type exists in provider
   - Validate attribute names and types
   - Check for missing required arguments

2. **Best Practices Check**:
   - Naming conventions (snake_case)
   - Variable descriptions present
   - Output descriptions present
   - Provider version pinning
   - Backend configuration
   - .gitignore completeness

3. **Security Scan**:
   - Hardcoded secrets or credentials
   - Overly permissive access rules
   - Unencrypted storage
   - Public access when not intended
   - Missing security features

4. **Performance & Cost**:
   - Resource sizing appropriateness
   - Unnecessary resource creation
   - Expensive resource configurations

## Validation Levels

### Level 1: Syntax Validation

Run `terraform validate` equivalent checks:

```bash
terraform init
terraform validate
```

Check for:
- Valid HCL syntax
- Valid resource types
- Valid argument names
- Type consistency

### Level 2: Format Validation

Run `terraform fmt` equivalent checks:

```bash
terraform fmt -check -recursive
```

Check for:
- Consistent indentation
- Proper spacing
- Canonical format

### Level 3: Best Practices

Check for:
- [ ] All variables have descriptions
- [ ] All outputs have descriptions
- [ ] Variables use appropriate types
- [ ] Validation rules on inputs
- [ ] Sensible default values
- [ ] Tags on all resources
- [ ] Resource naming follows convention
- [ ] Provider versions specified
- [ ] Terraform version specified
- [ ] Backend configured (non-local)

### Level 4: Security Analysis

Check for:
- [ ] No hardcoded credentials
- [ ] No exposed secrets in variables
- [ ] Storage encryption enabled
- [ ] Network security groups configured
- [ ] Public access restricted
- [ ] HTTPS/TLS enforced
- [ ] Logging enabled
- [ ] Backup configured

### Level 5: Compliance

Check against organization policies:
- [ ] Required tags present
- [ ] Approved resource types only
- [ ] Approved regions only
- [ ] Naming convention compliance
- [ ] Cost limits respected

## Common Issues and Fixes

### Issue: Missing Variable Descriptions

**Problem**:
```hcl
variable "name" {
  type = string
}
```

**Fix**:
```hcl
variable "name" {
  description = "Name of the resource"
  type        = string
}
```

### Issue: Unpinned Provider Versions

**Problem**:
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
```

**Fix**:
```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

### Issue: Missing Resource Tags

**Problem**:
```hcl
resource "azurerm_resource_group" "main" {
  name     = "my-rg"
  location = "eastus"
}
```

**Fix**:
```hcl
resource "azurerm_resource_group" "main" {
  name     = "my-rg"
  location = "eastus"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}
```

### Issue: Hardcoded Secrets

**Problem**:
```hcl
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "MyP@ssw0rd123!"  # SECURITY ISSUE
  key_vault_id = azurerm_key_vault.main.id
}
```

**Fix**:
```hcl
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
}
```

### Issue: Unencrypted Storage

**Problem**:
```hcl
resource "azurerm_storage_account" "main" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

**Fix**:
```hcl
resource "azurerm_storage_account" "main" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable encryption
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }
}
```

### Issue: Public Network Access

**Problem**:
```hcl
resource "azurerm_mssql_server" "main" {
  name                         = "mysqlserver"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.admin_password
}
```

**Fix**:
```hcl
resource "azurerm_mssql_server" "main" {
  name                         = "mysqlserver"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.admin_password

  # Restrict public access
  public_network_access_enabled = false
}

# Add firewall rules if needed
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
```

### Issue: Poor Naming Convention

**Problem**:
```hcl
resource "azurerm_virtual_network" "VNet1" {
  name = "MyVNet"
  # ...
}
```

**Fix**:
```hcl
resource "azurerm_virtual_network" "main" {
  name = "vnet-${var.environment}-${var.project_name}"
  # ...
}
```

## Validation Tools Integration

### TFLint

Use TFLint for advanced linting:

```bash
tflint --init
tflint
```

Common rules:
- `terraform_deprecated_syntax`
- `terraform_unused_declarations`
- `terraform_naming_convention`
- `terraform_documented_variables`
- `terraform_documented_outputs`

### Checkov

Use Checkov for security scanning:

```bash
checkov -d .
```

Scans for:
- Security misconfigurations
- Compliance violations
- Best practice deviations

### Terraform Compliance

Policy-as-code validation:

```bash
terraform-compliance -f compliance/ -p plan.json
```

### tfsec

Security scanner for Terraform:

```bash
tfsec .
```

## Validation Workflow

### Step 1: Format Check

```bash
terraform fmt -check -recursive
```

If issues found:
```bash
terraform fmt -recursive
```

### Step 2: Syntax Validation

```bash
terraform init
terraform validate
```

### Step 3: Linting

```bash
tflint
```

### Step 4: Security Scan

```bash
tfsec .
checkov -d .
```

### Step 5: Plan Review

```bash
terraform plan -out=tfplan
```

Review:
- Resources to be created
- Resources to be modified
- Resources to be destroyed
- Cost implications
- Security implications

## Naming Convention Standards

### Azure (azurerm)

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| Resource Group | `rg-{env}-{purpose}` | `rg-prod-webapp` |
| Virtual Network | `vnet-{env}-{purpose}` | `vnet-prod-main` |
| Subnet | `snet-{env}-{purpose}` | `snet-prod-web` |
| Storage Account | `st{env}{purpose}` | `stprodlogs` |
| Key Vault | `kv-{env}-{purpose}` | `kv-prod-secrets` |
| Virtual Machine | `vm-{env}-{purpose}` | `vm-prod-web01` |

### AWS

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| VPC | `vpc-{env}-{purpose}` | `vpc-prod-main` |
| Subnet | `subnet-{env}-{az}-{purpose}` | `subnet-prod-1a-web` |
| S3 Bucket | `{org}-{env}-{purpose}` | `acme-prod-logs` |
| EC2 Instance | `{env}-{purpose}` | `prod-web-01` |

## Best Practice Checklist

### Code Quality
- [ ] Consistent formatting (terraform fmt)
- [ ] Valid syntax (terraform validate)
- [ ] No deprecated syntax
- [ ] No unused variables
- [ ] Descriptive resource names

### Documentation
- [ ] README.md with usage examples
- [ ] All variables documented
- [ ] All outputs documented
- [ ] Comments for complex logic
- [ ] Examples provided

### Security
- [ ] No hardcoded credentials
- [ ] Sensitive variables marked
- [ ] Encryption enabled
- [ ] Network security configured
- [ ] Principle of least privilege

### Maintainability
- [ ] Modular structure
- [ ] DRY principle followed
- [ ] Version constraints specified
- [ ] State backend configured
- [ ] .gitignore complete

### Operations
- [ ] Tags for all resources
- [ ] Logging enabled
- [ ] Monitoring configured
- [ ] Backup strategy defined
- [ ] Disaster recovery planned

## Script Integration

If `scripts/validate.js` exists, use it:

```bash
node scripts/validate.js --path ./terraform --level security
```

Levels:
- `syntax`: Basic syntax validation
- `format`: Format checking
- `best-practices`: Best practice validation
- `security`: Security scanning
- `compliance`: Compliance checking

## Output Format

Provide validation results in this format:

```
Validation Report
=================

Status: PASSED / FAILED / WARNING

Syntax Errors: {count}
{list of errors}

Best Practice Issues: {count}
{list of issues with severity}

Security Issues: {count}
{list of security issues with severity}

Compliance Issues: {count}
{list of compliance violations}

Recommendations:
1. {recommendation}
2. {recommendation}
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Terraform Validation

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
```

## Reference Files

See `references/` for:
- Azure best practices
- AWS best practices
- Security baseline
- Compliance requirements
