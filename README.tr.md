# Terraform Şablonları

Temel altyapı bileşenlerinden daha kapsamlı mimari örneklere kadar uzanan pratik Terraform şablonları koleksiyonu.

## Genel Bakış

Bu repo, **Terraform** ile yazılmış **HCL** tabanlı Infrastructure as Code (IaC) şablonları içerir.  
Amaç:

- **Temel şablonlar** ile çekirdek altyapı bileşenlerini (compute + network) sağlamak
- **Daha kompleks mimari örnekleri** (ör. WordPress ve veritabanı instance’larının aynı VPC/ağ içinde, farklı subnet’lerde ve Security Group kurallarıyla çalışması) sunmak

Hedef, şablonları anlaşılır tutarken gerçek hayattaki dağıtım senaryolarını da kapsamak.

## İçerik

### 1) Temel Şablonlar
Altyapının temel parçalarına odaklanan basit şablonlar:

- Compute instance’ları
- Ağ bileşenleri (VPC, subnet, routing vb.)

Bu şablonlar hızlı başlangıç, öğrenme ve tekrar kullanılabilir temel kurulumlar için uygundur.

### 2) Kompleks Mimari Şablonları
Birden fazla bileşeni bir araya getiren daha gelişmiş senaryolar:

- WordPress uygulama instance’ları
- Veritabanı instance’ları
- Aynı ağ/VPC tasarımı
- Katmanlara ayrılmış subnet yapısı (uygulama ve veritabanı katmanları ayrı)
- Servisler arası trafiği kontrol eden Security Group (SG) kuralları

Bu şablonlar çok katmanlı altyapı yaklaşımını göstermek için uygundur.

## Repo Yapısı

```text
.
├── templates/              # Terraform şablonları (temel ve kompleks)
├── modules/                # Opsiyonel tekrar kullanılabilir modüller
└── README.md
```

> Klasör isimlerini mevcut repo yapınıza göre güncelleyebilirsiniz.

## Gereksinimler

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (önerilen: güncel stabil sürüm)
- Yapılandırılmış bulut kimlik bilgileri (şablona göre AWS / Azure / GCP)
- Terraform state için opsiyonel remote backend

## Kullanım

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/umutxcan/terraform-templates.git
   cd terraform-templates
   ```

2. Dağıtmak istediğiniz şablonu seçin (temel veya kompleks).

3. Terraform’u başlatın:
   ```bash
   terraform init
   ```

4. Doğrulama:
   ```bash
   terraform validate
   ```

5. Plan:
   ```bash
   terraform plan
   ```

6. Uygulama:
   ```bash
   terraform apply
   ```

## İyi Uygulamalar

- Altyapıyı modüler ve okunabilir tutun
- Gerekli yerlerde provider/modül sürümlerini sabitleyin
- En az yetki prensibiyle Security Group kuralları yazın
- Secret bilgileri koda gömmeyin; değişken/secret manager kullanın
- Commit öncesi `terraform fmt` ve `terraform validate` çalıştırın

## Katkı

Pull request ile katkılar memnuniyetle karşılanır.

## Lisans

Umut Can tarafından Lisanslanmıştır.
