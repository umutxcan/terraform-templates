# Template Rehberi (TR) — 00-single-instance

## Genel Bakış
Bu doküman, **tek bir compute instance** ve **temel network bileşenleri** (network, subnet, router ve security group) kurmak için kullanılan **00-single-instance** şablonunun adımlarını açıklar.

Bu şablon özellikle şu durumlar için uygundur:

- Terraform'a yeni başlarken
- Hızlı test ortamı kurarken
- Basit network + tek compute ihtiyacında

---

## Ön Koşullar

| Gereksinim | Açıklama |
|------------|-------------|
| PortvMind Account | Aktif bir PortvMind hesabı |
| Terraform | Terraform CLI kurulmuş olmalı |
| Provider Access | PortvMind username, password ve project bilgileri hazır olmalı |
| Local CLI | Terraform komutlarını çalıştırabileceğiniz bir ortam |

---

## İçerik

### `00-single-instance`
Tek bir sunucu (compute) ve temel ağ bileşenleri kurmak için hazırlanmıştır.

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
  Compute instance tanımları.
- `.gitignore`
  Terraform state ve tfvars gibi dosyaların git'e dahil edilmemesi için.

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

## Kullanım

```bash
cd 00-single-instance
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

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
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
project_id          = "YOUR_PROJECT_ID"
```

## Sunucuya Erişim (SSH) ve Anahtar Yönetimi

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

### 3) (Opsiyonel) Anahtar Dosyasını Sunucudan Bilgisayarınıza Çekme

> Bu komutu **kendi bilgisayarınızın terminalinde (PowerShell/CMD)** çalıştırın.

```bash
scp -i "<MEVCUT_BAGLANTI_ANAHTARI>.pem" "ubuntu@<SUNUCU_IP_ADRESI>:/yol/to/proje/<YENI_ANAHTAR>.pem" "C:\Keys\"
```

**Örnek:**
```bash
scp -i "C:\Keys\deneme12345.pem" "ubuntu@192.168.100.X:/home/ubuntu/vmind-terraform-projesi/vmind-Deneme-anahtar.pem" "C:\Dosya-Anahtar\"
```

### 4) SSH ile Bağlanın
```bash
ssh ubuntu@<PUBLIC_IP>
```

> Eğer SSH Agent kullanmıyorsanız:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<PUBLIC_IP>
```

`<PUBLIC_IP>` değerini Terraform outputlarından veya cloud konsoldan alabilirsiniz.

> Not: `<KEY_NAME>.pem` yerine kendi anahtar dosya adınızı yazın.

---

### Önemli Notlar

- `terraform.tfvars` dosyasını **repoya commit etmeyin**.
- Hassas alanlar (`portvmind_password` gibi) için secret yönetimi kullanın.
- `.gitignore` içinde `*.tfvars` olduğundan emin olun.

---

## Destroy Uyarısı

> **`terraform destroy` güçlü bir komuttur.**
> Tüm kaynakları kalıcı olarak siler ve geri alınamaz.
> Kaynakları kota nedeniyle yeniden oluşturmanız gerekiyorsa tekrar apply etmeden önce `terraform destroy` çalıştırın.
> Kullanırken **emin olun** ve mümkünse önce `terraform plan` ile kontrol edin.

Kaynakları silmek için:

```bash
terraform destroy -var-file="terraform.tfvars"
```
