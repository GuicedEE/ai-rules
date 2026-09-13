# terraform-doc-generator: Templates

Read this reference when working on the topics below. Commands run from the skill directory.

- [README.md Structure](#readmemd-structure)
- [Documentation Templates](#documentation-templates)

## README.md Structure

### Standard Module README

````markdown
# Terraform Module: {module-name}

{Brief description of what this module does}

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

### Basic Example

```hcl
module "{module_name}" {
  source = "{source_path}"

  {required_variables}
}
```

### Advanced Example

```hcl
module "{module_name}" {
  source = "{source_path}"

  {all_variables_with_examples}
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= {version} |
| {provider} | >= {version} |

## Providers

| Name | Version |
|------|---------|
| {provider} | >= {version} |

## Resources

| Name | Type |
|------|------|
| {resource} | resource |
| {data_source} | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| {variable} | {description} | {type} | {default} | yes/no |

## Outputs

| Name | Description |
|------|-------------|
| {output} | {description} |

## Examples

- [Basic](./examples/basic) - Basic usage
- [Advanced](./examples/advanced) - Advanced features

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

{license_type}

## Authors

{author_information}
````

## Documentation Templates

### Template: Azure Module

````markdown
# Azure {Resource} Module

Terraform module for managing Azure {Resource}.

## Features

- Creates and manages Azure {Resource}
- Supports {feature 1}
- Includes {feature 2}
- Configurable {feature 3}

## Usage

```hcl
module "{resource}" {
  source = "path/to/module"

  name                = "my-{resource}"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Production"
  }
}
```

## Azure Permissions Required

- Microsoft.{Service}/{Resource}/read
- Microsoft.{Service}/{Resource}/write

## Pricing

This module creates billable resources. See [Azure Pricing](https://azure.microsoft.com/pricing/).
````

### Template: AWS Module

````markdown
# AWS {Resource} Module

Terraform module for {resource description}.

## Features

- Creates {resource}
- Supports {feature}
- Includes {security feature}

## Usage

```hcl
module "{resource}" {
  source = "path/to/module"

  name   = "my-{resource}"
  region = "us-east-1"

  tags = {
    Environment = "Production"
  }
}
```

## IAM Permissions Required

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "{service}:{action}",
        "{service}:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```
````

