# 1. Sanal Ağ (Network) - Bu senin ana boru hattın
resource "openstack_networking_network_v2" "ozel_ag" {
  name           = "canu-terraform-network"
  admin_state_up = "true"
}

# 2. Alt Ağ (Subnet) - IP'lerin dağıtıldığı yer (192.168.10.X gibi)
resource "openstack_networking_subnet_v2" "ozel_subnet" {
  name            = "canu-subnet"
  network_id      = openstack_networking_network_v2.ozel_ag.id # Üstteki ağa bağladık
  cidr            = "192.168.10.0/24"                          # IP aralığın
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]                     # İnternete çıkış için DNS
}
