#!/usr/bin/env node

/**
 * Terraform Plan Analyzer
 * Parses and analyzes terraform plan JSON output
 */

const fs = require('fs');

// Parse command line arguments
const args = process.argv.slice(2);
const planFile = args.find(arg => arg.startsWith('--plan='))?.split('=')[1];
const reportType = args.find(arg => arg.startsWith('--report='))?.split('=')[1] || 'summary';
const checkBreaking = args.includes('--check-breaking');
const costAnalysis = args.includes('--cost-analysis');
const approvalReport = args.includes('--approval-report');

if (!planFile) {
  console.error('Error: --plan is required');
  console.error('Usage: node plan-analyzer.js --plan=plan.json [--report=summary|full] [--check-breaking] [--cost-analysis] [--approval-report]');
  console.error('\nTo generate plan.json:');
  console.error('  terraform plan -out=tfplan');
  console.error('  terraform show -json tfplan > plan.json');
  process.exit(1);
}

/**
 * Read and parse plan file
 */
function readPlanFile(filePath) {
  try {
    if (!fs.existsSync(filePath)) {
      console.error(`Error: Plan file not found: ${filePath}`);
      process.exit(1);
    }

    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`Error reading plan file: ${error.message}`);
    process.exit(1);
  }
}

/**
 * Analyze plan
 */
function analyzePlan(plan) {
  const analysis = {
    formatVersion: plan.format_version,
    terraformVersion: plan.terraform_version,
    changes: {
      create: [],
      update: [],
      delete: [],
      replace: [],
      read: [],
      noOp: []
    },
    outputs: {},
    resourceChanges: plan.resource_changes || [],
    outputChanges: plan.output_changes || {},
    summary: {
      create: 0,
      update: 0,
      delete: 0,
      replace: 0
    },
    risks: [],
    warnings: [],
    costImpact: {
      increase: [],
      decrease: [],
      neutral: []
    }
  };

  // Analyze resource changes
  plan.resource_changes?.forEach(change => {
    const action = getChangeAction(change.change.actions);
    const resourceAddress = change.address;
    const resourceType = change.type;

    const changeDetail = {
      address: resourceAddress,
      type: resourceType,
      action: action,
      before: change.change.before,
      after: change.change.after,
      beforeSensitive: change.change.before_sensitive,
      afterSensitive: change.change.after_sensitive,
      replacePaths: change.change.replace_paths || []
    };

    // Categorize change
    switch (action) {
      case 'create':
        analysis.changes.create.push(changeDetail);
        analysis.summary.create++;
        break;
      case 'update':
        analysis.changes.update.push(changeDetail);
        analysis.summary.update++;
        break;
      case 'delete':
        analysis.changes.delete.push(changeDetail);
        analysis.summary.delete++;
        break;
      case 'replace':
        analysis.changes.replace.push(changeDetail);
        analysis.summary.replace++;
        break;
      case 'read':
        analysis.changes.read.push(changeDetail);
        break;
      case 'no-op':
        analysis.changes.noOp.push(changeDetail);
        break;
    }

    // Risk assessment
    assessRisk(changeDetail, analysis);

    // Cost impact
    assessCostImpact(changeDetail, analysis);
  });

  // Analyze output changes
  for (const [name, change] of Object.entries(plan.output_changes || {})) {
    analysis.outputs[name] = {
      before: change.before,
      after: change.after,
      sensitive: change.sensitive
    };
  }

  return analysis;
}

/**
 * Determine change action from actions array
 */
function getChangeAction(actions) {
  if (!actions || actions.length === 0) return 'no-op';

  if (actions.includes('create') && actions.includes('delete')) return 'replace';
  if (actions.includes('create')) return 'create';
  if (actions.includes('delete')) return 'delete';
  if (actions.includes('update')) return 'update';
  if (actions.includes('read')) return 'read';

  return 'no-op';
}

/**
 * Assess risk for a change
 */
function assessRisk(change, analysis) {
  const resourceType = change.type;
  const action = change.action;

  // Critical risks
  if (action === 'delete' || action === 'replace') {
    // Database deletion
    if (resourceType.includes('database') || resourceType.includes('sql')) {
      analysis.risks.push({
        severity: 'critical',
        resource: change.address,
        message: 'Database will be deleted - RISK OF DATA LOSS!',
        action: action,
        recommendation: 'Backup database before proceeding'
      });
    }

    // Storage deletion
    if (resourceType.includes('storage') || resourceType.includes('bucket') || resourceType.includes('container')) {
      analysis.risks.push({
        severity: 'critical',
        resource: change.address,
        message: 'Storage will be deleted - RISK OF DATA LOSS!',
        action: action,
        recommendation: 'Backup data before proceeding'
      });
    }

    // Compute replacement
    if (resourceType.includes('virtual_machine') || resourceType.includes('instance')) {
      analysis.risks.push({
        severity: 'high',
        resource: change.address,
        message: 'Virtual machine will be recreated - SERVICE DOWNTIME!',
        action: action,
        recommendation: 'Schedule during maintenance window'
      });
    }

    // Network changes
    if (resourceType.includes('network') || resourceType.includes('vpc') || resourceType.includes('subnet')) {
      analysis.risks.push({
        severity: 'high',
        resource: change.address,
        message: 'Network resource will be recreated - POTENTIAL CONNECTIVITY LOSS!',
        action: action,
        recommendation: 'Review network dependencies'
      });
    }
  }

  // Security-related changes
  if (resourceType.includes('security_group') || resourceType.includes('firewall') || resourceType.includes('nsg')) {
    if (action === 'update' || action === 'replace' || action === 'delete') {
      analysis.warnings.push({
        severity: 'medium',
        resource: change.address,
        message: 'Security rule changes may affect access',
        recommendation: 'Verify security rules before applying'
      });
    }
  }

  // Production environment check
  const resourceName = change.address.toLowerCase();
  if (resourceName.includes('prod') || resourceName.includes('production')) {
    if (action === 'delete' || action === 'replace') {
      analysis.risks.push({
        severity: 'high',
        resource: change.address,
        message: 'Production resource will be modified',
        action: action,
        recommendation: 'Extra caution required for production changes'
      });
    }
  }
}

/**
 * Assess cost impact
 */
function assessCostImpact(change, analysis) {
  const resourceType = change.type;
  const action = change.action;
  const before = change.before;
  const after = change.after;

  // Resources that typically have cost
  const costlyResources = [
    'virtual_machine', 'instance', 'vm',
    'database', 'sql', 'cosmosdb',
    'storage', 'bucket',
    'kubernetes', 'aks', 'eks', 'gke',
    'load_balancer', 'gateway'
  ];

  const isCostly = costlyResources.some(keyword => resourceType.toLowerCase().includes(keyword));

  if (!isCostly) {
    analysis.costImpact.neutral.push({
      resource: change.address,
      reason: 'No significant cost impact'
    });
    return;
  }

  if (action === 'create') {
    analysis.costImpact.increase.push({
      resource: change.address,
      reason: 'New resource will incur costs',
      estimate: 'See pricing calculator'
    });
  } else if (action === 'delete') {
    analysis.costImpact.decrease.push({
      resource: change.address,
      reason: 'Resource removal will reduce costs'
    });
  } else if (action === 'update' || action === 'replace') {
    // Check for size/tier changes
    if (before && after) {
      // VM size changes
      if (before.vm_size && after.vm_size && before.vm_size !== after.vm_size) {
        const sizeChange = compareSizes(before.vm_size, after.vm_size);
        if (sizeChange === 'increase') {
          analysis.costImpact.increase.push({
            resource: change.address,
            reason: `VM size increase: ${before.vm_size} → ${after.vm_size}`,
            estimate: 'Higher compute costs'
          });
        } else {
          analysis.costImpact.decrease.push({
            resource: change.address,
            reason: `VM size decrease: ${before.vm_size} → ${after.vm_size}`,
            estimate: 'Lower compute costs'
          });
        }
      }

      // SKU/tier changes
      if (before.sku && after.sku && before.sku !== after.sku) {
        analysis.costImpact.increase.push({
          resource: change.address,
          reason: `SKU change: ${before.sku} → ${after.sku}`,
          estimate: 'Review pricing impact'
        });
      }

      // Instance type changes (AWS)
      if (before.instance_type && after.instance_type && before.instance_type !== after.instance_type) {
        analysis.costImpact.increase.push({
          resource: change.address,
          reason: `Instance type change: ${before.instance_type} → ${after.instance_type}`,
          estimate: 'Review pricing impact'
        });
      }
    }
  }
}

/**
 * Compare VM sizes (simplified)
 */
function compareSizes(before, after) {
  // Extract numbers from size names (e.g., D2s_v3 -> 2, D4s_v3 -> 4)
  const beforeNum = parseInt(before.match(/\d+/)?.[0] || '0');
  const afterNum = parseInt(after.match(/\d+/)?.[0] || '0');

  if (afterNum > beforeNum) return 'increase';
  if (afterNum < beforeNum) return 'decrease';
  return 'same';
}

/**
 * Generate summary report
 */
function generateSummaryReport(analysis) {
  console.log('='.repeat(60));
  console.log('Terraform Plan Analysis - Summary');
  console.log('='.repeat(60));
  console.log('');

  console.log('Plan Summary:');
  console.log(`  Resources to Create:  ${analysis.summary.create}`);
  console.log(`  Resources to Update:  ${analysis.summary.update}`);
  console.log(`  Resources to Replace: ${analysis.summary.replace}`);
  console.log(`  Resources to Destroy: ${analysis.summary.delete}`);
  console.log('');

  // Overall risk level
  const riskLevel = calculateOverallRisk(analysis);
  console.log(`Overall Risk Level: ${riskLevel}`);
  console.log('');

  // Critical risks
  if (analysis.risks.length > 0) {
    console.log('CRITICAL RISKS:');
    analysis.risks.forEach(risk => {
      console.log(`  [${risk.severity.toUpperCase()}] ${risk.resource}`);
      console.log(`    ${risk.message}`);
      console.log(`    → ${risk.recommendation}`);
      console.log('');
    });
  }

  // Warnings
  if (analysis.warnings.length > 0) {
    console.log('WARNINGS:');
    analysis.warnings.forEach(warning => {
      console.log(`  [${warning.severity.toUpperCase()}] ${warning.resource}`);
      console.log(`    ${warning.message}`);
      console.log('');
    });
  }

  // Cost impact summary
  if (analysis.costImpact.increase.length > 0 || analysis.costImpact.decrease.length > 0) {
    console.log('💰 Cost Impact:');
    if (analysis.costImpact.increase.length > 0) {
      console.log(`  Cost Increases: ${analysis.costImpact.increase.length} resources`);
    }
    if (analysis.costImpact.decrease.length > 0) {
      console.log(`  Cost Decreases: ${analysis.costImpact.decrease.length} resources`);
    }
    console.log('');
  }

  console.log('='.repeat(60));
}

/**
 * Generate full report
 */
function generateFullReport(analysis) {
  generateSummaryReport(analysis);

  // Detailed changes
  if (analysis.changes.create.length > 0) {
    console.log('\n📦 RESOURCES TO CREATE:');
    console.log('='.repeat(60));
    analysis.changes.create.forEach(change => {
      console.log(`  + ${change.address}`);
      console.log(`    Type: ${change.type}`);
    });
  }

  if (analysis.changes.update.length > 0) {
    console.log('\n🔄 RESOURCES TO UPDATE IN-PLACE:');
    console.log('='.repeat(60));
    analysis.changes.update.forEach(change => {
      console.log(`  ~ ${change.address}`);
      console.log(`    Type: ${change.type}`);
      console.log(`    Risk: Low (no downtime)`);
    });
  }

  if (analysis.changes.replace.length > 0) {
    console.log('\nRESOURCES TO REPLACE (DESTROY + CREATE):');
    console.log('='.repeat(60));
    analysis.changes.replace.forEach(change => {
      console.log(`  -/+ ${change.address}`);
      console.log(`    Type: ${change.type}`);
      console.log(`    WARNING: This will cause downtime!`);
    });
  }

  if (analysis.changes.delete.length > 0) {
    console.log('\nRESOURCES TO DESTROY:');
    console.log('='.repeat(60));
    analysis.changes.delete.forEach(change => {
      console.log(`  - ${change.address}`);
      console.log(`    Type: ${change.type}`);
      console.log(`    WARNING: This resource will be permanently deleted!`);
    });
  }

  // Cost details
  if (analysis.costImpact.increase.length > 0) {
    console.log('\n💸 COST INCREASES:');
    console.log('='.repeat(60));
    analysis.costImpact.increase.forEach(item => {
      console.log(`  ${item.resource}`);
      console.log(`    ${item.reason}`);
      console.log(`    Estimate: ${item.estimate || 'Unknown'}`);
    });
  }

  if (analysis.costImpact.decrease.length > 0) {
    console.log('\n💰 COST DECREASES:');
    console.log('='.repeat(60));
    analysis.costImpact.decrease.forEach(item => {
      console.log(`  ${item.resource}`);
      console.log(`    ${item.reason}`);
    });
  }

  console.log('\n' + '='.repeat(60));
}

/**
 * Generate breaking changes report
 */
function generateBreakingReport(analysis) {
  console.log('='.repeat(60));
  console.log('Breaking Changes Analysis');
  console.log('='.repeat(60));
  console.log('');

  const breakingChanges = [
    ...analysis.changes.delete,
    ...analysis.changes.replace
  ];

  if (breakingChanges.length === 0) {
    console.log('No breaking changes detected');
    console.log('');
    return;
  }

  console.log(`${breakingChanges.length} breaking changes found:\n`);

  breakingChanges.forEach(change => {
    console.log(`${change.action === 'delete' ? '-' : '-/+'} ${change.address}`);
    console.log(`  Action: ${change.action.toUpperCase()}`);
    console.log(`  Type: ${change.type}`);

    const relatedRisk = analysis.risks.find(r => r.resource === change.address);
    if (relatedRisk) {
      console.log(`  Risk: ${relatedRisk.severity.toUpperCase()}`);
      console.log(`  Impact: ${relatedRisk.message}`);
      console.log(`  Action Required: ${relatedRisk.recommendation}`);
    }

    console.log('');
  });

  console.log('='.repeat(60));
}

/**
 * Calculate overall risk level
 */
function calculateOverallRisk(analysis) {
  const criticalCount = analysis.risks.filter(r => r.severity === 'critical').length;
  const highCount = analysis.risks.filter(r => r.severity === 'high').length;

  if (criticalCount > 0) return '🔴 CRITICAL';
  if (highCount > 0) return '🟠 HIGH';
  if (analysis.risks.length > 0) return '🟡 MEDIUM';
  if (analysis.summary.replace > 0 || analysis.summary.delete > 0) return '🟡 MEDIUM';
  if (analysis.summary.update > 0) return '🟢 LOW';
  return '⚪ NONE';
}

/**
 * Main execution
 */
function main() {
  console.log('Terraform Plan Analyzer\n');

  const plan = readPlanFile(planFile);
  const analysis = analyzePlan(plan);

  if (checkBreaking) {
    generateBreakingReport(analysis);
  } else if (approvalReport) {
    generateFullReport(analysis);
    console.log('\n📋 APPROVAL CHECKLIST:');
    console.log('='.repeat(60));
    console.log('  [ ] Reviewed all changes');
    console.log('  [ ] Verified expected behavior');
    console.log('  [ ] Assessed risks');
    console.log('  [ ] Planned for downtime (if applicable)');
    console.log('  [ ] Created backups (if needed)');
    console.log('  [ ] Notified stakeholders');
    console.log('  [ ] Ready to apply');
    console.log('');
  } else if (reportType === 'full') {
    generateFullReport(analysis);
  } else {
    generateSummaryReport(analysis);
  }

  // Exit code based on risk
  if (analysis.risks.some(r => r.severity === 'critical')) {
    process.exit(2);
  }
}

main();
