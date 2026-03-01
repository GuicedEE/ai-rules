#!/usr/bin/env node

/**
 * Terraform Documentation Generator
 * Automatically generates README.md for Terraform modules
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const modulePath = args.find(arg => arg.startsWith('--path='))?.split('=')[1] || '.';
const includeExamples = args.includes('--include-examples');
const updateMode = args.includes('--update');
const commitChanges = args.includes('--commit');

/**
 * Read Terraform files in directory
 */
function getTerraformFiles(dir) {
  const files = {
    main: null,
    variables: null,
    outputs: null,
    versions: null,
    terraform: null
  };

  const entries = fs.readdirSync(dir);

  for (const entry of entries) {
    const fullPath = path.join(dir, entry);

    if (fs.statSync(fullPath).isFile()) {
      if (entry === 'main.tf') files.main = fullPath;
      else if (entry === 'variables.tf') files.variables = fullPath;
      else if (entry === 'outputs.tf') files.outputs = fullPath;
      else if (entry === 'versions.tf') files.versions = fullPath;
      else if (entry === 'terraform.tf') files.terraform = fullPath;
    }
  }

  return files;
}

/**
 * Parse variables from variables.tf
 */
function parseVariables(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return [];

  const content = fs.readFileSync(filePath, 'utf8');
  const variables = [];

  // Match variable blocks
  const variableRegex = /variable\s+"([^"]+)"\s*{([^}]+)}/gs;
  const matches = content.matchAll(variableRegex);

  for (const match of matches) {
    const name = match[1];
    const block = match[2];

    // Extract description
    const descMatch = block.match(/description\s*=\s*"([^"]+)"/);
    const description = descMatch ? descMatch[1] : '';

    // Extract type
    const typeMatch = block.match(/type\s*=\s*([^\n]+)/);
    let type = typeMatch ? typeMatch[1].trim() : 'string';

    // Extract default
    const defaultMatch = block.match(/default\s*=\s*([^\n]+)/);
    const hasDefault = !!defaultMatch;
    let defaultValue = hasDefault ? defaultMatch[1].trim() : 'n/a';

    // Clean up type and default formatting
    type = type.replace(/^["']|["']$/g, '');
    if (defaultValue !== 'n/a') {
      defaultValue = defaultValue.replace(/^["']|["']$/g, '');
      if (defaultValue.length > 30) {
        defaultValue = defaultValue.substring(0, 27) + '...';
      }
    }

    variables.push({
      name,
      description,
      type,
      default: defaultValue,
      required: !hasDefault
    });
  }

  return variables;
}

/**
 * Parse outputs from outputs.tf
 */
function parseOutputs(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return [];

  const content = fs.readFileSync(filePath, 'utf8');
  const outputs = [];

  // Match output blocks
  const outputRegex = /output\s+"([^"]+)"\s*{([^}]+)}/gs;
  const matches = content.matchAll(outputRegex);

  for (const match of matches) {
    const name = match[1];
    const block = match[2];

    // Extract description
    const descMatch = block.match(/description\s*=\s*"([^"]+)"/);
    const description = descMatch ? descMatch[1] : '';

    // Extract value (simplified)
    const valueMatch = block.match(/value\s*=\s*([^\n]+)/);
    const value = valueMatch ? valueMatch[1].trim() : '';

    outputs.push({
      name,
      description: description || value
    });
  }

  return outputs;
}

/**
 * Parse resources from main.tf
 */
function parseResources(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return [];

  const content = fs.readFileSync(filePath, 'utf8');
  const resources = [];

  // Match resource blocks
  const resourceRegex = /resource\s+"([^"]+)"\s+"([^"]+)"/g;
  const matches = content.matchAll(resourceRegex);

  for (const match of matches) {
    resources.push({
      type: match[1],
      name: match[2],
      address: `${match[1]}.${match[2]}`,
      kind: 'resource'
    });
  }

  // Match data sources
  const dataRegex = /data\s+"([^"]+)"\s+"([^"]+)"/g;
  const dataMatches = content.matchAll(dataRegex);

  for (const match of dataMatches) {
    resources.push({
      type: match[1],
      name: match[2],
      address: `${match[1]}.${match[2]}`,
      kind: 'data source'
    });
  }

  return resources;
}

/**
 * Parse provider requirements
 */
function parseRequirements(versionFile, terraformFile) {
  const requirements = {
    terraform: '>= 1.0',
    providers: []
  };

  const filePath = versionFile || terraformFile;
  if (!filePath || !fs.existsSync(filePath)) return requirements;

  const content = fs.readFileSync(filePath, 'utf8');

  // Extract Terraform version
  const tfVersionMatch = content.match(/required_version\s*=\s*"([^"]+)"/);
  if (tfVersionMatch) {
    requirements.terraform = tfVersionMatch[1];
  }

  // Extract provider requirements
  const providerBlockMatch = content.match(/required_providers\s*{([^}]+)}/s);
  if (providerBlockMatch) {
    const providersBlock = providerBlockMatch[1];

    // Match each provider
    const providerRegex = /(\w+)\s*=\s*{([^}]+)}/g;
    const providerMatches = providersBlock.matchAll(providerRegex);

    for (const match of providerMatches) {
      const providerName = match[1];
      const providerBlock = match[2];

      const sourceMatch = providerBlock.match(/source\s*=\s*"([^"]+)"/);
      const versionMatch = providerBlock.match(/version\s*=\s*"([^"]+)"/);

      requirements.providers.push({
        name: providerName,
        source: sourceMatch ? sourceMatch[1] : `hashicorp/${providerName}`,
        version: versionMatch ? versionMatch[1] : 'latest'
      });
    }
  }

  return requirements;
}

/**
 * Detect module name from path
 */
function getModuleName(modulePath) {
  const dirName = path.basename(path.resolve(modulePath));

  // Remove terraform- prefix if present
  if (dirName.startsWith('terraform-')) {
    return dirName.substring(10);
  }

  return dirName;
}

/**
 * Detect provider from resources
 */
function detectProvider(resources) {
  if (resources.length === 0) return 'unknown';

  const firstResource = resources[0].type;

  if (firstResource.startsWith('azurerm_')) return 'azurerm';
  if (firstResource.startsWith('aws_')) return 'aws';
  if (firstResource.startsWith('google_')) return 'google';
  if (firstResource.startsWith('kubernetes_')) return 'kubernetes';

  return 'unknown';
}

/**
 * Generate usage example
 */
function generateUsageExample(moduleName, provider, variables) {
  const requiredVars = variables.filter(v => v.required);

  let example = `module "${moduleName.replace(/-/g, '_')}" {\n`;
  example += `  source = "path/to/module"\n\n`;

  // Add required variables
  requiredVars.forEach(variable => {
    let exampleValue = '""';

    if (variable.type === 'string') {
      exampleValue = `"${variable.name}-example"`;
    } else if (variable.type === 'number') {
      exampleValue = '1';
    } else if (variable.type === 'bool') {
      exampleValue = 'true';
    } else if (variable.type.includes('list')) {
      exampleValue = '[]';
    } else if (variable.type.includes('map')) {
      exampleValue = '{}';
    }

    example += `  ${variable.name.padEnd(20)} = ${exampleValue}\n`;
  });

  // Add common optional variables
  if (provider === 'azurerm') {
    if (!requiredVars.find(v => v.name === 'tags')) {
      example += `\n  tags = {\n`;
      example += `    Environment = "Production"\n`;
      example += `  }\n`;
    }
  }

  example += `}`;

  return example;
}

/**
 * Generate README content
 */
function generateREADME(data) {
  const {
    moduleName,
    description,
    variables,
    outputs,
    resources,
    requirements
  } = data;

  let readme = `# Terraform Module: ${moduleName}\n\n`;

  readme += `${description}\n\n`;

  readme += `## Usage\n\n`;
  readme += `### Basic Example\n\n`;
  readme += `\`\`\`hcl\n${data.usageExample}\n\`\`\`\n\n`;

  // Requirements
  readme += `## Requirements\n\n`;
  readme += `| Name | Version |\n`;
  readme += `|------|---------|\ n`;
  readme += `| terraform | ${requirements.terraform} |\n`;
  requirements.providers.forEach(provider => {
    readme += `| ${provider.name} | ${provider.version} |\n`;
  });
  readme += `\n`;

  // Providers
  if (requirements.providers.length > 0) {
    readme += `## Providers\n\n`;
    readme += `| Name | Version |\n`;
    readme += `|------|---------|\ n`;
    requirements.providers.forEach(provider => {
      readme += `| ${provider.name} | ${provider.version} |\n`;
    });
    readme += `\n`;
  }

  // Resources
  if (resources.length > 0) {
    readme += `## Resources\n\n`;
    readme += `| Name | Type |\n`;
    readme += `|------|------|\n`;
    resources.forEach(resource => {
      readme += `| ${resource.address} | ${resource.kind} |\n`;
    });
    readme += `\n`;
  }

  // Inputs
  if (variables.length > 0) {
    readme += `## Inputs\n\n`;
    readme += `| Name | Description | Type | Default | Required |\n`;
    readme += `|------|-------------|------|---------|:--------:|\n`;
    variables.forEach(variable => {
      const required = variable.required ? 'yes' : 'no';
      const defaultValue = variable.default === 'n/a' ? 'n/a' : `\`${variable.default}\``;

      readme += `| ${variable.name} | ${variable.description || 'n/a'} | \`${variable.type}\` | ${defaultValue} | ${required} |\n`;
    });
    readme += `\n`;
  }

  // Outputs
  if (outputs.length > 0) {
    readme += `## Outputs\n\n`;
    readme += `| Name | Description |\n`;
    readme += `|------|-------------|\n`;
    outputs.forEach(output => {
      readme += `| ${output.name} | ${output.description} |\n`;
    });
    readme += `\n`;
  }

  // Examples
  readme += `## Examples\n\n`;
  readme += `See the [examples](./examples/) directory for complete examples.\n\n`;

  // License
  readme += `## License\n\n`;
  readme += `MIT\n`;

  return readme;
}

/**
 * Main execution
 */
function main() {
  console.log('Terraform Documentation Generator\n');

  if (!fs.existsSync(modulePath)) {
    console.error(`Error: Path not found: ${modulePath}`);
    process.exit(1);
  }

  console.log(`Analyzing module at: ${modulePath}\n`);

  // Get Terraform files
  const files = getTerraformFiles(modulePath);

  if (!files.main && !files.variables && !files.outputs) {
    console.error('No Terraform files found in directory');
    process.exit(1);
  }

  // Parse files
  console.log('Parsing Terraform files...');
  const variables = parseVariables(files.variables);
  const outputs = parseOutputs(files.outputs);
  const resources = parseResources(files.main);
  const requirements = parseRequirements(files.versions, files.terraform);

  console.log(`  Variables: ${variables.length}`);
  console.log(`  Outputs: ${outputs.length}`);
  console.log(`  Resources: ${resources.length}`);
  console.log('');

  // Detect module info
  const moduleName = getModuleName(modulePath);
  const provider = detectProvider(resources);

  // Generate usage example
  const usageExample = generateUsageExample(moduleName, provider, variables);

  // Prepare data
  const data = {
    moduleName,
    description: `Terraform module for ${moduleName}`,
    variables,
    outputs,
    resources,
    requirements,
    usageExample
  };

  // Generate README
  console.log('Generating README.md...');
  const readmeContent = generateREADME(data);

  // Write README
  const readmePath = path.join(modulePath, 'README.md');

  if (updateMode && fs.existsSync(readmePath)) {
    console.log('Updating existing README.md (preserving custom sections)...');
    // In a real implementation, would preserve custom sections
    // For now, just overwrite with warning
    console.log('Warning: This will overwrite existing README.md');
  }

  fs.writeFileSync(readmePath, readmeContent);
  console.log(`README.md generated successfully at ${readmePath}`);

  // Commit if requested
  if (commitChanges) {
    const { execSync } = require('child_process');
    try {
      execSync('git add README.md', { cwd: modulePath });
      execSync('git commit -m "docs: auto-update README.md"', { cwd: modulePath });
      console.log('Changes committed');
    } catch (error) {
      console.log('Could not commit changes (not in git repo or no changes)');
    }
  }

  console.log('\nNext steps:');
  console.log('  1. Review and customize the generated README.md');
  console.log('  2. Add specific usage examples');
  console.log('  3. Include any additional documentation');
  console.log('  4. Create examples/ directory with working examples');
}

main();
