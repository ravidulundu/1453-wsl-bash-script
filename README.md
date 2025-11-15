# 1453 WSL Kurulum Scripti

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-WSL-blue.svg)](https://docs.microsoft.com/en-us/windows/wsl/)

WSL (Windows Subsystem for Linux) için kapsamlı otomatik kurulum scripti. AI geliştiricileri ve "Vibe Coder"lar için özel olarak tasarlanmış, tam Türkçe arayüzlü geliştirme ortamı kurulum aracı.

## 📋 İçindekiler

- [Özellikler](#-özellikler)
- [Hızlı Kurulum](#-hızlı-kurulum)
- [Kullanım](#-kullanım)
- [Dosya Yapısı](#-dosya-yapısı)
- [Teknoloji Yığını](#-teknoloji-yığını)
- [Kurulum Sonrası](#-kurulum-sonrası)
- [Test ve Doğrulama](#-test-ve-doğrulama)
- [Temizleme ve Sıfırlama](#️-temizleme-ve-sıfırlama)
- [Sorun Giderme](#-sorun-giderme)
- [Katkı Sağlama](#-katkı-sağlama)
- [Lisans](#-lisans)

## ✨ Özellikler

### 🎯 Temel Özellikler
- **Tek Satır Kurulum** - curl/wget ile anında kurulum
- **Modüler Mimari** - 2,331 satırlık monolitik scriptten 14 modüler dosyaya refactor edildi
- **Türkçe Arayüz** - Tüm mesajlar ve menüler Türkçe
- **İnteraktif Menüler** - Kullanıcı dostu çoklu seçim desteği
- **Otomatik Algılama** - Paket yöneticisi ve işletim sistemi otomatik tespit
- **PEP 668 Uyumlu** - Python'un harici yönetilen ortam standardına uyumlu

### 🛠️ Desteklenen Platformlar
- **Debian/Ubuntu** (APT)
- **Fedora/RHEL 8+** (DNF)
- **CentOS/RHEL 7** (YUM)
- **Arch Linux** (Pacman)

### 💻 Geliştirme Araçları

#### Programlama Dilleri
- **Python 3.x** - pip, pipx, UV (ultra-hızlı paket yöneticisi)
- **Node.js** - NVM (Node Version Manager) ile çoklu versiyon desteği
- **PHP 7.4 - 8.5** - Çoklu PHP versiyonu, Composer, Laravel desteği
- **Bun.js** - Hızlı JavaScript runtime
- **Go** - Go dili ve ortam yapılandırması

#### Modern CLI Araçları
- **bat** - Syntax highlighting ile gelişmiş cat
- **eza** - Modern ls alternatifi
- **ripgrep (rg)** - Süper hızlı içerik arama
- **fd** - Modern find alternatifi
- **starship** - Akıllı cross-shell prompt
- **zoxide** - Akıllı cd komutu (z)
- **fzf** - Fuzzy finder (bulanık arama)
- **vivid** - LS_COLORS generator
- **fastfetch** - Hızlı sistem bilgisi
- **lazygit** - Terminal Git arayüzü
- **lazydocker** - Terminal Docker arayüzü

#### AI CLI Araçları
- **Claude Code CLI** - Anthropic Claude AI
- **Qoder CLI** - AI kod asistanı
- **Gemini CLI** - Google Gemini AI
- **Qwen CLI** - Alibaba Qwen AI
- **OpenCode CLI** - Açık kaynak AI
- **GitHub Copilot CLI** - GitHub AI asistanı
- **GitHub CLI (gh)** - GitHub komut satırı aracı

#### AI Framework'leri
- **SuperGemini** - Gelişmiş Gemini framework
- **SuperQwen** - Gelişmiş Qwen framework
- **SuperClaude** - Gelişmiş Claude framework
- **MCP Server Desteği** - Model Context Protocol entegrasyonu

#### Shell Ortamı
- **62+ Özel Alias** - Git, navigasyon, Docker, NPM, Python aliasları
- **Özel Fonksiyonlar** - mcd (mkdir + cd), gelişmiş make
- **Bashrc Geliştirmeleri** - Geçmiş ayarları, FZF entegrasyonu
- **Starship Yapılandırması** - Özel prompt teması

### 🎮 İki Kurulum Modu

#### 🚀 Hızlı Başlangıç Modu (Yeni Başlayanlar İçin)
5 hazır preset:
1. **Web Geliştirme** - Python + Node.js + PHP + Composer
2. **AI Geliştirme** - Python + AI CLI Araçları + AI Framework'leri
3. **Backend Geliştirme** - Python + Go + PHP + Composer
4. **Her Şey** - Full stack + AI + Backend
5. **Mobil + Web** - Python + Node.js + PHP + Flutter araçları

Tüm preset'ler otomatik olarak şunları içerir:
- Modern CLI araçları (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)
- Shell ortamı kurulumu (62+ alias, özel fonksiyonlar, gelişmiş bashrc)
- Python + pip + pipx + UV

#### ⚙️ Gelişmiş Mod (Detaylı Kontrol)
18 özelleştirilebilir seçenek:
1. Tam Kurulum
2. Hazırlık (sistem güncelleme + Git)
3. Python Kurulumu
4. Pip Güncelleme
5. Pipx Kurulumu
6. UV Kurulumu
7. NVM Kurulumu
8. Bun.js Kurulumu
9. PHP Kurulumu
10. Composer Kurulumu
11. AI CLI Araçları
12. AI Framework'leri
13. AI Framework'leri Kaldır
14. Go Kurulumu
15. Modern CLI Araçları
16. Shell Ortamı Kurulumu
17. Temizleme ve Sıfırlama
18. Docker (Docker Engine + lazydocker)

## 🚀 Hızlı Kurulum

### Tek Satır Kurulum (Önerilen)

WSL terminalinizde şu komutu çalıştırın:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

veya wget ile:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

Bu komut:
- Tüm script bileşenlerini GitHub'dan indirir
- Dizin yapısını `~/.1453-wsl-setup/` içinde oluşturur
- Kolay erişim için başlatıcı script oluşturur
- Kurulumu hemen başlatmak ister (Türkçe: "e/E=Evet, Enter=Hayır")

Kurulum tamamlandıktan sonra:

```bash
~/.1453-wsl-setup/1453-setup
```

### Manuel Kurulum

Depoyu klonlayıp doğrudan çalıştırın:

```bash
# Depoyu klonla
git clone https://github.com/ravidulundu/1453-wsl-bash-script.git
cd 1453-wsl-bash-script

# Çalıştırılabilir yap ve başlat
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

### Script Doğrulama

```bash
# Sözdizimi hatalarını kontrol et
bash -n src/linux-ai-setup-script.sh

# Shellcheck ile linting (kuruluysa)
shellcheck src/linux-ai-setup-script.sh
```

## 📖 Kullanım

### Hızlı Başlangıç Modu

1. Script'i çalıştırın:
```bash
~/.1453-wsl-setup/1453-setup
```

2. "Hızlı Başlangıç Modu (1)" seçin

3. İhtiyacınıza uygun preset'i seçin:
```
1) Web Geliştirme
2) AI Geliştirme
3) Backend Geliştirme
4) Her Şey
5) Mobil + Web
```

4. Kurulum otomatik olarak başlar, sudo şifresi yalnızca bir kez istenir

### Gelişmiş Mod

1. Script'i çalıştırın:
```bash
~/.1453-wsl-setup/1453-setup
```

2. "Gelişmiş Mod (2)" seçin

3. Menüden istediğiniz işlemi seçin (1-18)

4. İşlem tamamlandıktan sonra menü tekrar görüntülenir

### Modern CLI Araçları Kullanımı

Kurulum sonrası modern araçlar otomatik olarak kullanıma hazır:

```bash
# Modern ls (eza)
ll                    # Detaylı liste
la                    # Tüm dosyalar
lt                    # Ağaç görünümü

# Modern cat (bat)
cat dosya.py          # Syntax highlighting ile

# Hızlı arama (ripgrep)
rg "aranan_kelime"    # Tüm dosyalarda ara

# Akıllı cd (zoxide)
z proje               # Sık kullanılan dizine git

# Fuzzy finder (fzf)
# Ctrl+R              # Komut geçmişinde ara

# Git arayüzü
lazygit               # Terminal Git UI

# Docker arayüzü
lazydocker            # Terminal Docker UI
```

### 62+ Özel Alias

Script otomatik olarak yüklenir:

```bash
# Git aliasları
g         # git
gs        # git status
ga        # git add
gc        # git commit -m
gp        # git push
gl        # git pull
glog      # git log (renkli)

# Navigasyon
..        # cd ..
...       # cd ../..
~         # cd ~

# Dosya operasyonları
ll        # eza -lah (detaylı liste)
la        # eza -a (tümü)
lt        # eza --tree (ağaç)

# Güvenlik
rm        # rm -i (onay iste)
cp        # cp -i (onay iste)
mv        # mv -i (onay iste)

# Docker aliasları
dps       # docker ps
dpsa      # docker ps -a
di        # docker images
dex       # docker exec -it
dlog      # docker logs

# NPM aliasları
ni        # npm install
nid       # npm install --save-dev
ns        # npm start
nb        # npm run build
nt        # npm test

# Python aliasları
py        # python3
pip       # pip3
venv      # python3 -m venv
activate  # source venv/bin/activate

# Sistem
ports     # netstat -tulanp
myip      # curl ifconfig.me
c         # clear
```

Tüm alias listesi için:
```bash
cat ~/.bash_aliases
```

## 📁 Dosya Yapısı

### Repository Yapısı

```
1453-wsl-bash-script/
├── install.sh                          # Tek satır kurulum scripti (Türkçe)
├── fix-crlf.sh                        # CRLF satır sonu düzeltici
├── test-setup.sh                      # Kurulum doğrulama scripti
├── README.md                          # Proje dokümantasyonu (Türkçe)
├── CLAUDE.md                          # Geliştirici kılavuzu
├── LICENSE.md                         # MIT lisansı
│
└── src/
    ├── linux-ai-setup-script.sh           # Ana giriş noktası (52 satır)
    ├── linux-ai-setup-script-legacy.sh    # Eski monolitik script (yedek)
    │
    ├── lib/                               # Çekirdek kütüphaneler
    │   ├── init.sh                       # CRLF tespiti ve başlatma
    │   ├── common.sh                     # Paylaşılan araçlar (reload_shell_configs, mask_secret)
    │   └── package-manager.sh           # Paket yöneticisi tespiti ve sistem güncellemeleri
    │
    ├── config/                            # Yapılandırma dosyaları
    │   ├── colors.sh                     # Terminal renk tanımları
    │   ├── php-versions.sh               # PHP versiyon ve eklenti dizileri
    │   └── banner.sh                     # ASCII art ve banner gösterimi (Türkçe)
    │
    └── modules/                           # Özellik modülleri
        ├── python.sh                     # Python ekosistemi (Python, pip, pipx, UV)
        ├── javascript.sh                 # JavaScript ekosistemi (NVM, Bun.js)
        ├── php.sh                        # PHP ekosistemi (PHP versiyonları, Composer, Laravel)
        ├── go.sh                         # Go dili kurulumu
        ├── modern-tools.sh               # Modern CLI araçları (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)
        ├── shell-setup.sh                # Shell ortamı kurulumu (aliaslar, fonksiyonlar, bashrc geliştirmeleri)
        ├── ai-cli.sh                     # AI CLI araçları (Claude Code, Gemini, Qwen, vb.)
        ├── ai-frameworks.sh              # AI framework'leri (SuperGemini, SuperQwen, SuperClaude)
        ├── docker.sh                     # Docker Engine ve lazydocker kurulumu
        ├── cleanup.sh                    # Kapsamlı temizleme ve geri alma işlevleri
        ├── quickstart.sh                 # Hızlı Başlangıç modu yeni başlayanlar için
        └── menus.sh                      # İnteraktif menü sistemi ve ana döngü (Türkçe)
```

### Kurulum Sonrası Yapı

```
~/.1453-wsl-setup/
├── 1453-setup                         # Başlatıcı script
└── src/
    ├── linux-ai-setup-script.sh       # Ana script
    ├── lib/                           # Tüm kütüphane dosyaları
    ├── config/                        # Tüm yapılandırma dosyaları
    └── modules/                       # Tüm modül dosyaları
```

### Modül Kategorileri

1. **Çekirdek Kütüphaneler** (`lib/`) - Sistem başlatma, paylaşılan araçlar, paket yönetimi
2. **Yapılandırma** (`config/`) - Renkler, PHP versiyonları, banner/marka
3. **Python Ekosistemi** (`modules/python.sh`) - Python, pip, pipx, UV (PEP 668 uyumlu)
4. **JavaScript Ekosistemi** (`modules/javascript.sh`) - NVM ve Bun.js kurulumu
5. **PHP Ekosistemi** (`modules/php.sh`) - Çoklu PHP versiyonları (7.4-8.5) Laravel desteği ile
6. **Go Dili** (`modules/go.sh`) - Go kurulumu ve yapılandırması
7. **Modern CLI Araçları** (`modules/modern-tools.sh`) - Geleneksel araçlar için modern alternatifler
8. **Shell Ortamı** (`modules/shell-setup.sh`) - Özel aliaslar (62+), fonksiyonlar, bashrc geliştirmeleri
9. **AI CLI Araçları** (`modules/ai-cli.sh`) - Claude Code, Gemini, Qwen, OpenCode, Copilot, GitHub CLI
10. **AI Framework'leri** (`modules/ai-frameworks.sh`) - SuperGemini, SuperQwen, SuperClaude
11. **Docker** (`modules/docker.sh`) - Docker Engine, lazydocker
12. **Temizleme** (`modules/cleanup.sh`) - Kapsamlı geri alma ve sıfırlama
13. **Hızlı Başlangıç** (`modules/quickstart.sh`) - Yeni başlayanlar için basitleştirilmiş UX
14. **Menüler** (`modules/menus.sh`) - Menü tabanlı arayüz (Türkçe)

## 🔧 Teknoloji Yığını

### Script Dilleri
- **Bash 5.0+** - Ana script dili
- **POSIX Shell** - Maksimum uyumluluk için

### Paket Yöneticileri
- **APT** - Debian/Ubuntu
- **DNF** - Fedora/RHEL 8+
- **YUM** - CentOS/RHEL 7
- **Pacman** - Arch Linux

### Dış Bağımlılıklar
- **curl/wget** - İndirmeler için
- **git** - Versiyon kontrolü
- **sudo** - Yükseltilmiş izinler
- **dos2unix/sed/tr** - CRLF düzeltme

### Python Paket Yöneticileri
- **pip** - Standart Python paket yöneticisi
- **pipx** - İzole Python uygulamaları
- **UV** - Ultra-hızlı Python paket yöneticisi

### Node.js Araçları
- **NVM** - Node Version Manager
- **npm** - Node paket yöneticisi
- **Bun.js** - Hızlı JavaScript runtime

### PHP Araçları
- **Composer** - PHP bağımlılık yöneticisi
- **update-alternatives** - PHP versiyon değiştirme

## 🎉 Kurulum Sonrası

### 1. Terminali Yeniden Başlatın

```bash
# Seçenek 1: Windows Terminal'i kapatıp yeniden açın (önerilen)

# Seçenek 2: Shell config'i yenileyin
source ~/.bashrc
```

### 2. Kurulumu Doğrulayın

```bash
# Test scriptini çalıştırın
./test-setup.sh

# Snapshot/röntgen modunda sistem durumu
./test-setup.sh --snapshot
```

### 3. Modern CLI Araçlarını Test Edin

```bash
# Starship prompt aktif mi kontrol edin
echo $STARSHIP_CONFIG

# Modern ls (eza)
ll

# Modern cat (bat)
cat test-setup.sh

# Fuzzy finder (Ctrl+R ile komut geçmişinde ara)

# Akıllı cd (zoxide)
z ~
```

### 4. Git Yapılandırmasını Kontrol Edin

```bash
git config --global user.name
git config --global user.email

# Yoksa ayarlayın
git config --global user.name "Adınız"
git config --global user.email "email@example.com"
```

### 5. Python Ortamını Test Edin

```bash
python3 --version
pip3 --version
pipx --version
uv --version
```

### 6. Node.js Ortamını Test Edin

```bash
nvm --version
node --version
npm --version
```

### 7. İlk Projenizi Oluşturun

```bash
# Python projesi
mcd my-python-project
python3 -m venv venv
source venv/bin/activate
pip install requests

# Node.js projesi
mcd my-node-project
npm init -y
npm install express

# Go projesi
mcd my-go-project
go mod init my-project
```

## ✅ Test ve Doğrulama

### Test Scripti Kullanımı

```bash
# Temel test
./test-setup.sh

# Detaylı çıktı
./test-setup.sh --verbose

# JSON formatında rapor
./test-setup.sh --json > test-report.json

# Log dosyasına kaydet
./test-setup.sh --log test-results.log

# WSL sistem röntgeni
./test-setup.sh --snapshot
```

### Test Scripti Kontrolleri

Test scripti 15 kategoriyi kontrol eder:

1. **Sistem Bilgileri** - OS, kernel, WSL, paket yöneticisi
2. **Temel Araçlar** - git, curl, wget, jq, build essentials
3. **Python Ekosistemi** - Python, pip, pipx, UV
4. **JavaScript Ekosistemi** - NVM, Node.js, npm, Bun.js
5. **PHP Ekosistemi** - PHP versiyonları, Composer, eklentiler
6. **Go Language** - Go, GOPATH, GOROOT
7. **Modern CLI Araçları** - bat, eza, starship, zoxide, fzf, lazygit, lazydocker
8. **Shell Ortamı** - .bash_aliases, özel fonksiyonlar, bashrc geliştirmeleri
9. **AI CLI Araçları** - Claude Code, Gemini CLI, GitHub CLI
10. **AI Frameworks** - SuperGemini, SuperQwen, SuperClaude
11. **Docker** - Docker Engine, lazydocker
12. **Kurulum Dizini** - ~/.1453-wsl-setup yapısı
13. **Bash Aliases** - 62+ alias ve bağımlılık kontrolü
14. **Eksik Yüklemeler** - Kritik ve opsiyonel araçların detaylı analizi
15. **Fonksiyonel Testler** - Komutları gerçekten çalıştırıp test eder (20+ test)

### Test Sonuçları

Script şu bilgileri sağlar:
- ✓ **Başarılı** - Araç kurulu ve çalışıyor
- ✗ **Başarısız** - Araç kurulu değil veya hatalı
- ⚠ **Uyarı** - Opsiyonel bileşen eksik

Her testten sonra detaylı özet:
- Toplam test sayısı
- Kategori bazında sonuçlar
- Başarılı/Başarısız/Uyarı sayıları
- Eksik veya hatalı bileşenlerin listesi
- Başarı yüzdesi
- Süre

## 🗑️ Temizleme ve Sıfırlama

Script kapsamlı temizleme ve geri alma özellikleri sunar.

### Temizleme Seçenekleri

#### 1. 🔴 Tam Sıfırlama (Beyaz Bayrak)
- Sistemi tamamen temiz duruma getirir
- Tüm kurulumları ve yapılandırmaları kaldırır
- Temizlemeden önce otomatik yedek oluşturur
- ⚠️ UYARI: Bu işlem geri alınamaz!

#### 2. 🧹 Sadece Kurulumları Temizle
- Tüm kurulu araçları kaldırır
- Yapılandırma dosyalarını korur (.bashrc, .bash_aliases)
- Araçları yeniden yüklemenin güvenli yolu

#### 3. 📦 Tek Tek Temizle
Belirli bileşenleri seçerek kaldırın:
- Python ekosistemi (python3, pip, pipx, uv)
- Node.js ekosistemi (nvm, node, npm, bun)
- PHP ekosistemi (php, composer)
- Go
- Modern CLI araçları
- Shell yapılandırmaları
- AI CLI araçları
- AI framework'leri
- Docker (Docker Engine, lazydocker, repository, GPG key)

#### 4. ⚙️ Sadece Config Temizle
- Sadece yapılandırma dosyalarını kaldırır
- Tüm kurulumları korur

#### 5. 📊 Kurulu Olanları Göster
- Şu anda nelerin kurulu olduğunu gösterir
- Temizleme öncesi/sonrası durumu kontrol edin

### Güvenlik Özellikleri

- **Çift Onay** - Kritik işlemler için "evet" yazmanızı gerektirir
- **Otomatik Yedekleme** - Temizlemeden önce isteğe bağlı yedek
- **Zaman Damgalı Yedekler** - `~/.1453-backup-YYYYMMDD_HHMMSS/`
- **Sistem Koruması** - Sistem paketlerini korur
- **Geri Alınabilir İşlemler** - Config dosyaları `.removed` uzantısıyla taşınır

### Temizleme Kullanımı

```bash
# Script'i çalıştır
~/.1453-wsl-setup/1453-setup

# Gelişmiş Mod (2) seç
# 17 numaralı seçenek (Temizleme ve Sıfırlama)

# Temizleme türünü seç:
# - Kurulu olanları göster (5)
# - Belirli bileşeni kaldır (3)
# - Tam sıfırlama (1)
```

### Cleanup Neleri Kaldırır

**Kaldırılanlar:**
- `~/.1453-wsl-setup` (kurulum dizini)
- Kurulu araçlar (Python, Node, PHP, Go, Docker, AI araçları)
- Config değişiklikleri (.bashrc, .bash_aliases)
- APT repository'leri (Docker, PHP)
- GPG anahtarları
- Kullanıcı grup üyelikleri (docker)

**Korunanlar:**
- Kaynak kod repository'si (git clone yaptıysanız)
- Sistem paketleri
- Kişisel dosyalarınız

## 🐛 Sorun Giderme

### Script Sözdizimi Kontrolü

```bash
# Çalıştırmadan sözdizimi hatalarını kontrol et
bash -n src/linux-ai-setup-script.sh

# Test scriptini kontrol et
bash -n test-setup.sh
```

### Yaygın Sorunlar

#### 1. Permission Denied
```bash
chmod +x src/linux-ai-setup-script.sh
```

#### 2. CRLF Satır Sonları
```bash
# Yardımcı script ile
./fix-crlf.sh src/linux-ai-setup-script.sh

# Manuel düzeltme
sed -i 's/\r$//' src/linux-ai-setup-script.sh
```

#### 3. Eksik Bağımlılıklar
Script ön gereksinimleri otomatik yükler. Hata alırsanız:
```bash
sudo apt update
sudo apt install curl wget git
```

#### 4. Shell Yenilenmesi
```bash
# Terminali yeniden başlatın veya
source ~/.bashrc
```

#### 5. bat/fd Komutları Bulunamadı (Ubuntu)
Ubuntu `batcat` ve `fdfind` yükler. Script otomatik symlink oluşturur:
```bash
# Kontrol edin
ls -la ~/.local/bin/bat
ls -la ~/.local/bin/fd

# Manuel symlink
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
ln -s /usr/bin/fdfind ~/.local/bin/fd

# Shell'i yenileyin
source ~/.bashrc
```

#### 6. Test Başarısız
```bash
# Detaylı modda çalıştır
./test-setup.sh --verbose --log test-log.txt

# Log'u incele
cat test-log.txt

# Eksik araçları gör
./test-setup.sh | grep "✗\|FAIL"
```

#### 7. Docker İzin Hatası
```bash
# Docker grubuna eklendiğinizi kontrol edin
groups | grep docker

# Yoksa ekleyin
sudo usermod -aG docker $USER
newgrp docker

# Test edin
docker ps
```

## 🤝 Katkı Sağlama

Projeye katkıda bulunmak isterseniz:

### 1. Repository'yi Fork Edin

```bash
# GitHub'da fork edin
# Sonra klonlayın
git clone https://github.com/KULLANICI_ADINIZ/1453-wsl-bash-script.git
cd 1453-wsl-bash-script
```

### 2. Feature Branch Oluşturun

```bash
git checkout -b feature/yeni-ozellik
```

### 3. Değişikliklerinizi Yapın

```bash
# Kodunuzu yazın
# Test edin
bash -n src/modules/yeni-modul.sh
./test-setup.sh
```

### 4. Commit ve Push

```bash
git add .
git commit -m "Özellik: Yeni özellik açıklaması"
git push origin feature/yeni-ozellik
```

### 5. Pull Request Oluşturun

GitHub'da pull request açın ve değişikliklerinizi açıklayın.

### Kod Standartları

- **Modüler Yapı** - Değişikliklerinizi uygun modüle yerleştirin
- **Türkçe Mesajlar** - Kullanıcı mesajları Türkçe olmalı
- **Hata Yönetimi** - Hata kontrolü ve renkli çıktı kullanın
- **Dokümantasyon** - CLAUDE.md'ye önemli değişiklikleri ekleyin
- **Test** - test-setup.sh'ye gerekli kontrolleri ekleyin

### İletişim

- **Issues** - https://github.com/ravidulundu/1453-wsl-bash-script/issues
- **Pull Requests** - https://github.com/ravidulundu/1453-wsl-bash-script/pulls

## 👨‍💻 Katkıda Bulunanlar

- **Proje Yaratıcısı** - Alper Tunga
- **Geliştirici** - Tamer KARACA (A.K.A THE KING)
- **Katkıda Bulunanlar** - FitzGPT, Tuğser OKUR

## 📄 Lisans

MIT Lisansı - Detaylar için [LICENSE.md](LICENSE.md) dosyasına bakın.

---

**Versiyon**: 2.1.0
**Repository**: https://github.com/ravidulundu/1453-wsl-bash-script
**Platform**: WSL (Windows Subsystem for Linux)
**Dil**: Bash + Türkçe Arayüz
