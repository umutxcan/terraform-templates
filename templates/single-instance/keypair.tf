# 1. Bilgisayarında şifreli bir anahtar üretir (Görünmez işlem)
resource "tls_private_key" "vmind_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Bu anahtarı vMind'a "Bak bu benim anahtarım" diye gönderir
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "vmind-proje-anahtari"
  public_key = tls_private_key.vmind_key.public_key_openssh
}

# 3. Anahtarın SSH atmanı sağlayacak (.pem) dosyasını klasörüne indirir
resource "local_file" "private_key_save" {
  content         = tls_private_key.vmind_key.private_key_pem
  filename        = "vmind-anahtar.pem" # Dosya adın bu olacak
  file_permission = "0600"
}
