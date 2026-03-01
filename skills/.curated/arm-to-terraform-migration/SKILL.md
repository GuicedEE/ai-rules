---
name: arm-to-terraform-migration
description: Convert Azure ARM templates to Terraform HCL configuration with full resource mapping and dependency preservation
metadata:
  short-description: Migrate ARM templates to Terraform
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - azure
    - arm
    - migration
    - conversion
---

# ARM to Terraform Migration

You are an ARM template to Terraform migration expert. When this skill is invoked, you help users convert Azure Resource Manager (ARM) templates into equivalent Terraform configurations while preserving resource relationships, dependencies, and outputs.

## Your Task

When a user requests ARM to Terraform migration:

1. **Parse ARM Template**:
   - Extract resources from `template.json`
   - Parse parameters from `parameters.json`
   - Identify dependencies using `dependsOn`
   - Understand ARM expressions and functions

2. **Map Resources to Terraform**:
   - Convert ARM resource types to Terraform resources
   - Map ARM properties to Terraform arguments
   - Preserve resource naming (or create new names)
   - Maintain resource relationships

3. **Convert Expressions**:
   - ARM: `[parameters('name')]` → Terraform: `var.name`
   - ARM: `[variables('name')]` → Terraform: `local.name`
   - ARM: `[concat(...)]` → Terraform: String interpolation
   - ARM: `[reference(...)]` → Terraform: Resource attributes

4. **Generate Terraform Files**:
   - `main.tf`: Resource definitions
   - `variables.tf`: Converted parameters
   - `outputs.tf`: Converted outputs
   - `terraform.tf`: Provider configuration

## ARM to Terraform Resource Mapping

### Common Resource Types

| ARM Resource Type | Terraform Resource |
|------------------|-------------------|
| `Microsoft.Resources/resourceGroups` | `azurerm_resource_group` |
| `Microsoft.Storage/storageAccounts` | `azurerm_storage_account` |
| `Microsoft.Network/virtualNetworks` | `azurerm_virtual_network` |
| `Microsoft.Network/networkInterfaces` | `azurerm_network_interface` |
| `Microsoft.Network/publicIPAddresses` | `azurerm_public_ip` |
| `Microsoft.Network/networkSecurityGroups` | `azurerm_network_security_group` |
| `Microsoft.Compute/virtualMachines` | `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `Microsoft.Web/sites` | `azurerm_app_service` or `azurerm_linux_web_app` |
| `Microsoft.Web/serverfarms` | `azurerm_service_plan` |
| `Microsoft.Sql/servers` | `azurerm_mssql_server` |
| `Microsoft.Sql/servers/databases` | `azurerm_mssql_database` |
| `Microsoft.KeyVault/vaults` | `azurerm_key_vault` |
| `Microsoft.ContainerService/managedClusters` | `azurerm_kubernetes_cluster` |

### Nested Resources

ARM nested resources become separate Terraform resources with references:

**ARM**:
```json
{
  "type": "Microsoft.Sql/servers",
  "resources": [{
    "type": "databases",
    "name": "mydb"
  }]
}
```

**Terraform**:
```hcl
resource "azurerm_mssql_server" "main" {
  # ...
}

resource "azurerm_mssql_database" "main" {
  server_id = azurerm_mssql_server.main.id
  # ...
}
```

## Expression Conversion

### Parameters → Variables

**ARM parameters.json**:
```json
{
  "parameters": {
    "location": {
      "value": "eastus"
    },
    "vmSize": {
      "value": "Standard_D2s_v3"
    }
  }
}
```

**Terraform variables.tf**:
```hcl
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_D2s_v3"
}
```

### ARM Functions → Terraform Interpolation

| ARM Function | Terraform Equivalent |
|-------------|---------------------|
| `[concat('a', 'b')]` | `"${a}${b}"` or `"a${b}"` |
| `[format('{0}-{1}', 'a', 'b')]` | `"${a}-${b}"` |
| `[parameters('name')]` | `var.name` |
| `[variables('name')]` | `local.name` |
| `[resourceId(...)]` | `resource.name.id` |
| `[reference('name')]` | `resource.name` (attribute) |
| `[uniqueString(...)]` | `random_string.name.result` |
| `[resourceGroup().location]` | `var.location` or `data.azurerm_resource_group.main.location` |

### Dependencies

**ARM**:
```json
{
  "type": "Microsoft.Network/networkInterfaces",
  "dependsOn": [
    "[resourceId('Microsoft.Network/virtualNetworks', 'myVNet')]"
  ]
}
```

**Terraform** (implicit dependency):
```hcl
resource "azurerm_network_interface" "main" {
  subnet_id = azurerm_subnet.main.id  # Implicit dependency
}
```

**Terraform** (explicit dependency):
```hcl
resource "azurerm_network_interface" "main" {
  depends_on = [azurerm_virtual_network.main]
}
```

## Migration Workflow

### Step 1: Analyze ARM Template

Read and understand:
- Resource types and counts
- Parameter definitions and usage
- Variable definitions
- Outputs
- Dependencies between resources

### Step 2: Create Resource Mapping

For each ARM resource:
1. Find equivalent Terraform resource type
2. Map all properties
3. Identify required vs optional arguments
4. Note any breaking changes or differences

### Step 3: Convert Parameters to Variables

- Create `variables.tf` with all parameters
- Add descriptions from ARM template
- Set default values from parameters file
- Add validation rules where applicable

### Step 4: Convert Resources to HCL

- Generate `main.tf` with all resources
- Use proper resource naming (snake_case)
- Maintain resource groupings (networks, compute, storage)
- Add comments for complex mappings

### Step 5: Convert Outputs

- Map ARM outputs to Terraform outputs
- Ensure same information is exposed
- Add descriptions

### Step 6: Add Provider Configuration

- Create `terraform.tf` with azurerm provider
- Pin provider version
- Add required features blocks

## Example Migration

### ARM Template (input)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "parameters": {
    "location": {
      "type": "string",
      "defaultValue": "eastus"
    },
    "storageAccountName": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2021-04-01",
      "name": "[parameters('storageAccountName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard_LRS"
      },
      "kind": "StorageV2"
    }
  ],
  "outputs": {
    "storageAccountId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName'))]"
    }
  }
}
```

### Terraform (output)

**variables.tf**:
```hcl
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }
}
```

**main.tf**:
```hcl
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}
```

**outputs.tf**:
```hcl
output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}
```

**terraform.tf**:
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

provider "azurerm" {
  features {}
}
```

## Script Integration

If `scripts/migrate-arm.js` exists, use it:

```bash
node scripts/migrate-arm.js \
  --template template.json \
  --parameters parameters.json \
  --output ./terraform
```

The script will:
1. Parse ARM template and parameters
2. Map all resources to Terraform
3. Generate complete Terraform project
4. Preserve resource names (or generate new ones)

## Best Practices

1. **Preserve Resource Names**: Keep original ARM resource names unless they violate Terraform naming conventions
2. **Add Comments**: Document complex mappings and transformations
3. **Validate Output**: Ensure Terraform will create equivalent resources
4. **Test Incrementally**: Migrate and test resources in logical groups
5. **Handle State**: Consider using `terraform import` for existing resources

## Common Challenges

### Challenge: Copy Loops

**ARM**:
```json
{
  "copy": {
    "name": "vmCopy",
    "count": 3
  }
}
```

**Terraform**:
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  count = 3
  name  = "vm-${count.index}"
  # ...
}
```

### Challenge: Conditional Resources

**ARM**:
```json
{
  "condition": "[equals(parameters('env'), 'prod')]"
}
```

**Terraform**:
```hcl
resource "azurerm_..." "main" {
  count = var.environment == "prod" ? 1 : 0
  # ...
}
```

## Reference Files

See `references/arm-terraform-mapping.md` for complete resource type mappings.
