# Templates Rehberi (TR) — 02-loadBalancer-webserver-db

## Overview
Bu doküman, **load balancer (Octavia)**, **bastion**, **web sunucuları** ve **veritabanı** katmanlarını içeren çok katmanlı mimariyi kuran *02-loadBalancer-webserver-db* şablonunun kullanımını açıklar.

Bu şablon özellikle şu durumlar için uygundur:

- Load Balancer arkasında çoklu web sunucusu kurmak
- Uygulama ve veritabanını ayrı subnet’lerde izole etmek
- Bastion üzerinden güvenli erişim sağlamak

---

## Prerequisites

| Requirement | Description |
|------------|-------------|
| PortvMind Account | Aktif bir vMind hesabı |
| Terraform | Terraform CLI kurulmuş olmalı |
| Provider Access | vMind user / tenant bilgileri hazır olmalı |
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
  Dışarıdan alınan değişken tanımları.
- `network.tf`  
  VPC / subnet / router gibi ağ bileşenleri.
- `security.tf`  
  Security Group erişim kuralları.
- `keypair.tf`  
  Sunucu erişimi için key pair tanımları.
- `compute.tf`  
  Bastion, web ve DB instance tanımları.
- `loadbalancer.tf`  
  Octavia LB, listener, pool, health monitor ve members.

---

## VMind Kimlik Bilgileri ve Değişkenler

Bu projede provider erişimi için değerler `terraform.tfvars` dosyasında tutulur.

> **Not:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez.  
> Repoyu klonladıktan sonra **kullanıcı kendi değerleriyle oluşturmalıdır.**  
> Gerekli olan kaynaklar "resources" adlı klasör içinde bulunur.

Örnek `terraform.tfvars`:

```hcl
vmind_user          = "YOUR_USER"
vmind_pass          = "YOUR_PASSWORD"
vmind_tenant_id     = "YOUR_TENANT_ID"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
web_instance_count  = 2
```

### Önemli Notlar

- `terraform.tfvars` dosyasını **repoya commit etmeyin**.
- Hassas alanlar (`vmind_pass` gibi) için secret yönetimi kullanın.
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
- Web SG’de **80/tcp için app subnet CIDR** izni olmalıdır.
- VIP IP’nin public subnet’te olması, backend trafiğin de public subnet’ten geleceği anlamına gelmez.

---

## Destroy Uyarısı (Önemli)

> **`terraform destroy` güçlü bir komuttur.**  
> Tüm kaynakları kalıcı olarak siler ve geri alınamaz.  
> Kullanırken **emin olun** ve mümkünse önce `terraform plan` ile kontrol edin.

Kaynakları silmek için:

```bash
terraform destroy -var-file="terraform.tfvars"
```
