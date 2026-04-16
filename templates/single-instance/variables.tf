variable "vmind_user" {
  type = string
}

variable "vmind_pass" {
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
