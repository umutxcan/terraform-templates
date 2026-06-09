# Template Guide (EN) — 01-webserver-with-db

## Overview
This document explains how to use the **01-webserver-with-db** template, which provisions **web and database tiers** in the same network but in separate subnets.

This template is particularly suitable for:

- Setting up a multi-tier architecture example
- Testing scenarios like WordPress + DB
- Demonstrating subnet and security group segmentation

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

## Contents

### `webserver-with-db`
An architecture example where web and database instances run in the same network but in separate subnets.

#### Files

- `providers.tf`
  Terraform and OpenStack provider settings.
- `variables.tf`
  Input variable definitions.
- `network.tf`
  Network, subnet, and router configuration.
- `security.tf`
  Security group rules for the web and database tiers.
- `keypair.tf`
  Key pair definitions for server access.
- `compute.tf`
  Web and DB compute resources.
- `.gitignore`
  Prevents Terraform state and tfvars files from being included in git.

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
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
project_id          = "YOUR_PROJECT_ID"
```

### Important Notes

- **Do not commit** the `terraform.tfvars` file to the repository.
- Use secret management for sensitive fields (such as `portvmind_password`).
- Make sure `*.tfvars` is included in `.gitignore`.
- Use your own project ID in `terraform.tfvars`.

---

## Usage

```bash
cd 01-webserver-with-db
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Server Access (SSH) and Key Management

> Note: If the template generates a `.pem` key, the file will be created in the project directory.
> (This may vary depending on the template.)

### 1) Set Key Permissions

**Linux / macOS:**
```bash
chmod 600 <KEY_NAME>.pem
```

**Windows (PowerShell):**
```powershell
# Restrict file permissions to the current user only
icacls.exe <KEY_NAME>.pem /reset
icacls.exe <KEY_NAME>.pem /inheritance:r
icacls.exe <KEY_NAME>.pem /grant:r "$($env:username):(R)"
```

### 2) SSH Agent (Recommended)

Using SSH Agent, you can connect without typing `-i key.pem` every time.
This is especially useful in **bastion-to-DB-tier jump** scenarios, as it speeds up the process.

**Linux / macOS**
```bash
eval "$(ssh-agent -s)"
ssh-add /path/to/<KEY_NAME>.pem
ssh-add -l
```

**Windows (PowerShell)**
```powershell
Start-Service ssh-agent
ssh-add C:\path\to\<KEY_NAME>.pem
ssh-add -l
```

### 3) (Optional) Copy the Key File from the Server to Your Machine

> Run this command **in your local machine's terminal (PowerShell/CMD)**.

```bash
scp -i "<EXISTING_CONNECTION_KEY>.pem" "ubuntu@<SERVER_IP_ADDRESS>:/path/to/project/<NEW_KEY>.pem" "C:\Keys\"
```

**Example:**
```bash
scp -i "C:\Keys\example12345.pem" "ubuntu@192.168.100.X:/home/ubuntu/vmind-terraform-project/vmind-Example-key.pem" "C:\Key-Files\"
```

### 4) Jumping to the DB Server via Bastion

1) First, connect to the bastion:
```bash
ssh ubuntu@<BASTION_PUBLIC_IP>
```

2) From inside the bastion, jump to the DB instance:
```bash
ssh -A ubuntu@<DB_PRIVATE_IP>
```

> If you are not using SSH Agent, connect to the bastion with:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<BASTION_PUBLIC_IP>
```

> The same key is used for the DB jump as well.

> Note: Replace `<KEY_NAME>.pem` with your actual key file name.

---

## Destroy Warning

> **`terraform destroy` is a powerful command.**
> It permanently deletes all resources and cannot be undone.
> If you need to recreate resources because of quota limitations, run `terraform destroy` before applying again.
> Make sure you are certain before using it, and if possible, check with `terraform plan` first.

To delete resources:

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## Architecture Note

- The web tier and DB tier run in **separate subnets**.
- Security group rules allow web-to-database access only over the required port.
- The DB tier is not exposed to direct public access (recommended approach).
