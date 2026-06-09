# Template Rehberi (TR) — 03-vke-template

## Genel Bakış
Bu doküman, PortvMind **VKE** servisi üzerinde bir Kubernetes cluster oluşturmak için hazırlanan **03-vke-template** şablonunun adımlarını açıklar.

Bu şablon özellikle şu durumlar için uygundur:

- VKE üzerinde hızlı bir Kubernetes cluster oluşturmak
- OpenStack network bileşenleri (network, subnet ve router) ile birlikte uçtan uca kurulum yapmak
- Cluster API erişimini (public) kontrollü bir şekilde **CIDR allowlist** ile sınırlamak

---

## İçerik / Dosyalar

- `providers.tf`
  - `vmindtech/portvmind` provider (VKE API)
  - `terraform-provider-openstack/openstack` provider (network bileşenleri)

- `network.tf`
  - VKE için private network + subnet
  - Public network üzerinden outbound NAT erişimi için router ve interface

- `main.tf`
  - TLS SSH key üretimi
  - OpenStack keypair kaydı
  - Lokal `.pem` dosyası oluşturma
  - `portvmind_vke_cluster` ile Kubernetes cluster oluşturma

- `variables.tf`
  - Gerekli tüm input değişkenleri
  - `allowed_ips` (CIDR listesi) varsayılanı: `0.0.0.0/0`

---

## Ön Koşullar

| Gereksinim | Açıklama |
|------------|-------------|
| PortvMind Account | Aktif bir PortvMind hesabı |
| Terraform | Terraform CLI kurulu olmalı |
| Provider Access | PortvMind username, password ve project bilgileri hazır olmalı |
| Network IDs | External public network UUID ve flavor UUID’leri hazır olmalı |

---

## Terraform Kurulumu

### Ubuntu / Debian

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform version
```

### macOS (Homebrew)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### Windows (PowerShell + Chocolatey)

```powershell
choco install terraform -y
terraform version
```

---

## Önemli Güvenlik Notu (allowed_ips)

Bu şablonda cluster API erişimi `public` olarak açılıyor (`cluster_api_access = "public"`).

Cluster API erişimi public olarak yapılandırılmıştır; bu nedenle erişimi yalnızca güvenilir IP/CIDR aralıklarıyla sınırlamanız önerilir.

Bu yüzden `allowed_ips` değişkenini **mutlaka kendi IP/CIDR aralıklarınıza** göre daraltmanız önerilir.

> Varsayılan değer `0.0.0.0/0` olduğu için override edilmezse cluster API herkese açık olur.

### (Opsiyonel) Lokal test için otomatik public IP çekme
`main.tf` içinde yer alan aşağıdaki bloklar **local test** amaçlıdır:

- `data "http" "my_ip"` bloğunu uncomment edin
- `allowed_cidrs` listesine `${chomp(data.http.my_ip.response_body)}/32` ekleyin

---

## terraform.tfvars örneği

> **Not:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez.
> Repoyu klonladıktan sonra **kendi değerlerinizle oluşturun ve commit etmeyin.**
> Gerekli resource ID bilgileri `resources` klasöründe dokümante edilmiştir.

Aşağıdaki örneği `terraform.tfvars` olarak kaydedebilirsiniz:

```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"

# Flavor UUIDs
master_flavor_id    = "YOUR_MASTER_FLAVOR_UUID"
standard_flavor_id  = "YOUR_WORKER_FLAVOR_UUID"

# External/Public Network UUID
external_network_id = "YOUR_EXTERNAL_NETWORK_UUID"

# Cluster API erişimi için izinli CIDR'ler
# Örnek izinli aralıklar (VPN / ofis / sabit IP):
allowed_ips = [
  "203.0.113.10/32",
  "198.51.100.0/24",
]

# Boş bırakmak isterseniz (önerilmez):
# allowed_ips = [
#
# ]
```

---

## Kullanım

```bash
cd 03-vke-template
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Çıktılar

- `cluster_id` — oluşturulan cluster ID
- `cluster_status` — cluster durumu
- `cluster_kubeconfig` — **hassas** kubeconfig çıktısı

---

## Destroy Uyarısı (Önemli)

> **`terraform destroy` güçlü bir komuttur.** Tüm kaynakları kalıcı olarak siler ve geri alınamaz.
> Kaynakları kota nedeniyle yeniden oluşturmanız gerekiyorsa tekrar apply etmeden önce `terraform destroy` çalıştırın.

Kaynakları silmek için:

```bash
terraform destroy -var-file="terraform.tfvars"
```
