#!/usr/bin/env node

/**
 * Terraform Module Scaffolding Script
 * Creates complete module structure with examples and documentation
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const moduleName = args.find(arg => arg.startsWith('--name='))?.split('=')[1];
const provider = args.find(arg => arg.startsWith('--provider='))?.split('=')[1] || 'azurerm';
const description = args.find(arg => arg.startsWith('--description='))?.split('=')[1] || 'Terraform module';
const outputDir = args.find(arg => arg.startsWith('--output='))?.split('=')[1] || './modules';

if (!moduleName) {
  console.error('Error: --name is required');
  console.error('Usage: node scaffold-module.js --name=<module-name> [--provider=azurerm] [--description="Module description"] [--output=./modules]');
  process.exit(1);
}

// Provider configurations
const providerVersions = {
  azurerm: '>= 3.0',
  aws: '>= 5.0',
  google: '>= 5.0'
};

// Templates
const templates = {
  'versions.tf': (provider) => `terraform {
  required_version = ">= 1.6"

  required_providers {
    ${provider} = {
      source  = "hashicorp/${provider}"
      version = "${providerVersions[provider] || '>= 1.0'}"
    }
  }
}
`,

  'variables.tf': (provider) => {
    let content = `# Module input variables

variable "name" {
  description = "Name of the resource"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 63
    error_message = "Name must be between 3 and 63 characters."
  }
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
`;

    if (provider === 'azurerm') {
      content += `
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
`;
    } else if (provider === 'aws' || provider === 'google') {
      content += `
variable "region" {
  description = "Cloud region where resources will be created"
  type        = string
  default     = "${provider === 'aws' ? 'us-east-1' : 'us-central1'}"
}
`;
    }

    return content;
  },

  'outputs.tf': () => `# Module outputs

output "id" {
  description = "ID of the resource"
  value       = "# TODO: Add resource ID output"
}

output "name" {
  description = "Name of the resource"
  value       = var.name
}
`,

  'main.tf': (provider) => {
    let content = `# Main resource definitions

locals {
  # Combine default tags with user-provided tags
  tags = merge(
    {
      ManagedBy = "Terraform"
      Module    = "terraform-${provider}-${moduleName}"
    },
    var.tags
  )
}

`;

    if (provider === 'azurerm') {
      content += `# TODO: Add your Azure resources here
# Example:
# resource "azurerm_example_resource" "main" {
#   name                = var.name
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = local.tags
# }
`;
    } else if (provider === 'aws') {
      content += `# TODO: Add your AWS resources here
# Example:
# resource "aws_example_resource" "main" {
#   name = var.name
#   tags = local.tags
# }
`;
    } else if (provider === 'google') {
      content += `# TODO: Add your GCP resources here
# Example:
# resource "google_example_resource" "main" {
#   name = var.name
# }
`;
    }

    return content;
  },

  '.gitignore': () => `# Local .terraform directories
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

# Test files
*.test
.terraform.lock.hcl
`,

  'README.md': (moduleName, provider, description) => `# Terraform Module: ${moduleName}

${description}

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

### Basic Example

\`\`\`hcl
module "${moduleName.replace(/-/g, '_')}" {
  source = "path/to/module"

  name = "example"
${provider === 'azurerm' ? `  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name
` : provider === 'aws' || provider === 'google' ? `  region = "us-east-1"
` : ''}
  tags = {
    Environment = "Development"
  }
}
\`\`\`

See the [examples](./examples/) directory for more usage examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| ${provider} | ${providerVersions[provider] || '>= 1.0'} |

## Providers

| Name | Version |
|------|---------|
| ${provider} | ${providerVersions[provider] || '>= 1.0'} |

## Resources

| Name | Type |
|------|------|
| TBD | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource | \`string\` | n/a | yes |
${provider === 'azurerm' ? `| location | Azure region | \`string\` | n/a | yes |
| resource_group_name | Resource group name | \`string\` | n/a | yes |
` : ''}| tags | Resource tags | \`map(string)\` | \`{}\` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource ID |
| name | Resource name |

## Examples

- [Basic](./examples/basic) - Basic usage example

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT
`,

  'examples/basic/main.tf': (moduleName, provider) => {
    let content = `terraform {
  required_version = ">= 1.6"

  required_providers {
    ${provider} = {
      source  = "hashicorp/${provider}"
      version = "${providerVersions[provider] || '>= 1.0'}"
    }
  }
}

`;

    if (provider === 'azurerm') {
      content += `provider "azurerm" {
  features {}
}

# Example resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-example-${moduleName}"
  location = "eastus"
}

# Module usage
module "example" {
  source = "../.."

  name                = "example-${moduleName}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Example"
    Purpose     = "Testing"
  }
}
`;
    } else if (provider === 'aws') {
      content += `provider "aws" {
  region = "us-east-1"
}

# Module usage
module "example" {
  source = "../.."

  name   = "example-${moduleName}"
  region = "us-east-1"

  tags = {
    Environment = "Example"
    Purpose     = "Testing"
  }
}
`;
    } else if (provider === 'google') {
      content += `provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

# Module usage
module "example" {
  source = "../.."

  name   = "example-${moduleName}"
  region = "us-central1"
}
`;
    }

    content += `
# Outputs
output "id" {
  description = "Resource ID"
  value       = module.example.id
}

output "name" {
  description = "Resource name"
  value       = module.example.name
}
`;

    return content;
  },

  'examples/basic/README.md': (moduleName) => `# Basic Example

This example demonstrates the basic usage of the ${moduleName} module.

## Usage

1. Review and update the configuration in \`main.tf\`
2. Initialize Terraform:
   \`\`\`bash
   terraform init
   \`\`\`

3. Plan the deployment:
   \`\`\`bash
   terraform plan
   \`\`\`

4. Apply the configuration:
   \`\`\`bash
   terraform apply
   \`\`\`

## What This Creates

- Example resources defined in the module

## Cleanup

To destroy all resources created by this example:

\`\`\`bash
terraform destroy
\`\`\`
`
};

/**
 * Create module structure
 */
function createModule() {
  const moduleDir = path.join(outputDir, `terraform-${provider}-${moduleName}`);
  const examplesDir = path.join(moduleDir, 'examples', 'basic');

  try {
    // Create directories
    console.log('Creating module structure...');
    fs.mkdirSync(moduleDir, { recursive: true });
    fs.mkdirSync(examplesDir, { recursive: true });

    // Generate root module files
    console.log('Generating module files...');

    const rootFiles = {
      'versions.tf': templates['versions.tf'](provider),
      'variables.tf': templates['variables.tf'](provider),
      'outputs.tf': templates['outputs.tf'](),
      'main.tf': templates['main.tf'](provider),
      '.gitignore': templates['.gitignore'](),
      'README.md': templates['README.md'](moduleName, provider, description)
    };

    for (const [filename, content] of Object.entries(rootFiles)) {
      fs.writeFileSync(path.join(moduleDir, filename), content);
      console.log(`  Created: ${filename}`);
    }

    // Generate example files
    console.log('Generating example...');

    const exampleFiles = {
      'main.tf': templates['examples/basic/main.tf'](moduleName, provider),
      'README.md': templates['examples/basic/README.md'](moduleName)
    };

    for (const [filename, content] of Object.entries(exampleFiles)) {
      fs.writeFileSync(path.join(examplesDir, filename), content);
      console.log(`  Created: examples/basic/${filename}`);
    }

    console.log(`\nModule 'terraform-${provider}-${moduleName}' created successfully!`);
    console.log(`\nLocation: ${moduleDir}`);
    console.log(`\nNext steps:`);
    console.log(`  1. Edit main.tf to add your resource definitions`);
    console.log(`  2. Update variables.tf with required variables`);
    console.log(`  3. Add outputs to outputs.tf`);
    console.log(`  4. Test with the basic example:`);
    console.log(`     cd ${path.join(moduleDir, 'examples', 'basic')}`);
    console.log(`     terraform init`);
    console.log(`     terraform plan`);

  } catch (error) {
    console.error(`Error creating module: ${error.message}`);
    process.exit(1);
  }
}

// Main execution
createModule();
