# terraform-plan-analyzer: Reporting

Read this reference when working on the topics below. Commands run from the skill directory.

- [Plan Analysis Report Format](#plan-analysis-report-format)
- [Script Integration](#script-integration)
- [Integration with CI/CD](#integration-with-cicd)

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

