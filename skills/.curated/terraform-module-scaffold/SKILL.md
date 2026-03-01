---
name: terraform-module-scaffold
description: Create production-ready, reusable Terraform modules with complete documentation, examples, and tests
metadata:
  short-description: Scaffold Terraform modules
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - modules
    - scaffolding
    - reusable
---

# Terraform Module Scaffold

You are a Terraform module development expert. When this skill is invoked, you help users create complete, production-ready Terraform modules following HashiCorp best practices and community standards.

## Your Task

When a user requests a new Terraform module:

1. **Gather Requirements**:
   - Module purpose and description
   - Provider (azurerm, aws, google, etc.)
   - Resources to encapsulate
   - Input variables needed
   - Outputs to expose

2. **Generate Module Structure**:
   ```
   terraform-{module-name}/
   ├── main.tf              # Main resource definitions
   ├── variables.tf         # Input variable declarations
   ├── outputs.tf           # Output value declarations
   ├── versions.tf          # Terraform and provider version constraints
   ├── README.md            # Complete module documentation
   ├── examples/
   │   └── basic/
   │       ├── main.tf      # Example usage
   │       └── README.md    # Example documentation
   ├── tests/               # Optional: automated tests
   │   └── basic_test.go
   └── .gitignore
   ```

3. **Follow Module Best Practices**:
   - Single responsibility principle
   - Flexible and configurable
   - Sensible defaults
   - Comprehensive validation
   - Clear documentation
   - Working examples

## Module File Templates

### versions.tf
```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    {provider} = {
      source  = "hashicorp/{provider}"
      version = ">= {min_version}"
    }
  }
}
```

### variables.tf

Follow this pattern for all variables:

```hcl
variable "name" {
  description = "Clear description of what this variable does"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24
    error_message = "Name must be between 3 and 24 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_feature" {
  description = "Whether to enable optional feature"
  type        = bool
  default     = false
}
```

### outputs.tf

Always include:
- Resource IDs
- Resource names
- Important attributes
- Helpful descriptions

```hcl
output "id" {
  description = "ID of the {resource}"
  value       = azurerm_{resource}.main.id
}

output "name" {
  description = "Name of the {resource}"
  value       = azurerm_{resource}.main.name
}

output "resource" {
  description = "Full {resource} object for advanced use cases"
  value       = azurerm_{resource}.main
}
```

### main.tf

Structure resources logically:

```hcl
# Local values for computed/combined variables
locals {
  # Combine tags with defaults
  tags = merge(
    {
      Module    = "terraform-{module-name}"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  # Resource naming
  name = var.name_override != null ? var.name_override : "${var.project}-${var.environment}-${var.name_suffix}"
}

# Main resource(s)
resource "azurerm_{resource}" "main" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Required arguments
  required_arg = var.required_arg

  # Optional features
  dynamic "optional_block" {
    for_each = var.enable_feature ? [1] : []

    content {
      # Block configuration
    }
  }

  tags = local.tags
}

# Supporting resources
resource "azurerm_{supporting_resource}" "support" {
  count = var.create_supporting_resource ? 1 : 0

  name = "${azurerm_{resource}.main.name}-support"
  # ...
}
```

### README.md

Create comprehensive documentation:

```markdown
# Terraform Module: {Module Name}

{Brief description of what this module does}

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

### Basic Example

```hcl
module "{module_name}" {
  source = "path/to/module"

  name                = "my-resource"
  location            = "eastus"
  resource_group_name = "my-rg"

  tags = {
    Environment = "Production"
  }
}
```

### Advanced Example

```hcl
module "{module_name}" {
  source = "path/to/module"

  name                = "my-resource"
  location            = "eastus"
  resource_group_name = "my-rg"

  enable_feature      = true
  additional_config   = "value"

  tags = {
    Environment = "Production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| {provider} | >= {version} |

## Providers

| Name | Version |
|------|---------|
| {provider} | >= {version} |

## Resources

| Name | Type |
|------|------|
| {resource_type}.{name} | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource ID |
| name | Resource name |

## Examples

See the [examples](./examples/) directory for complete examples.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[License Type]
```

### examples/basic/main.tf

```hcl
terraform {
  required_version = ">= 1.6"
}

# Example resource group (in real use, this might already exist)
resource "azurerm_resource_group" "example" {
  name     = "rg-example"
  location = "eastus"
}

# Module usage
module "example" {
  source = "../.."  # Points to root of module

  name                = "example-resource"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Example"
    Purpose     = "Testing"
  }
}

# Outputs to verify
output "resource_id" {
  value = module.example.id
}
```

### examples/basic/README.md

```markdown
# Basic Example

This example demonstrates the basic usage of the {module-name} module.

## Usage

1. Update the variables in this file as needed
2. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What This Creates

- Resource group (for example purposes)
- {Main resource}

## Cleanup

```bash
terraform destroy
```
```

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

## Script Integration

If `scripts/scaffold-module.js` exists, use it:

```bash
node scripts/scaffold-module.js \
  --name virtual-network \
  --provider azurerm \
  --description "Create and manage Azure Virtual Networks" \
  --output ./modules
```

## Testing (Optional)

For critical modules, add automated tests using Terratest:

```go
package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestBasicExample(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../examples/basic",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  // Add assertions here
}
```

## Module Checklist

Before publishing a module, ensure:

- [ ] All variables have descriptions
- [ ] Validation rules where appropriate
- [ ] Sensible defaults for optional variables
- [ ] All important attributes are output
- [ ] README with usage examples
- [ ] At least one working example
- [ ] Version constraints specified
- [ ] .gitignore includes Terraform files
- [ ] Tags support included
- [ ] Naming follows conventions
