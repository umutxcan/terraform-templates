
# Kullanıcının verdiği ID'yi sistemde bulup doğrular
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}

# Senin özel LAN ağın
resource "openstack_networking_network_v2" "ozel_ag" {
  name = "user-network"
}

# Subnet ayarların
resource "openstack_networking_subnet_v2" "ozel_subnet" {
  network_id = openstack_networking_network_v2.ozel_ag.id
  cidr       = "192.168.10.0/24"
}

# Router (Dış dünyaya kullanıcının ID'si ile bağlanır)
resource "openstack_networking_router_v2" "ozel_router" {
  name                = "user-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.ozel_subnet.id
}
