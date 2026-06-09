# Template Rehberi (TR) — 02-loadBalancer-webserver-db

## Genel Bakış
Bu doküman, **load balancer (Octavia)**, **bastion**, **web sunucuları** ve **veritabanı** katmanlarını içeren çok katmanlı mimariyi kuran *02-loadBalancer-webserver-db* şablonunun kullanımını açıklar.

Bu şablon özellikle şu durumlar için uygundur:

- Load Balancer arkasında çoklu web sunucusu kurmak
- Uygulama ve veritabanını ayrı subnet’lerde izole etmek
- Bastion üzerinden güvenli erişim sağlamak

---

## Ön Koşullar

| Gereksinim | Açıklama |
|------------|-------------|
| PortvMind Account | Aktif bir PortvMind hesabı |
| Terraform | Terraform CLI kurulmuş olmalı |
| Provider Access | PortvMind username, password ve project bilgileri hazır olmalı |
| Local CLI | Terraform komutlarını çalıştırabileceğiniz bir ortam |

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

## Mimari

- **Public Subnet (10.0.1.0/24)**: Bastion + Load Balancer VIP
- **App Subnet (10.0.2.0/24)**: Web sunucuları
- **Data Subnet (10.0.3.0/24)**: Database
- **Router**: Public ağa çıkış ve subnetler arası yönlendirme

---

## İçerik

### `02-loadBalancer-webserver-db`

#### Dosyalar

- `providers.tf`
  Terraform ve OpenStack provider ayarları.
- `variables.tf`
  Input değişken tanımları.
- `network.tf`
  Network, subnet ve router yapılandırması.
- `security.tf`
  Security group erişim kuralları.
- `keypair.tf`
  Sunucu erişimi için key pair tanımları.
- `compute.tf`
  Bastion, web ve DB instance tanımları.
- `loadbalancer.tf`
  Octavia load balancer, listener, pool, health monitor ve member kaynakları.

---

## PortvMind Kimlik Bilgileri ve Değişkenler

Bu projede provider erişimi için değerler `terraform.tfvars` dosyasında tutulur.

> **Not:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez.
> Repoyu klonladıktan sonra **kendi değerlerinizle oluşturun ve commit etmeyin.**
> Gerekli resource ID bilgileri `resources` klasöründe dokümante edilmiştir.

Örnek `terraform.tfvars`:

```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
```

### Önemli Notlar

- `terraform.tfvars` dosyasını **repoya commit etmeyin**.
- Hassas alanlar (`portvmind_password` gibi) için secret yönetimi kullanın.
- `.gitignore` içinde `*.tfvars` olduğundan emin olun.

---

## Kullanım

```bash
cd 02-loadBalancer-webserver-db
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Load Balancer Notları

- LB health check **HTTP** olarak çalışır ve backend’lere **app subnet** üzerinden (10.0.2.x) ulaşır.
- Web security group içinde **80/tcp için app subnet CIDR** izni olmalıdır.
- VIP IP’nin public subnet’te olması, backend trafiğinin de public subnet’ten geleceği anlamına gelmez.

---

## Destroy Uyarısı (Önemli)

> **`terraform destroy` güçlü bir komuttur.**
> Tüm kaynakları kalıcı olarak siler ve geri alınamaz.
> Kaynakları kota nedeniyle yeniden oluşturmanız gerekiyorsa tekrar apply etmeden önce `terraform destroy` çalıştırın.
> Kullanırken **emin olun** ve mümkünse önce `terraform plan` ile kontrol edin.

Kaynakları silmek için:

```bash
terraform destroy -var-file="terraform.tfvars"
```
