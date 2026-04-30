terraform {
  required_providers {
    openstack = {
      
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  auth_url    = "https://tr-ist-01-apigw.portvmind.com/v3"
  user_name   = var.vmind_user
  password    = var.vmind_pass
  tenant_id   = var.vmind_tenant_id 
  domain_name = "Default"
  region      = "tr-ist-01"
}
