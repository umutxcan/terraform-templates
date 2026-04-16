# Web SG: HTTP (80) ve SSH (22) her yerden gelsin
resource "openstack_compute_secgroup_v2" "web_sg" {
  name        = "web-sg"
  description = "Web sunucusu erisim kurali"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# DB SG: Sadece Web SG'den gelen 3306 (MySQL) portuna izin ver
resource "openstack_compute_secgroup_v2" "db_sg" {
  name        = "db-sg"
  description = "Sadece web-sg'den baglanti kabul eder"

  rule {
    from_port   = 3306
    to_port     = 3306
    ip_protocol = "tcp"
    from_group_id = openstack_compute_secgroup_v2.web_sg.id
  }
}
