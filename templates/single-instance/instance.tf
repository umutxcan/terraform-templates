resource "openstack_compute_instance_v2" "basic" {
  name            = "terraform-deneme"
  flavor_id       = "73dee111-ff30-4837-b3c1-9284c422485e"
  key_pair        = "deneme"
  security_groups = ["ahmet"]

  # BURASI YENİ: Makineyi imajdan değil, bir diskten (volume) başlatıyoruz
  block_device {
    uuid                  = "d4086da9-366a-4482-a93c-d18e065fcd8b" 
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
