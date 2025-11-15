# 1453-wsl-bash-script

## 🚀 1453.AI - WSL Setup Script for AI Developers

Comprehensive automated setup script for WSL (Windows Subsystem for Linux) environments, specifically designed for AI developers and "Vibe Coders."

## 📥 Installation

### 🎯 Hızlı Kurulum (Tek Komut - Önerilen!)

WSL terminalinizde bu tek komutu çalıştırarak her şeyi indirip kurabilirsiniz:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

Veya wget ile:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

Bu komut:
- Tüm betik bileşenlerini indirir
- Her şeyi `~/.1453-wsl-setup` dizinine kurar
- Kolay erişim için başlatıcı oluşturur
- İsterseniz kurulumu hemen başlatır

Kurulumdan sonra çalıştırmak için:
```bash
~/.1453-wsl-setup/1453-setup
```

### Alternatif: Depoyu Klonlama
```bash
# Depoyu klonla
git clone https://github.com/ravidulundu/1453-wsl-bash-script.git
cd 1453-wsl-bash-script

# Kurulum betiğini çalıştır
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

### ⚠️ Windows Satır Sonu Sorunu

Eğer betiği Windows'tan indirdiyseniz veya bu hatayı alıyorsanız:
```
linux-ai-setup-script.sh: line 10: syntax error near unexpected token `elif'
```

**Çözüm 1: fix-crlf yardımcı betiğini kullanın**
```bash
chmod +x fix-crlf.sh
./fix-crlf.sh src/linux-ai-setup-script.sh
```

**Çözüm 2: Manuel düzeltme**
```bash
# Windows satır sonlarını Unix'e dönüştür
sed -i 's/\r$//' src/linux-ai-setup-script.sh

# Veya dos2unix varsa kullanın
dos2unix src/linux-ai-setup-script.sh

# Sonra betiği çalıştırın
bash src/linux-ai-setup-script.sh
```

## 🛠️ Features

- **Multi-Distribution Support**: Debian/Ubuntu, Fedora/RHEL, CentOS, Arch Linux
- **Programming Languages**: Python 3.x, Node.js (via NVM), PHP (7.4-8.5), Bun.js, Go
- **Modern CLI Tools**: bat, eza, starship, zoxide, fzf, vivid, fastfetch, lazygit, lazydocker
- **Shell Environment**: 62+ custom aliases, enhanced bash configuration, history optimization
- **AI CLI Tools**: Claude Code, Google Gemini, Qwen, OpenCode, GitHub Copilot, Codex
- **AI Frameworks**: SuperGemini, SuperQwen, SuperClaude with MCP server support
- **Automatic Configuration**: Git setup, shell configuration, package manager detection
- **Two Modes**: Quick Start (presets for beginners) and Advanced (detailed control)
- **Interactive Menu**: User-friendly interface with multi-choice support
- **Cleanup & Reset**: Comprehensive cleanup system with backup, selective removal, and full reset options

## 📋 Installation Modes

### 🚀 Quick Start Mode (Recommended for Beginners)
Choose from pre-configured presets:
1. **Web Development** - Python + Node.js + PHP + Composer
2. **AI Development** - Python + AI CLI Tools + AI Frameworks
3. **Backend Development** - Python + Go + PHP + Composer
4. **Everything** - Full stack + AI + Backend
5. **Mobile + Web** - Python + Node.js + PHP + Flutter tools

All presets automatically include:
- Modern CLI tools (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)
- Shell environment setup (62+ aliases, custom functions, enhanced bashrc)
- Python + pip + pipx + UV

### ⚙️ Advanced Mode (Gelişmiş Mod - Detaylı Kontrol)
1. Tam Kurulum (tüm araçlar)
2. Hazırlık (sistem güncelleme + Git)
3. Python Kurulumu
4. Pip Güncelleme
5. Pipx Kurulumu
6. UV Kurulumu (ultra-hızlı Python paket yükleyici)
7. NVM Kurulumu (Node Version Manager)
8. Bun.js Kurulumu
9. PHP Kurulumu (birden fazla versiyon)
10. Composer Kurulumu
11. AI CLI Araçları
12. AI Framework'leri
13. AI Framework'leri Kaldır
14. Go Kurulumu
15. Modern CLI Araçları
16. Shell Ortamı Kurulumu
17. 🗑️ Temizleme ve Sıfırlama
18. 🐳 Docker (Docker Engine + lazydocker)
0. Çıkış

## 🛠️ Modern CLI Araçları Kullanımı

Script ile kurulan modern CLI araçları ve kullanımları:

### 📁 Dosya Yönetimi

#### **bat** - Syntax Highlighted Cat
`cat` komutunun gelişmiş versiyonu, syntax highlighting ile dosya görüntüleme.

```bash
# Dosya içeriğini renkli göster
bat dosya.py

# Satır numaraları ile
bat -n dosya.js

# Birden fazla dosya
bat dosya1.txt dosya2.txt

# Alias olarak zaten tanımlı:
cat dosya.py  # otomatik bat kullanır
```

#### **eza** - Modern ls
Gelişmiş `ls` komutu, renkli ve detaylı listeleme.

```bash
# Temel kullanım (alias: ll)
ll

# Dosyaları listele
eza -la

# Ağaç görünümü
eza --tree

# Git durumu ile
eza -la --git

# Zaten tanımlı aliaslar:
ls   # eza kullanır
ll   # eza -lah
la   # eza -a
lt   # eza --tree
```

#### **fd** - Modern Find
Hızlı dosya arama.

```bash
# Dosya ara
fd dosya_adi

# Belirli uzantıda ara
fd -e js

# Dizin ara
fd -t d klasor_adi

# Ignore edilenleri dahil et
fd -H gizli_dosya
```

#### **ripgrep (rg)** - Süper Hızlı Grep
Çok hızlı içerik arama.

```bash
# Tüm dosyalarda ara
rg "aranan_kelime"

# Sadece .py dosyalarında ara
rg "fonksiyon" -t py

# Case insensitive
rg -i "KELIME"

# Satır numarası ile
rg -n "kod"
```

### 🎨 Terminal Güzelleştirme

#### **starship** - Modern Shell Prompt
Otomatik olarak aktif. Git durumu, Python/Node versiyonu, vs. gösterir.

```bash
# Starship config dosyası
~/.config/starship.toml

# Yeni terminal açtığınızda otomatik çalışır
# Git repo'sunda → branch ve değişiklikler gösterir
# Python projede → Python versiyonu gösterir
# Node projede → Node versiyonu gösterir
```

#### **vivid** - LS_COLORS Generator
`eza` ve `ls` için renk şemaları. Otomatik yapılandırılmış.

### 🚀 Navigasyon

#### **zoxide** - Akıllı cd
Sık kullandığınız dizinleri hatırlar, hızlı erişim sağlar.

```bash
# Bir dizine git (ilk seferde normal cd kullan)
cd ~/projeler/proje1

# Sonra sadece isim yeter
z proje1  # ~/projeler/proje1'e gider

# Kısmi eşleşme
z pro1    # ~/projeler/proje1'e gider

# Liste
zi        # interaktif seçim
```

#### **fzf** - Fuzzy Finder
İnteraktif bulanık arama.

```bash
# Komut geçmişinde ara (Ctrl+R)
# Terminalde Ctrl+R'ye bas, yazmaya başla

# Dosya ara ve aç
vim $(fzf)

# Dizin seç ve git
cd $(fd -t d | fzf)

# Kill process
kill -9 $(ps aux | fzf | awk '{print $2}')
```

### 🐙 Git Araçları

#### **lazygit** - Terminal Git UI
İnteraktif git arayüzü.

```bash
# Git repo'sunda çalıştır
lazygit

# Kullanımı:
# ↑↓ : Hareket
# Enter: Seç
# Space: Stage/Unstage
# c: Commit
# P: Push
# p: Pull
# q: Çıkış
```

#### **lazydocker** - Terminal Docker UI
İnteraktif Docker yönetimi.

```bash
# Docker çalışırken lazydocker kullan
lazydocker

# Kullanımı:
# ↑↓ : Hareket
# Enter: Seç/Aç
# m: Menüler
# x: Container exec
# l: Loglar
# s: Stats
# q: Çıkış
```

### 🐳 Docker Kurulumu

**Script ile Otomatik Kurulum (Önerilen):**

```bash
# Advanced Mode → Seçenek 18 (Docker)

1) Docker Engine Kurulumu
   - Docker CE + CLI
   - containerd
   - docker-compose plugin
   - Kullanıcıyı docker grubuna ekler

2) lazydocker Kurulumu
   - Terminal UI
   - Docker Engine kontrolü yapar

3) Tümünü Kur
   - Docker Engine + lazydocker
```

**Manuel Kurulum:**
```bash
# Docker Engine
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker grubuna kullanıcı ekle
sudo usermod -aG docker $USER
newgrp docker

# Lazydocker (script ile veya manuel)
# Script'ten: Advanced Mode → 18 → 2
```

### 📊 Sistem Bilgisi

#### **fastfetch** - Sistem Bilgisi
Renkli sistem bilgisi gösterimi.

```bash
# Hızlı sistem bilgisi
fastfetch

# Özel logo ile
fastfetch -l arch

# Sadece belirli bilgiler
fastfetch --structure Title:Separator:OS:Host:Kernel:Uptime
```

### 🎯 Özel Aliaslar (62+)

Script 62'den fazla alias yükler. İşte en kullanışlı olanlar:

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
la        # eza -a (tümünü göster)
lt        # eza --tree (ağaç görünüm)

# Güvenlik
rm        # rm -i (onay iste)
cp        # cp -i (onay iste)
mv        # mv -i (onay iste)

# Diğerleri
grep      # grep --color=auto
ports     # netstat -tulanp (port listesi)
myip      # curl ifconfig.me (public IP)
```

### 💡 İpuçları

1. **Tab Completion**: Çoğu araç tab completion destekler
2. **Help**: Her araç için `komut --help` çalıştırın
3. **Man Pages**: `man komut` ile detaylı dokümantasyon
4. **Alias Listesi**: `alias` komutu ile tüm aliasları görebilirsiniz

## 🗑️ Temizleme ve Sıfırlama Özellikleri

Kurulumlarınızı yönetmek ve sıfırlamak için kapsamlı araçlar sunar:

### Temizleme Seçenekleri

1. **🔴 Tam Sıfırlama (Beyaz Bayrak)**
   - Sistemi tamamen temiz duruma getirir
   - Tüm kurulumları ve yapılandırmaları kaldırır
   - Temizlemeden önce otomatik yedek oluşturur
   - ⚠️ UYARI: Bu işlem geri alınamaz!

2. **🧹 Sadece Kurulumları Temizle**
   - Tüm kurulu araçları kaldırır (Python, Node.js, PHP, Go, AI araçları)
   - Yapılandırma dosyalarını korur (.bashrc, .bash_aliases, vb.)
   - Özel ayarları kaybetmeden araçları yeniden yüklemenin güvenli yolu

3. **📦 Tek Tek Temizle**
   - Belirli bileşenleri seçerek kaldırın:
     - Python ekosistemi (python3, pip, pipx, uv)
     - Node.js ekosistemi (nvm, node, npm, bun)
     - PHP ekosistemi (php, composer)
     - Go
     - Modern CLI araçları (bat, eza, starship, zoxide, vb.)
     - Shell yapılandırmaları
     - AI CLI araçları
     - AI framework'leri

4. **⚙️ Sadece Config Temizle**
   - Sadece yapılandırma dosyalarını kaldırır
   - Tüm kurulumları korur
   - Shell özelleştirmelerini sıfırlamak için kullanışlı

5. **📊 Kurulu Olanları Göster**
   - Şu anda nelerin kurulu olduğunu gösterir
   - Temizlemeden önce kurulum durumunu kontrol edin
   - Temizleme sonrası sonuçları doğrulayın

### Güvenlik Özellikleri

- **Çift Onay**: Kritik işlemler için "evet" yazmanızı gerektirir
- **Otomatik Yedekleme**: Temizlemeden önce isteğe bağlı yedek oluşturma
- **Zaman Damgalı Yedekler**: `~/.1453-backup-YYYYMMDD_HHMMSS/` dizinine kaydedilir
- **Sistem Koruması**: Sistem paketlerini korur, sadece kullanıcı alanı kurulumlarını kaldırır
- **Geri Alınabilir İşlemler**: Config dosyaları silinmek yerine `.removed` uzantısıyla taşınır
- **Kaynak Kod Koruması**: Git clone'lanmış kaynak kod dizinini silmez (sadece `~/.1453-wsl-setup` silinir)

### ⚠️ Önemli Notlar

**Cleanup neleri SİLER:**
- `~/.1453-wsl-setup` (kurulum dizini)
- Kurulu araçlar (Python, Node, PHP, Go, vb.)
- Config dosyaları (.bashrc değişiklikleri, .bash_aliases, vb.)

**Cleanup neleri SİLMEZ:**
- Kaynak kod repository'si (eğer `git clone` yaptıysanız)
- Sistem paketleri
- Kişisel dosyalarınız

**Manuel temizlik için:**
```bash
# Kaynak kod dizinini bulmak
find ~ -name "1453-wsl-bash-script" -type d

# Manuel silmek (DİKKATLİ!)
rm -rf ~/1453-wsl-bash-script  # veya bulduğunuz dizin
```

### Kullanım Örneği

```bash
# Script'i çalıştır
~/.1453-wsl-setup/1453-setup

# Advanced Mode seç (2)
# 17 numaralı seçeneği seç (Temizleme ve Sıfırlama)

# Temizleme türünü seç:
# - Kurulu olanları göster (5)
# - Belirli bileşeni kaldır (3)
# - Gerekirse tam sıfırlama (1)
```

## 👨‍💻 Credits

- **Project Creator**: Alper Tunga
- **Developer**: Tamer KARACA (A.K.A THE KING)
- **Contributors**: FitzGPT, Tuğser OKUR
- **Version**: 2.1.0

## 📄 License

MIT License - See [LICENSE.md](LICENSE.md) for details

## ✅ Testing & Validation

Kurulumunuzun doğru yapıldığını kontrol etmek için test scripti kullanabilirsiniz:

### Hızlı Test
```bash
# Temel test
./test-setup.sh

# Detaylı çıktı ile test
./test-setup.sh --verbose

# JSON formatında rapor
./test-setup.sh --json > test-report.json

# Log dosyasına kaydet
./test-setup.sh --log test-results.log
```

### Test Scripti Neleri Kontrol Eder?

Test scripti şu kategorileri kontrol eder:

1. **Sistem Bilgileri** - OS, kernel, WSL, paket yöneticisi
2. **Temel Araçlar** - git, curl, wget, jq, build essentials
3. **Python Ekosistemi** - Python, pip, pipx, UV
4. **JavaScript Ekosistemi** - NVM, Node.js, npm, Bun.js
5. **PHP Ekosistemi** - PHP, Composer, birden fazla PHP versiyonu
6. **Go Language** - Go, GOPATH, GOROOT
7. **Modern CLI Araçları** - bat, eza, starship, zoxide, fzf, lazygit, lazydocker, vb.
8. **Shell Ortamı** - .bash_aliases, custom functions, bashrc enhancements
9. **AI CLI Araçları** - Claude Code, Gemini CLI, GitHub CLI
10. **AI Frameworks** - SuperGemini, SuperQwen, SuperClaude
11. **Docker** - Docker Engine, lazydocker
12. **Kurulum Dizini** - ~/.1453-wsl-setup yapısı

### Test Sonuçları

Script şu bilgileri sağlar:
- ✓ **Başarılı**: Araç kurulu ve çalışıyor
- ✗ **Başarısız**: Araç kurulu değil veya hatalı
- ⚠ **Uyarı**: Opsiyonel bileşen eksik

Her testten sonra detaylı özet rapor gösterilir:
- Toplam test sayısı
- Kategori bazında sonuçlar
- Başarılı/Başarısız/Uyarı sayıları
- Eksik veya hatalı bileşenlerin listesi

## 🐛 Troubleshooting

### Script Syntax Check
```bash
# Check for syntax errors without running
bash -n src/linux-ai-setup-script.sh

# Test scriptini kontrol et
bash -n test-setup.sh
```

### Common Issues

1. **Permission Denied**: Run `chmod +x` on the script
2. **CRLF Line Endings**: Use `fix-crlf.sh` helper or convert manually
3. **Missing Dependencies**: Script installs prerequisites automatically
4. **Shell Not Reloading**: Restart terminal or run `source ~/.bashrc`
5. **Test Failed**: Eksik bileşenleri test raporundan görebilir ve setup scriptini tekrar çalıştırabilirsiniz

## 🤝 Contributing

Feel free to submit issues and pull requests at https://github.com/ravidulundu/1453-wsl-bash-script
