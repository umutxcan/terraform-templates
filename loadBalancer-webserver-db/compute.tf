# ==========================================
# 1. BASTION HOST (Public Subnet)
# ==========================================

# Port for Bastion - Locks it to the Public Subnet
resource "openstack_networking_port_v2" "bastion_port" {
  name               = "bastion-port"
  network_id         = openstack_networking_network_v2.main_network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.bastion_sg.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.public_subnet.id
    ip_address = "10.0.1.10"
  }
}

# Bastion Instance with Block Device
resource "openstack_compute_instance_v2" "bastion" {
  name            = "vmind-bastion"
  flavor_id       = var.standard_flavor_id
  key_pair        = openstack_compute_keypair_v2.terraform_key.name
  
  # Link to the port object
  network {
    port = openstack_networking_port_v2.bastion_port.id
  }

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }
}

# Floating IP for Bastion
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = data.openstack_networking_network_v2.public_network.name 
}

resource "openstack_networking_floatingip_associate_v2" "bastion_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  port_id     = openstack_networking_port_v2.bastion_port.id
}

# ==========================================
# 2. WEB SERVERS (App Subnet)
# ==========================================

resource "openstack_networking_port_v2" "web_ports" {
  count              = 2
  name               = "web-port-${count.index + 1}"
  network_id         = openstack_networking_network_v2.main_network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.web_sg.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.app_subnet.id
    ip_address = "10.0.2.${11 + count.index}"
  }
}

resource "openstack_compute_instance_v2" "web_servers" {
  count           = 2
  name            = "vmind-web-${count.index + 1}"
  flavor_id       = var.standard_flavor_id
  key_pair        = openstack_compute_keypair_v2.terraform_key.name

  network {
    port = openstack_networking_port_v2.web_ports[count.index].id
  }

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }
}

# ==========================================
# 3. DATABASE SERVER (Data Subnet)
# ==========================================

resource "openstack_networking_port_v2" "db_port" {
  name               = "db-port"
  network_id         = openstack_networking_network_v2.main_network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.db_sg.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.data_subnet.id
    ip_address = "10.0.3.10"
  }
}

resource "openstack_compute_instance_v2" "db_server" {
  name            = "vmind-db"
  flavor_id       = var.standard_flavor_id
  key_pair        = openstack_compute_keypair_v2.terraform_key.name

  network {
    port = openstack_networking_port_v2.db_port.id
  }

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 40
  }
}