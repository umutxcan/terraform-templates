# --- AUTHENTICATION & PROJECT ---

variable "portvmind_username" {
  type = string
}

variable "portvmind_password" {
  type      = string
  sensitive = true
}

variable "vmind_region" {
  type    = string
  default = "tr-ist-01"
}

variable "vmind_tenant_id" {
  type        = string
  description = "vMind Project (Tenant) ID"
  sensitive   = true
}

# --- IMAGE & FLAVOR ---

variable "ubuntu_image_id" {
  type        = string
  description = "Ubuntu OS Image ID"
}

variable "standard_flavor_id" {
  type        = string
  description = "VM spec flavor ID"
}

# --- NETWORKING ---

variable "external_network_id" {
  type        = string
  description = "External (Public) Network UUID on vMind"
  sensitive   = true
}

# --- SCALABILITY ---

variable "web_instance_count" {
  type        = number
  default     = 2
  description = "Number of web servers to deploy behind the Load Balancer"
}

# --- DISK SIZE (VOLUMES) ---

variable "bastion_volume_size" {
  type    = number
  default = 20
}

variable "web_volume_size" {
  type    = number
  default = 20
}

variable "db_volume_size" {
  type    = number
  default = 40
}
