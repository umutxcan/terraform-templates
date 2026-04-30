# 1. BASTION SECURITY GROUP (Front Door)
resource "openstack_compute_secgroup_v2" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allows SSH and ICMP only from my IP"

  # SSH: Only allow your IP (safer if you restrict it)
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0" 
  }

  # ICMP: For ping tests
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

# 2. DATABASE SECURITY GROUP (Inner Room)
resource "openstack_compute_secgroup_v2" "db_sg" {
  name        = "db-sg"
  description = "Allows access only from the internal network (Bastion and WP)"

  # SSH: ONLY from Bastion subnet (192.168.10.x)
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "192.168.10.0/24" 
  }

  # MySQL / MariaDB (WordPress default)
  rule {
    from_port   = 3306
    to_port     = 3306
    ip_protocol = "tcp"
    cidr        = "192.168.10.0/24"
  }

  # PostgreSQL
  rule {
    from_port   = 5432
    to_port     = 5432
    ip_protocol = "tcp"
    cidr        = "192.168.10.0/24"
  }

  # Allow ping within internal network
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "192.168.10.0/24"
  }
}
