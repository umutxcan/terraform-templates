# 1. Ana Network
resource "openstack_networking_network_v2" "ana_ag" {
  name = "proje-network"
}

# 2. Web Subnet (Dış dünyaya bakan taraf)
resource "openstack_networking_subnet_v2" "web_subnet" {
  name       = "web-subnet"
  network_id = openstack_networking_network_v2.ana_ag.id
  cidr       = "10.0.1.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8"]
}

# 3. DB Subnet (Gizli ve güvenli taraf)
resource "openstack_networking_subnet_v2" "db_subnet" {
  name       = "db-subnet"
  network_id = openstack_networking_network_v2.ana_ag.id
  cidr       = "10.0.2.0/24"
  ip_version = 4
}
