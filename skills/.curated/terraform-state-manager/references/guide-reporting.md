# terraform-state-manager: Reporting

Read this reference when working on the topics below. Commands run from the skill directory.

- [Script Integration](#script-integration)
- [State Analysis Report Format](#state-analysis-report-format)

## Script Integration

If `scripts/state-analyzer.js` exists, use it:

```bash
# Analyze state file
node scripts/state-analyzer.js --state terraform.tfstate --report full

# Detect drift
node scripts/state-analyzer.js --detect-drift

# Show dependencies
node scripts/state-analyzer.js --dependencies azurerm_resource_group.main
```

## State Analysis Report Format

When analyzing state, provide:

```
State Analysis Report
=====================

State Information:
- Terraform Version: {version}
- State Serial: {serial}
- Last Modified: {timestamp}
- Backend: {backend_type}

Resources Summary:
- Total Resources: {count}
- Resource Types: {type_count}
- Orphaned Resources: {orphaned_count}

Resource Breakdown:
{type}: {count}
{type}: {count}

Potential Issues:
- [ ] Resources without tags: {count}
- [ ] Deprecated resource types: {count}
- [ ] Large state file (>{size}MB)
- [ ] Outdated Terraform version

Recommendations:
1. {recommendation}
2. {recommendation}
```

