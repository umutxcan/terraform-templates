# 1. Generate a strong 4096-bit RSA key on your machine
resource "tls_private_key" "vmind_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Upload the PUBLIC key to vMind
# This lets vMind inject the key into the created servers
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "vmind-proje-anahtari"
  public_key = tls_private_key.vmind_key.public_key_openssh
}

# 3. Save the PRIVATE (.pem) key locally
resource "local_file" "private_key_save" {
  content         = tls_private_key.vmind_key.private_key_pem
  filename        = "vmind5-anahtar.pem" # We will use this name now
  file_permission = "0600" # Auto for Linux
}
