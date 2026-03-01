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

## Understanding Plan Output

### Plan Symbols

Terraform uses these symbols in plan output:

- `+` Create resource
- `-` Destroy resource
- `~` Update in-place
- `-/+` Destroy and recreate
- `<=` Read (data source)
- `#` Comment/note

### Resource Actions

**Create** (New resource):
```
  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "my-rg"
    }
```

**Update in-place** (No downtime):
```
  # azurerm_storage_account.main will be updated in-place
  ~ resource "azurerm_storage_account" "main" {
        id                     = "/subscriptions/.../mystorageaccount"
      ~ min_tls_version        = "TLS1_0" -> "TLS1_2"
        # (15 unchanged attributes hidden)
    }
```

**Replace** (Destroy then create - **DOWNTIME**):
```
  # azurerm_virtual_machine.main must be replaced
-/+ resource "azurerm_virtual_machine" "main" {
      ~ id       = "/subscriptions/.../myvm" -> (known after apply)
      ~ vm_size  = "Standard_D2s_v3" -> "Standard_D4s_v3" # forces replacement
        name     = "my-vm"
    }
```

**Destroy** (Resource removed):
```
  # azurerm_resource_group.old will be destroyed
  - resource "azurerm_resource_group" "old" {
      - id       = "/subscriptions/.../old-rg" -> null
      - location = "eastus" -> null
      - name     = "old-rg" -> null
    }
```

### Change Modifiers

- `(known after apply)`: Value will be determined during apply
- `(sensitive value)`: Value is marked sensitive
- `forces replacement`: This change requires recreating the resource

## Generating Plan Files

### Create a Plan

**Basic plan**:
```bash
terraform plan
```

**Save plan to file**:
```bash
terraform plan -out=tfplan
```

**JSON format for analysis**:
```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
```

**Detailed exit code**:
```bash
terraform plan -detailed-exitcode
```

Exit codes:
- `0`: No changes
- `1`: Error
- `2`: Changes present

## Plan Analysis Categories

### 1. Impact Analysis

**High Impact Changes**:
- Resources being destroyed
- Resources being replaced
- Production database changes
- Network changes affecting connectivity
- Security group/firewall changes
- DNS changes

**Medium Impact Changes**:
- Resources updated in-place
- Configuration changes
- Scaling changes
- Tag updates

**Low Impact Changes**:
- Read-only operations
- Output changes
- Local value changes

### 2. Risk Assessment

**Critical Risks**:
- Data loss (database deletion, disk deletion)
- Service disruption (VM replacement, network changes)
- Security weakening (firewall rule removal)
- Irreversible changes (permanent deletion)

**High Risks**:
- Production resource replacement
- Breaking configuration changes
- Dependency chain disruption

**Medium Risks**:
- Non-critical resource replacement
- Performance impact changes
- Cost increase changes

**Low Risks**:
- Tag changes
- Description updates
- Non-functional changes

### 3. Cost Implications

**Cost Increases**:
- Larger VM sizes
- Additional resources
- Premium tiers/SKUs
- Data egress increases
- Storage expansion

**Cost Decreases**:
- Smaller VM sizes
- Resource removal
- Standard tiers/SKUs
- Reserved capacity

**Cost Neutral**:
- Configuration changes
- Tag updates
- In-place updates

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

## Common Plan Patterns

### Pattern 1: Attribute Update (Safe)

```
  ~ resource "azurerm_storage_account" "main" {
      ~ tags = {
          + "Environment" = "Production"
        }
    }
```

**Analysis**:
- **Action**: Update in-place
- **Impact**: None
- **Risk**: Low
- **Downtime**: None

### Pattern 2: Size Change (Requires Replacement)

```
-/+ resource "azurerm_linux_virtual_machine" "main" {
      ~ vm_size = "Standard_D2s_v3" -> "Standard_D4s_v3" # forces replacement
    }
```

**Analysis**:
- **Action**: Replace (destroy + create)
- **Impact**: Service disruption
- **Risk**: High
- **Downtime**: Yes
- **Warning**: VM will be destroyed and recreated

### Pattern 3: Name Change (Forces Recreation)

```
-/+ resource "azurerm_storage_account" "main" {
      ~ name = "oldstorageaccount" -> "newstorageaccount" # forces replacement
    }
```

**Analysis**:
- **Action**: Replace
- **Impact**: Data migration needed
- **Risk**: Critical
- **Warning**: Old storage account will be deleted with all data!

### Pattern 4: Dependent Resource Update

```
  # azurerm_network_interface.main must be replaced
-/+ resource "azurerm_network_interface" "main" {
        ...
    }

  # azurerm_linux_virtual_machine.main must be replaced
  # (because azurerm_network_interface.main must be replaced)
-/+ resource "azurerm_linux_virtual_machine" "main" {
        ...
    }
```

**Analysis**:
- **Action**: Cascading replacement
- **Impact**: Multiple resources affected
- **Risk**: High
- **Warning**: NIC change triggers VM replacement

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

## Plan Analysis Report Format

When analyzing a plan, provide:

```
Terraform Plan Analysis
=======================

Summary:
  Resources to Add:     {count}
  Resources to Change:  {count}
  Resources to Destroy: {count}

Impact Assessment:
  High Impact:   {count} changes
  Medium Impact: {count} changes
  Low Impact:    {count} changes

Risk Level: {CRITICAL|HIGH|MEDIUM|LOW}

Critical Warnings:
  ⚠ {warning}
  ⚠ {warning}

Resource Breakdown:

CREATE:
  + azurerm_resource_group.new
  + azurerm_storage_account.new

UPDATE IN-PLACE:
  ~ azurerm_storage_account.existing
    - Tags update (low risk)

REPLACE (DESTROY + CREATE):
  -/+ azurerm_linux_virtual_machine.main
    ! WARNING: This will cause downtime
    ! Reason: VM size change forces replacement

DESTROY:
  - azurerm_resource_group.old
    ! WARNING: All resources in this group will be deleted

Cost Impact:
  Estimated Monthly Change: +$150
  New Resources: +$200
  Removed Resources: -$50

Recommendations:
  1. Backup database before applying
  2. Schedule change during maintenance window
  3. Notify stakeholders of planned downtime
  4. Consider blue-green deployment for VM

Approval Required: YES (due to destructive changes)
```

## Script Integration

If `scripts/plan-analyzer.js` exists, use it:

```bash
# Analyze plan file
node scripts/plan-analyzer.js --plan plan.json --report full

# Check for breaking changes
node scripts/plan-analyzer.js --plan plan.json --check-breaking

# Estimate cost impact
node scripts/plan-analyzer.js --plan plan.json --cost-analysis

# Generate approval request
node scripts/plan-analyzer.js --plan plan.json --approval-report
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Terraform Plan Analysis

on:
  pull_request:
    paths:
      - '**.tf'

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Plan
        run: |
          terraform init
          terraform plan -out=tfplan
          terraform show -json tfplan > plan.json

      - name: Analyze Plan
        run: |
          node .codex/skills/terraform-plan-analyzer/scripts/plan-analyzer.js \
            --plan plan.json \
            --report full > plan-analysis.md

      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const analysis = fs.readFileSync('plan-analysis.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: analysis
            });
```

## Advanced Analysis

### Compare Plans Over Time

```bash
# Generate plan history
terraform plan -out=tfplan-$(date +%Y%m%d-%H%M%S)
terraform show -json tfplan-* > plan-history.json

# Compare changes
node scripts/plan-analyzer.js --compare plan-old.json plan-new.json
```

### Simulate What-If Scenarios

```bash
# Generate plan without actually planning
terraform plan -refresh-only -out=refresh.tfplan

# Analyze drift
node scripts/plan-analyzer.js --plan refresh.tfplan --detect-drift
```

### Resource-Specific Analysis

```bash
# Analyze specific resource
terraform plan -target=azurerm_resource_group.main
```

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

## Common Questions

**Q: Why is this resource being replaced?**
A: Look for "forces replacement" comments. Common reasons:
- Name change
- Location change
- Certain configuration changes
- Provider requirements

**Q: Can I prevent replacement?**
A: Sometimes:
- Review if the change is necessary
- Check if there's an alternative approach
- Use `lifecycle { prevent_destroy = true }` to block
- Consider manual migration

**Q: What does "(known after apply)" mean?**
A: The value will be determined when the resource is created/updated. Common for:
- Resource IDs
- Generated names
- Computed attributes

**Q: How do I estimate costs?**
A: Use:
- Azure Pricing Calculator
- AWS Pricing Calculator
- Infracost (automated tool)
- Cloud cost management tools

## Reference Files

See `references/` for:
- Plan output format specification
- Change action reference
- Risk assessment matrix
- Cost estimation guide
