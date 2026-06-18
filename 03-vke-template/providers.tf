terraform {
  required_providers {
    portvmind = {
      source  = "vmindtech/portvmind"
      version = "~> 1.0.2"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53"
    }
  }
}

locals {
  portvmind_username                      = var.portvmind_username != null && trimspace(var.portvmind_username) != "" ? var.portvmind_username : null
  portvmind_password                      = var.portvmind_password != null && trimspace(var.portvmind_password) != "" ? var.portvmind_password : null
  portvmind_application_credential_id     = var.portvmind_application_credential_id != null && trimspace(var.portvmind_application_credential_id) != "" ? var.portvmind_application_credential_id : null
  portvmind_application_credential_secret = var.portvmind_application_credential_secret != null && trimspace(var.portvmind_application_credential_secret) != "" ? var.portvmind_application_credential_secret : null
}

# provider for portvmind and openstack
provider "portvmind" {
  user_name                     = local.portvmind_username
  password                      = local.portvmind_password
  application_credential_id     = local.portvmind_application_credential_id
  application_credential_secret = local.portvmind_application_credential_secret

  user_domain_name = "Default"
  auth_url         = "https://tr-ist-01-apigw.portvmind.com"
  endpoint         = "https://tr-ist-01-apigw.portvmind.com/vke/api/v1"
  project_id       = var.project_id
}

provider "openstack" {
  user_name                     = local.portvmind_username
  password                      = local.portvmind_password
  application_credential_id     = local.portvmind_application_credential_id
  application_credential_secret = local.portvmind_application_credential_secret
  tenant_id                     = var.project_id
  domain_name                   = "Default"
  region                        = "tr-ist-01"
  auth_url                      = "https://tr-ist-01-apigw.portvmind.com/v3"
}
