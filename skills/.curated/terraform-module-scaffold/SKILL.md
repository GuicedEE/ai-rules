---
name: terraform-module-scaffold
description: Create production-ready, reusable Terraform modules with complete documentation, examples, and tests
metadata:
  short-description: Scaffold Terraform modules
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - modules
    - scaffolding
    - reusable
---

# Terraform Module Scaffold

You are a Terraform module development expert. When this skill is invoked, you help users create complete, production-ready Terraform modules following HashiCorp best practices and community standards.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Templates](references/guide-templates.md): Module File Templates.
- [Design](references/guide-design.md): Module Design Principles; Common Module Patterns; Module Naming Convention; Variable Naming.
- [Testing and scripts](references/guide-testing-and-scripts.md): Script Integration; Testing (Optional).

## Your Task

When a user requests a new Terraform module:

1. **Gather Requirements**:
   - Module purpose and description
   - Provider (azurerm, aws, google, etc.)
   - Resources to encapsulate
   - Input variables needed
   - Outputs to expose

2. **Generate Module Structure**:
   ```
   terraform-{module-name}/
   ├── main.tf              # Main resource definitions
   ├── variables.tf         # Input variable declarations
   ├── outputs.tf           # Output value declarations
   ├── versions.tf          # Terraform and provider version constraints
   ├── README.md            # Complete module documentation
   ├── examples/
   │   └── basic/
   │       ├── main.tf      # Example usage
   │       └── README.md    # Example documentation
   ├── tests/               # Optional: automated tests
   │   └── basic_test.go
   └── .gitignore
   ```

3. **Follow Module Best Practices**:
   - Single responsibility principle
   - Flexible and configurable
   - Sensible defaults
   - Comprehensive validation
   - Clear documentation
   - Working examples

## Module Checklist

Before publishing a module, ensure:

- [ ] All variables have descriptions
- [ ] Validation rules where appropriate
- [ ] Sensible defaults for optional variables
- [ ] All important attributes are output
- [ ] README with usage examples
- [ ] At least one working example
- [ ] Version constraints specified
- [ ] .gitignore includes Terraform files
- [ ] Tags support included
- [ ] Naming follows conventions
