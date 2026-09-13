# terraform-validator: Tools and reporting

Read this reference when working on the topics below. Commands run from the skill directory.

- [Validation Tools Integration](#validation-tools-integration)
- [Script Integration](#script-integration)
- [Output Format](#output-format)
- [Integration with CI/CD](#integration-with-cicd)

## Validation Tools Integration

### TFLint

Use TFLint for advanced linting:

```bash
tflint --init
tflint
```

Common rules:
- `terraform_deprecated_syntax`
- `terraform_unused_declarations`
- `terraform_naming_convention`
- `terraform_documented_variables`
- `terraform_documented_outputs`

### Checkov

Use Checkov for security scanning:

```bash
checkov -d .
```

Scans for:
- Security misconfigurations
- Compliance violations
- Best practice deviations

### Terraform Compliance

Policy-as-code validation:

```bash
terraform-compliance -f compliance/ -p plan.json
```

### tfsec

Security scanner for Terraform:

```bash
tfsec .
```

## Script Integration

If `scripts/validate.js` exists, use it:

```bash
node scripts/validate.js --path ./terraform --level security
```

Levels:
- `syntax`: Basic syntax validation
- `format`: Format checking
- `best-practices`: Best practice validation
- `security`: Security scanning
- `compliance`: Compliance checking

## Output Format

Provide validation results in this format:

```
Validation Report
=================

Status: PASSED / FAILED / WARNING

Syntax Errors: {count}
{list of errors}

Best Practice Issues: {count}
{list of issues with severity}

Security Issues: {count}
{list of security issues with severity}

Compliance Issues: {count}
{list of compliance violations}

Recommendations:
1. {recommendation}
2. {recommendation}
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Terraform Validation

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
```

