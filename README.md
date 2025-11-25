<div align="center">

# 🏛️ 1453 WSL ARCHITECT

### *Bu sadece bir kurulum scripti değil. Bir deneyim.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-WSL%20%7C%20Linux-blue.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![Version](https://img.shields.io/badge/Version-2.5.1-crimson.svg)](https://github.com/ravidulundu/1453-wsl-bash-script/releases)
[![PRD Compliant](https://img.shields.io/badge/PRD-99%25%20Compliant-gold.svg)](https://github.com/ravidulundu/1453-wsl-bash-script/blob/master/docs/reports/dev-kurulun-cli-prd.md)

---

**Soğuk ve mekanik kurulum scriptlerini geride bırakın.**
**Claude Code ve Gemini CLI'da gördüğünüz o "AI Agent" estetiğini terminalinize getirin.**
**Modern geliştirici deneyimini, Premium Crimson & Gold temasıyla buluşturun.**

</div>

---

## 🎯 Vizyon: Form ve Fonksiyon Birliği

Çoğu kurulum scripti sadece **çalışır**. 1453 WSL Architect ise **yaşar**.

Siz "Python kurulumu başlatılıyor..." yazan sıradan bir log beklerken, karşınıza şu çıkar:

```
╭─────────────────────────────────────────────╮
│  🤔  En iyi strateji belirleniyor...        │
╰─────────────────────────────────────────────╯

╭─────────────────────────────────────────────╮
│  ⚙️   Bileşenler inşa ediliyor...           │
╰─────────────────────────────────────────────╯

╭─────────────────────────────────────────────╮
│  ✅ Python Kuruldu                          │
│     pip + pipx + UV hazır!                  │
╰─────────────────────────────────────────────╯
```

**Her animasyon, her renk, her box delibere olarak seçilmiştir.**
Terminaliniz artık bir **yaşam alanı**. Bir **sanat eseri**.

---

## ✨ PRD-Driven Development: Özellikler

### 🎨 1. RESPONSIVE TASARIM (YENİ v2.5.1!)

**Sorun**: Çoğu TUI aracı sola yapışık, farklı terminal boyutlarında dağınık görünür.

**Çözüm**: Her box terminal genişliğine göre **otomatik merkeze hizalanır**.

```bash
# Dar terminal (80 karakter)
╭──────────────────────────────────╮
│  🎯 Kurulum Başladı              │
╰──────────────────────────────────╯

# Geniş terminal (120 karakter)
            ╭──────────────────────────────────╮
            │  🎯 Kurulum Başladı              │
            ╰──────────────────────────────────╯
```

**Teknoloji**: Dinamik `tput cols` hesaplaması + Gum `--width` parametresi

---

### ⏱️ 2. VİZÜEL COUNTDOWN (PRD FR-4.2)

**Sorun**: "Sistem 10 saniye sonra yeniden başlatılacak" yazan sıkıcı bir log.

**Çözüm**: Görsel, renk kodlu, iptal edilebilir countdown:

```bash
# 10-6 saniye: Kırmızı
╭─────────────────────────────────╮
│  🔴 Yeniden Başlatma: 8 saniye │
╰─────────────────────────────────╯

# 5-3 saniye: Sarı
╭─────────────────────────────────╮
│  🟡 Yeniden Başlatma: 4 saniye │
╰─────────────────────────────────╯

# 2-1 saniye: Yeşil
╭─────────────────────────────────╮
│  🟢 Yeniden Başlatma: 1 saniye │
╰─────────────────────────────────╯
```

**Ctrl+C ile iptal edilebilir!**

---

### 🖥️ 3. WINDOWS FONT KONTROLÜ (PRD FR-3.3)

**Sorun**: WSL'de modern CLI araçları (eza, starship, lazygit) ikonlar yerine bozuk karakterler gösteriyor.

**Çözüm**: Windows tarafındaki Nerd Fonts'u kontrol edip eksikleri **winget ile otomatik kurar**:

```bash
# Font kontrolü
✅ CascadiaCode NF - Kurulu
✅ JetBrainsMono NF - Kurulu
❌ FiraCode NF - Eksik

# Otomatik kurulum önerisi
╭─────────────────────────────────────────╮
│  ⚠️  Eksik Fontlar Bulundu              │
│     1 font eksik                        │
╰─────────────────────────────────────────╯

Eksik fontları şimdi kurmak ister misiniz? (e/H)
```

**Teknoloji**: PowerShell interop + Windows Registry okuma + winget

---

### 🔍 4. DOTFILES YÖNETİCİSİ (PRD FR-2.2)

**Sorun**: Dotfiles yedekleme/geri yükleme için manuel komutlar.

**Çözüm**: **Fuzzy search** ile interactive dotfiles manager:

```bash
# Yedekleme
🔍 Arama yaparak dosya seçin (ESC = İptal)
> bashrc_

# Arama sonuçları (fuzzy match)
.bashrc
.bash_history
.bash_aliases
.bash_profile

# Seçim sonrası
✅ .bashrc
✅ .vimrc
✅ .gitconfig

📦 Yedek konumu: ~/.1453-dotfiles-backup-20251125-143022
```

**Teknoloji**: `gum filter` + find + fuzzy matching

---

### 🤖 5. AI SİMÜLASYONU (Core Feature)

Terminaliniz artık bir **AI Agent** ile konuşuyor gibi:

#### a) Streaming Text (Typewriter Effect)
```bash
# Normal script
Sistem bilgisi: Ubuntu 24.04 | dev | 2025-11-25

# 1453 WSL Architect
S.y.s.t.e.m.:. .U.b.u.n.t.u. .2.4...0.4. .|. .d.e.v. .|. .2.0.2.5.-.1.1.-.2.5
```

#### b) Thinking States (14 Farklı Bağlam)
```bash
🏗️  Ortam hazırlanıyor...
🔍  Sistem mimarisi analiz ediliyor...
🤔  En iyi strateji belirleniyor...
⚙️   Bileşenler inşa ediliyor...
✓   Doğrulama yapılıyor...
```

#### c) Zero-Echo Policy
```bash
# ❌ Eski scriptler
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  python3-pip python3-venv

# ✅ 1453 WSL Architect
╭─────────────────────────────────────╮
│  ⚙️   Python kuruluyor...           │
╰─────────────────────────────────────╯
```

**Her işlem spinner arkasında. Terminal kirletilmez.**

---

### 🎨 6. CRIMSON & GOLD TEMA

Özel olarak tasarlanmış **24-bit TrueColor** paleti:

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Crimson** | `#DC143C` | Ana başlıklar, kritik vurgular |
| **Gold** | `#FFD700` | Kenarlıklar, ikonlar, başarı mesajları |
| **Off-White** | `#F5F5F5` | Okunabilir metin |
| **Teal** | `#008080` | Başarı kutuları |
| **Red** | `#FF0000` | Hata kutuları |

**Tutarlılık**: Her fonksiyon aynı stil kurallarına uyar. Profesyonel görünüm garantili.

---

### 🛡️ 7. HATA YÖNETİMİ (3 Seçenek)

```bash
╭─────────────────────────────────────╮
│  ❌ İşlem Başarısız                 │
│     Docker kurulumu sırasında hata  │
╰─────────────────────────────────────╯

Ne yapmak istersiniz?
> Logları Göster
  Yeniden Dene
  Atla

# "Logları Göster" seçimi
## 📋 Hata Logları

E: Package 'docker-ce' has no installation candidate
```

**180+ hata kutusunda** aynı yaklaşım. Hiçbir hata kullanıcıyı yalnız bırakmaz.

---

## 🚀 Kurulum: 1 Satır, 3 Dakika

### Hızlı Başlangıç

```bash
# Önerilen (kısa link)
curl -fsSL https://wsl.dulundu.dev | bash

# Alternatif (wget ile)
wget -qO- https://wsl.dulundu.dev | bash

# Manuel (tam GitHub linki)
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

**Ne kurulur?**
1. ✅ **Charm Gum** - Modern TUI framework
2. ✅ **25 modül** - lib/ + config/ + modules/
3. ✅ **Başlatıcı** - `~/.1453-wsl-setup/1453-setup`

### Kurulum Sonrası

```bash
# Script'i çalıştır
~/.1453-wsl-setup/1453-setup

# Veya PATH'e eklenmiş hali (önerilen)
1453-setup
```

---

## 📦 Ne Kurulabilir? (40+ Araç)

### 🐍 Python Ekosistemi
- Python 3.x + pip (PEP 668 uyumlu)
- pipx (izole uygulamalar)
- UV (ultra-hızlı paket yöneticisi)

### 🟨 JavaScript/TypeScript
- NVM (Node Version Manager)
- Node.js LTS
- Bun.js (modern runtime)

### 🐘 PHP Ekosistemi
- PHP 7.4 → 8.5 (multi-version)
- Composer + 12 extension
- Laravel-ready

### 🐹 Go Language
- Latest stable + GOPATH

### 🐋 Docker
- Docker Engine + Compose
- lazydocker (TUI)

### ⚡ Modern CLI Tools (12 Araç)

| Araç | Yerine Geçer | Özellik |
|------|--------------|---------|
| **bat** | cat | Syntax highlighting |
| **eza** | ls | İkonlar + Git entegrasyonu |
| **ripgrep** | grep | 10x daha hızlı |
| **fd** | find | Basit syntax |
| **starship** | PS1 | Cross-shell prompt |
| **zoxide** | cd | AI-powered (sık kullanılanları öğrenir) |
| **fzf** | - | Fuzzy finder |
| **lazygit** | - | Git TUI |
| **lazydocker** | - | Docker TUI |

### 🤖 AI CLI Tools (8 Araç)
- Claude Code CLI
- Qoder CLI
- Gemini CLI (Google AI)
- Qwen CLI
- OpenCode CLI
- GitHub Copilot CLI
- GitHub CLI

### 🧠 AI Frameworks (3 Framework)
- SuperGemini (MCP server'lı)
- SuperQwen (MCP server'lı)
- SuperClaude (MCP server'lı)

---

## 🎮 Kullanım: 2 Mod

### 1️⃣ Hızlı Başlangıç (Önerilen)

```
╔═════════════════════════════════════╗
║         KURULUM MODU SEÇİMİ         ║
║    Nasıl devam etmek istersiniz?    ║
╚═════════════════════════════════════╝

> 🚀 Hızlı Başlangıç (Önerilen)
  ⚙️  Gelişmiş Mod
  🚪 Çıkış
```

**5 Hazır Paket**:
- 🌐 Web Geliştirme (Python + Node + PHP)
- 🤖 AI Geliştirme (Python + AI Tools)
- ⚙️  Backend Geliştirme (Python + Go + PHP)
- 🐳 Docker Ortamı
- 📱 Mobil + Web (Flutter + Node + PHP)

**Multiselect**: Space ile birden fazla paket seçebilirsiniz!

---

### 2️⃣ Gelişmiş Mod

```
╔═════════════════════════════════════╗
║     GELİŞMİŞ KURULUM MENÜSÜ         ║
║  Yapmak istediğiniz işlemi seçin    ║
╚═════════════════════════════════════╝

Kategoriler:
  📦 Tam Kurulum (Tüm Araçlar)
  🎯 Çoklu Bileşen Seçimi (Multi-Select)
  ━━━ Python & JavaScript ━━━
  🐍 Python Ekosistemi (pip, pipx, uv)
  🟢 Node.js (NVM)
  ⚡ Bun.js Runtime
  ━━━ PRD Özel Özellikler ━━━
  🔍 Dotfiles Yöneticisi (Fuzzy Search)
  🌐 Windows Font Kontrolü (WSL)
  ━━━━━━━━━━━━━━━━━━━━━
  🔙 Ana Menüye Dön
  🚪 Çıkış
```

**Tam kontrol**: Her aracı tek tek seçin.

---

## 📊 PRD Uygunluk Raporu

Bu proje [Product Requirements Document (PRD)](docs/reports/dev-kurulun-cli-prd.md) standardına göre geliştirilmiştir.

| Gereksinim | Durum | Detay |
|------------|-------|-------|
| **FR-1.1** Ekran Temizleme | ✅ | `clear` + BANNER_SHOWN flag |
| **FR-1.2** Double Border Başlık | ✅ | Gum double border + Gold |
| **FR-1.3** Sistem Özeti | ✅ | WSL + Distro + User + Date |
| **FR-2.1** Multi-Select | ✅ | `gum choose --no-limit` |
| **FR-2.2** Fuzzy Search | ✅ | Dotfiles manager + `gum filter` |
| **FR-2.3** Masked Input | ✅ | `gum input --password` |
| **FR-3.1** Log Hiding | ✅ | Tüm işlemler spinner arkasında |
| **FR-3.2** Error Management | ✅ | 3 seçenek: Loglar/Retry/Skip |
| **FR-3.3** Windows Interop | ✅ | Font kontrolü + winget |
| **FR-4.1** Markdown Reports | ✅ | `gum format --type markdown` |
| **FR-4.2** Restart Countdown | ✅ | Görsel + renk kodlu |

### Genel Uygunluk: **99/100** ✅

**Kabul Kriterleri**:
- ✅ AC-1: Ham çıktı gizli (spinner arkasında)
- ✅ AC-2: Yuvarlatılmış kenarlı kutular (rounded border)
- ✅ AC-3: Tüm girdiler Gum üzerinden
- ✅ AC-4: Crimson & Gold teması %100 uygulanmış

---

## 🏗️ Mimari: Modüler ve Temiz

```
src/
├── linux-ai-setup-script.sh    # Entry point (150 satır)
├── lib/                        # Core libraries
│   ├── ai-text.sh             # 🤖 Typewriter + Thinking States
│   ├── gum-init.sh            # 🎨 Responsive Gum Wrappers
│   ├── windows-interop.sh     # 🖥️  WSL-Windows Bridge (YENİ!)
│   ├── system-restart.sh      # ⏱️  Visual Countdown (YENİ!)
│   └── ...
├── config/                     # Configuration
│   ├── theme.sh               # 🎨 Crimson & Gold (24-bit)
│   ├── constants.sh           # 📊 Magic Numbers → Named
│   ├── tool-versions.sh       # 📦 Smart Version Caching
│   └── banner.sh              # 🏛️  1453 WSL Architect Banner
└── modules/                    # Features
    ├── dotfiles.sh            # 🔍 Fuzzy Search Manager (YENİ!)
    ├── quickstart.sh          # 🚀 Beginner-Friendly UX
    ├── python.sh              # 🐍 Python Ecosystem
    ├── javascript.sh          # 🟨 JS/TS Ecosystem
    ├── ai-cli.sh              # 🤖 AI CLI Tools
    └── ...
```

**25 dosya, 9000+ satır kod**
**16 farklı fonksiyon kategorisi**
**Shellcheck clean**

---

## 🔒 Güvenlik: Hardened v2.2.0+

### Güvenlik Özellikleri
- ✅ **Zero eval()** - Tüm komut injection açıkları kapatıldı
- ✅ **SHA256 checksum** - Binary indirmeleri doğrulanıyor
- ✅ **Centralized versions** - GitHub API + offline fallback
- ✅ **Safe arrays** - Eval yerine array-based execution
- ✅ **Named constants** - Magic numbers eliminasyonu

### Güvenlik Seviyesi: **LOW RISK** ✅

---

## 📈 Versiyon Geçmişi

### v2.5.1 (2025-11-25) - PRD COMPLETE 🎯
- ✅ **Responsive Design** - Tüm box'lar merkeze otomatik hizalı
- ✅ **Visual Countdown** - Sistem restart countdown (FR-4.2)
- ✅ **Windows Font Check** - WSL-Windows interop (FR-3.3)
- ✅ **Dotfiles Manager** - Fuzzy search ile backup/restore (FR-2.2)
- ✅ **Banner Fix** - Banner artık sadece 1 kez gösteriliyor
- ✅ **Menu Fix** - Case statement pattern matching düzeltildi
- 📊 **PRD Compliance**: 95% → **99%**

### v2.5.0 (2025-11-24) - AI & UX Devrimi
- ✨ **AI Experience** - Typewriter, thinking states
- 🎨 **Crimson & Gold** - Premium tema
- ⚡ **Rate Limit Fix** - GitHub API caching
- 🚀 **Bootstrapping** - İlk anından modern UI

### v2.2.0 (2025-11-15) - Security Hardened
- 🔒 **Zero eval()** - Command injection fixed
- 🔐 **SHA256 verification** - Binary checksums
- 📦 **Centralized versions** - Smart caching

---

## 👨‍💻 Proje Ekibi

### 🎨 Vizyon Sahibi
**Alper Tunga** - Konsept ve Blueprint

### 💻 Lead Developer
**Tamer KARACA (A.K.A THE KING)** - Ana Geliştirici

### 🤝 Katkıda Bulunanlar
- **FitzGPT** - AI Asistan
- **Tuğser OKUR** - Contributor
- **Ravi DULUNDU** - Developer

---

## 🎓 Öğrenme Kaynakları

- 📘 [Product Requirements Document (PRD)](docs/reports/dev-kurulun-cli-prd.md)
- 📗 [API Reference](docs/API_REFERENCE.md)
- 📙 [LLM Coding Guide](docs/LLM_CODING_GUIDE.md)
- 📕 [Claude.md](CLAUDE.md) - AI yardımcısı için rehber

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz!

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

**PRD'ye uygunluk kontrol edin**: Yeni özellikler [PRD standartlarına](docs/reports/dev-kurulun-cli-prd.md) uymalıdır.

---

## 📜 Lisans

MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ravidulundu/1453-wsl-bash-script&type=Date)](https://star-history.com/#ravidulundu/1453-wsl-bash-script&Date)

---

<div align="center">

### ⭐ Beğendiniz mi? Yıldız verin!

**1453 WSL Architect** - *Form ve Fonksiyon Birliği*

[🏠 Ana Sayfa](https://github.com/ravidulundu/1453-wsl-bash-script) •
[📖 Dokümantasyon](docs/) •
[🐛 Issue Bildirin](https://github.com/ravidulundu/1453-wsl-bash-script/issues) •
[💬 Tartışmalar](https://github.com/ravidulundu/1453-wsl-bash-script/discussions)

---

*"Terminal sizin yaşam alanınız. Onu bir sanat eserine dönüştürün."*

**v2.5.1** | Crimson & Gold | PRD 99% Compliant

</div>
