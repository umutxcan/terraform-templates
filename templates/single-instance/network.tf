# 1. Dış Ağ (floating ip bu kısım Sistemdeki mevcut internet çıkışını bulur)
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}

# 2. Özel Ağ (Bu sadece bir 'kutu'dur, CIDR almaz)
resource "openstack_networking_network_v2" "ozel_ag" {
  name = "user-network"
}

# 3. Subnet (İşte CIDR buraya yazılır, ağın içini bu doldurur)
resource "openstack_networking_subnet_v2" "ozel_subnet" {
  name            = "user1905-subnet" # İsim ekledik
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.10.0/24" # Senin sorduğun CIDR burada kalmalı
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"] # Sunucunun internete çıkabilmesi için şart
}

# 4. Router (İçerideki trafiği dışarıya fırlatan cihaz)
resource "openstack_networking_router_v2" "ozel_router" {
  name                = "user-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# 5. Bağlantı (Router ile Subnet'i birbirine mühürler)
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.ozel_subnet.id
}
