variable "vmind_user" {
  type        = string
}

variable "vmind_pass" {
  type        = string
  sensitive   = true 
}

variable "vmind_tenant_id" {
  type        = string
}

variable "cluster_name" {
  type        = string
  default     = "dev-vke-cluster"
}

variable "standard_flavor_id" {
  type        = string
  description = "VM spec flavor ID"
}

variable "master_flavor_id" {
  type        = string
  description = "VM spec flavor ID"
}




variable "external_network_id" {
  type        = string
  description = "External (Public) Network UUID on vMind"
  sensitive   = true
}

variable "project_id" {
  type       = string
  sensitive  = true

}

variable "allowed_ips" {
  description = "Allowed IP ranges (e.g., VPN networks)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # User will override this with their own IP in terraform.tfvars
}