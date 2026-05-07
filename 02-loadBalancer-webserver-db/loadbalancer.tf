# ==========================================
# 1. LOAD BALANCER CORE
# ==========================================

# The main Load Balancer instance
resource "openstack_lb_loadbalancer_v2" "web_lb" {
  name          = "vmind-web-lb-1905"
  vip_network_id = openstack_networking_network_v2.main_network.id
  vip_subnet_id = openstack_networking_subnet_v2.public_subnet.id 

  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.lb_sg.id]

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

depends_on = [
    openstack_networking_router_interface_v2.public_interface,
    openstack_networking_router_interface_v2.app_interface
  ]

}


# Floating IP for the Load Balancer (To make it accessible from the internet)
resource "openstack_networking_floatingip_v2" "lb_fip" {
  pool = data.openstack_networking_network_v2.public_network.name
}

# Associate Floating IP with the Load Balancer's VIP Port
resource "openstack_networking_floatingip_associate_v2" "lb_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.lb_fip.address
  port_id     = openstack_lb_loadbalancer_v2.web_lb.vip_port_id
}

# ==========================================
# 2. LISTENER (The Ear)
# ==========================================

# Listens for HTTP traffic on port 80
resource "openstack_lb_listener_v2" "http_listener" {
  name            = "web-http-listener"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.web_lb.id
}

# ==========================================
# 3. POOL (The Target Group)
# ==========================================

resource "openstack_lb_pool_v2" "web_pool" {
  name        = "web-server-pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.http_listener.id

}

# ==========================================
# 4. HEALTH MONITOR 
# ==========================================

resource "openstack_lb_monitor_v2" "web_health_check" {
  name           = "web-health-check"
  pool_id        = openstack_lb_pool_v2.web_pool.id # Havuza buradan bağlanıyor
  type           = "HTTP"
  delay          = 5
  timeout        = 3
  max_retries    = 3
  url_path       = "/"
  expected_codes = "200"
}

# ==========================================
# 5. POOL MEMBERS 
# ==========================================

resource "openstack_lb_member_v2" "web_members" {
  count         = var.web_instance_count
  name          = "web-member-${count.index + 1}"
  pool_id       = openstack_lb_pool_v2.web_pool.id
  address       = openstack_networking_port_v2.web_ports[count.index].all_fixed_ips[0]
  protocol_port = 80
  subnet_id     = openstack_networking_subnet_v2.app_subnet.id
}