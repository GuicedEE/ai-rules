# Terraform Security Best Practices

This document outlines security best practices for Terraform configurations.

## General Security Principles

### 1. Never Hardcode Credentials

**Bad**:
```hcl
resource "azurerm_virtual_machine" "main" {
  admin_username = "adminuser"
  admin_password = "P@ssw0rd123!"  # NEVER DO THIS
}
```

**Good**:
```hcl
variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

resource "azurerm_virtual_machine" "main" {
  admin_username = "adminuser"
  admin_password = var.admin_password
}
```

### 2. Use Sensitive Flag for Secrets

Mark all sensitive variables:

```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for external service"
  type        = string
  sensitive   = true
}
```

### 3. Store Secrets in Key Vaults

**Azure Example**:
```hcl
data "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_mssql_server" "main" {
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

## Storage Security

### Enable HTTPS Only

```hcl
resource "azurerm_storage_account" "main" {
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
}
```

### Enable Encryption

```hcl
resource "azurerm_storage_account" "main" {
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }
}
```

## Network Security

### Restrict Public Access

```hcl
resource "azurerm_mssql_server" "main" {
  public_network_access_enabled = false
}
```

### Use Network Security Groups

```hcl
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
```

### Use Private Endpoints

```hcl
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
```

## Identity and Access Management

### Use Managed Identities

```hcl
resource "azurerm_linux_virtual_machine" "main" {
  identity {
    type = "SystemAssigned"
  }
}

# Grant permissions to the managed identity
resource "azurerm_role_assignment" "vm_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.main.identity[0].principal_id
}
```

### Implement Least Privilege

```hcl
resource "azurerm_role_assignment" "specific_permission" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"  # Specific, not "Contributor"
  principal_id         = var.service_principal_id
}
```

## Database Security

### Enable Auditing

```hcl
resource "azurerm_mssql_server" "main" {
  azuread_administrator {
    login_username = var.admin_username
    object_id      = var.admin_object_id
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  server_id                               = azurerm_mssql_server.main.id
  storage_endpoint                        = azurerm_storage_account.audit.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.audit.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 90
}
```

### Enable Threat Detection

```hcl
resource "azurerm_mssql_server_security_alert_policy" "main" {
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mssql_server.main.name
  state               = "Enabled"
  email_addresses     = ["security@example.com"]
}
```

## Logging and Monitoring

### Enable Diagnostic Logging

```hcl
resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = "diag-${var.resource_name}"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  metric {
    category = "AllMetrics"
  }
}
```

## Compliance Checks

### Azure CIS Benchmark

Key requirements:
- [ ] Enable Azure Security Center
- [ ] Enable MFA for all accounts
- [ ] Restrict access to Azure resources
- [ ] Enable logging and monitoring
- [ ] Encrypt data at rest and in transit

### HIPAA Compliance

For healthcare data:
- [ ] Encrypt all data
- [ ] Implement access controls
- [ ] Enable audit logging
- [ ] Regular security assessments
- [ ] Backup and disaster recovery

### PCI DSS

For payment card data:
- [ ] Network segmentation
- [ ] Encrypt cardholder data
- [ ] Regular security testing
- [ ] Access control measures
- [ ] Monitoring and logging

## Security Scanning Tools

### tfsec

Install and run:
```bash
brew install tfsec
tfsec .
```

### Checkov

Install and run:
```bash
pip install checkov
checkov -d .
```

### terrascan

Install and run:
```bash
brew install terrascan
terrascan scan
```

## Secure State Management

### Remote State with Encryption

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true  # Use Azure AD instead of storage keys
  }
}
```

### State Locking

Always use state locking to prevent concurrent modifications:

```hcl
terraform {
  backend "azurerm" {
    # ... other settings
    use_azuread_auth = true
  }
}
```

## Secrets Management

### Never Commit Secrets

Add to `.gitignore`:
```
*.tfvars
*.tfvars.json
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

### Use Environment Variables

```bash
export TF_VAR_admin_password="secure-password"
terraform apply
```

### Use CI/CD Secret Stores

In GitHub Actions:
```yaml
- name: Terraform Apply
  env:
    TF_VAR_admin_password: ${{ secrets.ADMIN_PASSWORD }}
  run: terraform apply -auto-approve
```

## Regular Security Reviews

1. **Weekly**: Review access logs
2. **Monthly**: Update provider versions
3. **Quarterly**: Security assessment
4. **Annually**: Full compliance audit

## Security Checklist

- [ ] No hardcoded credentials
- [ ] All sensitive variables marked
- [ ] Encryption enabled for storage
- [ ] HTTPS/TLS enforced
- [ ] Network security groups configured
- [ ] Public access restricted
- [ ] Managed identities used
- [ ] Least privilege access
- [ ] Logging enabled
- [ ] Monitoring configured
- [ ] State stored securely
- [ ] Secrets in key vault
- [ ] Regular security scans
- [ ] Compliance requirements met
