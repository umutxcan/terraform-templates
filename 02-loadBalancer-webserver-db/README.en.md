# PortvMind Terraform - 02 Load Balancer Webserver DB Setup Guide

## Overview

This document explains the steps for creating a multi-tier architecture on PortvMind with **Load Balancer (Octavia)**, **bastion**, **web servers**, and **database** tiers by using Terraform.

The `02-loadBalancer-webserver-db` template creates the following resources. You can access the repository from the PortvMind GitHub link in the Additional Resources section:

- Main network
- Public subnet
- App subnet
- Data subnet
- Router
- Bastion instance
- Web server instances
- Database instance
- Load Balancer, listener, pool, health monitor, and pool member resources
- Floating IP for the bastion and Load Balancer
- Security group rules
- Key pair

This template is especially suitable for:

- Running multiple web servers behind a Load Balancer
- Isolating the application and database tiers in separate subnets
- Securing access through a bastion host

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
| `network.tf` | Network, public subnet, app subnet, data subnet, and router configuration |
| `security.tf` | Bastion, Load Balancer, web, and DB security group rules |
| `keypair.tf` | Key pair definitions for server access |
| `compute.tf` | Bastion, web, and DB instance definitions |
| `loadbalancer.tf` | Octavia Load Balancer, listener, pool, health monitor, and member resources |

---

## Architecture Note

- **Public Subnet (10.0.1.0/24):** Used for the bastion and Load Balancer VIP.
- **App Subnet (10.0.2.0/24):** Web servers run in this subnet.
- **Data Subnet (10.0.3.0/24):** The database instance runs in this subnet.
- **Router:** Provides public egress and routing between subnets.
- The Load Balancer distributes HTTP traffic to the web servers.
- The database tier is not exposed to direct public access.

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

> **Resource ID reference:** If you need image, flavor, or external network ID values, see the combined resource guide: [`RESOURCES.md`](../RESOURCES.md).

Example `terraform.tfvars`:
```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
```

Variable descriptions:

| Variable | Description |
| --- | --- |
| `portvmind_username` | Your PortvMind username |
| `portvmind_password` | Your PortvMind user password |
| `project_id` | The project ID value where the resources will be created |
| `ubuntu_image_id` | The Ubuntu image ID value to use |
| `standard_flavor_id` | The flavor ID value to use for the instances |
| `external_network_id` | The external network ID value for floating IP and external access |
| `web_instance_count` | Number of Load Balancer pool members; default is `2` |
| `bastion_volume_size` | Bastion disk size; default is `20` |
| `web_volume_size` | Web server disk size; default is `20` |
| `db_volume_size` | Database disk size; default is `40` |

> **Security note:** Do not share sensitive fields such as `portvmind_password` in a public repository. Make sure the `terraform.tfvars` file is included in `.gitignore`.

---

## Setup Steps

### 1. Go to the Template Directory
```bash
cd 02-loadBalancer-webserver-db
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

In the `terraform plan` output, check the network, subnets, router, security group rules, bastion, web servers, database instance, Load Balancer, and Floating IP resources.

### 5. Create the Resources
```bash
terraform apply -var-file="terraform.tfvars"
```

When the command asks for confirmation, review the plan again and type `yes` if it is correct.

---

## Expected Result

When the setup is complete, the following resources should have been created on PortvMind:

- Main network
- Public, app, and data subnets
- A router attached to the external network
- A bastion instance in the public subnet
- Web servers in the app subnet
- A database instance in the data subnet
- A Load Balancer with HTTP listener, pool, health monitor, and pool members
- Floating IPs for the Load Balancer and bastion
- Security group rules for the bastion, Load Balancer, web, and DB tiers
- A `.pem` key file for SSH connection

---

## Load Balancer Notes

- The Load Balancer health check runs as **HTTP**.
- Backend web servers are reached through the **app subnet**.
- The web security group must allow **80/tcp from the app subnet CIDR**.
- Having the VIP IP in the public subnet does not mean backend traffic comes from the public subnet.
- Web servers are started with Nginx and can be tested over HTTP.

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

You can use SSH Agent to make jumping from the bastion to the web and DB tiers easier.

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

---

## Jump to Internal Servers via Bastion

### 1. Connect to the Bastion
```bash
ssh ubuntu@<BASTION_PUBLIC_IP>
```

If you are not using SSH Agent:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<BASTION_PUBLIC_IP>
```

### 2. Jump to a Web or DB Instance from Inside the Bastion
```bash
ssh -A ubuntu@<WEB_PRIVATE_IP>
ssh -A ubuntu@<DB_PRIVATE_IP>
```

> **Note:** The same key is used for web and DB jumps. Replace `<KEY_NAME>.pem` with your actual key file name.

---

## Possible Issues

### Load Balancer cannot reach backend servers

Checklist:

- Are the web servers running in the app subnet?
- Does the web security group include the required 80/tcp rules?
- Is the health monitor URL path set to `/`?
- Is Nginx running on the web servers?

### Bastion connection cannot be established

Checklist:

- Is the Floating IP attached to the bastion instance?
- Is the SSH port open in the bastion security group?
- Are you using the correct `.pem` file?
- Are the key permissions set correctly?

### terraform.tfvars cannot be found

Make sure you created the `terraform.tfvars` file inside the `02-loadBalancer-webserver-db` directory.
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

- Resource ID Reference: [`RESOURCES.md`](../RESOURCES.md)
- Terraform Documentation: https://developer.hashicorp.com/terraform/docs
- OpenStack Provider Documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- PortvMind GitHub Terraform Examples: https://github.com/vmindtech/portvmind-public-cloud-terraform-examples
