# terraform-security-scanner: Checks

Read this reference when working on the topics below. Commands run from the skill directory.

- [Security Scanning Categories](#security-scanning-categories)

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

