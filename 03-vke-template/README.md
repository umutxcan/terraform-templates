# Template Guide (EN) — 03-vke-template

## Overview
This document explains the steps for the **03-vke-template** template, which provisions a Kubernetes cluster on PortvMind **VKE (Kubernetes)**.

This template is especially useful when you want to:

- Create a Kubernetes cluster quickly on VKE
- Do an end-to-end setup together with OpenStack networking components (network/subnet/router)
- Restrict public Cluster API access using a controlled **CIDR allowlist**

---

## Files / What’s inside

- `providers.tf`
  - `vmindtech/portvmind` provider (VKE API)
  - `terraform-provider-openstack/openstack` provider (network components)

- `network.tf`
  - Private network + subnet for VKE
  - Router and interface for NAT outbound access via the public network

- `main.tf`
  - Generate an SSH key using TLS provider
  - Register the key as an OpenStack keypair
  - Create a local `.pem` file
  - Create the Kubernetes cluster using `portvmind_vke_cluster`

- `variables.tf`
  - All required input variables
  - Default for `allowed_ips` (CIDR list) is `0.0.0.0/0`

---

## Prerequisites

| Requirement | Description |
|------------|-------------|
| PortvMind Account | An active vMind account |
| Terraform | Terraform CLI must be installed |
| Provider Access | vMind user / password / tenant / project information |
| Network IDs | External public network UUID and flavor UUIDs |

---

## Important Security Note (allowed_ips)

In this template, the cluster API access is set to `public` (`cluster_api_access = "public"`).

Therefore, it’s strongly recommended to narrow down the `allowed_ips` variable to **your own IP/CIDR ranges**.

> Since the default is `0.0.0.0/0`, if you don’t override it, the cluster API will be exposed publicly.

### (Optional) Auto-fetch your public IP for local testing
The following blocks in `main.tf` are intended for **local testing**:

- Uncomment the `data "http" "my_ip"` block
- Add `${chomp(data.http.my_ip.response_body)}/32` into the `allowed_cidrs` list

---

## terraform.tfvars example

> **Note:** `terraform.tfvars` is not included in the repository by default. After cloning, create it with your own values and **do not commit it**.

You can save the following as `terraform.tfvars`:

```hcl
vmind_user      = "YOUR_USER"
vmind_pass      = "YOUR_PASSWORD"
vmind_tenant_id = "YOUR_TENANT_ID"
project_id      = "YOUR_PROJECT_ID"

# Flavor UUIDs
master_flavor_id   = "YOUR_MASTER_FLAVOR_UUID"
standard_flavor_id = "YOUR_WORKER_FLAVOR_UUID"

# External/Public Network UUID
external_network_id = "YOUR_EXTERNAL_NETWORK_UUID"

# IMPORTANT: Allowed CIDR ranges for Cluster API access
# Example block range (VPN / office / static IP):
allowed_ips = [
  "203.0.113.10/32",
  "198.51.100.0/24",
]

# If you want to leave it empty (not recommended), example:
# allowed_ips = [
#
# ]
```

---

## Usage

```bash
cd 03-vke-template
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Outputs

- `cluster_id` — created cluster ID
- `cluster_status` — current cluster status
- `cluster_kubeconfig` — **sensitive** kubeconfig output

---

## Destroy Warning (Important)

> **`terraform destroy` is a powerful command.** It permanently deletes all resources and cannot be undone.

To delete resources:

```bash
terraform destroy -var-file="terraform.tfvars"
```
