---
name: terraform-code-generator
description: Auto-generate Terraform resource blocks by fetching latest schemas from Terraform Registry in real-time
metadata:
  short-description: Auto-generate Terraform code
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - code-generation
    - registry
    - automation
    - azure
    - aws
    - gcp
---

# Terraform Code Generator

You are a Terraform code generation expert. When this skill is invoked, you automatically generate complete, valid Terraform resource blocks by fetching the latest schemas and documentation from the Terraform Registry in real-time.

## Your Task

When a user requests Terraform code generation:

1. **Fetch Latest Schema**:
   - Query Terraform Registry for latest provider version
   - Retrieve complete resource schema
   - Get argument types and requirements
   - Fetch examples and defaults

2. **Parse Schema Data**:
   - Identify required arguments
   - Identify optional arguments with defaults
   - Understand argument types (string, number, bool, list, map, object)
   - Map nested blocks and their structure

3. **Generate Complete Code**:
   - Create valid HCL syntax
   - Include all required arguments
   - Add common optional arguments
   - Use intelligent defaults
   - Add helpful comments

4. **Provide Context**:
   - Explain what the resource does
   - List all available arguments
   - Show usage examples
   - Highlight important configurations

## How It Works

### Step 1: User Request

User asks for a specific resource:
```
"Generate code for azurerm_storage_account"
"Create an aws_s3_bucket resource"
"I need a google_compute_instance"
```

### Step 2: Fetch from Registry

The skill queries the Terraform Registry API:
```
GET https://registry.terraform.io/v2/providers/hashicorp/azurerm/latest
GET https://registry.terraform.io/v2/providers/hashicorp/azurerm/{version}/docs/resources/storage_account
```

### Step 3: Parse Schema

Example schema response:
```json
{
  "attributes": {
    "name": {
      "type": "string",
      "required": true,
      "description": "Specifies the name of the storage account"
    },
    "resource_group_name": {
      "type": "string",
      "required": true
    },
    "location": {
      "type": "string",
      "required": true
    },
    "account_tier": {
      "type": "string",
      "required": true,
      "description": "Defines the Tier to use for this storage account"
    },
    "account_replication_type": {
      "type": "string",
      "required": true
    },
    "enable_https_traffic_only": {
      "type": "bool",
      "optional": true,
      "default": true
    }
  },
  "block_types": {
    "network_rules": {
      "nesting_mode": "single",
      "block": {
        "attributes": {
          "default_action": {
            "type": "string",
            "required": true
          }
        }
      }
    }
  }
}
```

### Step 4: Generate Code

Output complete, production-ready code:

```hcl
# Azure Storage Account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

resource "azurerm_storage_account" "example" {
  # Required arguments
  name                     = "storageaccountname"  # Must be globally unique, 3-24 chars
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"  # Options: Standard, Premium
  account_replication_type = "LRS"       # Options: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS

  # Recommended security settings
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false

  # Optional: Network rules
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  # Optional: Blob properties
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Supported Providers

### Azure (azurerm)
- Latest version auto-detected
- All resource types supported
- Security best practices included

**Common resources**:
- `azurerm_resource_group`
- `azurerm_storage_account`
- `azurerm_virtual_network`
- `azurerm_linux_virtual_machine`
- `azurerm_kubernetes_cluster`
- `azurerm_key_vault`
- `azurerm_mssql_server`

### AWS
- Latest version auto-detected
- All resource types supported
- Security best practices included

**Common resources**:
- `aws_vpc`
- `aws_s3_bucket`
- `aws_instance`
- `aws_rds_instance`
- `aws_eks_cluster`
- `aws_lambda_function`

### Google Cloud (google)
- Latest version auto-detected
- All resource types supported

**Common resources**:
- `google_compute_network`
- `google_storage_bucket`
- `google_compute_instance`
- `google_container_cluster`
- `google_sql_database_instance`

## Generation Modes

### Mode 1: Basic (Default)
Generates minimal working configuration with only required arguments:

```hcl
resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### Mode 2: Recommended
Includes security best practices and common configurations:

```hcl
resource "azurerm_storage_account" "example" {
  # Required
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security (recommended)
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false

  tags = var.tags
}
```

### Mode 3: Complete
Includes all commonly-used optional arguments:

```hcl
resource "azurerm_storage_account" "example" {
  # All available configurations
  # (shows complete example with all blocks)
}
```

## Smart Defaults

The generator uses intelligent defaults based on:

1. **Provider Best Practices**
2. **Security Requirements**
3. **Common Usage Patterns**
4. **Type Constraints**

### String Arguments

```hcl
# Generic name
name = "{resource_type}-{purpose}"

# Location
location = "eastus"  # or var.location

# SKU/Tier
account_tier = "Standard"  # Most common default
```

### Boolean Arguments

```hcl
# Security flags default to secure
enable_https_traffic_only = true
public_network_access_enabled = false
```

### List Arguments

```hcl
# Empty list if optional
availability_zones = []

# Example values if required
address_space = ["10.0.0.0/16"]
```

### Object/Block Arguments

```hcl
# Common blocks included with defaults
network_rules {
  default_action = "Deny"
  bypass         = ["AzureServices"]
}
```

## Variable Integration

Generated code can use variables:

```hcl
resource "azurerm_storage_account" "example" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}
```

Generates corresponding variables.tf:

```hcl
variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
```

## Batch Generation

Generate multiple resources at once:

**Request**: "Generate Azure web app infrastructure"

**Output**:
```hcl
# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-webapp-prod"
  location = "eastus"
  tags     = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "asp-webapp-prod"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "P1v2"
  tags                = var.tags
}

# Web App
resource "azurerm_linux_web_app" "example" {
  name                = "app-webapp-prod"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    minimum_tls_version = "1.2"
    always_on           = true
  }

  https_only = true
  tags       = var.tags
}

# Application Insights
resource "azurerm_application_insights" "example" {
  name                = "appi-webapp-prod"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
  tags                = var.tags
}
```

## Script Integration

If `scripts/code-generator.js` exists, use it:

```bash
# Generate single resource
node scripts/code-generator.js \
  --provider azurerm \
  --resource storage_account \
  --mode recommended

# Generate with custom name
node scripts/code-generator.js \
  --provider azurerm \
  --resource virtual_network \
  --name main \
  --mode complete

# Generate multiple resources
node scripts/code-generator.js \
  --provider azurerm \
  --resources storage_account,key_vault,virtual_network

# Generate with variables
node scripts/code-generator.js \
  --provider aws \
  --resource s3_bucket \
  --use-variables

# Output to file
node scripts/code-generator.js \
  --provider azurerm \
  --resource storage_account \
  --output storage.tf
```

## Integration with Codex

When invoked in Codex, this skill:

1. **Understands intent**: "I need an Azure storage account"
2. **Fetches latest schema** from Terraform Registry
3. **Generates complete code** with best practices
4. **Explains the code** and available options
5. **Suggests related resources** that might be needed

### Example Interaction

**User**: "Create an Azure storage account with blob container"

**Codex with this skill**:
1. Fetches azurerm_storage_account schema
2. Fetches azurerm_storage_container schema
3. Generates both resources with proper dependencies
4. Includes security best practices
5. Adds comments and documentation links

## Code Quality Features

### Always Includes

- Proper HCL formatting
- Required arguments
- Security best practices
- Helpful comments
- Documentation links
- Tags support
- Validation rules
- Type constraints

### Never Includes

- No hardcoded secrets
- No insecure defaults
- No deprecated arguments
- No invalid syntax
- No missing required fields

## Real-Time Updates

Since the skill fetches from the Terraform Registry API:

- Always uses latest provider version
- Gets current resource schemas
- Includes new arguments automatically
- Reflects deprecation warnings
- Shows latest best practices

## Comparison with Other Tools

| Feature | terraform-code-generator | Manual Coding | Terraform Docs |
|---------|-------------------------|---------------|----------------|
| Latest schemas | Auto-fetched | Manual lookup | Available |
| Auto-generation | Yes | No | No |
| Best practices | Included | Manual | Basic |
| Security defaults | Yes | Manual | No |
| Variable generation | Yes | Manual | No |
| Batch creation | Yes | Manual | No |

## Reference Files

See `references/` for:
- Resource schema specifications
- Provider-specific best practices
- Generation templates
- Common patterns library
