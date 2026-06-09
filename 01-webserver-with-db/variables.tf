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
variable "ubuntu_image_id" {
  type        = string
  description = "Ubuntu OS Image ID"
}

variable "standard_flavor_id" {
  type        = string
  description = "VM spec flavor ID"
}
variable "external_network_id" {
  type        = string
  description = "External (Public) Network UUID on vMind"
  sensitive = true
}

variable "vmind_tenant_id" {
  type        = string
  description = "vMind Project (Tenant) ID"
  sensitive = true
}
