# 1. External network (floating IPs use this existing internet egress)
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}

# 2. Private network (just a container, no CIDR)
resource "openstack_networking_network_v2" "ozel_ag" {
  name = "user-network"
}

# 3. Subnet (CIDR is defined here)
resource "openstack_networking_subnet_v2" "ozel_subnet" {
  name            = "user1905-subnet" # Added a name
  network_id      = openstack_networking_network_v2.ozel_ag.id
  cidr            = "192.168.10.0/24" # Keep your CIDR here
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"] # Required for outbound internet access
}

# 4. Router (pushes internal traffic to the outside)
resource "openstack_networking_router_v2" "ozel_router" {
  name                = "user-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# 5. Link (binds router and subnet)
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.ozel_router.id
  subnet_id = openstack_networking_subnet_v2.ozel_subnet.id
}
