# 1. Dış Ağ (Sistemdeki mevcut internet çıkışı)
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}

# 2. Özel Ağ (Tüm subnetlerin bağlı olduğu ana yapı)
resource "openstack_networking_network_v2" "ozel_ag" {
  name = "user-network"
}

# 3. Public Subnet (Bastion Host burada duracak)
resource "openstack_networking_subnet_v2" "public_subnet" {
  name            = "bastion-subnet"
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.10.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# 4. Private Subnet (DB Sunucusu burada duracak - Floating IP olmayacak)
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "db-private-subnet"
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.20.0/24" # Farklı bir IP bloğu verdik
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# 5. Router (Dış dünyaya açılan kapı)
resource "openstack_networking_router_v2" "ozel_router" {
  name                = "user-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# 6. Bağlantı - Public Subnet'i Router'a bağla
resource "openstack_networking_router_interface_v2" "public_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.public_subnet.id
}

# 7. Bağlantı - Private Subnet'i Router'a bağla 
# (Böylece DB dışarıdan erişilemez ama içeriden paket indirebilir)
resource "openstack_networking_router_interface_v2" "private_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}
