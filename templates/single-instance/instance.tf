# 1. Havuzdan bir adet boş Floating IP alıyoruz
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = data.openstack_networking_network_v2.public_network.name
}

# 2. Sunucu Oluşturma
resource "openstack_compute_instance_v2" "basic" {
  name      = "terraform-deneme"
  flavor_id = var.standard_flavor_id
  key_pair  = openstack_compute_keypair_v2.terraform_key.name

  # ÖNEMLİ: networking_secgroup referansı kullanıyoruz
  security_groups = [openstack_compute_secgroup_v2.basic_sg.name]
  depends_on = [openstack_networking_subnet_v2.ozel_subnet]
  block_device {
    uuid                  = var.ubuntu_image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }

  network {
    # network.tf içindeki ağın ID'sini çekiyoruz
    uuid = openstack_networking_network_v2.ozel_ag.id
  }
}

# 3. Floating IP'yi Sunucuya Mühürleme
resource "openstack_compute_floatingip_associate_v2" "fip_bagla" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.basic.id
}
