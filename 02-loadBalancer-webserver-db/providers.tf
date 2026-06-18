terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

locals {
  portvmind_username                      = var.portvmind_username != null && trimspace(var.portvmind_username) != "" ? var.portvmind_username : null
  portvmind_password                      = var.portvmind_password != null && trimspace(var.portvmind_password) != "" ? var.portvmind_password : null
  portvmind_application_credential_id     = var.portvmind_application_credential_id != null && trimspace(var.portvmind_application_credential_id) != "" ? var.portvmind_application_credential_id : null
  portvmind_application_credential_secret = var.portvmind_application_credential_secret != null && trimspace(var.portvmind_application_credential_secret) != "" ? var.portvmind_application_credential_secret : null
}

provider "openstack" {
  auth_url                      = "https://tr-ist-01-apigw.portvmind.com/v3"
  user_name                     = local.portvmind_username
  password                      = local.portvmind_password
  application_credential_id     = local.portvmind_application_credential_id
  application_credential_secret = local.portvmind_application_credential_secret
  tenant_id                     = var.project_id
  domain_name                   = "Default"
  region                        = "tr-ist-01"
}
