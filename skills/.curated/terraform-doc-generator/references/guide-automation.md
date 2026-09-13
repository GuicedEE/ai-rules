# terraform-doc-generator: Automation

Read this reference when working on the topics below. Commands run from the skill directory.

- [Script Integration](#script-integration)
- [Automation with Git Hooks](#automation-with-git-hooks)
- [Terraform Docs Tool Integration](#terraform-docs-tool-integration)
- [Multi-Language Documentation](#multi-language-documentation)

## Script Integration

If `scripts/doc-generator.js` exists, use it:

```bash
# Generate README for current directory
node scripts/doc-generator.js

# Generate README for specific module
node scripts/doc-generator.js --path ./modules/network

# Generate with examples
node scripts/doc-generator.js --path . --include-examples

# Update existing README (preserve custom sections)
node scripts/doc-generator.js --update

# Generate and commit
node scripts/doc-generator.js --commit
```

## Automation with Git Hooks

### Pre-commit Hook

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash

# Auto-generate documentation before commit
node .codex/skills/terraform-doc-generator/scripts/doc-generator.js --update

# Stage updated README
git add README.md
```

### CI/CD Integration

**GitHub Actions**:
```yaml
name: Update Documentation

on:
  push:
    branches: [main]
    paths:
      - '**.tf'

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate Documentation
        run: |
          node .codex/skills/terraform-doc-generator/scripts/doc-generator.js --update

      - name: Commit Changes
        run: |
          git config --global user.name 'docs-bot'
          git config --global user.email 'bot@example.com'
          git add README.md
          git diff --staged --quiet || git commit -m "docs: auto-update README"
          git push
```

## Terraform Docs Tool Integration

### Using terraform-docs

**Install**:
```bash
brew install terraform-docs
```

**Generate**:
```bash
terraform-docs markdown table . > README.md
```

**Config** (`.terraform-docs.yml`):
```yaml
formatter: markdown table

sections:
  show:
    - header
    - inputs
    - outputs
    - providers
    - requirements
    - resources

content: |-
  # {{.Header}}

  {{.Content}}

  ## Examples

  See [examples](./examples/) directory.
```

## Multi-Language Documentation

### Generate for Different Audiences

**Developer README** (`README.md`):
- Technical details
- All parameters
- Implementation notes

**User Guide** (`USAGE.md`):
- Simple examples
- Common scenarios
- Troubleshooting

**API Reference** (`API.md`):
- Complete parameter reference
- Type specifications
- Validation rules

