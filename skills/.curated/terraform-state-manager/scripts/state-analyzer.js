#!/usr/bin/env node

/**
 * Terraform State Analyzer
 * Analyzes Terraform state files for insights, issues, and recommendations
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const stateFile = args.find(arg => arg.startsWith('--state='))?.split('=')[1] || 'terraform.tfstate';
const reportType = args.find(arg => arg.startsWith('--report='))?.split('=')[1] || 'summary';
const detectDrift = args.includes('--detect-drift');
const showDependencies = args.find(arg => arg.startsWith('--dependencies='))?.split('=')[1];

/**
 * Read and parse state file
 */
function readStateFile(filePath) {
  try {
    if (!fs.existsSync(filePath)) {
      console.error(`Error: State file not found: ${filePath}`);
      process.exit(1);
    }

    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`Error reading state file: ${error.message}`);
    process.exit(1);
  }
}

/**
 * Analyze state file
 */
function analyzeState(state) {
  const analysis = {
    version: state.version,
    terraformVersion: state.terraform_version,
    serial: state.serial,
    lineage: state.lineage,
    resources: [],
    resourceTypes: {},
    totalResources: 0,
    orphanedResources: [],
    untaggedResources: [],
    deprecatedResources: [],
    dependencies: {},
    outputs: state.outputs || {},
    issues: [],
    recommendations: []
  };

  // Analyze resources
  if (state.resources) {
    state.resources.forEach(resource => {
      const resourceType = resource.type;
      const resourceName = resource.name;
      const fullAddress = `${resourceType}.${resourceName}`;

      // Count resources
      analysis.totalResources += resource.instances?.length || 0;

      // Count by type
      if (!analysis.resourceTypes[resourceType]) {
        analysis.resourceTypes[resourceType] = 0;
      }
      analysis.resourceTypes[resourceType] += resource.instances?.length || 0;

      // Check each instance
      resource.instances?.forEach((instance, idx) => {
        const instanceAddress = resource.instances.length > 1
          ? `${fullAddress}[${idx}]`
          : fullAddress;

        analysis.resources.push({
          address: instanceAddress,
          type: resourceType,
          name: resourceName,
          provider: resource.provider,
          mode: resource.mode,
          attributes: instance.attributes,
          dependencies: instance.dependencies || []
        });

        // Check for tags (Azure/AWS resources)
        if (resourceType.startsWith('azurerm_') || resourceType.startsWith('aws_')) {
          const tags = instance.attributes?.tags;
          if (!tags || Object.keys(tags).length === 0) {
            analysis.untaggedResources.push(instanceAddress);
          }
        }

        // Build dependency graph
        if (instance.dependencies?.length > 0) {
          analysis.dependencies[instanceAddress] = instance.dependencies;
        }

        // Check for deprecated resources
        const deprecatedTypes = [
          'azurerm_app_service',  // Use azurerm_linux_web_app or azurerm_windows_web_app
          'azurerm_app_service_plan',  // Use azurerm_service_plan
          'azurerm_virtual_machine'  // Use azurerm_linux_virtual_machine or azurerm_windows_virtual_machine
        ];

        if (deprecatedTypes.includes(resourceType)) {
          analysis.deprecatedResources.push({
            address: instanceAddress,
            type: resourceType,
            replacement: getReplacementResource(resourceType)
          });
        }
      });
    });
  }

  // Identify issues
  if (analysis.untaggedResources.length > 0) {
    analysis.issues.push({
      severity: 'warning',
      message: `${analysis.untaggedResources.length} resources without tags`,
      count: analysis.untaggedResources.length
    });
  }

  if (analysis.deprecatedResources.length > 0) {
    analysis.issues.push({
      severity: 'warning',
      message: `${analysis.deprecatedResources.length} deprecated resource types`,
      count: analysis.deprecatedResources.length
    });
  }

  // Check state file size
  const stateSize = JSON.stringify(state).length;
  if (stateSize > 1024 * 1024) {  // 1MB
    analysis.issues.push({
      severity: 'info',
      message: `Large state file (${(stateSize / 1024 / 1024).toFixed(2)}MB)`,
      recommendation: 'Consider splitting into multiple workspaces or modules'
    });
  }

  // Add recommendations
  if (analysis.untaggedResources.length > 0) {
    analysis.recommendations.push('Add tags to all resources for better organization and cost tracking');
  }

  if (analysis.deprecatedResources.length > 0) {
    analysis.recommendations.push('Migrate deprecated resources to their replacements');
  }

  if (!state.terraform_version || state.terraform_version < '1.0.0') {
    analysis.recommendations.push('Consider upgrading to Terraform 1.0 or higher');
  }

  return analysis;
}

/**
 * Get replacement resource for deprecated types
 */
function getReplacementResource(type) {
  const replacements = {
    'azurerm_app_service': 'azurerm_linux_web_app or azurerm_windows_web_app',
    'azurerm_app_service_plan': 'azurerm_service_plan',
    'azurerm_virtual_machine': 'azurerm_linux_virtual_machine or azurerm_windows_virtual_machine'
  };

  return replacements[type] || 'See provider documentation';
}

/**
 * Find resources that depend on a given resource
 */
function findDependents(analysis, resourceAddress) {
  const dependents = [];

  for (const [resource, deps] of Object.entries(analysis.dependencies)) {
    if (deps.includes(resourceAddress)) {
      dependents.push(resource);
    }
  }

  return dependents;
}

/**
 * Generate summary report
 */
function generateSummaryReport(analysis) {
  console.log('='.repeat(60));
  console.log('Terraform State Analysis - Summary');
  console.log('='.repeat(60));
  console.log('');

  console.log('State Information:');
  console.log(`  Version: ${analysis.version}`);
  console.log(`  Terraform Version: ${analysis.terraformVersion}`);
  console.log(`  Serial: ${analysis.serial}`);
  console.log('');

  console.log('Resources:');
  console.log(`  Total Resources: ${analysis.totalResources}`);
  console.log(`  Unique Types: ${Object.keys(analysis.resourceTypes).length}`);
  console.log('');

  console.log('Top Resource Types:');
  const sortedTypes = Object.entries(analysis.resourceTypes)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  sortedTypes.forEach(([type, count]) => {
    console.log(`  ${type}: ${count}`);
  });
  console.log('');

  if (analysis.issues.length > 0) {
    console.log('Issues Found:');
    analysis.issues.forEach(issue => {
      console.log(`  [${issue.severity.toUpperCase()}] ${issue.message}`);
    });
    console.log('');
  }

  if (analysis.recommendations.length > 0) {
    console.log('Recommendations:');
    analysis.recommendations.forEach((rec, idx) => {
      console.log(`  ${idx + 1}. ${rec}`);
    });
    console.log('');
  }

  console.log('='.repeat(60));
}

/**
 * Generate full report
 */
function generateFullReport(analysis) {
  generateSummaryReport(analysis);

  console.log('\nDetailed Resource List:');
  console.log('='.repeat(60));

  analysis.resources.forEach(resource => {
    console.log(`\n${resource.address}`);
    console.log(`  Type: ${resource.type}`);
    console.log(`  Provider: ${resource.provider}`);

    if (resource.dependencies.length > 0) {
      console.log(`  Dependencies: ${resource.dependencies.join(', ')}`);
    }

    if (resource.attributes?.id) {
      console.log(`  ID: ${resource.attributes.id}`);
    }

    if (resource.attributes?.tags && Object.keys(resource.attributes.tags).length > 0) {
      console.log(`  Tags: ${JSON.stringify(resource.attributes.tags)}`);
    }
  });

  if (analysis.untaggedResources.length > 0) {
    console.log('\n' + '='.repeat(60));
    console.log('Resources Without Tags:');
    console.log('='.repeat(60));
    analysis.untaggedResources.forEach(resource => {
      console.log(`  - ${resource}`);
    });
  }

  if (analysis.deprecatedResources.length > 0) {
    console.log('\n' + '='.repeat(60));
    console.log('Deprecated Resources:');
    console.log('='.repeat(60));
    analysis.deprecatedResources.forEach(resource => {
      console.log(`  - ${resource.address}`);
      console.log(`    Replace with: ${resource.replacement}`);
    });
  }

  console.log('\n' + '='.repeat(60));
}

/**
 * Show dependency graph for a resource
 */
function showDependencyGraph(analysis, resourceAddress) {
  console.log('='.repeat(60));
  console.log(`Dependency Graph for: ${resourceAddress}`);
  console.log('='.repeat(60));
  console.log('');

  // Find the resource
  const resource = analysis.resources.find(r => r.address === resourceAddress);

  if (!resource) {
    console.log(`Resource not found: ${resourceAddress}`);
    return;
  }

  console.log('This resource depends on:');
  if (resource.dependencies.length === 0) {
    console.log('  (none)');
  } else {
    resource.dependencies.forEach(dep => {
      console.log(`  - ${dep}`);
    });
  }

  console.log('');
  console.log('Resources that depend on this:');
  const dependents = findDependents(analysis, resourceAddress);

  if (dependents.length === 0) {
    console.log('  (none)');
  } else {
    dependents.forEach(dep => {
      console.log(`  - ${dep}`);
    });
  }

  console.log('');
  console.log('='.repeat(60));
}

/**
 * Detect drift (simplified - would need actual infrastructure state)
 */
function detectDriftSimulated(analysis) {
  console.log('='.repeat(60));
  console.log('Drift Detection');
  console.log('='.repeat(60));
  console.log('');

  console.log('Note: Full drift detection requires running "terraform plan"');
  console.log('This analysis shows potential drift indicators from state file.');
  console.log('');

  // Check for resources that might have drift
  console.log('Potential Drift Indicators:');
  console.log('');

  let foundIndicators = false;

  // Check for old Terraform versions
  if (analysis.terraformVersion && analysis.terraformVersion < '1.0.0') {
    console.log('  ⚠ State created with older Terraform version');
    console.log(`    Current: ${analysis.terraformVersion}`);
    console.log('    Consider: Run "terraform plan" to check for drift');
    console.log('');
    foundIndicators = true;
  }

  // Check for deprecated resources
  if (analysis.deprecatedResources.length > 0) {
    console.log('  ⚠ Deprecated resource types found');
    console.log('    These may behave differently in newer provider versions');
    console.log('');
    foundIndicators = true;
  }

  if (!foundIndicators) {
    console.log('  No obvious drift indicators in state file');
    console.log('');
  }

  console.log('To detect actual drift, run:');
  console.log('  terraform plan -detailed-exitcode');
  console.log('');
  console.log('Exit codes:');
  console.log('  0 = No changes (no drift)');
  console.log('  1 = Error');
  console.log('  2 = Changes detected (drift found)');
  console.log('');
  console.log('='.repeat(60));
}

/**
 * Export analysis to JSON
 */
function exportToJSON(analysis, outputFile) {
  const exportData = {
    timestamp: new Date().toISOString(),
    analysis: {
      summary: {
        version: analysis.version,
        terraformVersion: analysis.terraformVersion,
        serial: analysis.serial,
        totalResources: analysis.totalResources,
        resourceTypes: analysis.resourceTypes
      },
      resources: analysis.resources.map(r => ({
        address: r.address,
        type: r.type,
        dependencies: r.dependencies
      })),
      issues: analysis.issues,
      recommendations: analysis.recommendations,
      untaggedResources: analysis.untaggedResources,
      deprecatedResources: analysis.deprecatedResources
    }
  };

  fs.writeFileSync(outputFile, JSON.stringify(exportData, null, 2));
  console.log(`Analysis exported to: ${outputFile}`);
}

/**
 * Main execution
 */
function main() {
  console.log('Terraform State Analyzer\n');

  // Read state file
  const state = readStateFile(stateFile);

  // Analyze
  const analysis = analyzeState(state);

  // Generate reports based on options
  if (showDependencies) {
    showDependencyGraph(analysis, showDependencies);
  } else if (detectDrift) {
    detectDriftSimulated(analysis);
  } else if (reportType === 'full') {
    generateFullReport(analysis);
  } else if (reportType === 'json') {
    const outputFile = 'state-analysis.json';
    exportToJSON(analysis, outputFile);
  } else {
    generateSummaryReport(analysis);
  }

  // Additional options
  if (args.includes('--list-untagged')) {
    console.log('\nUntagged Resources:');
    analysis.untaggedResources.forEach(r => console.log(`  ${r}`));
  }

  if (args.includes('--list-deprecated')) {
    console.log('\nDeprecated Resources:');
    analysis.deprecatedResources.forEach(r => {
      console.log(`  ${r.address} -> ${r.replacement}`);
    });
  }
}

main();
