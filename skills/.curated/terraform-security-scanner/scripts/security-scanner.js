#!/usr/bin/env node

/**
 * Terraform Security Scanner
 * Comprehensive security scanning for Terraform code
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const scanPath = args.find(arg => arg.startsWith('--path='))?.split('=')[1] || '.';
const severity = args.find(arg => arg.startsWith('--severity='))?.split('=')[1] || 'all';
const secretsOnly = args.includes('--secrets-only');
const compliance = args.find(arg => arg.startsWith('--compliance='))?.split('=')[1]);
const outputFile = args.find(arg => arg.startsWith('--output='))?.split('=')[1];

// Security patterns
const secretPatterns = [
  {
    name: 'hardcoded_password',
    pattern: /password\s*=\s*"[^$\{][^"]{8,}"/gi,
    severity: 'critical',
    message: 'Hardcoded password detected',
    recommendation: 'Use variables or Key Vault'
  },
  {
    name: 'api_key',
    pattern: /api[_-]?key\s*=\s*"[^$\{][^"]+"/gi,
    severity: 'critical',
    message: 'Hardcoded API key detected',
    recommendation: 'Store in Key Vault or use environment variables'
  },
  {
    name: 'secret',
    pattern: /secret\s*=\s*"[^$\{][^"]{16,}"/gi,
    severity: 'critical',
    message: 'Hardcoded secret detected',
    recommendation: 'Use secure secret management'
  },
  {
    name: 'access_key',
    pattern: /access[_-]?key\s*=\s*"[^$\{][^"]+"/gi,
    severity: 'critical',
    message: 'Hardcoded access key detected',
    recommendation: 'Use managed identities or Key Vault'
  },
  {
    name: 'private_key',
    pattern: /private[_-]?key\s*=\s*"[^$\{][^"]+"/gi,
    severity: 'critical',
    message: 'Hardcoded private key detected',
    recommendation: 'Store in Key Vault'
  },
  {
    name: 'aws_access_key',
    pattern: /AKIA[0-9A-Z]{16}/g,
    severity: 'critical',
    message: 'AWS access key detected',
    recommendation: 'Remove immediately and rotate key'
  },
  {
    name: 'connection_string',
    pattern: /connection[_-]?string\s*=\s*"[^$\{][^"]+"/gi,
    severity: 'critical',
    message: 'Hardcoded connection string detected',
    recommendation: 'Use Key Vault for connection strings'
  }
];

const securityIssues = [
  {
    name: 'public_storage_access',
    pattern: /allow_nested_items_to_be_public\s*=\s*true/gi,
    resource: 'azurerm_storage_account',
    severity: 'high',
    message: 'Storage account allows public blob access',
    recommendation: 'Set allow_nested_items_to_be_public = false'
  },
  {
    name: 'http_enabled',
    pattern: /enable_https_traffic_only\s*=\s*false/gi,
    resource: 'azurerm_storage_account',
    severity: 'high',
    message: 'Storage account allows HTTP traffic',
    recommendation: 'Set enable_https_traffic_only = true'
  },
  {
    name: 'weak_tls',
    pattern: /min_tls_version\s*=\s*"TLS1_[01]"/gi,
    severity: 'high',
    message: 'Weak TLS version in use',
    recommendation: 'Use min_tls_version = "TLS1_2" or higher'
  },
  {
    name: 'public_network_access',
    pattern: /public_network_access_enabled\s*=\s*true/gi,
    severity: 'high',
    message: 'Public network access enabled',
    recommendation: 'Set public_network_access_enabled = false and use private endpoints'
  },
  {
    name: 'wildcard_source',
    pattern: /source_address_prefix\s*=\s*"\*"/gi,
    resource: 'network_security_rule',
    severity: 'critical',
    message: 'Security rule allows traffic from entire internet',
    recommendation: 'Specify explicit source IP ranges'
  },
  {
    name: 'wildcard_port',
    pattern: /destination_port_range\s*=\s*"\*"/gi,
    resource: 'network_security_rule',
    severity: 'high',
    message: 'Security rule allows all ports',
    recommendation: 'Specify explicit port ranges'
  },
  {
    name: 'no_encryption',
    pattern: /resource\s+"azurerm_storage_account"[^}]*(?!enable_https_traffic_only)/gs,
    severity: 'medium',
    message: 'Missing HTTPS enforcement configuration',
    recommendation: 'Add enable_https_traffic_only = true'
  },
  {
    name: 's3_public_acl',
    pattern: /acl\s*=\s*"public-read"/gi,
    resource: 'aws_s3_bucket',
    severity: 'critical',
    message: 'S3 bucket allows public read access',
    recommendation: 'Remove public ACL and use bucket policies'
  }
];

// Results storage
const results = {
  critical: [],
  high: [],
  medium: [],
  low: [],
  info: []
};

/**
 * Get all Terraform files
 */
function getTerraformFiles(dir) {
  const files = [];

  function walk(currentPath) {
    const entries = fs.readdirSync(currentPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentPath, entry.name);

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
 * Scan file for secrets
 */
function scanForSecrets(filePath, content) {
  const lines = content.split('\n');

  secretPatterns.forEach(pattern => {
    lines.forEach((line, idx) => {
      if (line.trim().startsWith('#')) return; // Skip comments

      const matches = line.matchAll(new RegExp(pattern.pattern));

      for (const match of matches) {
        results[pattern.severity].push({
          type: 'secret',
          name: pattern.name,
          severity: pattern.severity,
          file: filePath,
          line: idx + 1,
          code: line.trim(),
          message: pattern.message,
          recommendation: pattern.recommendation
        });
      }
    });
  });
}

/**
 * Scan file for security issues
 */
function scanForSecurityIssues(filePath, content) {
  const lines = content.split('\n');

  securityIssues.forEach(issue => {
    // Check if issue is resource-specific
    if (issue.resource) {
      const resourceRegex = new RegExp(`resource\\s+"${issue.resource}"`, 'gi');
      if (!resourceRegex.test(content)) return; // Skip if resource not present
    }

    lines.forEach((line, idx) => {
      if (line.trim().startsWith('#')) return;

      const matches = line.matchAll(new RegExp(issue.pattern));

      for (const match of matches) {
        results[issue.severity].push({
          type: 'security',
          name: issue.name,
          severity: issue.severity,
          file: filePath,
          line: idx + 1,
          code: line.trim(),
          message: issue.message,
          recommendation: issue.recommendation
        });
      }
    });
  });

  // Check for missing security configurations
  checkMissingConfigurations(filePath, content);
}

/**
 * Check for missing security configurations
 */
function checkMissingConfigurations(filePath, content) {
  // Azure Storage without HTTPS enforcement
  const storageAccountRegex = /resource\s+"azurerm_storage_account"\s+"[^"]+"\s*\{([^}]+)\}/gs;
  const storageMatches = content.matchAll(storageAccountRegex);

  for (const match of storageMatches) {
    const resourceBlock = match[1];

    if (!resourceBlock.includes('enable_https_traffic_only')) {
      results.high.push({
        type: 'missing_config',
        name: 'missing_https_enforcement',
        severity: 'high',
        file: filePath,
        line: content.substring(0, match.index).split('\n').length,
        message: 'Storage account missing HTTPS enforcement',
        recommendation: 'Add enable_https_traffic_only = true'
      });
    }

    if (!resourceBlock.includes('min_tls_version')) {
      results.medium.push({
        type: 'missing_config',
        name: 'missing_tls_version',
        severity: 'medium',
        file: filePath,
        line: content.substring(0, match.index).split('\n').length,
        message: 'Storage account missing TLS version specification',
        recommendation: 'Add min_tls_version = "TLS1_2"'
      });
    }

    if (!resourceBlock.includes('infrastructure_encryption_enabled')) {
      results.medium.push({
        type: 'missing_config',
        name: 'missing_infrastructure_encryption',
        severity: 'medium',
        file: filePath,
        line: content.substring(0, match.index).split('\n').length,
        message: 'Storage account missing infrastructure encryption',
        recommendation: 'Add infrastructure_encryption_enabled = true'
      });
    }
  }

  // SQL Server without auditing
  const sqlServerRegex = /resource\s+"azurerm_mssql_server"\s+"[^"]+"\s*\{([^}]+)\}/gs;
  const sqlMatches = content.matchAll(sqlServerRegex);

  for (const match of sqlMatches) {
    const resourceBlock = match[1];

    if (!resourceBlock.includes('azuread_administrator')) {
      results.medium.push({
        type: 'missing_config',
        name: 'missing_aad_admin',
        severity: 'medium',
        file: filePath,
        line: content.substring(0, match.index).split('\n').length,
        message: 'SQL Server missing Azure AD administrator',
        recommendation: 'Configure Azure AD authentication'
      });
    }
  }
}

/**
 * Check CIS compliance
 */
function checkCISCompliance(filePath, content) {
  const cisChecks = [];

  // CIS 3.1: Storage account encryption
  if (content.includes('azurerm_storage_account')) {
    if (!content.includes('infrastructure_encryption_enabled = true')) {
      cisChecks.push({
        check: 'CIS 3.1',
        status: 'FAIL',
        message: 'Storage account encryption not enabled',
        severity: 'high'
      });
    }
  }

  // CIS 3.7: Public access disabled
  if (content.includes('allow_nested_items_to_be_public = true')) {
    cisChecks.push({
      check: 'CIS 3.7',
      status: 'FAIL',
      message: 'Public access not disabled on storage',
      severity: 'high'
    });
  }

  // CIS 4.1: SQL Server auditing
  if (content.includes('azurerm_mssql_server') && !content.includes('azurerm_mssql_server_extended_auditing_policy')) {
    cisChecks.push({
      check: 'CIS 4.1',
      status: 'FAIL',
      message: 'SQL Server auditing not configured',
      severity: 'medium'
    });
  }

  return cisChecks;
}

/**
 * Generate report
 */
function generateReport() {
  console.log('='.repeat(70));
  console.log('TERRAFORM SECURITY SCAN REPORT');
  console.log('='.repeat(70));
  console.log(`Scan Time: ${new Date().toISOString()}`);
  console.log(`Path: ${scanPath}`);
  console.log('');

  const totalIssues = results.critical.length + results.high.length +
                      results.medium.length + results.low.length + results.info.length;

  console.log('Summary:');
  console.log(`  CRITICAL: ${results.critical.length}`);
  console.log(`  HIGH:     ${results.high.length}`);
  console.log(`  MEDIUM:   ${results.medium.length}`);
  console.log(`  LOW:      ${results.low.length}`);
  console.log(`  INFO:     ${results.info.length}`);
  console.log(`  TOTAL:    ${totalIssues}`);
  console.log('');

  // Critical issues
  if (results.critical.length > 0) {
    console.log('='.repeat(70));
    console.log('CRITICAL ISSUES');
    console.log('='.repeat(70));
    results.critical.forEach((issue, idx) => {
      console.log(`\n[${idx + 1}] ${issue.message}`);
      console.log(`    File: ${issue.file}:${issue.line}`);
      if (issue.code) {
        console.log(`    Code: ${issue.code}`);
      }
      console.log(`    Fix:  ${issue.recommendation}`);
    });
    console.log('');
  }

  // High issues
  if (results.high.length > 0) {
    console.log('='.repeat(70));
    console.log('HIGH SEVERITY ISSUES');
    console.log('='.repeat(70));
    results.high.forEach((issue, idx) => {
      console.log(`\n[${idx + 1}] ${issue.message}`);
      console.log(`    File: ${issue.file}:${issue.line}`);
      if (issue.code) {
        console.log(`    Code: ${issue.code}`);
      }
      console.log(`    Fix:  ${issue.recommendation}`);
    });
    console.log('');
  }

  // Medium issues (only if requested)
  if (severity === 'all' || severity.includes('medium')) {
    if (results.medium.length > 0) {
      console.log('='.repeat(70));
      console.log('MEDIUM SEVERITY ISSUES');
      console.log('='.repeat(70));
      results.medium.forEach((issue, idx) => {
        console.log(`\n[${idx + 1}] ${issue.message}`);
        console.log(`    File: ${issue.file}:${issue.line}`);
        console.log(`    Fix:  ${issue.recommendation}`);
      });
      console.log('');
    }
  }

  // Recommendations
  console.log('='.repeat(70));
  console.log('📋 REMEDIATION PRIORITIES');
  console.log('='.repeat(70));

  const secretCount = results.critical.filter(r => r.type === 'secret').length;
  if (secretCount > 0) {
    console.log(`  1. Remove ${secretCount} hardcoded secret(s) - URGENT!`);
  }

  const publicAccessCount = results.critical.filter(r => r.name?.includes('public')).length +
                             results.high.filter(r => r.name?.includes('public')).length;
  if (publicAccessCount > 0) {
    console.log(`  2. Restrict ${publicAccessCount} public access configuration(s)`);
  }

  const encryptionCount = results.high.filter(r => r.name?.includes('encryption') || r.name?.includes('https')).length;
  if (encryptionCount > 0) {
    console.log(`  3. Enable encryption on ${encryptionCount} resource(s)`);
  }

  console.log('');
  console.log('='.repeat(70));

  // Exit code based on severity
  if (results.critical.length > 0) {
    console.log('\nSCAN FAILED - Critical issues found');
    return 2;
  } else if (results.high.length > 0) {
    console.log('\nSCAN WARNING - High severity issues found');
    return 1;
  } else if (totalIssues > 0) {
    console.log('\nSCAN PASSED - Minor issues found');
    return 0;
  } else {
    console.log('\nSCAN PASSED - No issues found');
    return 0;
  }
}

/**
 * Export results to JSON
 */
function exportResults() {
  const report = {
    timestamp: new Date().toISOString(),
    path: scanPath,
    summary: {
      critical: results.critical.length,
      high: results.high.length,
      medium: results.medium.length,
      low: results.low.length,
      info: results.info.length,
      total: results.critical.length + results.high.length +
             results.medium.length + results.low.length + results.info.length
    },
    issues: results
  };

  fs.writeFileSync(outputFile, JSON.stringify(report, null, 2));
  console.log(`\nResults exported to: ${outputFile}`);
}

/**
 * Main execution
 */
function main() {
  console.log('Terraform Security Scanner\n');

  if (!fs.existsSync(scanPath)) {
    console.error(`Error: Path not found: ${scanPath}`);
    process.exit(1);
  }

  const files = getTerraformFiles(scanPath);

  if (files.length === 0) {
    console.error('No Terraform files found');
    process.exit(1);
  }

  console.log(`Scanning ${files.length} file(s)...\n`);

  // Scan each file
  files.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');

    if (secretsOnly) {
      scanForSecrets(file, content);
    } else {
      scanForSecrets(file, content);
      scanForSecurityIssues(file, content);

      if (compliance === 'cis-azure') {
        const cisResults = checkCISCompliance(file, content);
        // Add CIS results to medium severity
        cisResults.forEach(check => {
          results[check.severity].push({
            type: 'compliance',
            name: check.check,
            severity: check.severity,
            file: file,
            message: check.message,
            recommendation: 'See CIS benchmark documentation'
          });
        });
      }
    }
  });

  // Generate report
  const exitCode = generateReport();

  // Export if requested
  if (outputFile) {
    exportResults();
  }

  process.exit(exitCode);
}

main();
