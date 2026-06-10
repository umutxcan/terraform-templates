# PortvMind Terraform - 00 Single Instance Kurulum Rehberi

## Genel Bakış

Bu doküman, PortvMind üzerinde Terraform kullanarak **tek bir compute instance** ve bu instance için gerekli **temel network bileşenlerini** oluşturma adımlarını açıklar.

`00-single-instance` şablonu aşağıdaki kaynakları oluşturur:

- Network

- Subnet

- Router

- Security group

- Key pair

- Compute instance

- Floating IP

Bu şablon özellikle şu durumlar için uygundur:

- Terraform'a yeni başlarken

- Hızlı test ortamı kurarken

- Basit network + tek compute ihtiyacında



---

## Mimari Özeti

Bu şablonda compute instance, Terraform tarafından oluşturulan özel network içine yerleştirilir. Router üzerinden external network'e bağlanır ve sunucuya erişim için floating IP atanır.

Özet akış:

```text

Internet

|

External Network

|

Router

|

Private Network / Subnet

|

Compute Instance

|

Floating IP ile SSH erişimi


```

---

## Ön Koşullar

| Gereksinim | Açıklama |

| --- | --- |

| PortvMind Account | Aktif bir PortvMind hesabı |

| Terraform         | Terraform CLI kurulu olmalı |

| Provider Access   | PortvMind username, password ve project bilgileri hazır olmalı |

| Resource ID Bilgileri | Image, flavor, external network ve project ID bilgileri hazır olmalı |

| Local CLI         | Terraform komutlarını çalıştırabileceğiniz bir terminal |

---

## Şablon İçeriği

| Dosya | Açıklama |


| `providers.tf` | Terraform ve OpenStack provider ayarları |

| `variables.tf` | Input değişken tanımları |

| `network.tf`   |   Network, subnet ve router yapılandırması |

| `security.tf`  | Security group erişim kuralları |

| `keypair.tf`   | Sunucu erişimi için key pair tanımları |

| `compute.tf`   | Compute instance ve floating IP ilişkilendirmesi |

| `.gitignore`   | Terraform state ve tfvars dosyalarının git'e dahil edilmemesi için |

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

Örnek `terraform.tfvars`:

```hcl

portvmind_username  = "YOUR_USERNAME"

portvmind_password  = "YOUR_PASSWORD"

ubuntu_image_id     = "YOUR_IMAGE_ID"

standard_flavor_id  = "YOUR_FLAVOR_ID"

external_network_id = "YOUR_EXTERNAL_NETWORK_ID"

project_id          = "YOUR_PROJECT_ID"

```

Değişken açıklamaları:

| Değişken | Açıklama |

| --- | --- |

| `portvmind_username` | PortvMind kullanıcı adınız |

| `portvmind_password` | PortvMind kullanıcı parolanız |

| `ubuntu_image_id` | Kullanılacak Ubuntu image ID değeri |

| `standard_flavor_id` | Instance için kullanılacak flavor ID değeri |

| `external_network_id` | Floating IP ve dış erişim için external network ID değeri |

| `project_id` | Kaynakların oluşturulacağı project ID değeri |

> **Güvenlik notu:** `portvmind_password` gibi hassas alanları public repo içinde paylaşmayın. `terraform.tfvars` dosyasının `.gitignore` içinde olduğundan emin olun.

---

## Kurulum Adımları

### 1. Şablon Klasörüne Geçin

```bash

cd 00-single-instance

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

`terraform plan` çıktısında oluşturulacak network, subnet, router, security group, key pair, compute instance ve floating IP kaynaklarını kontrol edin.





### 5. Kaynakları Oluşturun

```bash

terraform apply -var-file="terraform.tfvars"

```

Komut onay istediğinde planı tekrar kontrol edin ve uygunsa `yes` yazarak devam edin.

---

## Beklenen Sonuç

Kurulum tamamlandığında PortvMind üzerinde aşağıdaki kaynaklar oluşmuş olmalıdır:

- Bir private network

- Bu network'e bağlı subnet

- External network'e bağlı router

- SSH erişimi için security group kuralı

- Compute instance

- Instance'a bağlı floating IP

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

SSH Agent kullanarak her bağlantıda `-i key.pem` yazmadan sunucuya bağlanabilirsiniz.

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

### 3. SSH Bağlantısı Kurun

```bash

ssh ubuntu@<PUBLIC_IP>

```

SSH Agent kullanmıyorsanız:

```bash

ssh -i <KEY_NAME>.pem ubuntu@<PUBLIC_IP>

```

> **Not:** `<PUBLIC_IP>` değerini Terraform outputlarından veya PortvMind cloud console üzerinden alabilirsiniz.

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

## Sık Karşılaşılan Durumlar

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

### SSH bağlantısı kurulamıyor

Kontrol listesi:

- Floating IP instance'a atanmış mı?

- Security group içinde SSH portu açık mı?

- Doğru `.pem` dosyası kullanılıyor mu?

- Anahtar izinleri doğru ayarlanmış mı?

- Kullanıcı adı doğru mu? Ubuntu image için genellikle `ubuntu` kullanılır.

### terraform.tfvars bulunamıyor

`terraform.tfvars` dosyasını `00-single-instance` klasörü içinde oluşturduğunuzdan emin olun.

```bash

ls

```

Dosya yoksa örnek değişkenleri kullanarak yeniden oluşturun.

---

## Kaynakları Silme

> **Destroy Uyarısı:** `terraform destroy` güçlü bir komuttur. Tüm kaynakları kalıcı olarak siler ve geri alınamaz.
 Kaynakları kota nedeniyle yeniden oluşturmanız gerekiyorsa tekrar apply etmeden önce `terraform destroy` çalıştırın.

Kaynakları silmek için:

```bash

terraform destroy -var-file="terraform.tfvars"

```

Komut onay istediğinde silinecek kaynakları dikkatlice kontrol edin.

---

## Ek Kaynaklar

- Terraform Documentation: https://developer.hashicorp.com/terraform/docs

- OpenStack Provider Documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs

- PortvMind Github Terraform-Examples: https://github.com/vmindtech/portvmind-public-cloud-terraform-examples