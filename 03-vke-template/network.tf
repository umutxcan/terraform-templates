# Fetches the external public network data
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id 
}

# Creates the main virtual network for VKE
resource "openstack_networking_network_v2" "vke_network" {
  name           = "vke-main-net"
  admin_state_up = true
}

# Creates the subnet where the cluster will be deployed
resource "openstack_networking_subnet_v2" "vke_subnet" {
  name            = "vke-subnet"
  network_id      = openstack_networking_network_v2.vke_network.id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# Creates a router to provide internet access to the cluster
resource "openstack_networking_router_v2" "vke_router" {
  name                = "vke-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# Attaches the subnet to the router for outbound connectivity
resource "openstack_networking_router_interface_v2" "vke_interface" {
  router_id = openstack_networking_router_v2.vke_router.id
  subnet_id = openstack_networking_subnet_v2.vke_subnet.id
}