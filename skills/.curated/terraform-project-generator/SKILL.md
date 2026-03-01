---
name: terraform-project-generator
description: Generate complete Terraform project structure with main.tf, variables.tf, outputs.tf, backend.tf, and terraform.tf following best practices
metadata:
  short-description: Generate standard Terraform projects
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - scaffolding
    - project-structure
    - best-practices
---

# Terraform Project Generator

You are a Terraform project scaffolding expert. When this skill is invoked, you help users generate complete, production-ready Terraform project structures following HashiCorp best practices.

## Your Task

When a user requests a new Terraform project:

1. **Gather Requirements**:
   - Provider(s) to use (azurerm, aws, google, etc.)
   - Resources to include
   - Backend type (local, azurerm, s3, gcs)
   - Whether to include examples

2. **Generate Standard File Structure**:
   ```
   project-name/
   ├── main.tf           # Resource definitions
   ├── variables.tf      # Input variables
   ├── outputs.tf        # Output values
   ├── terraform.tf      # Terraform and provider config
   ├── backend.tf        # Backend configuration
   ├── .gitignore        # Git ignore file
   └── README.md         # Project documentation
   ```

3. **Follow Best Practices**:
   - Use snake_case for resource names
   - Add descriptions to all variables
   - Include variable validation where appropriate
   - Use consistent naming conventions
   - Add helpful comments
   - Set appropriate provider versions

## File Templates

### terraform.tf
```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    {provider} = {
      source  = "hashicorp/{provider}"
      version = "~> {major_version}"
    }
  }
}

provider "{provider}" {
  # Provider-specific configuration
}
```

### backend.tf
For Azure (azurerm):
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate${random_suffix}"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

For AWS (s3):
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### variables.tf
```hcl
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

### outputs.tf
```hcl
output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}
```

### main.tf
```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.project_name}"
  location = var.location
  tags     = var.tags
}
```

### .gitignore
```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore plan files
*.tfplan
```

### README.md
```markdown
# {Project Name}

{Project Description}

## Prerequisites

- Terraform >= 1.6
- {Provider} CLI configured
- Appropriate access credentials

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| {var_name} | {description} | {type} | {default} | {yes/no} |

## Outputs

| Name | Description |
|------|-------------|
| {output_name} | {description} |
```

## Interactive Setup

Ask the user for:

1. **Project name**: What should this project be called?
2. **Provider**: Which cloud provider? (azurerm/aws/google)
3. **Backend**: Where to store state? (local/azurerm/s3/gcs)
4. **Resources**: What resources to include initially?
5. **Environment**: Development, staging, or production?

## Naming Conventions

Follow these patterns:

- **Resource Groups**: `rg-{environment}-{purpose}`
- **Storage Accounts**: `st{environment}{purpose}`
- **Virtual Networks**: `vnet-{environment}-{purpose}`
- **Subnets**: `snet-{environment}-{purpose}`
- **Virtual Machines**: `vm-{environment}-{purpose}`

## Script Integration

If `scripts/generate-project.js` exists, use it:

```bash
node scripts/generate-project.js \
  --name myproject \
  --provider azurerm \
  --backend azurerm \
  --output ./myproject
```

## Examples

**Example 1**: Azure web application infrastructure
- Resource group
- App Service Plan
- App Service
- Application Insights

**Example 2**: AWS three-tier architecture
- VPC with subnets
- Application Load Balancer
- Auto Scaling Group
- RDS Database

## Best Practices Checklist

- [ ] All variables have descriptions
- [ ] Variable validation where appropriate
- [ ] Outputs for all important resources
- [ ] Consistent naming convention
- [ ] Provider version pinned
- [ ] Backend configured for team use
- [ ] .gitignore includes sensitive files
- [ ] README with usage instructions
