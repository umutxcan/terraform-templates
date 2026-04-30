# 1. External network (existing internet egress)
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}

# 2. Private network (parent for all subnets)
resource "openstack_networking_network_v2" "ozel_ag" {
  name = "user-network"
}

# 3. Public subnet (Bastion Host will live here)
resource "openstack_networking_subnet_v2" "public_subnet" {
  name            = "bastion-subnet"
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.10.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# 4. Private subnet (DB server will live here - no Floating IP)
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "db-private-subnet"
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.20.0/24" # We set a different IP range
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# 5. Router (gateway to the outside world)
resource "openstack_networking_router_v2" "ozel_router" {
  name                = "user-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# 6. Attach Public Subnet to the Router
resource "openstack_networking_router_interface_v2" "public_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.public_subnet.id
}

# 7. Attach Private Subnet to the Router
# (This keeps DB inaccessible from the outside but allows outbound traffic)
resource "openstack_networking_router_interface_v2" "private_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}
