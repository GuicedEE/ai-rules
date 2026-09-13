# terraform-security-scanner: Reporting and compliance

Read this reference when working on the topics below. Commands run from the skill directory.

- [Security Scan Report Format](#security-scan-report-format)
- [Compliance Frameworks](#compliance-frameworks)
- [Script Integration](#script-integration)
- [Custom Security Policies](#custom-security-policies)

## Security Scan Report Format

When scanning for security issues, provide:

```
Security Scan Report
====================
Scan Time: {timestamp}
Files Scanned: {count}
Security Tool: {tool_name}

CRITICAL Issues: {count}
HIGH Issues:     {count}
MEDIUM Issues:   {count}
LOW Issues:      {count}
INFO:            {count}

=== CRITICAL ISSUES ===

[CRITICAL] Hardcoded Secret Detected
  File: main.tf:45
  Resource: azurerm_sql_server.main
  Issue: Hardcoded password in administrator_login_password
  Impact: Credentials exposed in code
  Fix: Use Azure Key Vault or variables marked as sensitive

[CRITICAL] Public Storage Access
  File: storage.tf:12
  Resource: azurerm_storage_account.data
  Issue: Storage account allows public access
  Impact: Data may be exposed to internet
  Fix: Set allow_nested_items_to_be_public = false

=== HIGH ISSUES ===

[HIGH] Unencrypted Storage
  File: storage.tf:8
  Resource: azurerm_storage_account.logs
  Issue: HTTPS not enforced
  Impact: Data transmitted without encryption
  Fix: Set enable_https_traffic_only = true

[HIGH] Weak TLS Version
  File: app.tf:23
  Resource: azurerm_app_service.main
  Issue: TLS 1.0 allowed
  Impact: Vulnerable to protocol attacks
  Fix: Set min_tls_version = "1.2"

=== REMEDIATION SUMMARY ===

Priority Actions:
1. Remove all hardcoded credentials (2 instances)
2. Enable encryption on storage accounts (3 instances)
3. Restrict public network access (5 instances)
4. Upgrade TLS versions (4 instances)

Compliance Impact:
- PCI DSS: 3 violations
- HIPAA: 2 violations
- CIS Benchmark: 7 violations

Estimated Fix Time: 2-4 hours
```

## Compliance Frameworks

### CIS Benchmarks

**Azure CIS 1.4**:
- [ ] 3.1: Ensure storage encryption is enabled
- [ ] 3.2: Ensure HTTPS is enforced
- [ ] 3.7: Ensure public access is disabled
- [ ] 4.1: Ensure auditing is enabled on SQL servers
- [ ] 5.1: Ensure Network Security Groups deny all by default

**AWS CIS 1.4**:
- [ ] 2.1: Ensure S3 buckets are encrypted
- [ ] 2.2: Ensure S3 bucket logging is enabled
- [ ] 2.3: Ensure S3 bucket versioning is enabled
- [ ] 4.1: Ensure no security groups allow 0.0.0.0/0
- [ ] 4.2: Ensure default security groups restrict all traffic

### PCI DSS

For payment card data:
- [ ] Encryption at rest
- [ ] Encryption in transit
- [ ] Network segmentation
- [ ] Access control
- [ ] Audit logging
- [ ] Regular security testing

### HIPAA

For healthcare data:
- [ ] Data encryption (at rest and in transit)
- [ ] Access controls and authentication
- [ ] Audit logging and monitoring
- [ ] Data backup and recovery
- [ ] Disaster recovery plan

## Script Integration

If `scripts/security-scanner.js` exists, use it:

```bash
# Full security scan
node scripts/security-scanner.js --path ./terraform --severity all

# Critical and high only
node scripts/security-scanner.js --path ./terraform --severity critical,high

# Secrets detection only
node scripts/security-scanner.js --path ./terraform --secrets-only

# Compliance check
node scripts/security-scanner.js --path ./terraform --compliance cis-azure

# Export report
node scripts/security-scanner.js --path ./terraform --output security-report.json
```

## Custom Security Policies

### Define Custom Rules

Using OPA (Open Policy Agent):

```rego
package terraform.security

# Deny if storage account doesn't enforce HTTPS
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  not resource.change.after.enable_https_traffic_only

  msg := sprintf("Storage account '%s' must enforce HTTPS", [resource.address])
}

# Deny if VM doesn't have managed identity
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_linux_virtual_machine"
  not resource.change.after.identity

  msg := sprintf("VM '%s' must use managed identity", [resource.address])
}
```

