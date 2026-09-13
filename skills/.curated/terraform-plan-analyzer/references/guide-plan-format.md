# terraform-plan-analyzer: Plan format

Read this reference when working on the topics below. Commands run from the skill directory.

- [Understanding Plan Output](#understanding-plan-output)
- [Generating Plan Files](#generating-plan-files)
- [Common Plan Patterns](#common-plan-patterns)

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

