#!/usr/bin/env node

/**
 * Terraform Project Generator Script
 * Generates complete Terraform project structure
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const projectName = args.find(arg => arg.startsWith('--name='))?.split('=')[1];
const provider = args.find(arg => arg.startsWith('--provider='))?.split('=')[1] || 'azurerm';
const backend = args.find(arg => arg.startsWith('--backend='))?.split('=')[1] || 'local';
const outputDir = args.find(arg => arg.startsWith('--output='))?.split('=')[1] || './';

if (!projectName) {
  console.error('Error: --name is required');
  console.error('Usage: node generate-project.js --name=<project> [--provider=azurerm|aws|google] [--backend=local|azurerm|s3] [--output=./]');
  process.exit(1);
}

// Provider configurations
const providerConfigs = {
  azurerm: {
    source: 'hashicorp/azurerm',
    version: '~> 3.0',
    config: `  features {}`,
    sampleResource: `resource "azurerm_resource_group" "main" {
  name     = "rg-\${var.environment}-\${var.project_name}"
  location = var.location
  tags     = var.tags
}`
  },
  aws: {
    source: 'hashicorp/aws',
    version: '~> 5.0',
    config: `  region = var.region`,
    sampleResource: `resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "\${var.project_name}-vpc"
    }
  )
}`
  },
  google: {
    source: 'hashicorp/google',
    version: '~> 5.0',
    config: `  project = var.project_id
  region  = var.region`,
    sampleResource: `resource "google_compute_network" "main" {
  name                    = "\${var.project_name}-network"
  auto_create_subnetworks = false
}`
  }
};

// Backend configurations
const backendConfigs = {
  local: '',
  azurerm: `terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "${projectName}.tfstate"
  }
}`,
  s3: `terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "${projectName}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}`,
  gcs: `terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "${projectName}"
  }
}`
};

// File templates
const templates = {
  'terraform.tf': (provider) => `terraform {
  required_version = ">= 1.6"

  required_providers {
    ${provider} = {
      source  = "${providerConfigs[provider].source}"
      version = "${providerConfigs[provider].version}"
    }
  }
}

provider "${provider}" {
${providerConfigs[provider].config}
}
`,

  'backend.tf': (backend) => backendConfigs[backend],

  'variables.tf': (provider) => {
    let vars = `variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "${projectName}"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "${projectName}"
    ManagedBy   = "Terraform"
  }
}
`;

    if (provider === 'azurerm') {
      vars += `
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}
`;
    } else if (provider === 'aws' || provider === 'google') {
      vars += `
variable "region" {
  description = "Cloud region where resources will be created"
  type        = string
  default     = "${provider === 'aws' ? 'us-east-1' : 'us-central1'}"
}
`;
    }

    if (provider === 'google') {
      vars += `
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
`;
    }

    return vars;
  },

  'outputs.tf': (provider) => {
    if (provider === 'azurerm') {
      return `output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}
`;
    } else if (provider === 'aws') {
      return `output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
`;
    } else if (provider === 'google') {
      return `output "network_name" {
  description = "Name of the network"
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "Self link of the network"
  value       = google_compute_network.main.self_link
}
`;
    }
  },

  'main.tf': (provider) => `# Main resource definitions

${providerConfigs[provider].sampleResource}
`,

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
`,

  'README.md': (provider) => `# ${projectName}

Terraform infrastructure for ${projectName}.

## Prerequisites

- Terraform >= 1.6
- ${provider === 'azurerm' ? 'Azure' : provider === 'aws' ? 'AWS' : 'Google Cloud'} CLI configured
- Appropriate access credentials

## Project Structure

\`\`\`
.
├── main.tf         # Resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── terraform.tf    # Terraform and provider configuration
├── backend.tf      # State backend configuration
└── README.md       # This file
\`\`\`

## Usage

1. Initialize Terraform:
   \`\`\`bash
   terraform init
   \`\`\`

2. Review the execution plan:
   \`\`\`bash
   terraform plan
   \`\`\`

3. Apply the configuration:
   \`\`\`bash
   terraform apply
   \`\`\`

## Variables

See \`variables.tf\` for all available variables and their descriptions.

## Outputs

See \`outputs.tf\` for all available outputs.

## License

Proprietary - ${new Date().getFullYear()}
`
};

// Create project directory
const projectDir = path.join(outputDir, projectName);

try {
  // Create main directory
  if (!fs.existsSync(projectDir)) {
    fs.mkdirSync(projectDir, { recursive: true });
  }

  // Generate all files
  const files = ['terraform.tf', 'backend.tf', 'variables.tf', 'outputs.tf', 'main.tf', '.gitignore', 'README.md'];

  files.forEach(file => {
    const content = file === 'backend.tf'
      ? templates[file](backend)
      : templates[file](provider);

    if (content) {  // Only create file if there's content
      const filePath = path.join(projectDir, file);
      fs.writeFileSync(filePath, content);
      console.log(`Created: ${file}`);
    }
  });

  console.log(`\nProject '${projectName}' created successfully in ${projectDir}`);
  console.log(`\nNext steps:`);
  console.log(`  cd ${projectName}`);
  console.log(`  terraform init`);
  console.log(`  terraform plan`);

} catch (error) {
  console.error(`Error creating project: ${error.message}`);
  process.exit(1);
}
