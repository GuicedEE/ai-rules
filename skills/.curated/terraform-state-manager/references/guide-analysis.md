# terraform-state-manager: Analysis

Read this reference when working on the topics below. Commands run from the skill directory.

- [Drift Detection](#drift-detection)
- [State File Structure](#state-file-structure)
- [State Analysis Patterns](#state-analysis-patterns)
- [State Troubleshooting](#state-troubleshooting)

## Drift Detection

### What is Drift?

Drift occurs when the actual infrastructure differs from what's defined in Terraform state. This can happen when:
- Resources modified manually through portal/CLI
- Changes made by other tools
- Resources deleted outside Terraform
- Automatic scaling or updates

### Detecting Drift

**Run a plan to see differences**:
```bash
terraform plan -detailed-exitcode
```

Exit codes:
- `0`: No changes needed
- `1`: Error occurred
- `2`: Changes needed (drift detected)

**Generate detailed drift report**:
```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan-output.json
```

### Analyzing Drift

The drift report shows:
- **Resource changes**: What will be modified
- **Attribute changes**: Specific values that differ
- **Dependencies**: What else might be affected

**Example drift output**:
```
  # azurerm_storage_account.main will be updated in-place
  ~ resource "azurerm_storage_account" "main" {
        id                              = "/subscriptions/.../mystorageaccount"
        name                            = "mystorageaccount"
      ~ min_tls_version                 = "TLS1_0" -> "TLS1_2"
        # (15 unchanged attributes hidden)
    }
```

### Responding to Drift

**Option 1: Apply to fix drift**:
```bash
terraform apply
```

**Option 2: Update code to match reality**:
```bash
# Refresh state to match reality
terraform apply -refresh-only
```

**Option 3: Accept drift and update state**:
```bash
terraform refresh
```

## State File Structure

### State File Format (Simplified)

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 5,
  "lineage": "unique-id",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "azurerm_resource_group",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "/subscriptions/.../resourceGroups/my-rg",
            "location": "eastus",
            "name": "my-rg",
            "tags": {}
          },
          "dependencies": []
        }
      ]
    }
  ]
}
```

### Key State Components

- **version**: State file format version
- **terraform_version**: Terraform version that wrote this state
- **serial**: Increments with each state change
- **lineage**: Unique ID for this state (prevents mixing states)
- **resources**: All managed resources
- **outputs**: Output values

## State Analysis Patterns

### Find All Resources of a Type

```bash
terraform state list | grep "azurerm_storage_account"
```

### Count Resources by Type

```bash
terraform state list | cut -d. -f1 | sort | uniq -c
```

### Show All Resource IDs

```bash
terraform state list | while read resource; do
  echo "=== $resource ==="
  terraform state show "$resource" | grep "id ="
done
```

### Find Resources Without Tags

```bash
terraform state list | while read resource; do
  if terraform state show "$resource" | grep -q "tags.*= {}"; then
    echo "No tags: $resource"
  fi
done
```

## State Troubleshooting

### Issue: State is Corrupted

**Symptoms**: Terraform commands fail with state errors

**Solution**:
```bash
# 1. Restore from backup
terraform state pull > corrupt-state.json

# 2. If using remote backend, check storage versioning
# For Azure:
az storage blob list --account-name tfstate --container-name tfstate

# 3. Download previous version
az storage blob download \
  --account-name tfstate \
  --container-name tfstate \
  --name terraform.tfstate \
  --version-id <version-id> \
  --file restored-state.json

# 4. Push restored state
terraform state push restored-state.json
```

### Issue: State Out of Sync

**Symptoms**: Plan shows unexpected changes

**Solution**:
```bash
# Refresh state to match reality
terraform apply -refresh-only

# Review changes
terraform plan
```

### Issue: Duplicate Resources in State

**Symptoms**: Same resource appears multiple times

**Solution**:
```bash
# List all resources
terraform state list

# Remove duplicates
terraform state rm <duplicate_resource>
```

### Issue: Resource Not Found

**Symptoms**: State references resource that doesn't exist

**Solution**:
```bash
# Remove from state
terraform state rm <missing_resource>

# Or import if it exists elsewhere
terraform import <resource_address> <resource_id>
```

