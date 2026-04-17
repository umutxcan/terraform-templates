# Terraform Templates

A practical collection of Terraform templates ranging from basic infrastructure building blocks to more complete architecture examples.

## Overview

This repository includes Infrastructure as Code (IaC) templates written in **HCL** with **Terraform**.  
It is designed to provide:

- **Basic templates** for core infrastructure components (compute + network)
- **More complex architecture examples** (such as WordPress and database instances in the same VPC/network with different subnets and Security Group rules)

The goal is to keep templates easy to understand while still covering real-world deployment patterns.

## What’s Included

### 1) Basic Templates
Simple templates focused on foundational resources, such as:

- Compute instances
- Networking components (VPC, subnets, routing, etc.)

These are intended for quick starts, learning, and reusable baseline setups.

### 2) Complex Architecture Templates
More advanced scenarios that combine multiple components, such as:

- WordPress application instances
- Database instances
- Same network/VPC design
- Segmented subnet layout (application and database tiers separated)
- Security Group (SG) rules to control inter-service traffic

These templates are useful for demonstrating multi-tier infrastructure patterns.

## Repository Structure

```text
.
├── templates/              # Terraform templates (basic and complex)
├── modules/                # Optional reusable modules
└── README.md
```

> Adjust folder names based on your current repository layout.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (latest stable recommended)
- Configured cloud credentials (AWS / Azure / GCP, depending on template)
- Optional remote backend for Terraform state

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/umutxcan/terraform-templates.git
   cd terraform-templates
   ```

2. Select the template you want to deploy (basic or complex).

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Validate:
   ```bash
   terraform validate
   ```

5. Plan:
   ```bash
   terraform plan
   ```

6. Apply:
   ```bash
   terraform apply
   ```

## Best Practices

- Keep infrastructure modular and readable
- Pin provider/module versions where needed
- Use least-privilege Security Group rules
- Do not hardcode secrets; use variables or secret managers
- Run `terraform fmt` and `terraform validate` before committing

## Contributing

Contributions are welcome via pull requests.

## License

Add your preferred license (e.g., MIT, Apache-2.0).
