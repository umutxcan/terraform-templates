# --- BASTION HOST (DIŞ KAPI) ---

# 1. Bastion için Floating IP alıyoruz
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = data.openstack_networking_network_v2.public_network.name
}

# 2. Bastion Sunucusu (Public Subnet'te)
resource "openstack_compute_instance_v2" "bastion" {
  name            = "bastion-host"
  flavor_id       = var.standard_flavor_id
  key_pair        = openstack_compute_keypair_v2.terraform_key.name
  security_groups = [openstack_compute_secgroup_v2.bastion_sg.name]
  
  # Public Subnet hazır olmadan kurulmasın
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
    # İstersen burada sabit iç IP de verebilirsin
  }
}

# 3. Floating IP'yi sadece Bastion'a bağlıyoruz
resource "openstack_compute_floatingip_associate_v2" "bastion_fip_bagla" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  instance_id = openstack_compute_instance_v2.bastion.id
}


# --- DATABASE SUNUCUSU (GÜVENLİ ODA) ---

# 4. DB Sunucusu (Private Subnet'te - Floating IP YOK)
resource "openstack_compute_instance_v2" "db_server" {
  name            = "db-server"
  flavor_id       = var.standard_flavor_id # DB için gerekirse flavor değişebilir
  key_pair        = openstack_compute_keypair_v2.terraform_key.name
  security_groups = [openstack_compute_secgroup_v2.db_sg.name]
  
  # Private Subnet hazır olmadan kurulmasın
  depends_on      = [openstack_networking_subnet_v2.private_subnet]

  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 40 # DB için genelde daha fazla alan istenir
  }

  network {
    uuid = openstack_networking_network_v2.ozel_ag.id
    # Sunucuyu private subnet IP bloğundan bir yere oturtur
  }
}
