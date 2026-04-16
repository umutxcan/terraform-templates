resource "openstack_compute_instance_v2" "basic" {
  name            = "terraform-deneme"
  flavor_id       = var.standard_flavor_id
  key_pair        = "deneme"
  security_groups = ["ahmet"]

  # BURASI YENİ: Makineyi imajdan değil, bir diskten (volume) başlatıyoruz
  block_device {
    uuid                  = var.ubuntu_image_id 
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20 # Buraya GB cinsinden disk boyutunu yaz (Örn: 20 veya 50)
  }

  network {
    uuid = openstack_networking_network_v2.ozel_ag.id
  }
}
