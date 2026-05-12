# 1. Generate a strong 4096-bit RSA private key locally during terraform apply
resource "tls_private_key" "vmind_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# This key will be injected into Bastion, Web, and DB instances
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "vmind-project-key"
  public_key = tls_private_key.vmind_key.public_key_openssh
}

# 3. Save the PRIVATE (.pem) key locally for SSH access
# The permission 0600 is crucial for SSH to accept the key
resource "local_file" "private_key_save" {
  content         = tls_private_key.vmind_key.private_key_pem
  filename        = "vmind-project-key.pem" 
  file_permission = "0600" 
}