# terraform-plan-analyzer: Evaluation

Read this reference when working on the topics below. Commands run from the skill directory.

- [Plan Analysis Categories](#plan-analysis-categories)
- [Advanced Analysis](#advanced-analysis)
- [Common Questions](#common-questions)

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

