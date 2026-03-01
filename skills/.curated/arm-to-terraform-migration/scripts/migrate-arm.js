#!/usr/bin/env node

/**
 * ARM to Terraform Migration Script
 * Converts Azure ARM templates to Terraform HCL
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const templateFile = args.find(arg => arg.startsWith('--template='))?.split('=')[1];
const parametersFile = args.find(arg => arg.startsWith('--parameters='))?.split('=')[1];
const outputDir = args.find(arg => arg.startsWith('--output='))?.split('=')[1] || './terraform';
const preserveNames = args.find(arg => arg === '--preserve-names') !== undefined;

if (!templateFile) {
  console.error('Error: --template is required');
  console.error('Usage: node migrate-arm.js --template=template.json [--parameters=parameters.json] [--output=./terraform] [--preserve-names]');
  process.exit(1);
}

// ARM to Terraform resource type mappings
const resourceMappings = {
  'Microsoft.Resources/resourceGroups': 'azurerm_resource_group',
  'Microsoft.Storage/storageAccounts': 'azurerm_storage_account',
  'Microsoft.Network/virtualNetworks': 'azurerm_virtual_network',
  'Microsoft.Network/virtualNetworks/subnets': 'azurerm_subnet',
  'Microsoft.Network/networkInterfaces': 'azurerm_network_interface',
  'Microsoft.Network/publicIPAddresses': 'azurerm_public_ip',
  'Microsoft.Network/networkSecurityGroups': 'azurerm_network_security_group',
  'Microsoft.Network/loadBalancers': 'azurerm_lb',
  'Microsoft.Compute/virtualMachines': 'azurerm_linux_virtual_machine', // or windows
  'Microsoft.Compute/disks': 'azurerm_managed_disk',
  'Microsoft.Web/sites': 'azurerm_linux_web_app',
  'Microsoft.Web/serverfarms': 'azurerm_service_plan',
  'Microsoft.Sql/servers': 'azurerm_mssql_server',
  'Microsoft.Sql/servers/databases': 'azurerm_mssql_database',
  'Microsoft.KeyVault/vaults': 'azurerm_key_vault',
  'Microsoft.ContainerService/managedClusters': 'azurerm_kubernetes_cluster',
  'Microsoft.DocumentDB/databaseAccounts': 'azurerm_cosmosdb_account',
  'Microsoft.Cache/redis': 'azurerm_redis_cache'
};

/**
 * Convert ARM property name to Terraform argument name
 */
function toSnakeCase(str) {
  return str
    .replace(/([A-Z])/g, '_$1')
    .toLowerCase()
    .replace(/^_/, '');
}

/**
 * Convert ARM parameter/variable reference to Terraform
 */
function convertExpression(expr) {
  if (typeof expr !== 'string') return JSON.stringify(expr);

  // Remove ARM brackets
  const cleaned = expr.replace(/^\[|\]$/g, '');

  // Parameters
  if (cleaned.startsWith("parameters('")) {
    const paramName = cleaned.match(/parameters\('([^']+)'\)/)?.[1];
    return `var.${toSnakeCase(paramName)}`;
  }

  // Variables
  if (cleaned.startsWith("variables('")) {
    const varName = cleaned.match(/variables\('([^']+)'\)/)?.[1];
    return `local.${toSnakeCase(varName)}`;
  }

  // Concat
  if (cleaned.startsWith('concat(')) {
    const parts = cleaned.slice(7, -1).split(',').map(p => p.trim());
    return parts.map(convertExpression).join('');
  }

  // ResourceGroup location
  if (cleaned === 'resourceGroup().location') {
    return 'var.location';
  }

  // Reference (simplified)
  if (cleaned.startsWith('reference(')) {
    return '# ARM reference() needs manual conversion';
  }

  // UniqueString
  if (cleaned.startsWith('uniqueString(')) {
    return 'random_string.unique.result';
  }

  return `"${cleaned}"`;
}

/**
 * Generate resource name from ARM resource
 */
function getResourceName(armResource, index) {
  if (preserveNames && armResource.name && !armResource.name.startsWith('[')) {
    return armResource.name.replace(/[^a-zA-Z0-9_]/g, '_');
  }
  return `resource_${index}`;
}

/**
 * Convert ARM SKU to Terraform arguments
 */
function convertSKU(sku) {
  if (!sku) return {};

  const result = {};

  // Storage account tier and replication
  if (sku.name) {
    const skuMap = {
      'Standard_LRS': { tier: 'Standard', replication: 'LRS' },
      'Standard_GRS': { tier: 'Standard', replication: 'GRS' },
      'Premium_LRS': { tier: 'Premium', replication: 'LRS' }
    };

    if (skuMap[sku.name]) {
      result.account_tier = skuMap[sku.name].tier;
      result.account_replication_type = skuMap[sku.name].replication;
    }
  }

  return result;
}

/**
 * Parse ARM template
 */
function parseARMTemplate(templatePath) {
  const content = fs.readFileSync(templatePath, 'utf8');
  return JSON.parse(content);
}

/**
 * Parse ARM parameters
 */
function parseParameters(parametersPath) {
  if (!parametersPath || !fs.existsSync(parametersPath)) {
    return {};
  }
  const content = fs.readFileSync(parametersPath, 'utf8');
  const params = JSON.parse(content);
  return params.parameters || {};
}

/**
 * Generate variables.tf content
 */
function generateVariables(template, parameters) {
  const vars = [];
  const armParams = template.parameters || {};

  for (const [name, def] of Object.entries(armParams)) {
    const varName = toSnakeCase(name);
    const defaultValue = parameters[name]?.value || def.defaultValue;

    let varDef = `variable "${varName}" {\n`;
    varDef += `  description = "${def.metadata?.description || name}"\n`;

    // Type mapping
    const typeMap = {
      'string': 'string',
      'int': 'number',
      'bool': 'bool',
      'object': 'map(any)',
      'array': 'list(any)'
    };
    varDef += `  type        = ${typeMap[def.type] || 'string'}\n`;

    if (defaultValue !== undefined) {
      varDef += `  default     = ${JSON.stringify(defaultValue)}\n`;
    }

    varDef += `}\n`;
    vars.push(varDef);
  }

  return vars.join('\n');
}

/**
 * Generate main.tf content
 */
function generateResources(template) {
  const resources = [];
  const armResources = template.resources || [];

  armResources.forEach((resource, index) => {
    const terraformType = resourceMappings[resource.type];
    if (!terraformType) {
      resources.push(`# Unsupported resource type: ${resource.type}\n`);
      return;
    }

    const resourceName = getResourceName(resource, index);
    let resourceBlock = `resource "${terraformType}" "${resourceName}" {\n`;

    // Name
    if (resource.name) {
      const name = resource.name.startsWith('[')
        ? convertExpression(resource.name)
        : `"${resource.name}"`;
      resourceBlock += `  name = ${name}\n`;
    }

    // Location
    if (resource.location) {
      const location = resource.location.startsWith('[')
        ? convertExpression(resource.location)
        : `"${resource.location}"`;
      resourceBlock += `  location = ${location}\n`;
    }

    // Properties
    if (resource.properties) {
      for (const [key, value] of Object.entries(resource.properties)) {
        const terraformKey = toSnakeCase(key);

        if (typeof value === 'object' && !Array.isArray(value)) {
          // Nested block
          resourceBlock += `\n  ${terraformKey} {\n`;
          for (const [nestedKey, nestedValue] of Object.entries(value)) {
            resourceBlock += `    ${toSnakeCase(nestedKey)} = ${JSON.stringify(nestedValue)}\n`;
          }
          resourceBlock += `  }\n`;
        } else {
          resourceBlock += `  ${terraformKey} = ${JSON.stringify(value)}\n`;
        }
      }
    }

    // SKU
    if (resource.sku) {
      const skuArgs = convertSKU(resource.sku);
      for (const [key, value] of Object.entries(skuArgs)) {
        resourceBlock += `  ${key} = "${value}"\n`;
      }
    }

    // Tags
    if (resource.tags) {
      resourceBlock += `  tags = ${JSON.stringify(resource.tags, null, 2).replace(/\n/g, '\n  ')}\n`;
    }

    resourceBlock += `}\n`;
    resources.push(resourceBlock);
  });

  return resources.join('\n');
}

/**
 * Generate outputs.tf content
 */
function generateOutputs(template) {
  const outputs = [];
  const armOutputs = template.outputs || {};

  for (const [name, def] of Object.entries(armOutputs)) {
    const outputName = toSnakeCase(name);

    let outputBlock = `output "${outputName}" {\n`;
    outputBlock += `  description = "${name}"\n`;

    // Convert value expression
    const value = typeof def.value === 'string' && def.value.startsWith('[')
      ? convertExpression(def.value)
      : JSON.stringify(def.value);

    outputBlock += `  value = ${value}\n`;
    outputBlock += `}\n`;

    outputs.push(outputBlock);
  }

  return outputs.join('\n');
}

/**
 * Generate terraform.tf content
 */
function generateTerraformConfig() {
  return `terraform {
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
`;
}

/**
 * Main execution
 */
function main() {
  try {
    console.log('Parsing ARM template...');
    const template = parseARMTemplate(templateFile);

    console.log('Parsing parameters...');
    const parameters = parseParameters(parametersFile);

    // Create output directory
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    console.log('Generating Terraform files...');

    // Generate variables.tf
    const variablesContent = generateVariables(template, parameters);
    fs.writeFileSync(path.join(outputDir, 'variables.tf'), variablesContent);
    console.log('  Created: variables.tf');

    // Generate main.tf
    const mainContent = generateResources(template);
    fs.writeFileSync(path.join(outputDir, 'main.tf'), mainContent);
    console.log('  Created: main.tf');

    // Generate outputs.tf
    const outputsContent = generateOutputs(template);
    fs.writeFileSync(path.join(outputDir, 'outputs.tf'), outputsContent);
    console.log('  Created: outputs.tf');

    // Generate terraform.tf
    const terraformContent = generateTerraformConfig();
    fs.writeFileSync(path.join(outputDir, 'terraform.tf'), terraformContent);
    console.log('  Created: terraform.tf');

    console.log(`\nMigration complete! Terraform files generated in ${outputDir}`);
    console.log('\nNext steps:');
    console.log('  1. Review generated files for accuracy');
    console.log('  2. Manually adjust complex expressions and references');
    console.log('  3. Run: terraform init');
    console.log('  4. Run: terraform plan');

  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
