# --- AUTHENTICATION & PROJECT ---

variable "portvmind_username" {
  type        = string
  default     = null
  description = "PortvMind username for password authentication. Leave null when using application credentials."
}

variable "portvmind_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "PortvMind password for password authentication. Leave null when using application credentials."

  validation {
    condition = (
      (
        var.portvmind_username != null && trimspace(var.portvmind_username) != "" &&
        var.portvmind_password != null && trimspace(var.portvmind_password) != "" &&
        (var.portvmind_application_credential_id == null || trimspace(var.portvmind_application_credential_id) == "") &&
        (var.portvmind_application_credential_secret == null || trimspace(var.portvmind_application_credential_secret) == "")
      ) ||
      (
        (var.portvmind_username == null || trimspace(var.portvmind_username) == "") &&
        (var.portvmind_password == null || trimspace(var.portvmind_password) == "") &&
        var.portvmind_application_credential_id != null && trimspace(var.portvmind_application_credential_id) != "" &&
        var.portvmind_application_credential_secret != null && trimspace(var.portvmind_application_credential_secret) != ""
      )
    )
    error_message = "Use exactly one authentication method: set portvmind_username and portvmind_password, or set portvmind_application_credential_id and portvmind_application_credential_secret."
  }
}

variable "portvmind_application_credential_id" {
  type        = string
  default     = null
  sensitive   = true
  description = "PortvMind/OpenStack application credential ID. Leave null when using username/password authentication."
}

variable "portvmind_application_credential_secret" {
  type        = string
  default     = null
  sensitive   = true
  description = "PortvMind/OpenStack application credential secret. Leave null when using username/password authentication."
}

variable "vmind_region" {
  type    = string
  default = "tr-ist-01"
}



variable "project_id" {
  type      = string
  sensitive = true

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
