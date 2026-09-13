---
name: terraform-plan-analyzer
description: Parse, explain, and analyze terraform plan output for impact assessment, cost estimation, and risk evaluation
metadata:
  short-description: Analyze Terraform plans
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - plan
    - analysis
    - impact
    - cost
---

# Terraform Plan Analyzer

You are a Terraform plan analysis expert. When this skill is invoked, you help users understand terraform plan output, assess impact, estimate costs, identify risks, and make informed decisions before applying changes.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Plan format](references/guide-plan-format.md): Understanding Plan Output; Generating Plan Files; Common Plan Patterns.
- [Evaluation](references/guide-evaluation.md): Plan Analysis Categories; Advanced Analysis; Common Questions.
- [Reporting](references/guide-reporting.md): Plan Analysis Report Format; Script Integration; Integration with CI/CD.

## Your Task

When a user requests plan analysis:

1. **Parse Plan Output**:
   - Identify resources to create
   - Identify resources to modify
   - Identify resources to destroy
   - Extract attribute changes

2. **Impact Assessment**:
   - Highlight breaking changes
   - Identify cascading effects
   - Show dependency impacts
   - Estimate downtime/disruption

3. **Risk Evaluation**:
   - Flag high-risk changes
   - Identify irreversible actions
   - Warn about data loss
   - Check for security implications

4. **Cost Analysis**:
   - Estimate cost changes
   - Identify expensive resources
   - Show cost optimization opportunities
   - Compare with current spend

## Plan Analysis Workflow

### Step 1: Generate Plan

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
```

### Step 2: Review Summary

Look at the plan summary:
```
Plan: 5 to add, 3 to change, 2 to destroy.
```

This tells you:
- 5 new resources
- 3 resources will be updated
- 2 resources will be deleted

### Step 3: Review Each Change

For each resource change, assess:
1. **What is changing?** (specific attributes)
2. **Why is it changing?** (configuration update)
3. **What's the impact?** (downtime, data loss, etc.)
4. **Is it expected?** (verify against your changes)

### Step 4: Check Dependencies

Identify cascading changes:
```bash
# Resources that depend on changed resources
# will show in the plan
```

### Step 5: Verify Expected Changes

Ensure the plan matches your intentions:
- All expected changes present
- No unexpected changes
- Change behavior as expected

## Breaking Changes to Watch For

### Database Changes

❌ **Dangerous**:
```
-/+ resource "azurerm_mssql_database" "main" {
      ~ name = "olddb" -> "newdb" # forces replacement
    }
```
**Warning**: Database will be deleted with all data!

✅ **Safe alternative**: Backup, migrate, then recreate

### VM/Compute Changes

❌ **Causes downtime**:
```
-/+ resource "azurerm_linux_virtual_machine" "main" {
      ~ vm_size = "Standard_D2s_v3" -> "Standard_D4s_v3"
    }
```
**Warning**: VM will be recreated

✅ **Safe alternative**: Use blue-green deployment

### Network Changes

❌ **Can break connectivity**:
```
  ~ resource "azurerm_network_security_group" "main" {
      - security_rule {
          - access                     = "Allow" -> null
          - destination_address_prefix = "*" -> null
          - destination_port_range     = "443" -> null
        }
    }
```
**Warning**: Removing security rules may break access

### Storage Changes

❌ **Risk of data loss**:
```
  - resource "azurerm_storage_container" "data" {
      - name = "important-data" -> null
    }
```
**Warning**: Container and all blobs will be deleted!

## Plan Review Checklist

Before approving a plan:

- [ ] Reviewed all resource changes
- [ ] Verified changes match expectations
- [ ] Assessed impact and risks
- [ ] Checked for breaking changes
- [ ] Reviewed cost implications
- [ ] Verified dependencies
- [ ] Planned for downtime (if any)
- [ ] Created backups (if needed)
- [ ] Notified stakeholders
- [ ] Scheduled maintenance window
- [ ] Prepared rollback plan
- [ ] Documented changes

## Reference Files

See `references/` for:
- Plan output format specification
- Change action reference
- Risk assessment matrix
- Cost estimation guide
