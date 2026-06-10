# PortvMind Terraform - 03 VKE Template Setup Guide

## Overview

This document explains the steps for creating a Kubernetes cluster on the PortvMind **VKE** service by using Terraform.

The `03-vke-template` template creates the following resources. You can access the repository from the PortvMind GitHub link in the Additional Resources section:

- VKE private network
- VKE subnet
- Router and router interface
- SSH key pair
- Local `.pem` key file
- PortvMind VKE Kubernetes cluster
- Worker node group configuration
- Cluster outputs

This template is especially suitable for:

- Creating a Kubernetes cluster quickly on VKE
- Running an end-to-end setup with OpenStack networking components
- Restricting cluster API access with a controlled **CIDR allowlist**

---

## Prerequisites

| Requirement | Description |
| --- | --- |
| PortvMind Account | An active PortvMind account |
| Terraform | Terraform CLI must be installed |
| Provider Access | PortvMind username, password, and project information must be ready |
| Resource ID Information | External public network UUID and flavor UUID values must be ready |
| Local CLI | A terminal where you can run Terraform commands |

---

## Template Contents

| File | Description |
| --- | --- |
| `providers.tf` | `vmindtech/portvmind` and OpenStack provider settings |
| `variables.tf` | Required input variables and the `allowed_ips` definition |
| `network.tf` | Private network, subnet, router, and router interface configuration for VKE |
| `main.tf` | SSH key generation, keypair registration, `.pem` file, and VKE cluster creation |

---

## Architecture Note

- The VKE cluster is created on a private network and subnet created by Terraform.
- The router provides outbound connectivity for the cluster network.
- The `portvmind_vke_cluster` resource creates the Kubernetes cluster.
- Cluster API access is configured as `public`.
- API access should be restricted to allowed CIDR ranges with the `allowed_ips` variable.
- The `cluster_kubeconfig` output is sensitive and must be stored securely.

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

## Important Security Note (`allowed_ips`)

In this template, cluster API access is opened as `public`:

```hcl
cluster_api_access = "public"
```

Because cluster API access is public, it is strongly recommended to narrow the `allowed_ips` variable to **your own IP/CIDR ranges**.

> **Important:** Since the default value is `0.0.0.0/0`, if you do not override it, the cluster API will be open to everyone.

### Optional: Fetch Public IP for Local Testing

In `main.tf`, example blocks are available as comments for local testing:

- Uncomment the `data "http" "my_ip"` block.
- Add `${chomp(data.http.my_ip.response_body)}/32` to the `allowed_cidrs` list.

---

## PortvMind Credentials and Variables

In this project, the required values for provider access and cluster configuration are stored in the `terraform.tfvars` file.

> **Important:** The `terraform.tfvars` file does not come with the repository by default. After cloning the repository, create it with your own values and do not commit it.

Example `terraform.tfvars`:
```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"

# Flavor UUIDs
master_flavor_id    = "YOUR_MASTER_FLAVOR_UUID"
standard_flavor_id  = "YOUR_WORKER_FLAVOR_UUID"

# External/Public Network UUID
external_network_id = "YOUR_EXTERNAL_NETWORK_UUID"

# Allowed CIDR ranges for Cluster API access
allowed_ips = [
  "203.0.113.10/32",
  "198.51.100.0/24",
]
```

Variable descriptions:

| Variable | Description |
| --- | --- |
| `portvmind_username` | Your PortvMind username |
| `portvmind_password` | Your PortvMind user password |
| `project_id` | The project ID value where the resources will be created |
| `cluster_name` | Name of the VKE cluster to create; default is `dev-vke-cluster` |
| `master_flavor_id` | Flavor UUID value for the master node |
| `standard_flavor_id` | Flavor UUID value for worker nodes |
| `external_network_id` | External/public network UUID value |
| `allowed_ips` | CIDR list allowed to access the cluster API |

> **Security note:** Do not share sensitive information such as `portvmind_password`, `project_id`, `external_network_id`, or kubeconfig in a public repository.

---

## Setup Steps

### 1. Go to the Template Directory
```bash
cd 03-vke-template
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

In the `terraform plan` output, check the network, subnet, router, keypair, and VKE cluster resources. Pay special attention to whether the `allowed_ips` values are correct.

### 5. Create the Resources
```bash
terraform apply -var-file="terraform.tfvars"
```

When the command asks for confirmation, review the plan again and type `yes` if it is correct.

---

## Expected Result

When the setup is complete, the following resources should have been created on PortvMind:

- VKE private network
- VKE subnet with `10.0.0.0/24` CIDR
- A router attached to the external network
- Router interface
- VKE cluster SSH key pair
- Local `vke-cluster-key.pem` file
- Kubernetes VKE cluster
- Worker node group that can scale between 1 and 2 worker nodes

---

## Outputs

After Terraform apply is complete, the following outputs are available:

| Output | Description |
| --- | --- |
| `cluster_id` | Created cluster ID value |
| `cluster_status` | Cluster status |
| `cluster_kubeconfig` | **Sensitive** kubeconfig output |

> **Note:** `cluster_kubeconfig` is a sensitive output. Store it securely and do not share it publicly.

---

## Possible Issues

### Cluster API appears open to everyone

Checklist:

- Did you override `allowed_ips` with your own IP/CIDR ranges?
- Are you sure `allowed_ips = ["0.0.0.0/0"]` was not left in `terraform.tfvars`?
- Are your VPN, office, or static IP CIDR ranges correct?

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

### terraform.tfvars cannot be found

Make sure you created the `terraform.tfvars` file inside the `03-vke-template` directory.
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
