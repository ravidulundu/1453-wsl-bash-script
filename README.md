# 1453-wsl-bash-script

## 🚀 1453.AI - WSL Setup Script for AI Developers

Comprehensive automated setup script for WSL (Windows Subsystem for Linux) environments, specifically designed for AI developers and "Vibe Coders."

## 📥 Installation

### 🎯 Hızlı Kurulum (Tek Komut - Önerilen!)

WSL terminalinizde bu tek komutu çalıştırarak her şeyi indirip kurabilirsiniz:

```bash
curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh | bash
```

Veya wget ile:
```bash
wget -qO- https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh | bash
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

### ⚙️ Advanced Mode (Detailed Control)
1. Full installation (all tools)
2. Setup preparation (system update + Git)
3. Install Python
4. Install pip
5. Install pipx
6. Install UV (ultra-fast Python package installer)
7. Install NVM (Node Version Manager)
8. Install Bun.js
9. Install PHP (multiple versions)
10. Install Composer
11. Install AI CLI tools
12. Install AI frameworks
13. Remove AI frameworks
14. Install Go
15. Install Modern CLI tools
16. Setup Shell environment
0. Exit

## 👨‍💻 Credits

- **Project Creator**: Alper Tunga
- **Developer**: Tamer KARACA (A.K.A THE KING)
- **Contributors**: FitzGPT, Tuğser OKUR
- **Version**: 1.0.1

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
