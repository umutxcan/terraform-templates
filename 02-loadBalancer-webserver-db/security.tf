# ==========================================
# 1. SECURITY GROUP DEFINITIONS
# ==========================================

# Bastion Host: The only entry point for SSH
resource "openstack_networking_secgroup_v2" "bastion_sg" {
  name        = "vmind-bastion-sg"
  description = "Allows SSH from internet"
}

# Load Balancer: The only entry point for Web traffic
resource "openstack_networking_secgroup_v2" "lb_sg" {
  name        = "vmind-lb-sg"
  description = "Allows HTTP/HTTPS from internet"
}

# Web Servers: Hidden behind the Load Balancer
resource "openstack_networking_secgroup_v2" "web_sg" {
  name        = "vmind-web-sg"
  description = "Allows HTTP from LB and SSH from Bastion"
}

# Database: The most isolated layer
resource "openstack_networking_secgroup_v2" "db_sg" {
  name        = "vmind-db-sg"
  description = "Allows DB traffic from Web and SSH from Bastion"
}

# ==========================================
# 2. SECURITY GROUP RULES (The Chain of Trust)
# ==========================================

# --- BASTION RULES ---
# Rule: Allow SSH (22) from anywhere (0.0.0.0/0)
resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# --- LOAD BALANCER RULES ---
# Rule: Allow HTTP (80) from anywhere
resource "openstack_networking_secgroup_rule_v2" "lb_http_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.lb_sg.id
}

# --- WEB SERVER RULES ---
# Rule 1: Allow HTTP ONLY from the Load Balancer (using remote_group_id)
resource "openstack_networking_secgroup_rule_v2" "web_from_lb" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_group_id   = openstack_networking_secgroup_v2.lb_sg.id
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
}

# Rule 2: Allow SSH ONLY from the Bastion Host
resource "openstack_networking_secgroup_rule_v2" "web_from_bastion" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.bastion_sg.id
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
}

# --- DATABASE RULES ---
# Rule 1: Allow PostgreSQL (5432) ONLY from the Web Servers
resource "openstack_networking_secgroup_rule_v2" "db_from_web" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = openstack_networking_secgroup_v2.web_sg.id
  security_group_id = openstack_networking_secgroup_v2.db_sg.id
}

# Rule 2: Allow SSH ONLY from the Bastion Host
resource "openstack_networking_secgroup_rule_v2" "db_from_bastion" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.bastion_sg.id
  security_group_id = openstack_networking_secgroup_v2.db_sg.id
}