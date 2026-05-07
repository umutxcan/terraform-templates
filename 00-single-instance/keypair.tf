# 1. Generate an encrypted key on your machine (hidden step)
resource "tls_private_key" "vmind_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Upload the public key to vMind portal
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "vmind-proje-anahtari"
  public_key = tls_private_key.vmind_key.public_key_openssh
}

# 3. Save the private key (.pem) file locally
resource "local_file" "private_key_save" {
  content         = tls_private_key.vmind_key.private_key_pem
  filename        = "vmind-terraform-anahtar.pem" # This will be your file name
  file_permission = "0600"
}
