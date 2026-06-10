# PortvMind Terraform - 03 VKE Template Kurulum Rehberi

## Genel Bakış

Bu doküman, PortvMind **VKE** servisi üzerinde Terraform kullanarak bir Kubernetes cluster oluşturma adımlarını açıklar.

`03-vke-template` şablonu aşağıdaki kaynakları oluşturur. Repoya, Ek Kaynaklar bölümündeki PortvMind GitHub bağlantısından ulaşabilirsiniz:

- VKE private network
- VKE subnet
- Router ve router interface
- SSH key pair
- Lokal `.pem` anahtar dosyası
- PortvMind VKE Kubernetes cluster
- Worker node group yapılandırması
- Cluster çıktıları

Bu şablon özellikle şu durumlar için uygundur:

- VKE üzerinde hızlı bir Kubernetes cluster oluşturmak
- OpenStack network bileşenleri ile birlikte uçtan uca kurulum yapmak
- Cluster API erişimini kontrollü bir **CIDR allowlist** ile sınırlamak

---

## Ön Koşullar

| Gereksinim | Açıklama |
| --- | --- |
| PortvMind Account | Aktif bir PortvMind hesabı |
| Terraform | Terraform CLI kurulu olmalı |
| Provider Access | PortvMind username, password ve project bilgileri hazır olmalı |
| Resource ID Bilgileri | External public network UUID ve flavor UUID değerleri hazır olmalı |
| Local CLI | Terraform komutlarını çalıştırabileceğiniz bir terminal |

---

## Şablon İçeriği

| Dosya | Açıklama |
| --- | --- |
| `providers.tf` | `vmindtech/portvmind` ve OpenStack provider ayarları |
| `variables.tf` | Gerekli input değişkenleri ve `allowed_ips` tanımı |
| `network.tf` | VKE için private network, subnet, router ve router interface yapılandırması |
| `main.tf` | SSH key üretimi, keypair kaydı, `.pem` dosyası ve VKE cluster oluşturma |

---

## Mimari Notu

- VKE cluster, Terraform tarafından oluşturulan private network ve subnet üzerinde oluşturulur.
- Router, cluster network'ü için outbound bağlantı sağlar.
- `portvmind_vke_cluster` kaynağı Kubernetes cluster oluşturur.
- Cluster API erişimi `public` olarak yapılandırılır.
- API erişimi `allowed_ips` değişkeni ile izin verilen CIDR aralıklarıyla sınırlandırılmalıdır.
- `cluster_kubeconfig` çıktısı hassastır ve güvenli saklanmalıdır.

---

## Terraform Kurulumu

Terraform kurulu değilse işletim sisteminize göre aşağıdaki adımları kullanabilirsiniz.

### Ubuntu / Debian
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform version
```

### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### Windows
```powershell
choco install terraform -y
terraform version
```

---

## Önemli Güvenlik Notu (`allowed_ips`)

Bu şablonda cluster API erişimi `public` olarak açılır:

```hcl
cluster_api_access = "public"
```

Cluster API erişimi public olduğu için `allowed_ips` değişkenini **mutlaka kendi IP/CIDR aralıklarınıza** göre daraltmanız önerilir.

> **Önemli:** Varsayılan değer `0.0.0.0/0` olduğu için override edilmezse cluster API herkese açık olur.

### Opsiyonel: Lokal Test İçin Public IP Çekme

`main.tf` içinde local test için kullanılabilecek örnek bloklar yorum satırı olarak bulunur:

- `data "http" "my_ip"` bloğunu uncomment edin.
- `allowed_cidrs` listesine `${chomp(data.http.my_ip.response_body)}/32` değerini ekleyin.

---

## PortvMind Kimlik Bilgileri ve Değişkenler

Bu projede provider erişimi ve cluster yapılandırması için gerekli değerler `terraform.tfvars` dosyasında tutulur.

> **Önemli:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez. Repoyu klonladıktan sonra kendi değerlerinizle oluşturun ve commit etmeyin.

> **Resource ID referansı:** Image, flavor veya external network ID değerlerine ihtiyacınız varsa birleşik kaynak rehberine bakabilirsiniz: [`RESOURCES.md`](../RESOURCES.md).

Örnek `terraform.tfvars`:
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
allowed_ips = [
  "203.0.113.10/32",
  "198.51.100.0/24",
]
```

Değişken açıklamaları:

| Değişken | Açıklama |
| --- | --- |
| `portvmind_username` | PortvMind kullanıcı adınız |
| `portvmind_password` | PortvMind kullanıcı parolanız |
| `project_id` | Kaynakların oluşturulacağı project ID değeri |
| `cluster_name` | Oluşturulacak VKE cluster adı; varsayılan değer `dev-vke-cluster` |
| `master_flavor_id` | Master node için kullanılacak flavor UUID değeri |
| `standard_flavor_id` | Worker node için kullanılacak flavor UUID değeri |
| `external_network_id` | External/public network UUID değeri |
| `allowed_ips` | Cluster API erişimine izin verilecek CIDR listesi |

> **Güvenlik notu:** `portvmind_password`, `project_id`, `external_network_id` ve kubeconfig gibi hassas bilgileri public repo içinde paylaşmayın.

---

## Kurulum Adımları

### 1. Şablon Klasörüne Geçin
```bash
cd 03-vke-template
```

### 2. Terraform'u Başlatın
```bash
terraform init
```

Bu komut, gerekli provider dosyalarını indirir ve Terraform çalışma dizinini hazırlar.

### 3. Konfigürasyonu Doğrulayın
```bash
terraform validate
```

Bu adım, Terraform dosyalarında temel syntax ve yapılandırma hatası olup olmadığını kontrol eder.

### 4. Oluşturulacak Kaynakları Önceden İnceleyin
```bash
terraform plan -var-file="terraform.tfvars"
```

`terraform plan` çıktısında network, subnet, router, keypair ve VKE cluster kaynaklarını kontrol edin. Özellikle `allowed_ips` değerlerinin doğru olduğundan emin olun.

### 5. Kaynakları Oluşturun
```bash
terraform apply -var-file="terraform.tfvars"
```

Komut onay istediğinde planı tekrar kontrol edin ve uygunsa `yes` yazarak devam edin.

---

## Beklenen Sonuç

Kurulum tamamlandığında PortvMind üzerinde aşağıdaki kaynaklar oluşmuş olmalıdır:

- VKE private network
- `10.0.0.0/24` CIDR değerine sahip VKE subnet
- External network'e bağlı router
- Router interface
- VKE cluster SSH key pair
- Lokal `vke-cluster-key.pem` dosyası
- Kubernetes VKE cluster
- 1 ile 2 worker node arasında ölçeklenebilen worker node group

---

## Çıktılar

Terraform apply tamamlandıktan sonra aşağıdaki çıktılar kullanılabilir:

| Çıktı | Açıklama |
| --- | --- |
| `cluster_id` | Oluşturulan cluster ID değeri |
| `cluster_status` | Cluster durumu |
| `cluster_kubeconfig` | **Hassas** kubeconfig çıktısı |

> **Not:** `cluster_kubeconfig` hassas bir çıktıdır. Güvenli şekilde saklayın ve public olarak paylaşmayın.

---

## Karşılaşılabilecek Durumlar

### Cluster API herkese açık görünüyor

Kontrol listesi:

- `allowed_ips` değerini kendi IP/CIDR aralıklarınızla override ettiniz mi?
- `terraform.tfvars` içinde `allowed_ips = ["0.0.0.0/0"]` bırakılmadığından emin misiniz?
- VPN, ofis veya sabit IP CIDR aralıklarınız doğru mu?

### Terraform provider indirilemiyor

Olası nedenler:

- İnternet bağlantısı yoktur.
- Terraform registry erişimi kısıtlıdır.
- Proxy veya firewall provider indirmeyi engelliyordur.

Çözüm:
```bash
terraform init
```

Hata devam ederse network/proxy ayarlarını kontrol edin.

### terraform.tfvars bulunamıyor

`terraform.tfvars` dosyasını `03-vke-template` klasörü içinde oluşturduğunuzdan emin olun.
```bash
ls
```

Dosya yoksa örnek değişkenleri kullanarak yeniden oluşturun.

---

## Kaynakları Silme

> **Destroy Uyarısı:** `terraform destroy` güçlü bir komuttur. Tüm kaynakları kalıcı olarak siler ve geri alınamaz.
> Kaynakları kota nedeniyle yeniden oluşturmanız gerekiyorsa tekrar apply etmeden önce `terraform destroy` çalıştırın.

Kaynakları silmek için:
```bash
terraform destroy -var-file="terraform.tfvars"
```

Komut onay istediğinde silinecek kaynakları dikkatlice kontrol edin.

---

## Ek Kaynaklar

- Resource ID Reference: [`RESOURCES.md`](../RESOURCES.md)
- Terraform Documentation: https://developer.hashicorp.com/terraform/docs
- OpenStack Provider Documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- PortvMind GitHub Terraform Examples: https://github.com/vmindtech/portvmind-public-cloud-terraform-examples
