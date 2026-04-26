k# 1. BASTION SECURITY GROUP (Dış Kapı)
resource "openstack_compute_secgroup_v2" "bastion_sg" {
  name        = "bastion-sg"
  description = "Sadece benim IP'mden SSH ve ICMP kabul eder"

  # SSH: Sadece sen girebil diye (Buraya kendi IP'ni yazman daha güvenli olur)
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0" 
  }

  # ICMP: Ping testi için
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

# 2. DATABASE SECURITY GROUP (İç Oda)
resource "openstack_compute_secgroup_v2" "db_sg" {
  name        = "db-sg"
  description = "Sadece iç ağdan (Bastion ve WP) erişim kabul eder"

  # SSH: SADECE Bastion'ın olduğu subnet'ten (192.168.10.x) gelene izin ver
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "192.168.10.0/24" 
  }

  # MySQL / MariaDB (WordPress varsayılanı)
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

  # İç ağda makineler birbirine ping atabilsin
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "192.168.10.0/24"
  }
}
