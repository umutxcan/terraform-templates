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

# provider for portvmind and openstack
provider "portvmind" {
  user_name   = var.portvmind_username
  password    = var.portvmind_password
 
  user_domain_name = "Default"
  auth_url    = "https://tr-ist-01-apigw.portvmind.com"
  endpoint    = "https://tr-ist-01-apigw.portvmind.com/vke/api/v1"
  project_id  = var.project_id
}

provider "openstack" {
  user_name   = var.portvmind_username
  password    = var.portvmind_password
  tenant_id  =  var.project_id
  domain_name = "Default"
  region      = "tr-ist-01"
  auth_url    = "https://tr-ist-01-apigw.portvmind.com/v3"
}
