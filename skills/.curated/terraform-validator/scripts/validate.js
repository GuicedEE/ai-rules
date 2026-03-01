#!/usr/bin/env node

/**
 * Terraform Validation Script
 * Validates Terraform code for syntax, best practices, and security
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const terraformPath = args.find(arg => arg.startsWith('--path='))?.split('=')[1] || '.';
const level = args.find(arg => arg.startsWith('--level='))?.split('=')[1] || 'best-practices';

const validLevels = ['syntax', 'format', 'best-practices', 'security', 'compliance'];

if (!validLevels.includes(level)) {
  console.error(`Error: Invalid level '${level}'`);
  console.error(`Valid levels: ${validLevels.join(', ')}`);
  process.exit(1);
}

// Validation results storage
const results = {
  syntax: [],
  format: [],
  bestPractices: [],
  security: [],
  compliance: []
};

/**
 * Read all .tf files in directory
 */
function getTerraformFiles(dir) {
  const files = [];

  function walk(currentPath) {
    const entries = fs.readdirSync(currentPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentPath, entry.name);

      // Skip .terraform directory
      if (entry.name === '.terraform') continue;

      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.tf')) {
        files.push(fullPath);
      }
    }
  }

  walk(dir);
  return files;
}

/**
 * Parse HCL (simplified - for basic validation)
 */
function parseHCL(content, filePath) {
  const issues = [];

  // Check for basic syntax issues
  const lines = content.split('\n');

  let braceCount = 0;
  let inString = false;
  let stringChar = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;

    // Track braces (simplified)
    for (let char of line) {
      if (!inString) {
        if (char === '"' || char === "'") {
          inString = true;
          stringChar = char;
        } else if (char === '{') {
          braceCount++;
        } else if (char === '}') {
          braceCount--;
        }
      } else if (char === stringChar) {
        inString = false;
        stringChar = null;
      }
    }

    // Check for common issues
    if (line.trim().startsWith('resource') && !line.includes('{')) {
      if (!lines[i + 1]?.includes('{')) {
        issues.push({
          file: filePath,
          line: lineNum,
          severity: 'error',
          message: 'Resource block missing opening brace'
        });
      }
    }
  }

  if (braceCount !== 0) {
    issues.push({
      file: filePath,
      line: 0,
      severity: 'error',
      message: `Mismatched braces (count: ${braceCount})`
    });
  }

  return issues;
}

/**
 * Validate syntax
 */
function validateSyntax(files) {
  console.log('Running syntax validation...');

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const issues = parseHCL(content, file);

    results.syntax.push(...issues);
  }

  console.log(`  Found ${results.syntax.length} syntax issues`);
}

/**
 * Validate format
 */
function validateFormat(files) {
  console.log('Running format validation...');

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const lines = content.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const lineNum = i + 1;

      // Check for tabs
      if (line.includes('\t')) {
        results.format.push({
          file,
          line: lineNum,
          severity: 'warning',
          message: 'Use spaces instead of tabs'
        });
      }

      // Check for trailing whitespace
      if (line.endsWith(' ') || line.endsWith('\t')) {
        results.format.push({
          file,
          line: lineNum,
          severity: 'info',
          message: 'Trailing whitespace'
        });
      }

      // Check for inconsistent equals spacing
      if (line.match(/\w+=\w/) || line.match(/\w+ =\w/) || line.match(/\w+= \w/)) {
        results.format.push({
          file,
          line: lineNum,
          severity: 'info',
          message: 'Inconsistent spacing around ='
        });
      }
    }
  }

  console.log(`  Found ${results.format.length} format issues`);
}

/**
 * Validate best practices
 */
function validateBestPractices(files) {
  console.log('Running best practices validation...');

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const fileName = path.basename(file);

    // Check for variable descriptions
    if (fileName === 'variables.tf') {
      const variableBlocks = content.match(/variable\s+"[^"]+"\s*{[^}]+}/g) || [];

      for (const block of variableBlocks) {
        if (!block.includes('description')) {
          const varName = block.match(/variable\s+"([^"]+)"/)?.[1];
          results.bestPractices.push({
            file,
            line: 0,
            severity: 'warning',
            message: `Variable '${varName}' missing description`
          });
        }
      }
    }

    // Check for output descriptions
    if (fileName === 'outputs.tf') {
      const outputBlocks = content.match(/output\s+"[^"]+"\s*{[^}]+}/g) || [];

      for (const block of outputBlocks) {
        if (!block.includes('description')) {
          const outputName = block.match(/output\s+"([^"]+)"/)?.[1];
          results.bestPractices.push({
            file,
            line: 0,
            severity: 'warning',
            message: `Output '${outputName}' missing description`
          });
        }
      }
    }

    // Check for provider version pinning
    if (fileName === 'terraform.tf' || fileName === 'versions.tf') {
      const providerBlocks = content.match(/required_providers\s*{[^}]+}/gs) || [];

      for (const block of providerBlocks) {
        const providers = block.match(/(\w+)\s*=\s*{[^}]+}/g) || [];

        for (const provider of providers) {
          if (!provider.includes('version')) {
            const providerName = provider.match(/(\w+)\s*=/)?.[1];
            results.bestPractices.push({
              file,
              line: 0,
              severity: 'warning',
              message: `Provider '${providerName}' version not pinned`
            });
          }
        }
      }
    }

    // Check for resource tags
    const resourceBlocks = content.match(/resource\s+"[^"]+"\s+"[^"]+"\s*{[^}]+}/gs) || [];

    for (const block of resourceBlocks) {
      const resourceType = block.match(/resource\s+"([^"]+)"/)?.[1];
      const resourceName = block.match(/resource\s+"[^"]+"\s+"([^"]+)"/)?.[1];

      // Azure resources should have tags
      if (resourceType?.startsWith('azurerm_') && !block.includes('tags')) {
        results.bestPractices.push({
          file,
          line: 0,
          severity: 'info',
          message: `Resource '${resourceType}.${resourceName}' missing tags`
        });
      }
    }
  }

  console.log(`  Found ${results.bestPractices.length} best practice issues`);
}

/**
 * Validate security
 */
function validateSecurity(files) {
  console.log('Running security validation...');

  const sensitivePatterns = [
    { pattern: /password\s*=\s*"[^$]/, message: 'Hardcoded password detected' },
    { pattern: /secret\s*=\s*"[^$]/, message: 'Hardcoded secret detected' },
    { pattern: /api[_-]?key\s*=\s*"[^$]/, message: 'Hardcoded API key detected' },
    { pattern: /access[_-]?key\s*=\s*"[^$]/, message: 'Hardcoded access key detected' },
    { pattern: /AKIA[0-9A-Z]{16}/, message: 'AWS access key detected' },
    { pattern: /private[_-]?key\s*=\s*"[^$]/, message: 'Hardcoded private key detected' }
  ];

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const lines = content.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const lineNum = i + 1;

      // Skip comments
      if (line.trim().startsWith('#')) continue;

      // Check for sensitive data
      for (const { pattern, message } of sensitivePatterns) {
        if (pattern.test(line)) {
          results.security.push({
            file,
            line: lineNum,
            severity: 'critical',
            message
          });
        }
      }
    }

    // Check for unencrypted storage
    if (content.includes('azurerm_storage_account')) {
      if (!content.includes('enable_https_traffic_only')) {
        results.security.push({
          file,
          line: 0,
          severity: 'high',
          message: 'Storage account should enable HTTPS-only traffic'
        });
      }
    }

    // Check for public network access
    if (content.includes('public_network_access_enabled = true')) {
      results.security.push({
        file,
        line: 0,
        severity: 'medium',
        message: 'Public network access enabled - ensure this is intended'
      });
    }
  }

  console.log(`  Found ${results.security.length} security issues`);
}

/**
 * Validate compliance
 */
function validateCompliance(files) {
  console.log('Running compliance validation...');

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');

    // Check for required tags
    const requiredTags = ['Environment', 'ManagedBy', 'Project'];
    const resourceBlocks = content.match(/resource\s+"[^"]+"\s+"[^"]+"\s*{[^}]+}/gs) || [];

    for (const block of resourceBlocks) {
      const tagsMatch = block.match(/tags\s*=\s*{([^}]+)}/s);

      if (tagsMatch) {
        const tagsContent = tagsMatch[1];

        for (const requiredTag of requiredTags) {
          if (!tagsContent.includes(requiredTag)) {
            const resourceType = block.match(/resource\s+"([^"]+)"/)?.[1];
            const resourceName = block.match(/resource\s+"[^"]+"\s+"([^"]+)"/)?.[1];

            results.compliance.push({
              file,
              line: 0,
              severity: 'warning',
              message: `Resource '${resourceType}.${resourceName}' missing required tag: ${requiredTag}`
            });
          }
        }
      }
    }
  }

  console.log(`  Found ${results.compliance.length} compliance issues`);
}

/**
 * Generate report
 */
function generateReport() {
  console.log('\n' + '='.repeat(60));
  console.log('Terraform Validation Report');
  console.log('='.repeat(60) + '\n');

  let totalIssues = 0;
  let criticalCount = 0;
  let errorCount = 0;
  let warningCount = 0;

  const allIssues = [
    ...results.syntax,
    ...results.format,
    ...results.bestPractices,
    ...results.security,
    ...results.compliance
  ];

  for (const issue of allIssues) {
    totalIssues++;
    if (issue.severity === 'critical') criticalCount++;
    else if (issue.severity === 'error') errorCount++;
    else if (issue.severity === 'warning') warningCount++;
  }

  console.log(`Total Issues: ${totalIssues}`);
  console.log(`  Critical: ${criticalCount}`);
  console.log(`  Errors: ${errorCount}`);
  console.log(`  Warnings: ${warningCount}`);
  console.log('');

  // Print issues by category
  const categories = [
    { name: 'Syntax', issues: results.syntax },
    { name: 'Format', issues: results.format },
    { name: 'Best Practices', issues: results.bestPractices },
    { name: 'Security', issues: results.security },
    { name: 'Compliance', issues: results.compliance }
  ];

  for (const category of categories) {
    if (category.issues.length > 0) {
      console.log(`${category.name} Issues (${category.issues.length}):`);
      console.log('-'.repeat(60));

      for (const issue of category.issues) {
        const severity = issue.severity.toUpperCase().padEnd(10);
        const location = issue.line > 0 ? `${issue.file}:${issue.line}` : issue.file;
        console.log(`  [${severity}] ${location}`);
        console.log(`    ${issue.message}`);
        console.log('');
      }
    }
  }

  // Determine overall status
  let status = 'PASSED';
  if (criticalCount > 0 || errorCount > 0) {
    status = 'FAILED';
  } else if (warningCount > 0) {
    status = 'WARNING';
  }

  console.log('='.repeat(60));
  console.log(`Overall Status: ${status}`);
  console.log('='.repeat(60));

  return status === 'FAILED' ? 1 : 0;
}

/**
 * Main execution
 */
function main() {
  console.log(`Terraform Validator`);
  console.log(`Path: ${terraformPath}`);
  console.log(`Level: ${level}`);
  console.log('');

  const files = getTerraformFiles(terraformPath);

  if (files.length === 0) {
    console.error('No Terraform files found');
    process.exit(1);
  }

  console.log(`Found ${files.length} Terraform files\n`);

  // Run validations based on level
  if (level === 'syntax' || level === 'format' || level === 'best-practices' || level === 'security' || level === 'compliance') {
    validateSyntax(files);
  }

  if (level === 'format' || level === 'best-practices' || level === 'security' || level === 'compliance') {
    validateFormat(files);
  }

  if (level === 'best-practices' || level === 'security' || level === 'compliance') {
    validateBestPractices(files);
  }

  if (level === 'security' || level === 'compliance') {
    validateSecurity(files);
  }

  if (level === 'compliance') {
    validateCompliance(files);
  }

  const exitCode = generateReport();
  process.exit(exitCode);
}

main();
