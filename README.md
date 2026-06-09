# PortvMind Terraform Templates

---

## About This Repository

This repository contains Terraform templates for common PortvMind infrastructure scenarios:

- **Basic templates**: core compute and network components
- **Complex architecture examples**: scenarios such as WordPress and database instances in the same network, separated by subnets, with security group rules controlling traffic
- **High-availability web infrastructure**: a multi-tier setup with a load balancer distributing traffic to web servers across isolated subnets, secured by strict cross-subnet security group rules
- **Secure Kubernetes provisioning**: a Terraform-managed VKE environment with dynamic security group rules, bastion-isolated API access, and load balancer support for distributed microservices

> **Detailed, step-by-step guides live inside each template folder.**

Choose the appropriate language guide for each template, and use the template-specific README for deployment steps.
