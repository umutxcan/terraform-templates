# Templates Guide (EN) — single-instance

## Overview
This document describes the steps for the *single-instance* template, which sets up **a single compute instance** and **basic network components** (VPC/Subnet/Route/SG).

This template is particularly suitable for:

- Getting started with Terraform
- Setting up a quick test environment
- Simple network + single compute needs

---

## Prerequisites

| Requirement | Description |
|------------|-------------|
| PortvMind Account | An active vMind account |
| Terraform | Terraform CLI must be installed |
| Provider Access | vMind user / tenant credentials must be ready |
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

### 4) Connect via SSH
```bash
ssh ubuntu@<PUBLIC_IP>
```

> If you are not using SSH Agent:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<PUBLIC_IP>
```

You can get the `<PUBLIC_IP>` value from the Terraform outputs or the cloud console.

> Note: Replace `<KEY_NAME>.pem` with your actual key file name.

---

## Contents

### `single-instance`
Prepared for setting up a single server (compute) and basic network components.

#### Files

- `providers.tf`  
  Terraform and OpenStack provider settings.
- `variables.tf`  
  Variable definitions received from outside.
- `network.tf`  
  Network components such as network / subnet / route.
- `security.tf`  
  Security Group access rules.
- `keypair.tf`  
  Key pair definitions for server access.
- `instance.tf`  
  Compute instance definitions.
- `.gitignore`  
  Prevents Terraform state and tfvars files from being included in git.

---

## VMind Credentials and Variables

In this project, values for provider access are stored in the `terraform.tfvars` file.

> **Note:** The `terraform.tfvars` file does not come with the repo by default.  
> After cloning the repo, **the user must create it with their own values**.

Example `terraform.tfvars`:

```hcl
vmind_user          = "YOUR_USER"
vmind_pass          = "YOUR_PASSWORD"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
vmind_tenant_id     = "YOUR_TENANT_ID"
```

### Important Notes

- **Do not commit** the `terraform.tfvars` file to the repo.
- Use secret management for sensitive fields (such as `vmind_pass`).
- Make sure `*.tfvars` is included in `.gitignore`.

---

## Usage

```bash
cd templates/single-instance
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Destroy Warning (Important)

> **`terraform destroy` is a powerful command.**  
> It permanently deletes all resources and cannot be undone.  
> Make sure you are certain before using it, and if possible, check with `terraform plan` first.

To delete resources:

```bash
terraform destroy -var-file="terraform.tfvars"
```
