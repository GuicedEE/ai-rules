# terraform-module-scaffold: Design

Read this reference when working on the topics below. Commands run from the skill directory.

- [Module Design Principles](#module-design-principles)
- [Common Module Patterns](#common-module-patterns)
- [Module Naming Convention](#module-naming-convention)
- [Variable Naming](#variable-naming)

## Module Design Principles

### 1. Single Responsibility
Each module should do ONE thing well.

**Good**: `terraform-azurerm-virtual-network` creates a VNet
**Bad**: `terraform-azurerm-infrastructure` creates VNet, VMs, databases, etc.

### 2. Sensible Defaults
Provide defaults for optional variables:

```hcl
variable "enable_https" {
  description = "Enable HTTPS"
  type        = bool
  default     = true  # Secure by default
}
```

### 3. Validation
Validate inputs to fail fast:

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 4. Flexibility
Use `dynamic` blocks for optional features:

```hcl
dynamic "network_rules" {
  for_each = var.network_rules != null ? [var.network_rules] : []

  content {
    default_action = network_rules.value.default_action
    # ...
  }
}
```

### 5. Output Everything Important
Users might need any attribute:

```hcl
output "resource" {
  description = "Complete resource object"
  value       = azurerm_resource.main
}
```

## Common Module Patterns

### Optional Resource Creation

```hcl
resource "azurerm_resource" "optional" {
  count = var.create_resource ? 1 : 0
  # ...
}

output "resource_id" {
  value = var.create_resource ? azurerm_resource.optional[0].id : null
}
```

### Multiple Instances

```hcl
resource "azurerm_resource" "multiple" {
  for_each = var.instances

  name = each.key
  # Use each.value for configuration
}
```

### Conditional Configuration

```hcl
resource "azurerm_resource" "main" {
  name = var.name

  sku_name = var.environment == "prod" ? "Premium" : "Standard"
}
```

## Module Naming Convention

Follow this pattern:
- `terraform-{provider}-{resource}`
- Examples:
  - `terraform-azurerm-virtual-network`
  - `terraform-aws-vpc`
  - `terraform-google-compute-network`

## Variable Naming

- Use descriptive names: `storage_account_name` not `san`
- Group related variables: `network_*`, `security_*`
- Boolean variables: `enable_*`, `create_*`, `use_*`

