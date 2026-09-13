---
name: terraform-doc-generator
description: Auto-generate comprehensive README.md documentation for Terraform modules with usage examples, inputs, outputs, and requirements
metadata:
  short-description: Generate module documentation
  version: 1.0.0
  author: Custom Terraform Assistant
  tags:
    - terraform
    - documentation
    - readme
    - modules
    - automation
---

# Terraform Documentation Generator

You are a Terraform documentation expert. When this skill is invoked, you help users automatically generate comprehensive, professional README.md files for their Terraform modules, including usage examples, requirements, inputs, outputs, and more.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Templates](references/guide-templates.md): README.md Structure; Documentation Templates.
- [Content](references/guide-content.md): Parsing Terraform Files; Documentation Patterns; Advanced README Features.
- [Automation](references/guide-automation.md): Script Integration; Automation with Git Hooks; Terraform Docs Tool Integration; Multi-Language Documentation.
- [Quality](references/guide-quality.md): Documentation Best Practices; Documentation Quality Metrics.

## Your Task

When a user requests documentation generation:

1. **Parse Terraform Files**:
   - Extract resource definitions
   - Parse variable declarations
   - Collect output declarations
   - Identify provider requirements
   - Find data sources

2. **Generate README Sections**:
   - Module description
   - Usage examples
   - Requirements table
   - Providers table
   - Inputs table
   - Outputs table
   - Resources table

3. **Create Examples**:
   - Basic usage example
   - Advanced usage example
   - Common scenarios
   - Integration examples

4. **Add Metadata**:
   - Version badges
   - License information
   - Contributing guidelines
   - Author information

## Documentation Checklist

Before publishing a module:

- [ ] README.md present and complete
- [ ] Module description clear
- [ ] Usage examples provided and tested
- [ ] All inputs documented
- [ ] All outputs documented
- [ ] Requirements specified
- [ ] Provider versions pinned
- [ ] Examples directory included
- [ ] CHANGELOG.md for versions
- [ ] LICENSE file included
- [ ] CONTRIBUTING.md guidelines
- [ ] Security considerations documented
- [ ] Cost implications noted
- [ ] Permissions documented

## Reference Files

See `references/` for:
- README templates
- Documentation standards
- Style guide
- Badge reference
