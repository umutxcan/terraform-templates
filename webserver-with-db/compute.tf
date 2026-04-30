# --- BASTION HOST (FRONT DOOR) ---

# 1. Allocate a Floating IP for the bastion
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = data.openstack_networking_network_v2.public_network.name
}

# 2. Bastion server (in the Public Subnet)
resource "openstack_compute_instance_v2" "bastion" {
  name            = "bastion-host"
  flavor_id       = var.standard_flavor_id
  key_pair        = openstack_compute_keypair_v2.terraform_key.name
  security_groups = [openstack_compute_secgroup_v2.bastion_sg.name]
  
  # Don't create until the Public Subnet is ready
  depends_on      = [openstack_networking_subnet_v2.public_subnet]

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }

  network {
    uuid = openstack_networking_network_v2.ozel_ag.id
    # You can assign a fixed internal IP here if you want
  }
}

# 3. Attach the Floating IP only to the Bastion
resource "openstack_compute_floatingip_associate_v2" "bastion_fip_bagla" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  instance_id = openstack_compute_instance_v2.bastion.id
}


# --- DATABASE SERVER (SECURE ROOM) ---

# 4. DB server (in Private Subnet - NO Floating IP)
resource "openstack_compute_instance_v2" "db_server" {
  name            = "db-server"
  flavor_id       = var.standard_flavor_id # Flavor can be different for DB if needed
  key_pair        = openstack_compute_keypair_v2.terraform_key.name
  security_groups = [openstack_compute_secgroup_v2.db_sg.name]
  
  # Don't create until the Private Subnet is ready
  depends_on      = [openstack_networking_subnet_v2.private_subnet]

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 40 # DB usually needs more disk space
  }

  network {
    uuid = openstack_networking_network_v2.ozel_ag.id
    # Places the server in the private subnet IP range
  }
}
