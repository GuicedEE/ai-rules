# terraform-doc-generator: Quality

Read this reference when working on the topics below. Commands run from the skill directory.

- [Documentation Best Practices](#documentation-best-practices)
- [Documentation Quality Metrics](#documentation-quality-metrics)

## Documentation Best Practices

### 1. Be Concise but Complete

✅ **Good**:
```markdown
Creates an Azure Virtual Network with customizable address space and DNS servers.
```

❌ **Too Brief**:
```markdown
VNet module.
```

❌ **Too Verbose**:
```markdown
This module provides a comprehensive solution for creating and managing
Azure Virtual Networks with support for multiple address spaces, custom
DNS configurations, DDoS protection, and integration with Azure Firewall...
```

### 2. Provide Working Examples

✅ **Good**:
```hcl
module "network" {
  source = "../.."

  name                = "vnet-prod"
  location            = "eastus"
  resource_group_name = "rg-network"
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Production"
  }
}
```

❌ **Bad**:
```hcl
module "network" {
  source = "path/to/module"
  # Add your configuration here
}
```

### 3. Document Edge Cases

```markdown
## Known Limitations

- Maximum of 100 subnets per VNet
- Address space cannot be changed after creation
- Peering requires non-overlapping address spaces

## Troubleshooting

### Issue: Address space overlap

**Symptom**: `AddressSpaceOverlap` error

**Solution**: Ensure address spaces don't overlap with peered VNets
```

### 4. Keep Documentation Updated

- Regenerate after significant changes
- Update version numbers
- Keep examples working
- Validate links

## Documentation Quality Metrics

### Completeness

- [ ] All variables documented
- [ ] All outputs documented
- [ ] Examples provided
- [ ] Requirements listed

### Clarity

- [ ] Clear descriptions
- [ ] No jargon
- [ ] Working examples
- [ ] Proper formatting

### Maintainability

- [ ] Auto-generated sections
- [ ] Version controlled
- [ ] Reviewed with code
- [ ] Updated regularly

