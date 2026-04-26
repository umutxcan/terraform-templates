# 1. Bilgisayarında RSA 4096 bitlik çok güçlü bir anahtar üretir
resource "tls_private_key" "vmind_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Bu anahtarın PUBLIC kısmını vMind paneline yükler
# Bu sayede vMind, oluşturduğun sunucuların içine bu kilidi takar
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "vmind-proje-anahtari"
  public_key = tls_private_key.vmind_key.public_key_openssh
}

# 3. Anahtarın PRIVATE (.pem) kısmını bilgisayarına kaydeder
resource "local_file" "private_key_save" {
  content         = tls_private_key.vmind_key.private_key_pem
  filename        = "vmind-anahtar.pem" # Artık bu ismi kullanacağız
  file_permission = "0600" # Linux için otomatik ayar
}
