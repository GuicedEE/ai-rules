# terraform-module-scaffold: Testing and scripts

Read this reference when working on the topics below. Commands run from the skill directory.

- [Script Integration](#script-integration)
- [Testing (Optional)](#testing-optional)

## Script Integration

If `scripts/scaffold-module.js` exists, use it:

```bash
node scripts/scaffold-module.js \
  --name virtual-network \
  --provider azurerm \
  --description "Create and manage Azure Virtual Networks" \
  --output ./modules
```

## Testing (Optional)

For critical modules, add automated tests using Terratest:

```go
package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestBasicExample(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../examples/basic",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  // Add assertions here
}
```

