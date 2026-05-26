# [OPTIONAL] For local testing only: Automatically fetches your current public IP.
# If you want to use this, uncomment the block in allowed cidr part and add 
# "${chomp(data.http.my_ip.response_body)}/32" to your allowed_ips variable.

# data "http" "my_ip" {
#   url = "https://ipv4.icanhazip.com"
# }

resource "tls_private_key" "vke_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registers the public key to PortvMind (OpenStack)
resource "openstack_compute_keypair_v2" "vke_keypair" {
  name       = "vke-cluster-key"
  public_key = tls_private_key.vke_ssh_key.public_key_openssh
}

# Saves the private key locally as a .pem file for SSH access
resource "local_file" "private_key_file" {
  content         = tls_private_key.vke_ssh_key.private_key_pem
  filename        = "${path.module}/vke-cluster-key.pem"
  file_permission = "0600" # Security: Read-only access for the owner
}

# --- KUBERNETES CLUSTER ---

resource "portvmind_vke_cluster" "prod_cluster" {
  name               = var.cluster_name
  kubernetes_version = "v1.35.4+rke2r1" # Or "v1.35.2+rke2r1" as in the official template
  
  
  subnet_ids = [
    openstack_networking_subnet_v2.vke_subnet.id
  ]
  node_key_pair_name = openstack_compute_keypair_v2.vke_keypair.name
  cluster_api_access = "public"
  #allowed_cidrs = [
  #  "${chomp(data.http.my_ip.response_body)}/32",
  #  "172.66.161.0/24"
  #]

  allowed_cidrs = var.allowed_ips
  
  
  
  master_instance_flavor_uuid = var.master_flavor_id
  
  # Defines the worker node group directly within the cluster
  worker_node_group_min_size  = 1
  worker_node_group_max_size  = 2
  worker_instance_flavor_uuid = var.standard_flavor_id
  worker_disk_size_gb         = 40
  
  depends_on = [
    openstack_networking_router_interface_v2.vke_interface
  ]
}

# --- OUTPUTS ---
output "cluster_id" {
  value       = portvmind_vke_cluster.prod_cluster.id
  description = "ID of the created cluster"
}

output "cluster_status" {
  value       = portvmind_vke_cluster.prod_cluster.status
  description = "Current status of the cluster"
}

output "cluster_kubeconfig" {
  value       = portvmind_vke_cluster.prod_cluster.kubeconfig
  sensitive   = true
  description = "Sensitive kubeconfig file for cluster access"
}