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
