# PortvMind Terraform - 00 Single Instance Setup Guide

## Overview

This document explains the steps for creating **a single compute instance** and the required **basic network components** on PortvMind by using Terraform.

The `00-single-instance` template creates the following resources. You can access the repository from the PortvMind GitHub link in the Additional Resources section:

- Network
- Subnet
- Router
- Security group
- Key pair
- Compute instance
- Floating IP

This template is especially suitable for:

- Getting started with Terraform
- Setting up a quick test environment
- Simple network + single compute needs

---

## Prerequisites

| Requirement | Description |
| --- | --- |
| PortvMind Account | An active PortvMind account |
| Terraform | Terraform CLI must be installed |
| Provider Access | PortvMind username, password, and project information must be ready |
| Resource ID Information | Image, flavor, external network, and project ID information must be ready |
| Local CLI | A terminal where you can run Terraform commands |

---

## Template Contents

| File | Description |
| --- | --- |
| `providers.tf` | Terraform and OpenStack provider settings |
| `variables.tf` | Input variable definitions |
| `network.tf` | Network, subnet, and router configuration |
| `security.tf` | Security group access rules |
| `keypair.tf` | Key pair definitions for server access |
| `compute.tf` | Compute instance and floating IP association |
| `.gitignore` | Prevents Terraform state and tfvars files from being included in git |

---

## Terraform Installation

If Terraform is not installed, you can use the following steps according to your operating system.

### Ubuntu / Debian
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform version
```

### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### Windows
```powershell
choco install terraform -y
terraform version
```

---

## PortvMind Credentials and Variables

In this project, the required values for provider access are stored in the `terraform.tfvars` file.

> **Important:** The `terraform.tfvars` file does not come with the repository by default. After cloning the repository, create it with your own values and do not commit it.

Example `terraform.tfvars`:
```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
project_id          = "YOUR_PROJECT_ID"
```

Variable descriptions:

| Variable | Description |
| --- | --- |
| `portvmind_username` | Your PortvMind username |
| `portvmind_password` | Your PortvMind user password |
| `ubuntu_image_id` | The Ubuntu image ID value to use |
| `standard_flavor_id` | The flavor ID value to use for the instance |
| `external_network_id` | The external network ID value for floating IP and external access |
| `project_id` | The project ID value where the resources will be created |

> **Security note:** Do not share sensitive fields such as `portvmind_password` in a public repository. Make sure the `terraform.tfvars` file is included in `.gitignore`.

---

## Setup Steps

### 1. Go to the Template Directory
```bash
cd 00-single-instance
```

### 2. Initialize Terraform
```bash
terraform init
```

This command downloads the required provider files and prepares the Terraform working directory.

### 3. Validate the Configuration
```bash
terraform validate
```

This step checks whether there are basic syntax and configuration errors in the Terraform files.

### 4. Review the Resources to Be Created
```bash
terraform plan -var-file="terraform.tfvars"
```

In the `terraform plan` output, check the network, subnet, router, security group, key pair, compute instance, and floating IP resources that will be created.

### 5. Create the Resources
```bash
terraform apply -var-file="terraform.tfvars"
```

When the command asks for confirmation, review the plan again and type `yes` if it is correct.

---

## Expected Result

When the setup is complete, the following resources should have been created on PortvMind:

- A private network
- A subnet attached to this network
- A router attached to the external network
- A security group rule for SSH access
- A compute instance
- A floating IP attached to the instance
- A `.pem` key file for SSH connection

---

## Connect to the Server with SSH

If the template generates a `.pem` key, the file is created in the project directory. Replace the key file name according to your own environment.

### 1. Set Key Permissions

Linux / macOS:
```bash
chmod 600 <KEY_NAME>.pem
```

Windows PowerShell:
```powershell
icacls.exe <KEY_NAME>.pem /reset
icacls.exe <KEY_NAME>.pem /inheritance:r
icacls.exe <KEY_NAME>.pem /grant:r "$($env:username):(R)"
```

### 2. Use SSH Agent

By using SSH Agent, you can connect to the server without typing `-i key.pem` for every connection.

Linux / macOS:
```bash
eval "$(ssh-agent -s)"
ssh-add /path/to/<KEY_NAME>.pem
ssh-add -l
```

Windows PowerShell:
```powershell
Start-Service ssh-agent
ssh-add C:\path\to\<KEY_NAME>.pem
ssh-add -l
```

### 3. Connect with SSH
```bash
ssh ubuntu@<PUBLIC_IP>
```

If you are not using SSH Agent:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<PUBLIC_IP>
```

> **Note:** You can get the `<PUBLIC_IP>` value from Terraform outputs or from the PortvMind cloud console.

---

## Optional: Copy the Key File from the Server to Your Computer

Run this command in your own computer's terminal.
```bash
scp -i "<EXISTING_CONNECTION_KEY>.pem" "ubuntu@<SERVER_IP_ADDRESS>:/path/to/project/<NEW_KEY>.pem" "C:\Keys\"
```

Example:
```bash
scp -i "C:\Keys\example12345.pem" "ubuntu@192.168.100.X:/home/ubuntu/vmind-terraform-project/vmind-Example-key.pem" "C:\Key-Folder\"
```

---

## Possible Issues

### Terraform provider cannot be downloaded

Possible reasons:

- There is no internet connection.
- Terraform registry access is restricted.
- Proxy or firewall settings are blocking the provider download.

Solution:
```bash
terraform init
```

If the error continues, check your network/proxy settings.

### SSH connection cannot be established

Checklist:

- Is the floating IP attached to the instance?
- Is the SSH port open in the security group?
- Are you using the correct `.pem` file?
- Are the key permissions set correctly?
- Is the username correct? For Ubuntu images, `ubuntu` is usually used.

### terraform.tfvars cannot be found

Make sure you created the `terraform.tfvars` file inside the `00-single-instance` directory.
```bash
ls
```

If the file does not exist, create it again by using the example variables.

---

## Deleting Resources

> **Destroy Warning:** `terraform destroy` is a powerful command. It permanently deletes all resources and cannot be undone.
> If you need to recreate resources because of quota limitations, run `terraform destroy` before applying again.

To delete the resources:
```bash
terraform destroy -var-file="terraform.tfvars"
```

When the command asks for confirmation, carefully check the resources that will be deleted.

---

## Additional Resources

- Terraform Documentation: https://developer.hashicorp.com/terraform/docs
- OpenStack Provider Documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- PortvMind GitHub Terraform Examples: https://github.com/vmindtech/portvmind-public-cloud-terraform-examples
