# WORDPRESS (Web) Sunucusu
resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress-vm"
  flavor_id       = var.standard_flavor_id
  key_pair        = "deneme"
  security_groups = [openstack_compute_secgroup_v2.web_sg.name]

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }

  network {
    uuid = openstack_networking_network_v2.ana_ag.id
  }
}

# DATABASE Sunucusu
resource "openstack_compute_instance_v2" "database" {
  name            = "db-vm"
  flavor_id       = var.standard_flavor_id # İsteğine göre bu da standard_flavor_id oldu
  key_pair        = "deneme"
  security_groups = [openstack_compute_secgroup_v2.db_sg.name]

  block_device {
    uuid                  = var.ubuntu_image_id # tfvars'taki Ubuntu ID'sini çeker
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 30
  }

  network {
    uuid = openstack_networking_network_v2.ana_ag.id
  }
}
