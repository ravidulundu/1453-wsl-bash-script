# 🚀 1453 WSL Kurulum Betiği

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-WSL%20%7C%20Linux-blue.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![Version](https://img.shields.io/badge/Version-2.3.2-brightgreen.svg)](https://github.com/ravidulundu/1453-wsl-bash-script/releases)
[![Security](https://img.shields.io/badge/Security-Hardened-success.svg)](https://github.com/ravidulundu/1453-wsl-bash-script)

**AI geliştiricileri için Windows Subsystem for Linux (WSL) ortamınızı tek komutla tam otomatik kurun!**

Modern, güvenli ve Türkçe arayüzlü tam otomatik geliştirme ortamı kurulum betiği. 40+ araç, 8 AI CLI, 3 AI Framework ve 62+ özel alias ile geliştirme deneyiminizi bir üst seviyeye taşıyın.

![WSL CLI Arayüzü](docs/wsl-cli.png)

---

## 📊 Hızlı Bakış

| Kategori | İçerik |
|----------|---------|
| **Versiyon** | 2.3.2 (2025-11-20) |
| **Durum** | ✅ Production-Ready |
| **Güvenlik** | 🔒 LOW Risk (Hardened) |
| **Mimari** | 📦 Modüler (23 dosya, 7,614 satır) |
| **Diller** | Python, JavaScript, PHP, Go |
| **Araçlar** | 40+ geliştirme aracı |
| **AI** | 8 CLI + 3 Framework |
| **Platform** | WSL + Linux (APT/DNF/YUM/Pacman) |
| **Arayüz** | 🎨 Modern TUI (Gum Framework) |
| **Dil** | 🇹🇷 Tam Türkçe |

---

## ✨ Öne Çıkan Özellikler

### 🎯 Kurulum ve Kullanım

- ✅ **Tek Satır Kurulum** - `bash <(curl ...)` ile anında başlat
- ✅ **Modern TUI** - Gum framework ile profesyonel terminal arayüzü
- ✅ **Responsive Tasarım** - Terminal genişliğine göre otomatik düzenleme
- ✅ **İki Kullanım Modu**:
  - 🚀 **Hızlı Başlangıç**: 5 hazır paket, tek tık kurulum (yeni başlayanlar için)
  - 🔧 **Gelişmiş Mod**: 18 seçenek, detaylı kontrol (profesyoneller için)
- ✅ **Modüler Mimari** - 23 dosyaya ayrılmış temiz, bakımı kolay yapı
- ✅ **Akıllı Kurulum Takibi** - Başarı/hata/atlanan kurulumları detaylı raporlama

### 🔐 Güvenlik

- ✅ **Sıfırlanmış Command Injection** - 16 eval kullanımı kaldırıldı
- ✅ **SHA256 Checksum Doğrulama** - Binary dosyaların güvenliği garanti
- ✅ **Güvenli Paket Yönetimi** - Array-based safe execution pattern
- ✅ **Path Validation** - Sistem dizinlerini koruma
- ✅ **Variable Safety** - `set -u` uyumlu değişken kullanımı
- ✅ **Tek Sudo Prompt** - Arka plan keep-alive ile sürekli şifre girişi yok
- ✅ **Çift Onay Sistemi** - Kritik işlemler için güvenlik kontrolü

### 🛠️ Programlama Dilleri ve Ekosistemler

#### 🐍 Python Ekosistemi
- **Python 3.x** - Sistem Python
- **pip** - PEP 668 uyumlu (`--break-system-packages` desteği)
- **pipx** - İzole Python uygulamaları
- **UV** - Ultra-hızlı Python paket yöneticisi (astral.sh)

#### 🟨 JavaScript/TypeScript Ekosistemi
- **NVM v0.40.3** - Node Version Manager
  - Node.js LTS otomatik kurulum
  - npm dahil
- **Bun.js** - Modern JavaScript runtime
  - Hızlı paket yöneticisi
  - Native TypeScript desteği

#### 🐘 PHP Ekosistemi
- **PHP 7.4, 8.1, 8.2, 8.3, 8.4, 8.5** - Çoklu versiyon desteği
- **12 PHP Extension**: mbstring, zip, gd, tokenizer, curl, xml, bcmath, intl, sqlite3, pgsql, mysql, fpm
- **Composer** - Latest (SHA384 doğrulamalı)
- **Laravel Ready** - Tüm Laravel gereksinimleri dahil
- **update-alternatives** - Kolay versiyon değiştirme

#### 🐹 Go Language
- **Latest Stable Go**
- **GOPATH/GOROOT** - Otomatik ortam yapılandırması
- **Shell Entegrasyonu** - PATH güncellemeleri

#### 🐋 Docker Ekosistemi
- **Docker Engine** - Latest stable
- **Docker Compose** - Container orchestration
- **lazydocker** - Terminal Docker UI

### ⚡ Modern CLI Araçları (11 Araç)

| Araç | Açıklama | Yerine Geçtiği |
|------|----------|----------------|
| **bat** | Syntax highlighting'li cat | `cat` |
| **eza** | Modern ls (ikon + git desteği) | `ls` |
| **ripgrep (rg)** | Çok hızlı grep | `grep` |
| **fd** | Basit ve hızlı find | `find` |
| **starship** | Hızlı cross-shell prompt | PS1 |
| **zoxide** | Akıllı cd (frecency algorithm) | `cd` |
| **fzf** | Fuzzy finder | - |
| **vivid** | LS_COLORS generator | - |
| **fastfetch** | Sistem bilgisi (Catppuccin tema) | `neofetch` |
| **lazygit** | Terminal Git TUI | - |
| **lazydocker** | Terminal Docker TUI | - |

**Özel Özellikler:**
- ✅ Ubuntu için otomatik symlink (`batcat` → `bat`, `fdfind` → `fd`)
- ✅ GitHub API'den dinamik versiyon çekme
- ✅ Offline fallback versiyonlar
- ✅ Binary dosyalar için SHA256 checksum doğrulama

### 🤖 AI Geliştirme Araçları

#### AI CLI Tools (8 Araç)

1. **Claude Code CLI** - Anthropic Claude resmi CLI
   - Komut: `claude`
   - Doğrudan resmi installer
2. **Gemini CLI** - Google Gemini AI
   - Python package: `google-generativeai`
3. **GitHub CLI (gh)** - Resmi GitHub CLI
4. **GitHub Copilot CLI** - AI pair programmer
   - npm package: `@githubnext/github-copilot-cli`
5. **Qoder CLI** - Modern AI kod asistanı
6. **OpenCode CLI** - Açık kaynak AI coding tool
7. **Qwen CLI** - Alibaba Qwen AI model
8. **Kiro CLI** - En yeni AI development tool

#### AI Frameworks (3 Framework)

1. **SuperGemini** - Gemini-powered framework (pipx)
2. **SuperQwen** - Qwen-powered framework (pipx)
3. **SuperClaude** - Claude-powered framework (pipx)

**Tüm frameworkler:**
- ✅ MCP (Model Context Protocol) desteği
- ✅ İzole kurulum (pipx)
- ✅ Otomatik bağımlılık yönetimi

### 🎨 Shell Ortamı Özelleştirmeleri

#### 62+ Özel Alias

**Git Aliases (10)**
```bash
g, gs, ga, gc, gp, gl, glog, gundo, gclean, gstash
```

**Navigasyon (5)**
```bash
.., ..., ...., ....., ~
```

**Dizin İşlemleri (10)**
```bash
ll, la, lt, lh, tree, mkcd, back, up
```

**Dosya İşlemleri (8)**
```bash
rm, cp, mv, cat, grep, find, disk, space
```

**Docker (12)**
```bash
dps, dpsa, di, drm, drmi, dstop, dclean, dlog, dex, dc, dcup, dcdown
```

**NPM/Node (8)**
```bash
ni, nid, nig, nis, ns, nb, nt, nrd
```

**Python (5)**
```bash
py, pip, venv, activate, deactivate
```

**Sistem (4)**
```bash
ports, myip, weather, c (clear)
```

#### Özel Bash Fonksiyonları

- **mcd** - mkdir + cd birleşimi
- **extract** - Universal arşiv açıcı (zip, tar, gz, etc.)
- **backup** - Zaman damgalı dosya yedeği
- **serve** - Basit HTTP server (Python)

#### Gelişmiş Yapılandırmalar

**Bash History:**
- 100,000 komut hafızası
- 200,000 satır dosya boyutu
- Duplicate control

**Entegrasyonlar:**
- ✅ **FZF** - Ctrl+R ile komut geçmişi arama
- ✅ **Starship** - Catppuccin Mocha temalı prompt
- ✅ **Zoxide** - Akıllı dizin atlama
- ✅ **Vivid** - Gelişmiş LS_COLORS

**Değiştirilen Dosyalar:**
- `~/.bash_aliases` - Tüm aliaslar (oluşturulur)
- `~/.bashrc` - START/END marker'lı güvenli ekleme
- `~/.config/starship.toml` - Starship yapılandırması

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

1. ✅ Modern Gum TUI framework'ünü yükler
2. ✅ 24 modüler dosyayı GitHub'dan indirir
   - 1 ana script
   - 5 core library
   - 5 configuration
   - 12 feature module
   - 1 template
3. ✅ `~/.1453-wsl-setup/` dizini oluşturur
4. ✅ Başlatıcı script hazırlar (`1453-setup`)
5. ✅ Hemen çalıştırmak ister misiniz sorar (e/E=Evet)

**Kurulum sonrası dizin yapısı:**
```
~/.1453-wsl-setup/
├── 1453-setup                     # Başlatıcı script
├── templates/
│   └── starship.toml              # Starship config
└── src/
    ├── linux-ai-setup-script.sh   # Ana script
    ├── lib/ (5 dosya)             # Core libraries
    ├── config/ (5 dosya)          # Configuration
    └── modules/ (12 dosya)        # Feature modules
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

# Veya alias oluştur (isteğe bağlı)
echo 'alias 1453="$HOME/.1453-wsl-setup/1453-setup"' >> ~/.bashrc
source ~/.bashrc
1453
```

### Güncelleme

```bash
# Installer'ı tekrar çalıştır (dosyalar üzerine yazılır)
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

---

## 📖 Kullanım Kılavuzu

### 1️⃣ Hızlı Başlangıç Modu (Yeni Başlayanlar)

Script'i başlattığınızda mod seçimi gelir. **"Hızlı Başlangıç"** modunu seçin.

#### 5 Hazır Paket

```
┌─────────────────────────────────────────────────────┐
│  Hangi geliştirme ortamı kurulumunu istersiniz?    │
└─────────────────────────────────────────────────────┘

1) 🌐 Web Geliştirme
   → Python + Node.js + PHP + Composer
   → Modern CLI Tools + Shell

2) 🤖 AI Geliştirme
   → Python + AI CLI Tools + AI Frameworks
   → Modern CLI Tools + Shell

3) 🔧 Backend Geliştirme
   → Python + Go + PHP + Composer
   → Modern CLI Tools + Shell

4) 🚀 Her Şey (Full Stack)
   → Tüm diller + Tüm AI araçları
   → Docker + Tüm modern toollar

5) 📱 Mobil + Web
   → Python + Node.js + PHP
   → Modern CLI Tools + Shell
```

**Tüm paketler otomatik olarak içerir:**
- ✅ Modern CLI araçları (bat, eza, ripgrep, fd, starship, zoxide, fzf, vivid, fastfetch, lazygit)
- ✅ Shell ortamı (62+ alias, özel fonksiyonlar)
- ✅ Bash konfigürasyonu (history, FZF, Starship)
- ✅ Python temeli (Python 3, pip, pipx, UV)

**Örnek Kullanım:**
```
┌─────────────────────────────────────┐
│ Hangi paketi kurmak istersiniz?     │
└─────────────────────────────────────┘
  > 🤖 AI Geliştirme (Claude, Gemini, SuperFrameworks)
    🌐 Full-Stack (Python, Node.js, PHP, Docker)
    🐍 Python Developer (Python + Modern Tools)

✅ AI Geliştirme paketi seçildi

📦 Kurulacak araçlar:
  • Python 3.x
  • pip (PEP 668 uyumlu)
  • pipx
  • UV
  • Claude Code CLI
  • Gemini CLI
  • GitHub CLI
  • SuperGemini Framework
  • SuperClaude Framework
  • Modern CLI Tools (11 araç)
  • Shell Ortamı (62+ alias)

Kuruluma başlansın mı? (e/E)
```

### 2️⃣ Gelişmiş Mod (Profesyoneller)

Script'i başlattığınızda **"Gelişmiş Mod"** seçin veya Quick Start'ı atlayın.

#### 18 Detaylı Seçenek

```
┌─────────────────────────────────────────────────────┐
│           1453 WSL Setup - Ana Menü                 │
└─────────────────────────────────────────────────────┘

  🚀 Tam Kurulum (Her şey)
  🔧 Sistem Hazırlık (güncelleme + Git)
  🐍 Python Ekosistemi
  📦 Pip Güncelleme
  🔌 Pipx Kurulumu
  ⚡ UV Kurulumu (ultra-fast pip)
  🟨 NVM (Node.js Version Manager)
  🥟 Bun.js
> 🐘 PHP Versiyonları
  🎼 Composer
  🤖 AI CLI Araçları
  🧠 AI Frameworkleri
  🗑️ AI Framework Kaldırma
  🐹 Go Language
  ⚡ Modern CLI Araçları
  🎨 Shell Ortamı
  🗑️ Temizleme ve Sıfırlama
  🐋 Docker
  ━━━━━━━━━━━━━━━━━━━━━
  ◀ Çıkış
```

**Tam Kurulum Seçeneği:**
- Tüm programlama dillerini kurar
- Tüm AI araçlarını kurar
- Tüm modern CLI toolları kurar
- Tam shell ortamı yapılandırması
- Docker kurulumu

**Tekil Kurulum:**
Her seçenek ayrı ayrı çalıştırılabilir. Örneğin sadece Python kurmak, sadece Docker kurmak, sadece shell ortamını güncellemek mümkün.

---

## 📁 Proje Mimarisi

### Dizin Yapısı

```
1453-wsl-bash-script/
├── install.sh                       # Tek satır installer (519 satır)
├── test-setup.sh                    # Validation script (1,337 satır)
├── README.md                        # Bu dosya
├── CLAUDE.md                        # Geliştirici kılavuzu (29,156 satır)
├── LICENSE.md                       # MIT Lisansı
│
├── src/                             # Ana kaynak dizin (7,614 satır)
│   ├── linux-ai-setup-script.sh     # Entry point (152 satır)
│   │
│   ├── lib/                         # Core kütüphaneler (5 dosya)
│   │   ├── init.sh                  # CRLF fix + başlatma
│   │   ├── common.sh                # Ortak fonksiyonlar
│   │   ├── package-manager.sh       # Paket yöneticisi tespiti
│   │   ├── installation-tracker.sh  # Kurulum takibi
│   │   └── tui.sh                   # Gum TUI wrapper'ları
│   │
│   ├── config/                      # Yapılandırma (5 dosya)
│   │   ├── colors.sh                # Terminal renkleri
│   │   ├── constants.sh             # Global sabitler
│   │   ├── tool-versions.sh         # Versiyon yönetimi
│   │   ├── php-versions.sh          # PHP konfigürasyonu
│   │   └── banner.sh                # ASCII banner
│   │
│   └── modules/                     # Feature modülleri (12 dosya)
│       ├── quickstart.sh            # Hızlı Başlangıç modu
│       ├── python.sh                # Python ekosistemi
│       ├── javascript.sh            # Node.js, Bun
│       ├── php.sh                   # PHP versiyonları
│       ├── go.sh                    # Go language
│       ├── docker.sh                # Docker
│       ├── modern-tools.sh          # Modern CLI tools
│       ├── shell-setup.sh           # Shell ortamı
│       ├── ai-cli.sh                # AI CLI araçları
│       ├── ai-frameworks.sh         # AI frameworkleri
│       ├── cleanup.sh               # Temizleme sistemi
│       └── menus.sh                 # Menü sistemi
│
├── templates/                       # Konfigürasyon şablonları
│   └── starship.toml                # Starship prompt (Catppuccin Mocha)
│
├── docs/                            # Dokümantasyon (4 MD + reports)
│   ├── INDEX.md
│   ├── PROJECT_OVERVIEW.md
│   ├── API_REFERENCE.md (28,485 satır)
│   ├── LLM_CODING_GUIDE.md
│   ├── how-to-install-go-on-linux.md
│   ├── wsl-cli.png
│   └── reports/ (4 bug report + plan)
│
├── scripts/                         # Yardımcı scriptler (7 dosya)
│   ├── fix-crlf.sh
│   ├── validate-cleanup.sh
│   └── ...
│
└── tests/                           # Test dosyaları
    ├── README.md
    └── test_cleanup_fix.sh
```

### Modül Yükleme Sırası

**Kritik yükleme sırası** (bağımlılık zinciri):

```
1. lib/init.sh              # CRLF düzeltme (ilk)
2. config/*.sh              # Tüm yapılandırmalar
3. lib/*.sh                 # Core kütüphaneler
4. modules/*.sh             # Feature modülleri
5. modules/menus.sh         # Menü sistemi (son, hepsine bağımlı)
```

**Bağımlılık Grafiği:**

```
menus.sh
└── TÜM modüllere bağımlı

ai-cli.sh
├── python.sh (pipx için)
├── javascript.sh (npm için)
└── package-manager.sh

ai-frameworks.sh
└── python.sh (pipx için)

python.sh, javascript.sh, php.sh, go.sh, docker.sh
├── package-manager.sh
└── common.sh

modern-tools.sh
├── package-manager.sh
├── common.sh
└── tool-versions.sh

shell-setup.sh
└── common.sh

quickstart.sh
└── TÜM feature modüllerine bağımlı

cleanup.sh
├── package-manager.sh
└── common.sh
```

---

## 🎮 Kurulum Sonrası Kullanım

### Modern CLI Araçları

```bash
# Modern ls (eza) - ikonlar ve Git durumu
ll                    # Detaylı liste
la                    # Tüm dosyalar (gizli dahil)
lt                    # Ağaç görünümü

# Modern cat (bat) - syntax highlighting
cat dosya.py          # Renkli Python kodu
bat dosya.json        # JSON formatting

# Hızlı arama (ripgrep)
rg "fonksiyon"        # Tüm dosyalarda ara
rg -i "hatA"          # Case-insensitive
rg "TODO" --type py   # Sadece Python dosyalarında

# Modern find (fd)
fd "*.py"             # Python dosyalarını bul
fd -e js              # JS uzantılı dosyalar

# Akıllı cd (zoxide)
z proje               # Sık kullanılan dizine git
zi                    # Interactive seçim

# Fuzzy finder (fzf)
Ctrl+R                # Komut geçmişinde ara
ls | fzf              # Liste içinde ara

# Git TUI
lazygit               # Terminal Git arayüzü
lg                    # Alias (eğer kurulduysa)

# Docker TUI
lazydocker            # Terminal Docker arayüzü
ld                    # Alias (eğer kurulduysa)

# Sistem bilgisi
fastfetch             # Renkli sistem özeti
```

### Git Aliases

```bash
g                     # git
gs                    # git status
ga .                  # git add .
gc "mesaj"            # git commit -m
gp                    # git push
gl                    # git pull
glog                  # git log --oneline --graph
gundo                 # Son commit'i geri al
gclean                # Branch temizliği
gstash                # Değişiklikleri sakla
```

### Docker Aliases

```bash
dps                   # docker ps
dpsa                  # docker ps -a
di                    # docker images
dex container         # docker exec -it
dlog container        # docker logs -f
dstop                 # Tüm container'ları durdur
dclean                # Kullanılmayan her şeyi temizle

# Docker Compose
dc                    # docker compose
dcup                  # docker compose up -d
dcdown                # docker compose down
```

### NPM/Node Aliases

```bash
ni                    # npm install
nid                   # npm install --save-dev
nig                   # npm install -g
nis                   # npm install --save
ns                    # npm start
nb                    # npm run build
nt                    # npm test
nrd                   # npm run dev
```

### Python Aliases

```bash
py                    # python3
pip                   # python3 -m pip
venv                  # python3 -m venv
activate              # source venv/bin/activate
deactivate            # deactivate
```

### Özel Fonksiyonlar

```bash
# Dizin oluştur ve içine gir
mcd yeni-proje
# mkdir -p yeni-proje && cd yeni-proje

# Arşiv aç (universal extractor)
extract dosya.tar.gz
extract dosya.zip
extract dosya.rar

# Dosya yedeği (timestamp ile)
backup önemli.txt
# Oluşturur: önemli.txt.backup-20250120_143022

# Basit HTTP server
serve
# Python HTTP server başlatır (port 8000)
```

### Sistem Aliases

```bash
ports                 # Açık portları listele
myip                  # Dış IP adresini göster
c                     # clear (ekranı temizle)
```

---

## ✅ Test ve Doğrulama

### Validation Script

Script kurulumdan sonra ne kuruldu, ne kurulmadı kontrol edebilirsiniz:

```bash
# Temel test
./test-setup.sh

# Detaylı çıktı
./test-setup.sh --verbose

# JSON formatında rapor
./test-setup.sh --json > report.json

# Log dosyasına kaydet
./test-setup.sh --log kurulum-raporu.log

# Snapshot mod (tam sistem analizi)
./test-setup.sh --snapshot
```

### Test Kategorileri (15 Kategori)

1. **Sistem Bilgileri** - OS, kernel, WSL versiyonu, paket yöneticisi
2. **Temel Araçlar** - git, curl, wget, jq, build-essential
3. **Python Ekosistemi** - Python, pip, pipx, UV versiyonları
4. **JavaScript Ekosistemi** - NVM, Node.js, npm, Bun.js
5. **PHP Ekosistemi** - PHP versiyonları, Composer, extensionlar
6. **Go Language** - Go versiyonu, GOPATH, GOROOT
7. **Modern CLI Tools** - 11 aracın durumu ve versiyonları
8. **Shell Ortamı** - .bash_aliases, .bashrc, fonksiyonlar
9. **AI CLI Tools** - 8 AI aracının kurulum durumu
10. **AI Frameworks** - 3 framework'ün durumu
11. **Docker** - Docker Engine, Compose, lazydocker
12. **Kurulum Dizini** - ~/.1453-wsl-setup/ yapısı
13. **Bash Aliases** - 62+ alias'ın varlığı
14. **Eksik Yüklemeler** - Kurulmamış olanlar
15. **Fonksiyonel Testler** - Komutların çalışırlığı

### Örnek Çıktı

```
====================================
   Kurulum Doğrulama Testi
   Version: 2.3.2
====================================

[1/15] Sistem Bilgileri...
  ✓ İşletim Sistemi: Ubuntu 22.04.3 LTS
  ✓ Kernel: 5.15.90.1-microsoft-standard-WSL2
  ✓ WSL Versiyonu: WSL2
  ✓ Paket Yöneticisi: apt

[2/15] Temel Araçlar...
  ✓ git: 2.34.1
  ✓ curl: 7.81.0
  ✓ wget: 1.21.2
  ✓ jq: 1.6
  ✓ gcc: 11.4.0

[3/15] Python Ekosistemi...
  ✓ Python: 3.10.12
  ✓ pip: 24.0
  ✓ pipx: 1.4.3
  ✓ UV: 0.1.6

...

====================================
   Test Özeti
====================================
Toplam Test: 156
Başarılı: 152 ✓
Başarısız: 2 ✗
Uyarı: 2 ⚠

Başarı Oranı: 97.4%
Süre: 3.2 saniye

Başarısız Testler:
  ✗ PHP 8.5 kurulu değil
  ✗ SuperQwen framework kurulu değil

Uyarılar:
  ⚠ Docker daemon çalışmıyor
  ⚠ Go GOPATH ayarlanmamış
```

---

## 🗑️ Temizleme ve Sıfırlama

Script'ten **"Temizleme ve Sıfırlama"** menüsünü seçin.

### 5 Temizleme Seçeneği

```
┌──────────────────────────────────────────┐
│     Temizleme ve Sıfırlama Menüsü        │
└──────────────────────────────────────────┘

1) 🔥 Tam Sıfırlama (GERİ ALINAMAZ!)
   → Her şeyi sil (paketler + config + dizin)
   → WSL'i temiz kurulum haline döndür

2) 🗑️ Sadece Kurulumlar
   → Araçları sil
   → Config dosyalarını koru (.bashrc, aliaslar)

3) 🎯 Tek Tek Temizle
   → Python, JavaScript, PHP, Go, Docker, Modern Tools
   → AI CLI, AI Frameworks, Shell Config
   → İstediğini seç

4) 📝 Sadece Config Temizle
   → .bash_aliases sil
   → .bashrc'den modifikasyonları kaldır
   → Araçları olduğu gibi bırak

5) 📋 Kurulu Olanları Göster
   → Nelerin kurulu olduğunu listele
   → Zararsız, sadece bilgi

0) Geri Dön
```

### Temizleme Detayları

#### 1. Tam Sıfırlama (Full Reset)

**Siler:**
- Tüm sistem paketleri (jq, zip, unzip, p7zip, build-essential)
- Development Tools group (DNF/YUM)
- base-devel (Pacman)
- Python (pipx, UV, pip cache)
- Node.js (NVM, Bun.js)
- PHP (tüm versiyonlar, Composer, Ondřej PPA)
- Go (GOPATH temizliği)
- Modern CLI tools (tüm 11 araç + symlink'ler)
- AI CLI tools (tüm 8 araç)
- AI Frameworks (tüm 3 framework + MCP)
- Docker (Engine, Compose, lazydocker)
- Shell config (.bash_aliases, .bashrc düzenlemeleri)
- Kurulum dizini (~/.1453-wsl-setup/)

**Korur:**
- curl, wget, git (sistem kritik)
- Kullanıcı dosyaları

**Güvenlik:**
- Çift onay gerektirir
- Otomatik yedek sunar

#### 2. Sadece Kurulumlar

**Siler:**
- Tüm araçlar ve paketler

**Korur:**
- .bashrc
- .bash_aliases
- Shell konfigürasyonları
- Kurulum dizini

#### 3. Tek Tek Temizle

Alt menü açılır, seçim yaparsınız:

```
Hangi bileşeni temizlemek istiyorsunuz?

1) Python Ekosistemi
2) JavaScript (NVM, Bun)
3) PHP Ekosistemi
4) Go Language
5) Docker
6) Modern CLI Tools
7) AI CLI Tools
8) AI Frameworks
9) Shell Konfigürasyonu
```

#### 4. Sadece Config

**Siler:**
- ~/.bash_aliases
- ~/.bashrc'deki START/END marker'lı bölümler
- ~/.config/starship.toml

**Korur:**
- Tüm kurulumlar olduğu gibi kalır

#### 5. Kurulu Olanları Göster

Zararsız bilgi görüntüleme. Çıktı örneği:

```
====================================
   Kurulu Araçlar ve Versiyonlar
====================================

Python Ekosistemi:
  ✓ Python 3.10.12
  ✓ pip 24.0
  ✓ pipx 1.4.3
  ✓ UV 0.1.6

JavaScript Ekosistemi:
  ✓ NVM 0.40.3
  ✓ Node.js 20.11.0
  ✓ Bun 1.0.23

Modern CLI Tools:
  ✓ bat 0.24.0
  ✓ eza 0.18.0
  ✓ ripgrep 14.1.0
  ...

AI Tools:
  ✓ Claude Code CLI
  ✓ GitHub CLI 2.42.0
  ✗ Gemini CLI (kurulu değil)
  ...
```

### Güvenlik Önlemleri

**Yedekleme Sistemi:**
```
Temizlemeden önce yedek oluşturulsun mu? (e/E)

✓ Yedek oluşturuluyor...
  Konum: ~/.1453-backup-20250120_143055/

Yedeklenen dosyalar:
  • .bashrc
  • .bash_aliases
  • .config/starship.toml
  • ~/.1453-wsl-setup/ (tüm dizin)

✓ Yedek tamamlandı!
```

**Onay Mekanizması:**
```
⚠️  UYARI: Bu işlem GERİ ALINAMAZ!

Aşağıdakiler SİLİNECEK:
  • Python ekosistemi (pip, pipx, UV)
  • JavaScript ekosistemi (NVM, Bun)
  • PHP tüm versiyonları
  • Go language
  • Docker
  • Modern CLI tools (11 araç)
  • AI Tools (8 CLI + 3 Framework)
  • Shell konfigürasyonları
  • Kurulum dizini

Devam etmek istediğinize EMİN misiniz?
Onaylamak için "EVET" yazın (büyük harfle):
```

**Marker Sistemi:**

`.bashrc` dosyası güvenli temizleme için marker kullanır:

```bash
# ===== START: Enhanced Bash Config - 1453 WSL Setup =====
# (custom config)
# ===== END: Enhanced Bash Config - 1453 WSL Setup =====
```

Cleanup sadece bu marker'lar arasını siler, diğer kullanıcı konfigürasyonlarına dokunmaz.

---

## 🐛 Sorun Giderme

### Yaygın Sorunlar ve Çözümleri

#### 1. Permission Denied Hatası

**Sorun:**
```
bash: ./src/linux-ai-setup-script.sh: Permission denied
```

**Çözüm:**
```bash
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

#### 2. CRLF Satır Sonu Hatası (Windows)

**Sorun:**
```
bash: $'\r': command not found
```

**Çözüm:**
Script otomatik düzeltir. Manuel düzeltme:
```bash
# dos2unix varsa
dos2unix src/linux-ai-setup-script.sh

# yoksa sed ile
sed -i 's/\r$//' src/linux-ai-setup-script.sh

# ya da tr ile
tr -d '\r' < src/linux-ai-setup-script.sh > fixed.sh
mv fixed.sh src/linux-ai-setup-script.sh
```

#### 3. bat/fd Komutları Bulunamadı (Ubuntu)

**Sorun:**
```bash
bat: command not found
fd: command not found
```

**Neden:**
Ubuntu'da `batcat` ve `fdfind` olarak kurulur.

**Çözüm:**
Script otomatik symlink oluşturur. Kontrol:
```bash
ls -la ~/.local/bin/bat
ls -la ~/.local/bin/fd

# Shell'i yenile
source ~/.bashrc
```

Manuel symlink:
```bash
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
ln -s /usr/bin/fdfind ~/.local/bin/fd
```

#### 4. PEP 668 Hatası (Python pip)

**Sorun:**
```
error: externally-managed-environment
```

**Çözüm:**
Script otomatik `--break-system-packages` kullanır. Manuel:
```bash
pip install package --break-system-packages

# veya pipx kullan
pipx install package
```

#### 5. Docker Permission Hatası

**Sorun:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Çözüm:**
```bash
# Kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER

# Grup değişikliğini aktive et
newgrp docker

# Kontrol
groups | grep docker

# Docker daemon'u başlat (WSL)
sudo service docker start
```

#### 6. NVM Command Not Found

**Sorun:**
```bash
nvm: command not found
```

**Çözüm:**
```bash
# Shell'i yenile
source ~/.bashrc

# NVM yüklenmiş mi kontrol
ls -la ~/.nvm

# Manuel yükleme
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"
```

#### 7. PHP Versiyon Değiştirme

**Sorun:**
`update-alternatives` hata veriyor.

**Çözüm:**
```bash
# Mevcut alternatifleri listele
sudo update-alternatives --list php

# Manuel seçim
sudo update-alternatives --set php /usr/bin/php8.3

# Interactive seçim
sudo update-alternatives --config php
```

#### 8. Starship Prompt Görünmüyor

**Sorun:**
Prompt değişmedi.

**Çözüm:**
```bash
# Starship kurulu mu?
which starship

# Config dosyası var mı?
cat ~/.config/starship.toml

# .bashrc'de eval var mı?
grep starship ~/.bashrc

# Shell'i yenile
source ~/.bashrc

# Manuel aktive et
eval "$(starship init bash)"
```

#### 9. Zoxide "z" Komutu Çalışmıyor

**Sorun:**
```bash
z: command not found
```

**Çözüm:**
```bash
# Zoxide kurulu mu?
which zoxide

# .bashrc'de init var mı?
grep zoxide ~/.bashrc

# Shell'i yenile
source ~/.bashrc

# Manuel init
eval "$(zoxide init bash)"

# İlk kullanımda dizin geçmişi boş, bir süre cd kullan
cd ~/projects
cd ~/documents
z proj  # artık çalışır
```

#### 10. Sudo Şifre Sürekli Soruluyor

**Sorun:**
Her komutta sudo şifresi isteniyor.

**Çözüm:**
Script v2.2.1+ otomatik background keep-alive kullanır. Manuel kontrol:
```bash
# Sudo timestamp kontrolü
sudo -n true 2>/dev/null && echo "Sudo aktif" || echo "Sudo süresi dolmuş"

# Uzun süre aktif tutma (güvenlik riski!)
# /etc/sudoers.d/custom-timeout oluştur
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
```

**NOT:** `NOPASSWD` güvenlik riski taşır, production'da önerilmez!

---

## 🔐 Güvenlik ve Sağlamlaştırma

### Versiyon 2.3.2 Güvenlik Durumu

| Kategori | Durum | Açıklama |
|----------|-------|----------|
| **Command Injection** | ✅ FIXED | 16 eval kullanımı kaldırıldı |
| **Checksum Validation** | ✅ ENABLED | SHA256 doğrulama aktif |
| **Path Traversal** | ✅ PROTECTED | Sistem dizinleri korumalı |
| **Variable Safety** | ✅ COMPLIANT | set -u uyumlu |
| **Sudo Management** | ✅ OPTIMIZED | Background keep-alive |
| **Package Safety** | ✅ SECURE | Array-based execution |
| **CRLF Handling** | ✅ AUTO-FIX | Otomatik düzeltme |
| **Error Handling** | ✅ ROBUST | set -euo pipefail |
| **Risk Level** | 🟢 LOW | Production-ready |

### Güvenlik İyileştirmeleri (v2.2.0)

#### PHASE 1: Command Injection Temizliği

**Sorun:**
```bash
# ESKİ (GÜVENSIZ):
INSTALL_CMD="sudo apt install -y"
eval "$INSTALL_CMD package1 package2"  # COMMAND INJECTION RISKI!
```

**Çözüm:**
```bash
# YENİ (GÜVENLİ):
local packages=("package1" "package2")
case "$PKG_MANAGER" in
    apt)
        sudo apt install -y "${packages[@]}"
        ;;
    dnf)
        sudo dnf install -y "${packages[@]}"
        ;;
esac
```

**İstatistik:**
- 16 eval kullanımı kaldırıldı
- 5 dosya güncellendi (python.sh, php.sh, ai-cli.sh, go.sh, package-manager.sh)

#### PHASE 2a: Merkezi Versiyon Yönetimi

**Sorun:**
Her modülde hardcoded versiyon numaraları.

**Çözüm:**
`config/tool-versions.sh` oluşturuldu:

```bash
# GitHub API'den dinamik çekme
fetch_github_version() {
    local repo="$1"
    local fallback="$2"

    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r '.tag_name' 2>/dev/null)

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "$fallback"
    else
        echo "$version"
    fi
}

# Kullanım
NVM_VERSION=$(fetch_github_version "nvm-sh/nvm" "v0.40.3")
```

**Fayda:**
- Otomatik güncelleme
- Offline fallback
- Tek yerden yönetim

#### PHASE 2b: SHA256 Checksum Doğrulama

**Eklenen Fonksiyonlar:**

```bash
# Checksum doğrula
verify_checksum() {
    local file_path="$1"
    local expected_checksum="$2"

    local actual=$(sha256sum "$file_path" | awk '{print $1}')

    if [ "${actual,,}" = "${expected_checksum,,}" ]; then
        return 0
    else
        echo "CHECKSUM MISMATCH!"
        return 1
    fi
}

# Checksum'la indir
download_with_checksum() {
    local url="$1"
    local output="$2"
    local checksum_url="$3"

    curl -fsSL "$url" -o "$output"

    local checksum=$(curl -fsSL "$checksum_url" | grep "$output" | awk '{print $1}')

    verify_checksum "$output" "$checksum"
}
```

**Uygulanan Araçlar:**
- Vivid (LS_COLORS generator)
- Lazygit (Git TUI)
- Lazydocker (Docker TUI)

#### PHASE 3a: Merkezi Sabitler

**Sorun:**
Magic numbers kod içinde dağılmış durumda.

**Çözüm:**
`config/constants.sh` oluşturuldu:

```bash
# Retry sabitleri
declare -rx MAX_PACKAGE_RETRIES=3
declare -rx MAX_UPDATE_RETRIES=3
declare -rx RETRY_DELAY_SECONDS=2

# Timeout sabitleri
declare -rx NETWORK_TIMEOUT_SECONDS=3
declare -rx APT_UPDATE_TIMEOUT_SECONDS=10

# Sudo sabitleri
declare -rx SUDO_KEEPALIVE_INTERVAL=60

# Disk sabitleri
declare -rx RECOMMENDED_DISK_SPACE_MB=2000
declare -rx WARNING_DISK_SPACE_MB=1000

# History sabitleri
declare -rx BASH_HISTSIZE=100000
declare -rx BASH_HISTFILESIZE=200000

# DNS sabitleri
declare -rx PRIMARY_DNS_SERVER="8.8.8.8"
declare -rx SECONDARY_DNS_SERVER="1.1.1.1"
```

**Fayda:**
- Tek yerden ayarlama
- Readonly koruma (`-rx`)
- Export edilmiş (alt shell'lerde erişilebilir)

### Güvenlik En İyi Uygulamaları

#### 1. Bash Safety Flags

```bash
set -euo pipefail

# -e: Hata oluşunca dur
# -u: Tanımsız değişkeni hata say
# -o pipefail: Pipe'daki hatayı yakala
```

#### 2. Path Validation

```bash
case "$INSTALL_DIR" in
    /|/bin|/sbin|/usr|/usr/bin|/usr/sbin|/etc|/var|/tmp|/boot)
        echo "FATAL: System directory risk!"
        exit 1
        ;;
esac
```

#### 3. Variable Safety

```bash
if [ -z "${HOME:-}" ]; then
    echo "FATAL: HOME not set!"
    exit 1
fi

# ${VAR:-} syntax: set -u uyumlu
```

#### 4. Array-Based Execution

```bash
# GÜVENLI: Array expansion
local packages=("pkg1" "pkg2" "pkg3")
sudo apt install -y "${packages[@]}"

# GÜVENSIZ: String expansion
INSTALL_CMD="sudo apt install -y pkg1 pkg2 pkg3"
eval "$INSTALL_CMD"  # Command injection riski!
```

#### 5. Input Validation

```bash
validate_package_name() {
    local package="$1"

    # Sadece alfanumerik, tire, nokta, underscore
    if ! [[ "$package" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Geçersiz paket adı!"
        return 1
    fi
}
```

### Bug İstatistikleri

**v2.2.0 Öncesi (70 bug tespit edildi):**
- 🔴 CRITICAL: 29 bug
- 🟡 HIGH: 3 bug
- 🟢 MEDIUM: 38 bug

**v2.3.2 Sonrası:**
- 🔴 CRITICAL: 0 bug (✅ 100% çözüldü)
- 🟡 HIGH: 0 bug (✅ 100% çözüldü)
- 🟢 MEDIUM: 1 bug (ertelendi, LOW priority)

**Toplam Düzeltme:** 55/56 bug (%98.2)

---

## 📚 Ek Kaynaklar

### Dokümantasyon

| Dosya | Açıklama | Satır Sayısı |
|-------|----------|--------------|
| `README.md` | Kullanıcı kılavuzu (bu dosya) | ~1,800 |
| `CLAUDE.md` | Geliştirici kılavuzu | 29,156 |
| `docs/INDEX.md` | Dokümantasyon indeksi | - |
| `docs/PROJECT_OVERVIEW.md` | Proje mimarisi | - |
| `docs/API_REFERENCE.md` | Fonksiyon referansı | 28,485 |
| `docs/LLM_CODING_GUIDE.md` | LLM agent kılavuzu | - |

### Script Kılavuzları

- `install.sh` - Tek satır installer nasıl çalışır
- `test-setup.sh` - Validation script kullanımı
- `src/linux-ai-setup-script.sh` - Ana script entry point

### Modül Dokümantasyonu

Her modül kendi içinde detaylı comment'lere sahip:
- `src/modules/quickstart.sh` - Quick Start wizard
- `src/modules/python.sh` - Python ecosystem
- `src/modules/javascript.sh` - Node.js/Bun
- `src/modules/php.sh` - PHP versions
- `src/modules/modern-tools.sh` - Modern CLI tools
- `src/modules/shell-setup.sh` - Shell environment
- `src/modules/ai-cli.sh` - AI CLI tools
- `src/modules/ai-frameworks.sh` - AI frameworks
- `src/modules/cleanup.sh` - Cleanup system
- `src/modules/menus.sh` - Menu system

### External Links

**Kurulu Araçların Dökümantasyonları:**

- [bat](https://github.com/sharkdp/bat) - Modern cat
- [eza](https://github.com/eza-community/eza) - Modern ls
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast grep
- [fd](https://github.com/sharkdp/fd) - Fast find
- [starship](https://starship.rs/) - Cross-shell prompt
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter cd
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
- [lazydocker](https://github.com/jesseduffield/lazydocker) - Docker TUI
- [NVM](https://github.com/nvm-sh/nvm) - Node Version Manager
- [Bun](https://bun.sh/) - Fast JavaScript runtime

**AI Tools:**

- [Claude Code](https://claude.ai) - Anthropic Claude CLI
- [Gemini AI](https://ai.google.dev/) - Google Gemini SDK
- [GitHub CLI](https://cli.github.com/) - Official GitHub CLI
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer

---

## 🤝 Katkıda Bulunma

Projeye katkıda bulunmak isterseniz:

### 1. Repository'yi Fork Edin

```bash
# GitHub'da fork butonuna tıklayın
# Kendi hesabınıza fork oluşturun
```

### 2. Lokal Olarak Clone Edin

```bash
git clone https://github.com/YOUR_USERNAME/1453-wsl-bash-script.git
cd 1453-wsl-bash-script
```

### 3. Feature Branch Oluşturun

```bash
git checkout -b feature/yeni-ozellik

# veya
git checkout -b fix/bug-duzeltmesi
```

### 4. Değişiklik Yapın

**Yeni modül eklemek:**
```bash
# Yeni dosya oluştur
touch src/modules/yeni-modul.sh

# Şablon yapı:
# - Header comment
# - Fonksiyon tanımları
# - Export statements

# Ana script'e ekle
vim src/linux-ai-setup-script.sh
# source "${SCRIPT_DIR}/modules/yeni-modul.sh"
```

**Mevcut kodu düzeltmek:**
```bash
# İlgili modülü düzenle
vim src/modules/python.sh

# Syntax kontrolü
bash -n src/modules/python.sh
```

### 5. Test Edin

```bash
# Syntax kontrolü
bash -n src/linux-ai-setup-script.sh
bash -n src/modules/*.sh

# Çalıştırma testi
./src/linux-ai-setup-script.sh

# Validation testi
./test-setup.sh
```

### 6. Commit ve Push

```bash
git add .
git commit -m "Özellik: Yeni özellik eklendi

Detaylı açıklama:
- Ne değişti
- Neden değişti
- Nasıl test edildi"

git push origin feature/yeni-ozellik
```

### 7. Pull Request Açın

GitHub'da Pull Request oluşturun:

**PR Başlığı:**
```
Özellik: Yeni özellik başlığı
```

**PR Açıklaması:**
```markdown
## Değişiklikler
- Eklenen yeni özellik
- Düzeltilen bug

## Test
- [ ] Syntax kontrolü yapıldı
- [ ] Manuel test yapıldı
- [ ] Validation script çalıştırıldı

## Checklist
- [ ] Türkçe mesajlar eklendi
- [ ] Dokümantasyon güncellendi
- [ ] Geriye dönük uyumluluk korundu
```

### Kod Standartları

**Bash Coding Style:**
```bash
# Fonksiyon tanımı
function_name() {
    local variable_name="value"

    if [ condition ]; then
        # action
    fi
}

# Export et
export -f function_name
```

**Türkçe Mesajlar:**
```bash
echo -e "${GREEN}[BAŞARILI]${NC} İşlem tamamlandı"
echo -e "${RED}[HATA]${NC} İşlem başarısız"
echo -e "${YELLOW}[UYARI]${NC} Dikkat gerekli"
echo -e "${CYAN}[BİLGİ]${NC} Bilgilendirme"
```

**Error Handling:**
```bash
if ! command; then
    echo -e "${RED}[HATA]${NC} Komut başarısız!"
    return 1
fi
```

**Function Naming:**
- Snake_case kullanın: `install_python()`
- Açıklayıcı isimler: `setup_bash_aliases()`
- Prefix kullanın: `cleanup_python()`

### İletişim

- **GitHub Issues**: Bug raporu ve özellik önerileri
- **Pull Requests**: Kod katkıları
- **Discussions**: Genel tartışmalar

---

## 👨‍💻 Katkıda Bulunanlar

Bu projeyi oluşturan ve geliştiren kişiler:

| Kişi | Rol | Katkı |
|------|-----|-------|
| **Alper Tunga** | Proje Yaratıcısı | İlk monolithic script |
| **Tamer KARACA** | Lead Developer | Modüler mimari, güvenlik, TUI |
| **Ravi DULUNDU** | Contributor | Bug fixes, documentation |
| **FitzGPT** | AI Assistant | Code review, optimization |
| **Tuğser OKUR** | Contributor | Testing, feedback |

**Özel Teşekkür:**
- Tüm issue açan ve feedback veren kullanıcılara
- Open source topluluğuna
- WSL ve Linux ekosistem geliştiricilerine

---

## 📄 Lisans

Bu proje **MIT Lisansı** altında lisanslanmıştır.

```
MIT License

Copyright (c) 2025 1453.AI - Alper Tunga & Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Detaylar için [LICENSE.md](LICENSE.md) dosyasına bakın.

---

## 🔗 Bağlantılar

### Resmi Kaynaklar

- **GitHub Repository**: https://github.com/ravidulundu/1453-wsl-bash-script
- **GitHub Issues**: https://github.com/ravidulundu/1453-wsl-bash-script/issues
- **GitHub Releases**: https://github.com/ravidulundu/1453-wsl-bash-script/releases
- **Geliştirici Kılavuzu**: [CLAUDE.md](CLAUDE.md)
- **Dokümantasyon İndeksi**: [docs/INDEX.md](docs/INDEX.md)

### İlgili Projeler

- **Starship Prompts**: https://starship.rs/presets/
- **Catppuccin Theme**: https://github.com/catppuccin/catppuccin
- **Charm Gum**: https://github.com/charmbracelet/gum
- **Modern Unix Tools**: https://github.com/ibraheemdev/modern-unix

### Topluluk

- **Discussions**: https://github.com/ravidulundu/1453-wsl-bash-script/discussions
- **Issues (Bug Reports)**: https://github.com/ravidulundu/1453-wsl-bash-script/issues
- **Pull Requests**: https://github.com/ravidulundu/1453-wsl-bash-script/pulls

---

## 📊 Proje İstatistikleri

| Metrik | Değer |
|--------|-------|
| **Toplam Dosya** | 50+ |
| **Kaynak Kod Satırı** | 7,614 |
| **Dokümantasyon Satırı** | 60,000+ |
| **Modül Sayısı** | 12 |
| **Kurulabilir Araç** | 40+ |
| **AI Tool** | 11 (8 CLI + 3 Framework) |
| **Özel Alias** | 62+ |
| **Test Kategorisi** | 15 |
| **Commit Sayısı** | 181+ |
| **Versiyon** | 2.3.2 |
| **İlk Versiyon** | 2025-01 |
| **Son Güncelleme** | 2025-11-20 |
| **Lisans** | MIT |
| **Platform** | WSL + Linux |
| **Desteklenen PM** | APT, DNF, YUM, Pacman |
| **Minimum Bash** | 5.0+ |
| **Güvenlik Seviyesi** | LOW Risk (Hardened) |

---

<div align="center">

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!**

**🚀 WSL geliştirme ortamınızı bir üst seviyeye taşıyın!**

**🇹🇷 Türk geliştiriciler için Türk geliştiriciler tarafından yapıldı**

---

**Platform**: WSL (Windows Subsystem for Linux) | **Dil**: Bash + Türkçe Arayüz | **TUI**: Gum Framework ✨

**Modern | Güvenli | Modüler | Responsive | Production-Ready**

---

Made with ❤️ by [1453.AI](https://github.com/ravidulundu)

© 2025 | MIT License

</div>
