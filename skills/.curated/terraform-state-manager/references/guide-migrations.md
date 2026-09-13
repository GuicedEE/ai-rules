# terraform-state-manager: Migrations

Read this reference when working on the topics below. Commands run from the skill directory.

- [State Migration](#state-migration)
- [Advanced State Operations](#advanced-state-operations)

## State Migration

### Migrate from Local to Remote

**Step 1: Configure backend**:
```hcl
terraform {
  backend "azurerm" {
    # backend config
  }
}
```

**Step 2: Reinitialize**:
```bash
terraform init -migrate-state
```

**Step 3: Verify**:
```bash
terraform state list
```

### Migrate Between Backends

```bash
# 1. Reconfigure backend in code
# 2. Run init with migration
terraform init -migrate-state -reconfigure
```

## Advanced State Operations

### Use Targeted Operations

```bash
# Only plan specific resource
terraform plan -target=azurerm_resource_group.main

# Only apply specific resource
terraform apply -target=azurerm_resource_group.main
```

**Warning**: Use targets sparingly - can lead to inconsistent state!

### Working with Count/For-Each

**Move specific instance**:
```bash
terraform state mv 'azurerm_vm.example[0]' 'azurerm_vm.example[1]'
```

**Move from count to for_each**:
```bash
terraform state mv 'azurerm_vm.example[0]' 'azurerm_vm.example["vm1"]'
```

