# terraform-module-scaffold: Templates

Read this reference when working on the topics below. Commands run from the skill directory.

- [Module File Templates](#module-file-templates)

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

````markdown
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
````

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

````markdown
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
````

