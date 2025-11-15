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
0. Çıkış

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

## 🐛 Troubleshooting

### Script Syntax Check
```bash
# Check for syntax errors without running
bash -n src/linux-ai-setup-script.sh
```

### Common Issues

1. **Permission Denied**: Run `chmod +x` on the script
2. **CRLF Line Endings**: Use `fix-crlf.sh` helper or convert manually
3. **Missing Dependencies**: Script installs prerequisites automatically
4. **Shell Not Reloading**: Restart terminal or run `source ~/.bashrc`

## 🤝 Contributing

Feel free to submit issues and pull requests at https://github.com/ravidulundu/1453-wsl-bash-script
