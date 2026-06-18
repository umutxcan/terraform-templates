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

variable "cluster_name" {
  type    = string
  default = "dev-vke-cluster"
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
  type      = string
  sensitive = true

}

variable "allowed_ips" {
  description = "Allowed IP ranges (e.g., VPN networks)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # User will override this with their own IP in terraform.tfvars
}
