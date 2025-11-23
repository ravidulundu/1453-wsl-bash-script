# 1453 WSL Architect - Blueprint

## Belge Bilgileri

| Alan | Değer |
|------|-------|
| **Proje Adı** | 1453 WSL Architect |
| **Sürüm** | 1.0 (Draft) |
| **Durum** | Planlama Aşaması |
| **Platform** | Windows Subsystem for Linux (WSL) / Bash |
| **Temel Teknoloji** | Charmbracelet Gum |
| **İlham Kaynakları** | Claude Code CLI, Gemini CLI |

---

## 1. Giriş ve Vizyon
### 1.1 Sorun Tanımı

Mevcut 1453-wsl-bash-script ve benzeri WSL kurulum araçları, işlevsel olmalarına rağmen "soğuk" ve mekanik bir kullanıcı deneyimi sunmaktadır. Hızlı akan log yazıları, estetikten yoksun sorgu ekranları ve görsel hiyerarşinin eksikliği, modern geliştirici deneyimi (DX) standartlarının gerisindedir.

### 1.2 Çözüm Vizyonu

Proje, standart bir Bash betiğini Claude Code ve Gemini CLI araçlarında görülen "Akıllı Ajan" (Agentic) estetiğine dönüştürmeyi hedefler. Amaç, arka planda bir LLM çalışmasa dahi, kullanıcıya sistemi anlayan, düşünen ve şık bir şekilde raporlayan bir "Mimar" ile çalıştığı hissini vermektir.

### 1.3 Değer Önerisi (Value Proposition)

- **Bilişsel Rahatlık**: Karmaşık kurulum süreçlerini görselleştirerek kullanıcının stresini azaltmak
- **Estetik Tatmin**: Terminali sadece bir araç değil, bir yaşam alanı olarak sunmak
- **Marka Kimliği**: "1453" temasını (Yeni Çağ) yansıtan özgün bir renk ve tasarım dili oluşturmak

## 2. Kullanıcı Deneyimi (UX) ve Tasarım Dili

Bu proje için en kritik bileşen, işlevden ziyade sunumdur. Tüm etkileşimler aşağıdaki kurallara uymalıdır.

### 2.1 Tasarım Temaları (Theme & Styling)

Uygulama, standart terminal renkleri yerine 24-bit TrueColor paleti kullanacaktır.

| Öğe | Renk | Hex | Kullanım |
|-----|------|-----|---------|
| Ana Renk (Primary) | Crimson | #DC143C | Marka vurgusu ve başlıklar |
| İkincil Renk (Secondary) | Gold | #FFD700 | Sınırlar (Borders) ve ikonlar |
| Metin Rengi | Off-White | #F5F5F5 | Okunabilirlik |
| Hata Rengi | Red | #FF0000 | Kritik uyarılar |
| Başarı Rengi | Teal | #008080 | Tamamlanan işlemler |

### 2.2 "Yapay Zeka" Hissi (AI Simulation)

Kullanıcı, statik bir script ile değil, canlı bir varlıkla etkileşimde olduğunu hissetmelidir.

- **Streaming Text**: Metinler ekrana aniden değil, bir insanın okuma hızına uygun şekilde (daktilo efekti) akarak gelmelidir (gum style + döngüsel gecikme)
- **Thinking State**: İşlem yapılırken (örneğin paket yüklenirken) kullanıcı asla boş imleçle bırakılmamalı; "Analiz ediliyor...", "İnşa ediliyor..." gibi bağlamsal mesajlar içeren animasyonlu spinner'lar kullanılmalıdır

## 3. Fonksiyonel Gereksinimler

Proje 4 ana fazdan oluşacaktır.

### 3.1 Faz 1: Başlatma ve Karşılama (Initialization)

| ID | Gereksinim | Tanım |
|-----|-----------|-------|
| FR-1.1 | Ekran Temizleme | Script çalıştırıldığında terminal ekranı temizlenmelidir |
| FR-1.2 | Başlık Gösterimi | "1453 WSL Architect" logosu veya başlığı, çift çizgili (double border) altın renkli bir kutu içinde gösterilmelidir |
| FR-1.3 | Sistem Özeti | Sistemin mevcut durumu (WSL sürümü, Distro adı) analiz edilmeli ve kısa bir özet olarak kullanıcıya sunulmalıdır |

### 3.2 Faz 2: Etkileşimli Konfigürasyon (Interactive Setup)

Kullanıcıya "evet/hayır" soruları sormak yerine, modern seçim menüleri sunulmalıdır.

| ID | Gereksinim | Tanım | Gum Bileşeni |
|-----|-----------|-------|-------------|
| FR-2.1 | Çoklu Seçim | Kullanıcı, kurulacak araçları (Git, Node.js, Docker vb.) liste üzerinden seçebilmelidir. Seçilen öğeler ikonlarla (◉) işaretlenmelidir | `gum choose --no-limit` |
| FR-2.2 | Bulanık Arama | Dotfiles veya konfigürasyon dosyaları seçilirken, kullanıcı dosya yolunu yazmak yerine dizin ağacında arama yapabilmelidir | `gum filter` |
| FR-2.3 | Gizli Giriş | Eğer sudo şifresi veya API anahtarı gerekiyorsa, giriş maskelenmelidir | `gum input --password` |

### 3.3 Faz 3: Yürütme ve Geri Bildirim (Execution & Feedback)

Kurulum işlemleri sırasında terminal kirliliği önlenmelidir.

| ID | Gereksinim | Tanım |
|-----|-----------|-------|
| FR-3.1 | Log Gizleme | apt-get veya winget çıktıları varsayılan olarak gizlenmeli, sadece işlem başlığı ve spinner gösterilmelidir |
| FR-3.2 | Hata Yönetimi | Bir işlem başarısız olursa, script durmamalı; hata yakalanmalı ve kırmızı bir "Alert Box" içinde özetlenmelidir. Kullanıcıya "Logları Göster" veya "Yeniden Dene" seçenekleri sunulmalıdır |
| FR-3.3 | Windows Interop | Script, Windows tarafındaki fontları (Nerd Fonts) kontrol etmeli ve eksikse winget aracılığıyla Windows tarafına kurulum önermelidir |

### 3.4 Faz 4: Raporlama (Reporting)

| ID | Gereksinim | Tanım |
|-----|-----------|-------|
| FR-4.1 | Markdown Rapor | Tüm işlemler bittiğinde, yapılan değişikliklerin özeti Markdown formatında render edilerek sunulmalıdır |
| FR-4.2 | Yeniden Başlatma | Kullanıcıya sistemin yeniden başlatılması gerekiyorsa, geri sayımlı bir onay kutusu gösterilmelidir |

## 4. Teknik Mimari

### 4.1 Teknoloji Yığını

| Bileşen | Teknoloji | Açıklama |
|---------|-----------|---------|
| **Core Language** | Bash (Shell Script) | Ana programlama dili |
| **UI Framework** | Charmbracelet Gum | Go tabanlı, pre-compiled binary |
| **Dependency Management** | Otomatik | Script, gum'ın kurulu olup olmadığını kontrol etmeli ve gerekirse otomatik kurmalıdır |

### 4.2 Dosya Yapısı Önerisi

```
1453-architect/
├── install.sh                # Ana giriş noktası (Entry point)
├── lib/
│   ├── ui.sh                # Gum wrapper fonksiyonları (Colors, Borders, Spinners)
│   ├── logic.sh             # Kurulum mantığı (apt, git, stow komutları)
│   └── text.sh              # AI benzeri metinler ve promptlar
└── config/
    └── packages.csv         # Kurulacak paket listesi
```

### 4.3 Kod Standartları (Style Guide)

- Tüm gum komutları, tekrar kullanılabilirlik için `lib/ui.sh` içinde fonksiyonlaştırılmalıdır
  - Örnek: `show_info_box "Mesaj"`
- Markdown render işlemleri için `gum format` kullanılmalı, ham `echo` kullanımından kaçınılmalıdır
- Tüm fonksiyonlar başında kısa bir açıklama yorumu içermelidir

## 5. Uygulama Yol Haritası (Roadmap)

### Aşama 1: MVP (Minimum Viable Product)

- [ ] Temel Bash iskeletinin oluşturulması
- [ ] Gum entegrasyonu ve renk temasının uygulanması
- [ ] Temel paket kurulum (Git, Zsh) modüllerinin görselleştirilmesi

### Aşama 2: "Akıllı" Özellikler

- [ ] Windows/WSL arası dosya kopyalama arayüzü (Windows User klasörünü gum filter ile gezme)
- [ ] AI "Streaming Text" simülasyonunun eklenmesi
- [ ] Hata durumunda detaylı Markdown raporu oluşturma

### Aşama 3: İleri Seviye (Future Work)

- [ ] Eğer proje karmaşıklaşırsa, Bash'ten Go + Bubble Tea yapısına tam geçiş (Gum'ın native kütüphane hali)
- [ ] Gerçek bir LLM API'sine bağlanarak (OpenAI/Anthropic) hata mesajlarının yapay zeka tarafından yorumlanması

## 6. Kabul Kriterleri (Acceptance Criteria)

| Kriter | Açıklama | Durum |
|--------|---------|-------|
| AC-1 | Script çalıştırıldığında ham terminal çıktısı görülmemelidir (spinner arkasına gizlenmelidir) | ⏳ |
| AC-2 | Kullanıcı arayüzü, Claude Code CLI'daki gibi yuvarlatılmış kenarlıklı kutular kullanmalıdır | ⏳ |
| AC-3 | Tüm kullanıcı girdileri (seçimler, metinler) Gum bileşenleri üzerinden alınmalıdır | ⏳ |
| AC-4 | Renk paleti, belirlenen Kızıl ve Altın temasına sadık kalmalıdır | ⏳ |

---

## 7. Notlar ve Ek Bilgiler

### Tasarım Felsefesi

Bu proje, **form** ve **fonksiyon**ın iç içe geçtiği bir deneyim sunmayı amaçlar. Bir Bash scripti olmasına rağmen, kullanıcıya "AI asistanı" hissini yaşatmalıdır. Her animasyon, her renk seçimi ve her metni delibere olarak seçilmelidir.

### Başarı Metrikleri

- Kullanıcı geri bildirimi: Betik "profesyonel" ve "modern" olarak algılanmalıdır
- Hata oranı: Başarısız kurulumlar %90'dan daha az olmalıdır
- Performans: Tüm animasyonlar ve render işlemleri 100ms altında tamamlanmalıdır

