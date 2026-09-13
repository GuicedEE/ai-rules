# terraform-validator: Validation rules

Read this reference when working on the topics below. Commands run from the skill directory.

- [Validation Levels](#validation-levels)
- [Common Issues and Fixes](#common-issues-and-fixes)
- [Naming Convention Standards](#naming-convention-standards)

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

