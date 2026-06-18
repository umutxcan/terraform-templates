# PortvMind Terraform - 01 Webserver with DB Kurulum Rehberi

## Genel Bakış

Bu doküman, PortvMind üzerinde Terraform kullanarak **aynı network içinde** çalışan **web ve database katmanlarını** ayrı subnetlerde oluşturma adımlarını açıklar.

`01-webserver-with-db` şablonu aşağıdaki kaynakları oluşturur. Repoya, Ek Kaynaklar bölümündeki PortvMind GitHub bağlantısından ulaşabilirsiniz:

- Network
- Public subnet
- Private subnet
- Router
- Bastion security group
- Database security group
- Key pair
- Bastion / web erişim instance'ı
- Database instance
- Bastion için Floating IP

Bu şablon özellikle şu durumlar için uygundur:

- Çok katmanlı mimari örneği kurmak istediğinizde
- WordPress + DB gibi senaryoları test ederken
- Subnet ve security group segmentasyonu göstermek istediğinizde

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
| `network.tf` | Network, public subnet, private subnet ve router yapılandırması |
| `security.tf` | Web/bastion ve DB katmanları için security group kuralları |
| `keypair.tf` | Sunucu erişimi için key pair tanımları |
| `compute.tf` | Bastion / web erişim instance'ı ve DB compute kaynakları |
| `.gitignore` | Terraform state ve tfvars dosyalarının git'e dahil edilmemesi için |

---

## Mimari Notu

- Web/bastion katmanı ve DB katmanı **ayrı subnetlerde** çalışır.
- Bastion / web erişim instance'ı public subnet içinde konumlanır ve Floating IP alır.
- DB instance private subnet içinde konumlanır ve doğrudan public erişime açık tutulmaz.
- Security group kuralları ile DB erişimi sadece gerekli portlar üzerinden sınırlandırılır.
- DB sunucusuna erişim bastion üzerinden yapılır.

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

> **Resource ID referansı:** Image, flavor veya external network ID değerlerine ihtiyacınız varsa birleşik kaynak rehberine bakabilirsiniz: [`RESOURCES.md`](../RESOURCES.md).

Username/password authentication ile örnek `terraform.tfvars`:
```hcl
portvmind_username  = "YOUR_USERNAME"
portvmind_password  = "YOUR_PASSWORD"
ubuntu_image_id     = "YOUR_IMAGE_ID"
standard_flavor_id  = "YOUR_FLAVOR_ID"
external_network_id = "YOUR_EXTERNAL_NETWORK_ID"
project_id          = "YOUR_PROJECT_ID"
```

Application credential authentication ile örnek `terraform.tfvars`:
```hcl
portvmind_application_credential_id     = "YOUR_APPLICATION_CREDENTIAL_ID"
portvmind_application_credential_secret = "YOUR_APPLICATION_CREDENTIAL_SECRET"
ubuntu_image_id                         = "YOUR_IMAGE_ID"
standard_flavor_id                      = "YOUR_FLAVOR_ID"
external_network_id                     = "YOUR_EXTERNAL_NETWORK_ID"
project_id                              = "YOUR_PROJECT_ID"
```

Sadece bir authentication yöntemi kullanın. Application credential kullanıyorsanız `portvmind_username` ve `portvmind_password` değerlerini set etmeyin.

> **Application credential notu:** PortvMind UI içinde application credential oluştururken bu template için gerekli rolleri seçin. **Allow creating other application credentials with this credential** checkbox'ı bu template için gerekli değildir; yalnızca kendi workflow'unuz bu credential ile ek application credential oluşturmayı gerektiriyorsa işaretleyin.


Değişken açıklamaları:

| Değişken | Açıklama |
| --- | --- |
| `portvmind_username` | Sadece username/password authentication için PortvMind kullanıcı adınız |
| `portvmind_password` | Sadece username/password authentication için PortvMind kullanıcı parolanız |
| `portvmind_application_credential_id` | Sadece application credential authentication için application credential ID |
| `portvmind_application_credential_secret` | Sadece application credential authentication için application credential secret |
| `ubuntu_image_id` | Kullanılacak Ubuntu image ID değeri |
| `standard_flavor_id` | Instance'lar için kullanılacak flavor ID değeri |
| `external_network_id` | Floating IP ve dış erişim için external network ID değeri |
| `project_id` | Kaynakların oluşturulacağı project ID değeri |

> **Güvenlik notu:** `portvmind_password` veya `portvmind_application_credential_secret` gibi hassas alanları public repo içinde paylaşmayın. `terraform.tfvars` dosyasının `.gitignore` içinde olduğundan emin olun.

---

## Kurulum Adımları

### 1. Şablon Klasörüne Geçin
```bash
cd 01-webserver-with-db
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

`terraform plan` çıktısında oluşturulacak network, public subnet, private subnet, router, security group, key pair, bastion / web erişim instance'ı, database instance ve Floating IP kaynaklarını kontrol edin.

### 5. Kaynakları Oluşturun
```bash
terraform apply -var-file="terraform.tfvars"
```

Komut onay istediğinde planı tekrar kontrol edin ve uygunsa `yes` yazarak devam edin.

---

## Beklenen Sonuç

Kurulum tamamlandığında PortvMind üzerinde aşağıdaki kaynaklar oluşmuş olmalıdır:

- Bir private network
- Public subnet
- Private DB subnet
- External network'e bağlı router
- Bastion / web erişim instance'ı
- Private subnet içinde DB instance
- Bastion instance'a bağlı Floating IP
- Bastion ve DB katmanları için security group kuralları
- SSH bağlantısı için `.pem` anahtar dosyası

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

SSH Agent kullanarak her bağlantıda `-i key.pem` yazmadan sunucuya bağlanabilirsiniz. Bu özellikle bastion üzerinden DB katmanına geçiş senaryolarında süreci hızlandırır.

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

## Bastion Üzerinden DB Sunucusuna Geçiş

### 1. Bastion'a Bağlanın
```bash
ssh ubuntu@<BASTION_PUBLIC_IP>
```

SSH Agent kullanmıyorsanız:
```bash
ssh -i <KEY_NAME>.pem ubuntu@<BASTION_PUBLIC_IP>
```

### 2. Bastion İçinden DB Instance'a Geçin
```bash
ssh -A ubuntu@<DB_PRIVATE_IP>
```

> **Not:** DB geçişinde de aynı anahtar kullanılır. `<KEY_NAME>.pem` yerine kendi anahtar dosya adınızı yazın.

---

## Opsiyonel: Anahtar Dosyasını Sunucudan Bilgisayarınıza Çekme

Bu komutu kendi bilgisayarınızın terminalinde çalıştırın.
```bash
scp -i "<MEVCUT_BAGLANTI_ANAHTARI>.pem" "ubuntu@<SUNUCU_IP_ADRESI>:/yol/to/proje/<YENI_ANAHTAR>.pem" "C:\Keys\"
```

Örnek:
```bash
scp -i "C:\Keys\deneme12345.pem" "ubuntu@192.168.100.X:/home/ubuntu/vmind-terraform-projesi/vmind-Deneme-anahtar.pem" "C:\Dosya-Anahtar\"
```

---

## Karşılaşılabilecek Durumlar

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

### Bastion bağlantısı kurulamıyor

Kontrol listesi:

- Floating IP bastion instance'a atanmış mı?
- Bastion security group içinde SSH portu açık mı?
- Doğru `.pem` dosyası kullanılıyor mu?
- Anahtar izinleri doğru ayarlanmış mı?
- Kullanıcı adı doğru mu? Ubuntu image için genellikle `ubuntu` kullanılır.

### DB sunucusuna geçiş yapılamıyor

Kontrol listesi:

- DB instance private subnet içinde çalışıyor mu?
- Bastion'dan DB private IP adresine erişim var mı?
- SSH Agent aktif mi?
- `ssh -A` ile agent forwarding kullanılıyor mu?
- DB security group içinde bastion subnetinden SSH erişimi açık mı?

### terraform.tfvars bulunamıyor

`terraform.tfvars` dosyasını `01-webserver-with-db` klasörü içinde oluşturduğunuzdan emin olun.
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
