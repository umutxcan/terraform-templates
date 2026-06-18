# PortvMind Terraform Resource ID Reference

## Overview

This file collects the resource IDs used by the Terraform templates in this repository.

Use this guide when you need values for:

- `external_network_id`
- `ubuntu_image_id`
- `standard_flavor_id`
- `master_flavor_id`

These values are usually placed inside a `terraform.tfvars` file in the template folder you want to run.

> **Important:** Resource IDs can differ by region, project, or cloud environment. Confirm that these IDs are valid for your PortvMind project before running `terraform apply`.

---

## Stage 1: Pick the Template You Want to Use

Each template needs slightly different values.

| Template | Required IDs |
| --- | --- |
| `00-single-instance` | `ubuntu_image_id`, `standard_flavor_id`, `external_network_id`, `project_id` |
| `01-webserver-with-db` | `ubuntu_image_id`, `standard_flavor_id`, `external_network_id`, `project_id` |
| `02-loadBalancer-webserver-db` | `ubuntu_image_id`, `standard_flavor_id`, `external_network_id`, `project_id` |
| `03-vke-template` | `master_flavor_id`, `standard_flavor_id`, `external_network_id`, `project_id` |

---

## Stage 2: Use the External Network ID

The external network is used for public access, Floating IPs, and outbound connectivity through routers.

```hcl
external_network_id = "a35a0723-9600-4473-b29b-222b50e0fe10"
```

| Name | ID |
| --- | --- |
| External Network | `a35a0723-9600-4473-b29b-222b50e0fe10` |

---

## Stage 3: Choose an Image ID

Use an image ID for templates that create compute instances.

For the current examples, Ubuntu is usually the expected operating system because the SSH examples use the `ubuntu` user and some templates install packages with `apt`.

Recommended default for these templates:

```hcl
ubuntu_image_id = "d4086da9-366a-4482-a93c-d18e065fcd8b"
```

| Image Name | Image ID |
| --- | --- |
| Ubuntu Server 24.04 | `d4086da9-366a-4482-a93c-d18e065fcd8b` |
| Debian 13.1.0 | `7742e04a-0ada-43f7-9daa-b18aaca523fc` |
| Debian 10.13 | `6d0b3a9d-ba5f-49e3-b58c-3002cf93584c` |
| Rocky 9.5 | `fa54d786-00ee-4f79-996c-9d5c8eb77df5` |
| Rocky 8.10 | `dd02e569-a098-4ec3-aced-683100f3d4ab` |
| Centos Stream 10 | `33b1d2ec-9a75-4640-9a11-f093e2dd2058` |
| Pardus Server 21.05 | `ccc46dba-36d0-45c3-a42a-f52f9f7d2e0f` |
| Windows Server 2025 | `9ab5ea8e-a946-4456-a868-ec16fe603755` |
| Windows Server 2022 | `849e6226-418f-46f0-95f2-901c91ca3f97` |
| Windows Server 2019 | `39dc7903-e39b-4808-a521-547d7bd1db84` |

---

## Stage 4: Choose a Flavor ID

Use a flavor ID to define the CPU/RAM size of compute instances or VKE nodes.

For simple testing, start with a smaller general-purpose flavor. For production-like workloads, choose a larger flavor based on your workload needs.

Example:

```hcl
standard_flavor_id = "73dee111-ff30-4837-b3c1-9284c422485e"
```

| Flavor Name | Flavor ID |
| --- | --- |
| g1.nano | `5afc50cd-3f80-47c5-8596-bb303dfa5e17` |
| g1.micro | `4d3c3930-42c7-48f4-ac0b-01c624c4d3a6` |
| g1.small | `73dee111-ff30-4837-b3c1-9284c422485e` |
| g1.medium | `fd9ee6ed-a56d-483e-98c9-1a05d634ffcb` |
| g1.large | `d3072fd4-9a17-4d03-9f86-149c84bf8006` |
| g1.xlarge | `27214b9a-5f54-43e6-9d2c-aba341a7d41a` |
| g1.2xlarge | `90f729ed-7dee-43bc-9c42-ed8f8baaf06d` |
| g1.4xlarge | `f1cbc38a-1bb0-424c-9c49-f2edd3766042` |
| m1.large | `9236d7c3-1247-4ebb-9d9e-57f3c6a9db0c` |
| m1.xlarge | `473854dc-3e9d-42e8-a0d2-758dcb98e4e9` |
| m1.2xlarge | `25483aa9-972c-43f4-b7bb-85744cbe2152` |
| m1.4xlarge | `afad1d49-746d-4237-9827-488b44a1c1cb` |
| m1.8xlarge | `2db059da-36c8-461d-80b2-a258b3acae67` |
| m1.12xlarge | `e4cbbdf4-d139-46f8-9ca2-d2f465f71674` |
| gpu.t4s.xlarge | `a5bb79dc-3453-493d-8e85-3092c3316f24` |
| gpu.t4s.2xlarge | `5138c6bf-9b23-4b0d-811d-fe4ae0ad040f` |
| gpu.t4m.xlarge | `a29c3a9a-34ee-4a53-9fad-25ff016e479f` |
| gpu.t4m.2xlarge | `82625601-a21e-4bfc-956d-151db2d4a750` |

---

## Stage 5: Copy the Values into terraform.tfvars

### For `00-single-instance`, `01-webserver-with-db`, and `02-loadBalancer-webserver-db`

Username/password authentication:

```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"

ubuntu_image_id     = "d4086da9-366a-4482-a93c-d18e065fcd8b"
standard_flavor_id  = "73dee111-ff30-4837-b3c1-9284c422485e"
external_network_id = "a35a0723-9600-4473-b29b-222b50e0fe10"
```

Application credential authentication:

```hcl
portvmind_application_credential_id     = "YOUR_APPLICATION_CREDENTIAL_ID"
portvmind_application_credential_secret = "YOUR_APPLICATION_CREDENTIAL_SECRET"
project_id                              = "YOUR_PROJECT_ID"

ubuntu_image_id     = "d4086da9-366a-4482-a93c-d18e065fcd8b"
standard_flavor_id  = "73dee111-ff30-4837-b3c1-9284c422485e"
external_network_id = "a35a0723-9600-4473-b29b-222b50e0fe10"
```

Use exactly one authentication method for these templates.

> **Application credential note:** For `00-single-instance`, `01-webserver-with-db`, and `02-loadBalancer-webserver-db`, select the roles required by the template. The **Allow creating other application credentials with this credential** checkbox is not required for these templates; enable it only if your own workflow needs it.

### For `03-vke-template`

Username/password authentication:

```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"

master_flavor_id    = "73dee111-ff30-4837-b3c1-9284c422485e"
standard_flavor_id  = "73dee111-ff30-4837-b3c1-9284c422485e"
external_network_id = "a35a0723-9600-4473-b29b-222b50e0fe10"

allowed_ips = [
  "YOUR_PUBLIC_IP/32"
]
```

Application credential authentication:

```hcl
portvmind_application_credential_id     = "YOUR_APPLICATION_CREDENTIAL_ID"
portvmind_application_credential_secret = "YOUR_APPLICATION_CREDENTIAL_SECRET"
project_id                              = "YOUR_PROJECT_ID"

master_flavor_id    = "73dee111-ff30-4837-b3c1-9284c422485e"
standard_flavor_id  = "73dee111-ff30-4837-b3c1-9284c422485e"
external_network_id = "a35a0723-9600-4473-b29b-222b50e0fe10"

allowed_ips = [
  "YOUR_PUBLIC_IP/32"
]
```

Use exactly one authentication method for `03-vke-template`.

> **Application credential note:** For `03-vke-template`, select the roles required by this template, such as `member`, `creator`, and `load-balancer_admin`. The **Allow creating other application credentials with this credential** checkbox is required so VKE cluster creation can complete.

> **Security note:** Do not commit `terraform.tfvars` files. They can contain passwords, application credential secrets, project IDs, network IDs, and other sensitive values.

---

## Stage 6: Quick Lookup

| Need | Use This Variable | Example Value |
| --- | --- | --- |
| Public network / Floating IP network | `external_network_id` | `a35a0723-9600-4473-b29b-222b50e0fe10` |
| Ubuntu compute image | `ubuntu_image_id` | `d4086da9-366a-4482-a93c-d18e065fcd8b` |
| General-purpose instance size | `standard_flavor_id` | `73dee111-ff30-4837-b3c1-9284c422485e` |
| VKE master node size | `master_flavor_id` | `73dee111-ff30-4837-b3c1-9284c422485e` |
| VKE API access allowlist | `allowed_ips` | `YOUR_PUBLIC_IP/32` |

---

## Original Source Files

This combined reference was created from:

- `resources/ExternalNetworkId.md`
- `resources/FlavorId.md`
- `resources/ImageId.md`

