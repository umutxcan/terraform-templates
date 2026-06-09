# Template Guide (EN) — 02-loadBalancer-webserver-db

## Overview
This document explains how to use the **02-loadBalancer-webserver-db** template, which deploys a multi-tier architecture with **Load Balancer (Octavia)**, **bastion**, **web server**, and **database** tiers.

This template is particularly suitable for:

- Running multiple web servers behind a Load Balancer
- Isolating application and database tiers on separate subnets
- Securing access through a bastion host

---

## Prerequisites

| Requirement | Description |
|------------|-------------|
| PortvMind Account | An active PortvMind account |
| Terraform | Terraform CLI must be installed |
| Provider Access | PortvMind username, password, and project information |
| Local CLI | An environment where you can run Terraform commands |

---

## Terraform Installation

### Ubuntu / Debian
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform version
```

### macOS (Homebrew)
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### Windows (PowerShell + Chocolatey)
```powershell
choco install terraform -y
terraform version
```

---

## Architecture

- **Public Subnet (10.0.1.0/24)**: Bastion + Load Balancer VIP
- **App Subnet (10.0.2.0/24)**: Web servers
- **Data Subnet (10.0.3.0/24)**: Database
- **Router**: Public egress and subnet routing

---

## Contents

### `02-loadBalancer-webserver-db`

#### Files

- `providers.tf`
  Terraform and OpenStack provider settings.
- `variables.tf`
  Input variable definitions.
- `network.tf`
  Network, subnet, and router configuration.
- `security.tf`
  Security Group access rules.
- `keypair.tf`
  Key pair definitions for server access.
- `compute.tf`
  Bastion, web, and DB instance definitions.
- `loadbalancer.tf`
  Octavia LB, listener, pool, health monitor, and members.

---

## PortvMind Credentials and Variables

In this project, provider access values are stored in a `terraform.tfvars` file.

> **Note:** The `terraform.tfvars` file does not come with the repository by default.
> After cloning the repository, **create it with your own values and do not commit it.**
> Required resource IDs are documented in the `resources` folder.

Example `terraform.tfvars`:

```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
```

### Important Notes

- **Do not commit** the `terraform.tfvars` file to the repository.
- Use secret management for sensitive fields (such as `portvmind_password`).
- Make sure `*.tfvars` is included in `.gitignore`.

---

## Usage

```bash
cd 02-loadBalancer-webserver-db
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Load Balancer Notes

- The LB health check runs as **HTTP** and reaches backends via the **app subnet** (10.0.2.x).
- The web security group must allow **80/tcp from the app subnet CIDR**.
- Having the VIP in the public subnet does not mean backend traffic comes from the public subnet.

---

## Destroy Warning (Important)

> **`terraform destroy` is a powerful command.**
> It permanently deletes all resources and cannot be undone.
> If you need to recreate resources because of quota limitations, run `terraform destroy` before applying again.
> Make sure you are certain before using it, and if possible, check with `terraform plan` first.

To delete resources:

```bash
terraform destroy -var-file="terraform.tfvars"
```
