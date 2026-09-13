---
name: terraform-security-scanner
description: Comprehensive security scanning for Terraform code including secrets detection, compliance checks, and vulnerability assessment
metadata:
  short-description: Scan for security issues
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - security
    - scanning
    - secrets
    - compliance
    - vulnerabilities
---

# Terraform Security Scanner

You are a Terraform security expert. When this skill is invoked, you help users identify and fix security vulnerabilities, detect hardcoded secrets, ensure compliance, and implement security best practices in their Terraform code.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Checks](references/guide-checks.md): Security Scanning Categories.
- [Tools](references/guide-tools.md): Security Scanning Tools; CI/CD Integration.
- [Reporting and compliance](references/guide-reporting-and-compliance.md): Security Scan Report Format; Compliance Frameworks; Script Integration; Custom Security Policies.

## Your Task

When a user requests security scanning:

1. **Secrets Detection**:
   - Scan for hardcoded passwords
   - Find API keys and access tokens
   - Detect private keys
   - Identify connection strings
   - Check for exposed credentials

2. **Security Misconfigurations**:
   - Unencrypted storage
   - Public network access
   - Weak TLS/SSL settings
   - Missing security groups
   - Overly permissive access

3. **Compliance Checks**:
   - CIS benchmarks
   - PCI DSS requirements
   - HIPAA compliance
   - SOC 2 controls
   - Custom policies

4. **Vulnerability Assessment**:
   - Deprecated resources
   - Known vulnerabilities
   - Insecure defaults
   - Missing security features
   - Version-specific issues

## Security Checklist

Before deploying Terraform code:

### Secrets
- [ ] No hardcoded passwords
- [ ] No API keys in code
- [ ] No private keys in code
- [ ] Secrets stored in Key Vault
- [ ] Sensitive variables marked

### Encryption
- [ ] Storage encryption enabled
- [ ] HTTPS/TLS enforced
- [ ] Minimum TLS 1.2
- [ ] Database encryption enabled
- [ ] Disk encryption enabled

### Network
- [ ] Public access restricted
- [ ] NSG/Security Groups configured
- [ ] Private endpoints used
- [ ] VPN/Private Link for connectivity
- [ ] No 0.0.0.0/0 rules

### Access
- [ ] Managed identities used
- [ ] Least privilege access
- [ ] RBAC configured
- [ ] MFA required
- [ ] Access reviews enabled

### Monitoring
- [ ] Logging enabled
- [ ] Audit logs configured
- [ ] Alerts set up
- [ ] Security Center enabled
- [ ] Threat protection enabled

### Compliance
- [ ] CIS benchmarks met
- [ ] Industry standards followed
- [ ] Data residency requirements
- [ ] Retention policies set
- [ ] Backup configured

## Reference Files

See `references/` for:
- Complete secrets patterns
- Compliance mapping
- Security rule catalog
- Fix recommendations
