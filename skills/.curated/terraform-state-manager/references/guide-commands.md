# terraform-state-manager: Commands

Read this reference when working on the topics below. Commands run from the skill directory.

- [State Commands Reference](#state-commands-reference)
- [Common State Scenarios](#common-state-scenarios)
- [State Locking](#state-locking)
- [State Backends](#state-backends)

## State Commands Reference

### Inspecting State

**List all resources**:
```bash
terraform state list
```

**Show specific resource**:
```bash
terraform state show <resource_address>
```

**Show entire state** (JSON format):
```bash
terraform show -json terraform.tfstate
```

**Pull remote state**:
```bash
terraform state pull > state.json
```

### Manipulating State

**Move resource within state**:
```bash
terraform state mv <source> <destination>
```

**Remove resource from state**:
```bash
terraform state rm <resource_address>
```

**Import existing resource**:
```bash
terraform import <resource_address> <resource_id>
```

**Replace provider in state**:
```bash
terraform state replace-provider <old_provider> <new_provider>
```

### Advanced Operations

**Backup state**:
```bash
terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json
```

**Restore state**:
```bash
terraform state push state-backup.json
```

## Common State Scenarios

### Scenario 1: Resource Renamed in Configuration

**Problem**: Renamed resource in code, Terraform wants to destroy and recreate.

**Solution**:
```bash
# Move in state to match new name
terraform state mv azurerm_resource_group.old_name azurerm_resource_group.new_name
```

### Scenario 2: Resource Created Outside Terraform

**Problem**: Resource exists but not in state.

**Solution**:
```bash
# Import the existing resource
terraform import azurerm_resource_group.main /subscriptions/{sub-id}/resourceGroups/my-rg
```

### Scenario 3: Resource Stuck in State

**Problem**: Resource deleted manually but still in state.

**Solution**:
```bash
# Remove from state
terraform state rm azurerm_resource_group.deleted
```

### Scenario 4: Move Resource to Different Module

**Problem**: Reorganizing code structure.

**Solution**:
```bash
# Move between modules
terraform state mv module.old.azurerm_resource_group.main module.new.azurerm_resource_group.main
```

### Scenario 5: Split State Files

**Problem**: Need to separate resources into different state files.

**Solution**:
```bash
# 1. Pull original state
terraform state pull > original-state.json

# 2. Remove resources that should move
terraform state rm <resources_to_move>

# 3. In new workspace/backend, import those resources
terraform import <resource_address> <resource_id>
```

## State Locking

### Understanding State Locking

State locking prevents concurrent modifications:

- **Automatic**: Happens during `plan`, `apply`, `destroy`
- **Backends**: Supported by azurerm, s3, consul, etc.
- **Force unlock**: Use only when necessary

### Unlock a Locked State

```bash
# Get lock ID from error message
terraform force-unlock <lock-id>
```

**Warning**: Only use when you're certain no other operation is running!

## State Backends

### Local Backend (Default)

```hcl
# State stored in local file: terraform.tfstate
```

**Pros**: Simple, no setup
**Cons**: No locking, no collaboration, no encryption

### Remote Backend (Recommended)

**Azure (azurerm)**:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}
```

**AWS (s3)**:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**GCP (gcs)**:
```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state"
    prefix = "prod"
  }
}
```

