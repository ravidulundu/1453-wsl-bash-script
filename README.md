# 🚀 1453 WSL Kurulum Scripti

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-WSL%20%7C%20Linux-blue.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![Version](https://img.shields.io/badge/Version-2.4.0-brightgreen.svg)](https://github.com/ravidulundu/1453-wsl-bash-script/releases)
[![Security](https://img.shields.io/badge/Security-Hardened-success.svg)](https://github.com/ravidulundu/1453-wsl-bash-script)

**AI geliştiricileri için Windows Subsystem for Linux (WSL) ve Linux ortamınızı tek komutla tam otomatik kurun!**

Modern, güvenli ve Türkçe arayüzlü tam otomatik geliştirme ortamı kurulum scripti. **40+ araç**, **8 AI CLI**, **3 AI Framework**, **75+ özel alias/fonksiyon** ve **modern TUI** ile geliştirme deneyiminizi bir üst seviyeye taşıyın.

---

## 📊 Hızlı Bakış

| Kategori | İçerik |
|----------|---------|
| **Versiyon** | v2.4.0 (2025-11-23) |
| **Durum** | ✅ Production-Ready |
| **Güvenlik** | 🔒 Hardened (safe_rm, hash clearing) |
| **Mimari** | 📦 Modüler (23 dosya, 8000+ satır) |
| **Diller** | Python, JavaScript, PHP, Go |
| **Araçlar** | 40+ geliştirme aracı |
| **AI** | 8 CLI + 3 Framework |
| **Platform** | WSL2 + Linux (APT/DNF/YUM/Pacman) |
| **Arayüz** | 🎨 Modern TUI (Charm Gum) |
| **Dil** | 🇹🇷 Tam Türkçe |

---

## ✨ Öne Çıkan Özellikler

### 🎯 Modern Kullanıcı Deneyimi

- ✅ **Tek Satır Kurulum** - `bash <(curl ...)` ile anında başlat
- ✅ **Modern TUI** - Charm Gum framework ile profesyonel arayüz
- ✅ **İki Kullanım Modu**:
  - 🚀 **Hızlı Başlangıç**: 5 hazır paket, tek tık kurulum
  - 🛠️ **Gelişmiş Mod**: 18 seçenek, detaylı kontrol
- ✅ **Akıllı Menüler** - İkon + metin, CLI standartlarına uygun
- ✅ **Canlı İlerleme** - Her adımda detaylı geri bildirim
- ✅ **Renk ve İkon Desteği** - Görsel olarak zengin terminal deneyimi

### 🔐 Güvenlik ve Kararlılık

- ✅ **safe_rm Koruması** - Kritik dizinlerin yanlışlıkla silinmesini engeller
- ✅ **Hash Cache Temizleme** - Binary path hatalarını önler
- ✅ **SHA256 Checksum** - İndirilen dosyaların güvenliği garanti
- ✅ **Command Injection Koruması** - 16 eval kullanımı elimine edildi
- ✅ **Path Validation** - Sistem dizinlerini koruma
- ✅ **Variable Safety** - `set -u` uyumlu değişken kullanımı
- ✅ **Tek Sudo Prompt** - Arka plan keep-alive ile sürekli şifre girişi yok

### 🛠️ Programlama Dilleri ve Araçlar

#### 🐍 Python Ekosistemi
- **Python 3.x** + **pip** (PEP 668 uyumlu)
- **pipx** - İzole Python uygulamaları
- **UV** - Ultra-hızlı paket yöneticisi

#### 🟨 JavaScript/TypeScript
- **NVM** - Node Version Manager
- **Node.js LTS** - Otomatik kurulum
- **Bun.js** - Modern JavaScript runtime

#### 🐘 PHP Ekosistemi
- **PHP 7.4 → 8.5** - Çoklu versiyon desteği
- **12 Extension** - Laravel-ready
- **Composer** - SHA384 doğrulamalı

#### 🐹 Go Language
- **Latest Stable** - GOPATH otomatik yapılandırma

#### 🐋 Docker
- **Docker Engine** + **Docker Compose**
- **lazydocker** - Terminal UI

### ⚡ Modern CLI Araçları (12 Araç)

| Araç | Açıklama | Yerine Geçtiği |
|------|----------|----------------|
| **bat** | Syntax highlighting'li cat | `cat` |
| **eza** | Modern ls (ikon + git) | `ls` |
| **ripgrep** | Çok hızlı grep | `grep` |
| **fd** | Basit ve hızlı find | `find` |
| **tree** | Dizin ağacı görüntüleyici | - |
| **starship** | Cross-shell prompt | PS1 |
| **zoxide** | Akıllı cd (AI-powered) | `cd` |
| **fzf** | Fuzzy finder | - |
| **vivid** | LS_COLORS generator | - |
| **fastfetch** | Sistem bilgisi | `neofetch` |
| **lazygit** | Terminal Git TUI | - |
| **lazydocker** | Terminal Docker TUI | - |

**✨ Yeni Eklenen:**
- ✅ `tree` - Otomatik kurulum (APT/DNF/Pacman)
- ✅ Hash cache temizleme - Kurulum sonrası komutlar anında tanınır

### 🤖 AI Geliştirme Araçları

#### AI CLI Tools (8 Araç)
1. **Claude Code CLI** - Anthropic Claude
2. **Gemini CLI** - Google Gemini
3. **GitHub CLI (gh)** - Resmi GitHub CLI
4. **GitHub Copilot CLI** - AI pair programmer
5. **Qoder CLI** - Modern AI kod asistanı
6. **OpenCode CLI** - Açık kaynak AI tool
7. **Qwen CLI** - Alibaba Qwen
8. **Kiro CLI** - Yeni AI development tool

#### AI Frameworks (3 Framework)
1. **SuperGemini** - Gemini-powered (MCP desteği)
2. **SuperQwen** - Qwen-powered (MCP desteği)
3. **SuperClaude** - Claude-powered (MCP desteği)

### 🎨 Shell Ortamı (75+ Alias ve Fonksiyon)

#### 🆕 Gelişmiş Navigasyon Alias'ları
```bash
..    # Bir üst dizin
...   # İki üst dizin
....  # Üç üst dizin
back  # Önceki dizine dön (cd -)
up    # cd .. (alternatif)
up2   # cd ../..
up3   # cd ../../..
```

#### 🆕 Gelişmiş Listeleme Alias'ları
```bash
ll    # Detaylı liste (eza ile, git bilgisi)
la    # Tüm dosyalar (gizli dahil)
lt    # Tree görünümü (2 seviye)
llt   # Detaylı tree (git bilgisi ile)
lh    # Sadece gizli dosyaları göster
tree  # Renkli dizin ağacı
```

#### 🆕 GitHub Otomasyon Fonksiyonları

**`ghnew` - Yeni Proje Oluştur ve GitHub'a Gönder**
```bash
ghnew my-awesome-project          # Public repo
ghnew my-private-project --private # Private repo
```
**Ne yapar:**
- ✅ Proje klasörü oluşturur
- ✅ Git başlatır
- ✅ README.md + .gitignore oluşturur
- ✅ İlk commit yapar
- ✅ GitHub'da repo oluşturur ve push eder
- ✅ Repo linkini gösterir

**`ghpush` - Hızlı Commit ve Push**
```bash
ghpush "feat: added new feature"  # Özel mesaj
ghpush                            # "Quick update" mesajı
```

**`ghclone` - Hızlı Clone ve CD**
```bash
ghclone username/repo-name
ghclone https://github.com/username/repo.git
```

#### Git Aliases (12)
```bash
g, gs, ga, gc, gp, gl, gco, gb, glog, gundo, gclean, gstash
```

#### Docker Aliases (12)
```bash
dps, dpsa, di, dex, dlog, dstop, drm, dclean, dc, dcup, dcdown
```

#### NPM/Node Aliases (8)
```bash
ni, nid, nig, ns, nb, nt, nrd
```

#### Python Aliases (5)
```bash
py, pip, venv, activate, deactivate
```

#### Özel Fonksiyonlar
```bash
mcd <dir>         # mkdir + cd birleşimi
mkexec <file>     # Dosyayı çalıştırılabilir yap
```

---

## 🚀 Kurulum

### Tek Satır Kurulum (Önerilen)

```bash
# curl ile (önerilen)
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)

# veya wget ile
bash <(wget -qO- https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

**Kurulum ne yapar:**

1. ✅ Charm Gum TUI framework'ünü yükler
2. ✅ 24 modüler dosyayı GitHub'dan indirir
3. ✅ `~/.1453-wsl-setup/` dizini oluşturur
4. ✅ Başlatıcı script hazırlar (`1453-setup`)
5. ✅ Hemen çalıştırmak ister misiniz sorar

**Kurulum sonrası dizin yapısı:**
```
~/.1453-wsl-setup/
├── 1453-setup                    # Başlatıcı script
├── templates/
│   └── starship.toml             # Starship config
└── src/
    ├── linux-ai-setup-script.sh  # Ana script
    ├── lib/                      # Core libraries
    ├── config/                   # Configuration
    └── modules/                  # Feature modules
```

### Manuel Kurulum

```bash
# Repository'yi klonla
git clone https://github.com/ravidulundu/1453-wsl-bash-script.git
cd 1453-wsl-bash-script

# Çalıştırılabilir yap ve başlat
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

### Kurulum Sonrası Çalıştırma

```bash
# Doğrudan çalıştırma
~/.1453-wsl-setup/1453-setup

# PATH'e ekle (isteğe bağlı)
echo 'export PATH="$HOME/.1453-wsl-setup:$PATH"' >> ~/.bashrc
source ~/.bashrc
1453-setup
```

---

## 📖 Kullanım Kılavuzu

### 1️⃣ Hızlı Başlangıç Modu

Ana menüden **"🚀 Hızlı Başlangıç (Önerilen)"** seçeneğini seçin.

#### 5 Hazır Paket:

1. **🌐 Web Geliştirme** - Python + Node + PHP
2. **🤖 AI Geliştirme** - Python + AI Tools
3. **⚙️ Backend Geliştirme** - Python + Go + PHP
4. **🚀 Her Şey** - Full Stack + AI
5. **📱 Mobil + Web** - Flutter + Node + PHP

**Tüm paketler otomatik içerir:**
- Modern CLI araçları (12 araç)
- Shell ortamı (75+ alias/fonksiyon)
- Python temeli (pip, pipx, UV)

### 2️⃣ Gelişmiş Mod

Ana menüden **"🛠️ Gelişmiş Mod"** seçeneğini seçin.

#### Menü Seçenekleri:

```
📦 Tam Kurulum (Tüm Araçlar)
🔧 Sistem Hazırlığı (Update + Git)
━━━ Python & JavaScript ━━━
🐍 Python Ekosistemi
🟢 Node.js (NVM)
⚡ Bun.js Runtime
━━━ Backend & Languages ━━━
🐘 PHP Kurulumu
🎼 Composer
🐹 Go Dili
━━━ AI & Modern Tools ━━━
🤖 AI CLI Araçları
🧠 AI Frameworks
🚀 Modern CLI Araçları
🐚 Shell Yapılandırması
━━━ Docker & Utilities ━━━
🐳 Docker Ortamı
━━━ Bakım & Onarım ━━━
🗑️ AI Frameworks Kaldır
⚠️ Temizleme ve Sıfırlama
━━━━━━━━━━━━━━━━━━━━━
🔙 Ana Menüye Dön
🚪 Çıkış
```

---

## 🎮 Kurulum Sonrası Kullanım

### Modern CLI Araçları

```bash
# Modern ls (eza)
ll              # Detaylı liste (git bilgisi ile)
la              # Tüm dosyalar (gizli dahil)
lt              # Tree görünümü (2 seviye)
llt             # Detaylı tree
lh              # Sadece gizli dosyalar

# Modern cat (bat)
cat file.py     # Syntax highlighting

# Hızlı arama (ripgrep)
rg "TODO"       # Tüm dosyalarda ara
rg -i "error"   # Case-insensitive

# Akıllı cd (zoxide)
z project       # Sık kullanılan dizine git
zi              # Interactive seçim

# Fuzzy finder (fzf)
Ctrl+R          # Komut geçmişinde ara

# Git & Docker TUI
lazygit         # Terminal Git arayüzü
lazydocker      # Terminal Docker arayüzü
```

### 🆕 GitHub Otomasyon

```bash
# Yeni proje oluştur ve GitHub'a gönder
ghnew my-app
ghnew my-private-app --private

# Hızlı commit ve push
ghpush "feat: added cool feature"
ghpush  # "Quick update" mesajı ile

# Repo klonla ve içine gir
ghclone username/repo-name
```

### Navigasyon

```bash
..              # Bir üst dizin
...             # İki üst dizin
back            # Önceki dizine dön
up / up2 / up3  # Üst dizinlere git
mkcd new-dir    # Dizin oluştur ve gir
```

### Git Aliases

```bash
g               # git
gs              # git status -s
ga .            # git add .
gc "msg"        # git commit -m
gp              # git push
gl              # git log --oneline --graph
```

### Docker Aliases

```bash
dps             # docker ps
dpsa            # docker ps -a
di              # docker images
dex container   # docker exec -it
dlog container  # docker logs -f
dstop           # Tüm container'ları durdur
dclean          # Kullanılmayan her şeyi temizle
```

---

## 🔐 Güvenlik Özellikleri

### safe_rm Koruması

Kritik dizinlerin yanlışlıkla silinmesini engeller:
- `/` - Root dizini
- `$HOME` - Kullanıcı ana dizini
- `/usr`, `/bin`, `/etc` - Sistem dizinleri

**Kullanım:**
```bash
# Script'te otomatik kullanılır
safe_rm "$temp_dir"  # Güvenli silme
```

### Hash Cache Temizleme

Binary konumu değişen araçlar için (örn: starship `/usr/local/bin` → `/usr/bin`):
```bash
# Otomatik olarak yapılır
hash -r  # Komut cache'ini temizle
```

### Checksum Doğrulama

İndirilen binary dosyalar SHA256 ile doğrulanır:
```bash
# Otomatik doğrulama
download_with_checksum "$url" "$file" "$checksum_url"
```

---

## 🗑️ Temizleme ve Sıfırlama

Script'ten **"⚠️ Temizleme ve Sıfırlama"** menüsünü seçin.

### Temizleme Seçenekleri:

1. **🔥 Tam Sıfırlama** - Her şeyi sil (GERİ ALINAMAZ!)
2. **🗑️ Sadece Kurulumlar** - Araçları sil, config'leri koru
3. **🎯 Tek Tek Temizle** - İstediğini seç
4. **📝 Sadece Config Temizle** - Config'leri temizle, araçları bırak
5. **📋 Kurulu Olanları Göster** - Bilgi amaçlı

**Güvenlik:**
- ✅ Çift onay sistemi
- ✅ Otomatik yedek seçeneği
- ✅ Detaylı uyarılar

---

## 📁 Proje Mimarisi

```
1453-wsl-bash-script/
├── install.sh                      # Tek satır installer
├── README.md                       # Bu dosya
├── BUG_FIX_REPORT.md               # Güvenlik raporu
│
├── src/
│   ├── linux-ai-setup-script.sh    # Entry point
│   │
│   ├── lib/                        # Core libraries (5 dosya)
│   │   ├── init.sh                 # CRLF fix
│   │   ├── common.sh               # safe_rm, checksums
│   │   ├── package-manager.sh      # Paket yöneticisi
│   │   ├── installation-tracker.sh # Kurulum takibi
│   │   └── tui.sh                  # Gum wrappers
│   │
│   ├── config/                     # Configuration (5 dosya)
│   │   ├── colors.sh
│   │   ├── constants.sh
│   │   ├── tool-versions.sh
│   │   ├── php-versions.sh
│   │   └── banner.sh
│   │
│   └── modules/                    # Features (12 dosya)
│       ├── quickstart.sh           # Hızlı Başlangıç
│       ├── python.sh               # Python
│       ├── javascript.sh           # Node, Bun
│       ├── php.sh                  # PHP
│       ├── go.sh                   # Go
│       ├── docker.sh               # Docker
│       ├── modern-tools.sh         # Modern CLI (+tree)
│       ├── shell-setup.sh          # Shell (+ghnew, ghpush)
│       ├── ai-cli.sh               # AI CLI
│       ├── ai-frameworks.sh        # AI Frameworks
│       ├── cleanup.sh              # safe_rm cleanup
│       └── menus.sh                # Menü sistemi
│
└── templates/
    └── starship.toml               # Starship config
```

---

## 🔄 Versiyon Geçmişi

### v2.4.0 (2025-11-23) - 🎨 UI ve GitHub Otomasyon

**✨ Yeni Özellikler:**
- 🎨 Charm Gum ile modern TUI
- 🆕 GitHub otomasyon fonksiyonları (ghnew, ghpush, ghclone)
- 🆕 Gelişmiş navigasyon alias'ları (back, up, up2, up3)
- 🆕 Gelişmiş listeleme alias'ları (lt, llt, lh)
- 📦 tree otomatik kurulumu (12. modern araç)

**🔐 Güvenlik İyileştirmeleri:**
- ✅ safe_rm fonksiyonu (kritik dizin koruması)
- ✅ Hash cache temizleme (binary path hataları önleniyor)
- ✅ Starship init hata düzeltmesi

**🎯 UI İyileştirmeleri:**
- ✅ İkon + metin standardizasyonu
- ✅ gum style entegrasyonu (banner, menüler, onaylar)
- ✅ Tutarlı renk şeması

### v2.3.x (2025-11) - Güvenlik ve Kararlılık
- 🔒 16 command injection riski elimine edildi
- ✅ SHA256 checksum doğrulama
- ✅ PEP 668 uyumu

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz!

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing`)
3. Commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Push edin (`git push origin feature/amazing`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje [MIT License](LICENSE.md) ile lisanslanmıştır.

---

## 👨‍💻 Geliştirici

**Ravid Ulundu** - [@ravidulundu](https://github.com/ravidulundu)

**Proje Linki:** [https://github.com/ravidulundu/1453-wsl-bash-script](https://github.com/ravidulundu/1453-wsl-bash-script)

---

## 🙏 Teşekkürler

Bu projeyi mümkün kılan harika açık kaynak projelere teşekkürler:

- [Charm Gum](https://github.com/charmbracelet/gum) - Modern TUI
- [Starship](https://starship.rs) - Cross-shell prompt
- [eza](https://github.com/eza-community/eza) - Modern ls
- [bat](https://github.com/sharkdp/bat) - Cat clone
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast grep
- [fd](https://github.com/sharkdp/fd) - Fast find
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

---

## 📞 Destek

Sorun mu yaşıyorsunuz? Yardım almak için:

1. [Issues](https://github.com/ravidulundu/1453-wsl-bash-script/issues) sayfasını kontrol edin
2. Yeni bir issue açın
3. Detaylı açıklama ve log çıktıları ekleyin

---

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!**
