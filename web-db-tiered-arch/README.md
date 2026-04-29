# Templates Rehberi (TR) — web-db-tiered-arch

## Overview
Bu doküman, **aynı network içinde** çalışan **web + database katmanlarını** ayrı subnet’lerde kuran *web-db-tiered-arch* şablonunun adımlarını açıklar.

Bu şablon özellikle şu durumlar için uygundur:

- Çok katmanlı mimari örneği kurmak istediğinizde
- WordPress + DB gibi senaryoları test ederken
- Subnet & SG segmentasyonu göstermek istediğinizde

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

## Sunucuya Erişim (SSH) ve Anahtar Yönetimi (Önemli)

> Not: Şablon `.pem` anahtarı üretiyorsa dosya proje dizininde oluşur.  
> (Şablona göre değişebilir.)

### 1) Anahtar İzinlerini Ayarlayın

**Linux / macOS:**
```bash
chmod 600 <KEY_NAME>.pem
```

**Windows (PowerShell):**
```powershell
# Dosya izinlerini sadece mevcut kullanıcıya özel hale getirin
icacls.exe <KEY_NAME>.pem /reset
icacls.exe <KEY_NAME>.pem /inheritance:r
icacls.exe <KEY_NAME>.pem /grant:r "$($env:username):(R)"
```

### 2) SSH Agent (Önerilir)

SSH Agent kullanarak her seferinde `-i key.pem` yazmadan bağlanabilirsiniz.  
Bu özellikle **bastion üzerinden DB katmanına geçiş** senaryolarında süreci hızlandırır.

**Linux / macOS**
```bash
eval "$(ssh-agent -s)"
ssh-add /path/to/<KEY_NAME>.pem
ssh-add -l
```

**Windows (PowerShell)**
```powershell
Start-Service ssh-agent
ssh-add C:\path\to\<KEY_NAME>.pem
ssh-add -l
```

### 3) (Opsiyonel) Anahtar Dosyasını Sunucudan Bilgisayarına Çekme

> Bu komutu **kendi bilgisayarınızın terminalinde (PowerShell/CMD)** çalıştırın.

```bash
scp -i "<MEVCUT_BAGLANTI_ANAHTARI>.pem" "ubuntu@<SUNUCU_IP_ADRESI>:/yol/to/proje/<YENI_ANAHTAR>.pem" "C:\Keys\"
```

**Örnek:**
```bash
scp -i "C:\Keys\deneme12345.pem" "ubuntu@192.168.100.X:/home/ubuntu/vmind-terraform-projesi/vmind-Deneme-anahtar.pem" "C:\Dosya-Anahtar\"
```

### 4) Bastion Üzerinden DB Sunucusuna Geçiş

1) Önce bastion’a bağlanın:
```bash
ssh ubuntu@<BASTION_PUBLIC_IP>
```

2) Bastion içinden DB instance’a geçin:
```bash
ssh ubuntu@<DB_PRIVATE_IP>
```

> SSH Agent kullanmıyorsanız bastion bağlantısında:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<BASTION_PUBLIC_IP>
```

> DB geçişinde de aynı anahtar kullanılır.

> Not: `<KEY_NAME>.pem` yerine kendi anahtar dosya adınızı yazın.

---

## İçerik

### `web-db-tiered-arch`
Web ve DB instance’larının aynı VPC içinde fakat farklı subnet’lerde çalıştığı mimari örneği.

#### Dosyalar

- `providers.tf`  
  Terraform ve OpenStack provider ayarları.
- `variables.tf`  
  Dışarıdan alınan değişken tanımları.
- `network.tf`  
  VPC / subnet / route yapılandırması.
- `security.tf`  
  Web ve DB katmanları için SG kuralları.
- `keypair.tf`  
  Sunucu erişimi için key pair tanımları.
- `compute.tf`  
  Web ve DB compute kaynakları.
- `.gitignore`  
  Terraform state ve tfvars gibi dosyaların git'e dahil edilmemesi için.

---

## VMind Kimlik Bilgileri ve Değişkenler

Bu projede provider erişimi için değerler `terraform.tfvars` dosyasında tutulur.

> **Not:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez.  
> Repoyu klonladıktan sonra **kullanıcı kendi değerleriyle** oluşturmalıdır.

Örnek `terraform.tfvars`:

```hcl
vmind_user          = "YOUR_USER"
vmind_pass          = "YOUR_PASSWORD"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
vmind_tenant_id     = "YOUR_TENANT_ID"
```

### Önemli Notlar

- `terraform.tfvars` dosyasını **repoya commit etmeyin**.
- Hassas alanlar (`vmind_pass` gibi) için secret yönetimi kullanın.
- `.gitignore` içinde `*.tfvars` olduğundan emin olun.
- `providers.tf` içinde tenant ID sabit verilmişse, kendi tenant ID’nizle güncelleyin.

---

## Kullanım

```bash
cd web-db-tiered-arch
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Destroy Uyarısı (Önemli)

> **`terraform destroy` güçlü bir komuttur.**  
> Tüm kaynakları kalıcı olarak siler ve geri alınamaz.  
> Kullanırken **emin olun** ve mümkünse önce `terraform plan` ile kontrol edin.

Kaynakları silmek için:

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## Mimari Notu

- Web katmanı ve DB katmanı **ayrı subnet’lerde** çalışır.
- SG kuralları ile web -> DB erişimi sadece gerekli port üzerinden açılır.
- DB katmanı doğrudan public erişime açık tutulmaz (önerilen yaklaşım).
