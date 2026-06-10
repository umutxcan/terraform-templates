# PortvMind Terraform - 02 Load Balancer Webserver DB Kurulum Rehberi

## Genel Bakış

Bu doküman, PortvMind üzerinde Terraform kullanarak **Load Balancer (Octavia)**, **bastion**, **web sunucuları** ve **veritabanı** katmanlarını içeren çok katmanlı mimariyi oluşturma adımlarını açıklar.

`02-loadBalancer-webserver-db` şablonu aşağıdaki kaynakları oluşturur. Repoya, Ek Kaynaklar bölümündeki PortvMind GitHub bağlantısından ulaşabilirsiniz:

- Main network
- Public subnet
- App subnet
- Data subnet
- Router
- Bastion instance
- Web server instance'ları
- Database instance
- Load Balancer, listener, pool, health monitor ve pool member kaynakları
- Bastion ve Load Balancer için Floating IP
- Security group kuralları
- Key pair

Bu şablon özellikle şu durumlar için uygundur:

- Load Balancer arkasında çoklu web sunucusu kurmak
- Uygulama ve veritabanını ayrı subnet'lerde izole etmek
- Bastion üzerinden güvenli erişim sağlamak

---

## Ön Koşullar

| Gereksinim | Açıklama |
| --- | --- |
| PortvMind Account | Aktif bir PortvMind hesabı |
| Terraform | Terraform CLI kurulu olmalı |
| Provider Access | PortvMind username, password ve project bilgileri hazır olmalı |
| Resource ID Bilgileri | Image, flavor, external network ve project ID bilgileri hazır olmalı |
| Local CLI | Terraform komutlarını çalıştırabileceğiniz bir terminal |

---

## Şablon İçeriği

| Dosya | Açıklama |
| --- | --- |
| `providers.tf` | Terraform ve OpenStack provider ayarları |
| `variables.tf` | Input değişken tanımları |
| `network.tf` | Network, public subnet, app subnet, data subnet ve router yapılandırması |
| `security.tf` | Bastion, Load Balancer, web ve DB security group kuralları |
| `keypair.tf` | Sunucu erişimi için key pair tanımları |
| `compute.tf` | Bastion, web ve DB instance tanımları |
| `loadbalancer.tf` | Octavia Load Balancer, listener, pool, health monitor ve member kaynakları |

---

## Mimari Notu

- **Public Subnet (10.0.1.0/24):** Bastion ve Load Balancer VIP için kullanılır.
- **App Subnet (10.0.2.0/24):** Web sunucuları bu subnet içinde çalışır.
- **Data Subnet (10.0.3.0/24):** Database instance bu subnet içinde çalışır.
- **Router:** Public ağa çıkış ve subnetler arası yönlendirme sağlar.
- Load Balancer, HTTP trafiğini web sunucularına dağıtır.
- Database katmanı doğrudan public erişime açık tutulmaz.

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

## PortvMind Kimlik Bilgileri ve Değişkenler

Bu projede provider erişimi için gerekli değerler `terraform.tfvars` dosyasında tutulur.

> **Önemli:** `terraform.tfvars` dosyası repoda varsayılan olarak gelmez. Repoyu klonladıktan sonra kendi değerlerinizle oluşturun ve commit etmeyin.

> **Resource ID referansı:** Image, flavor veya external network ID değerlerine ihtiyacınız varsa birleşik kaynak rehberine bakabilirsiniz: [`resources/Resources.md`](../resources/Resources.md).

Örnek `terraform.tfvars`:
```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
project_id          = "YOUR_PROJECT_ID"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
```

Değişken açıklamaları:

| Değişken | Açıklama |
| --- | --- |
| `portvmind_username` | PortvMind kullanıcı adınız |
| `portvmind_password` | PortvMind kullanıcı parolanız |
| `project_id` | Kaynakların oluşturulacağı project ID değeri |
| `ubuntu_image_id` | Kullanılacak Ubuntu image ID değeri |
| `standard_flavor_id` | Instance'lar için kullanılacak flavor ID değeri |
| `external_network_id` | Floating IP ve dış erişim için external network ID değeri |
| `web_instance_count` | Load Balancer pool member sayısı; varsayılan değer `2` |
| `bastion_volume_size` | Bastion disk boyutu; varsayılan değer `20` |
| `web_volume_size` | Web sunucusu disk boyutu; varsayılan değer `20` |
| `db_volume_size` | Database disk boyutu; varsayılan değer `40` |

> **Güvenlik notu:** `portvmind_password` gibi hassas alanları public repo içinde paylaşmayın. `terraform.tfvars` dosyasının `.gitignore` içinde olduğundan emin olun.

---

## Kurulum Adımları

### 1. Şablon Klasörüne Geçin
```bash
cd 02-loadBalancer-webserver-db
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

`terraform plan` çıktısında network, subnetler, router, security group kuralları, bastion, web sunucuları, database instance, Load Balancer ve Floating IP kaynaklarını kontrol edin.

### 5. Kaynakları Oluşturun
```bash
terraform apply -var-file="terraform.tfvars"
```

Komut onay istediğinde planı tekrar kontrol edin ve uygunsa `yes` yazarak devam edin.

---

## Beklenen Sonuç

Kurulum tamamlandığında PortvMind üzerinde aşağıdaki kaynaklar oluşmuş olmalıdır:

- Main network
- Public, app ve data subnetleri
- External network'e bağlı router
- Public subnet içinde bastion instance
- App subnet içinde web sunucuları
- Data subnet içinde database instance
- HTTP listener, pool, health monitor ve pool member içeren Load Balancer
- Load Balancer ve bastion için Floating IP
- Bastion, Load Balancer, web ve DB katmanları için security group kuralları
- SSH bağlantısı için `.pem` anahtar dosyası

---

## Load Balancer Notları

- Load Balancer health check **HTTP** olarak çalışır.
- Backend web sunucularına **app subnet** üzerinden ulaşılır.
- Web security group içinde **80/tcp için app subnet CIDR** izni olmalıdır.
- VIP IP'nin public subnet'te olması, backend trafiğinin de public subnet'ten geleceği anlamına gelmez.
- Web sunucuları Nginx ile başlatılır ve HTTP üzerinden test edilebilir.

---

## Sunucuya SSH ile Bağlanma

Şablon `.pem` anahtarı üretiyorsa dosya proje dizininde oluşur. Anahtar dosya adını kendi ortamınıza göre değiştirin.

### 1. Anahtar İzinlerini Ayarlayın

Linux / macOS:
```bash
chmod 600 <KEY_NAME>.pem
```

Windows PowerShell:
```powershell
icacls.exe <KEY_NAME>.pem /reset
icacls.exe <KEY_NAME>.pem /inheritance:r
icacls.exe <KEY_NAME>.pem /grant:r "$($env:username):(R)"
```

### 2. SSH Agent Kullanın

SSH Agent kullanarak bastion üzerinden web ve DB katmanlarına geçiş sürecini kolaylaştırabilirsiniz.

Linux / macOS:
```bash
eval "$(ssh-agent -s)"
ssh-add /path/to/<KEY_NAME>.pem
ssh-add -l
```

Windows PowerShell:
```powershell
Start-Service ssh-agent
ssh-add C:\path\to\<KEY_NAME>.pem
ssh-add -l
```

---

## Bastion Üzerinden İç Sunuculara Geçiş

### 1. Bastion'a Bağlanın
```bash
ssh ubuntu@<BASTION_PUBLIC_IP>
```

SSH Agent kullanmıyorsanız:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<BASTION_PUBLIC_IP>
```

### 2. Bastion İçinden Web veya DB Instance'a Geçin
```bash
ssh -A ubuntu@<WEB_PRIVATE_IP>
ssh -A ubuntu@<DB_PRIVATE_IP>
```

> **Not:** Web ve DB geçişinde aynı anahtar kullanılır. `<KEY_NAME>.pem` yerine kendi anahtar dosya adınızı yazın.

---

## Karşılaşılabilecek Durumlar

### Load Balancer backend'lere ulaşamıyor

Kontrol listesi:

- Web sunucuları app subnet içinde çalışıyor mu?
- Web security group içinde 80/tcp için gerekli izinler var mı?
- Health monitor URL path değeri `/` olarak doğru mu?
- Web sunucularında Nginx çalışıyor mu?

### Bastion bağlantısı kurulamıyor

Kontrol listesi:

- Floating IP bastion instance'a atanmış mı?
- Bastion security group içinde SSH portu açık mı?
- Doğru `.pem` dosyası kullanılıyor mu?
- Anahtar izinleri doğru ayarlanmış mı?

### terraform.tfvars bulunamıyor

`terraform.tfvars` dosyasını `02-loadBalancer-webserver-db` klasörü içinde oluşturduğunuzdan emin olun.
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

- Resource ID Reference: [`resources/Resources.md`](../resources/Resources.md)
- Terraform Documentation: https://developer.hashicorp.com/terraform/docs
- OpenStack Provider Documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- PortvMind GitHub Terraform Examples: https://github.com/vmindtech/portvmind-public-cloud-terraform-examples
