# 0. External Network
data "openstack_networking_network_v2" "public_network" {
  network_id = var.external_network_id
}


# 1. Main Network (The Outer Boundary / VPC equivalent)
resource "openstack_networking_network_v2" "main_network" {
  name           = "vmind-main-net"
  admin_state_up = true
}

# 2. Public Subnet (Internet-facing - For Bastion and Load Balancer)
resource "openstack_networking_subnet_v2" "public_subnet" {
  name            = "vmind-public-subnet"
  network_id      = openstack_networking_network_v2.main_network.id
  cidr            = "10.0.1.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# 3. Private App Subnet (Application Tier - For Web Servers)
resource "openstack_networking_subnet_v2" "app_subnet" {
  name            = "vmind-app-subnet"
  network_id      = openstack_networking_network_v2.main_network.id
  cidr            = "10.0.2.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# 4. Private Data Subnet (Data Tier - For the Database)
resource "openstack_networking_subnet_v2" "data_subnet" {
  name            = "vmind-data-subnet"
  network_id      = openstack_networking_network_v2.main_network.id
  cidr            = "10.0.3.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# 5. Router 

resource "openstack_networking_router_v2" "main_router" {
  name                = "vmind-main-router"
  admin_state_up      = true
  external_network_id = var.external_network_id # Dış ağa bağlayan kapı
}

resource "openstack_networking_router_interface_v2" "public_interface" {
  router_id = openstack_networking_router_v2.main_router.id
  subnet_id = openstack_networking_subnet_v2.public_subnet.id
}


resource "openstack_networking_router_interface_v2" "app_interface" {
  router_id = openstack_networking_router_v2.main_router.id
  subnet_id = openstack_networking_subnet_v2.app_subnet.id
}

resource "openstack_networking_router_interface_v2" "data_interface" {
  router_id = openstack_networking_router_v2.main_router.id
  subnet_id = openstack_networking_subnet_v2.data_subnet.id
}