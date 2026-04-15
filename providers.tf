
terraform {
  required_providers {
    openstack = {
      # BURASI EN KRİTİK NOKTA:
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  auth_url    = "https://tr-ist-01-apigw.portvmind.com/v3"
  user_name   = var.vmind_user
  password    = var.vmind_pass
  tenant_id  = "a478009f97244c32a36660417592869f"
  domain_name = "Default"
  region      = "tr-ist-01"
}
