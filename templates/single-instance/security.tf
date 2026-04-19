resource "openstack_compute_secgroup_v2" "basic_sg" {
  name        = "basic-ssh-sg"
  description = "Temel SSH ve ICMP erisim grubu"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}
