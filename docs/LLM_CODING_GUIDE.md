# LLM Coding Agent Guide: 1453 WSL Bash Script

## 🎯 Quick Start for LLM Agents

### Project Type
**Bash scripting project with modular architecture** - WSL development environment automation tool for AI developers.

### Language
**Primary**: Bash (with Turkish user interface)
**Lines of Code**: ~1,500 (modular v2.0) + ~2,300 (legacy v1.0 backup)

### Core Purpose
One-command installation of complete AI/ML development environment on WSL:
- Python ecosystem (Python, pip, pipx, UV)
- JavaScript ecosystem (NVM, Bun.js)
- PHP ecosystem (multiple versions, Composer, Laravel-ready)
- AI CLI tools (Claude, Qwen, Gemini, GitHub Copilot, etc.)
- AI frameworks (SuperGemini, SuperQwen, SuperClaude)

---

## 📁 Project Structure (Critical for LLM Understanding)

```
/workspace/1453-wsl-bash-script/
├── install.sh              # 188 lines - One-line installer (MAIN ENTRY POINT)
├── fix-crlf.sh             # 64 lines - Windows line ending fixer
├── README.md               # User documentation (Turkish)
├── CLAUDE.md               # Developer documentation (THIS FILE)
│
└── src/
    ├── linux-ai-setup-script.sh      # 52 lines - Main entry point (LOADS MODULES)
    ├── linux-ai-setup-script-legacy.sh # 2,331 lines - Monolithic backup
    │
    ├── lib/                          # Core libraries
    │   ├── init.sh                   # 46 lines - CRLF detection & fixes
    │   ├── common.sh                 # 68 lines - Shared utilities
    │   └── package-manager.sh        # 74 lines - Package manager detection
    │
    ├── config/                       # Configuration
    │   ├── colors.sh                 # 15 lines - Terminal color codes
    │   ├── php-versions.sh           # Arrays of PHP versions & extensions
    │   └── banner.sh                 # 33 lines - ASCII art banner
    │
    └── modules/                      # Feature modules
        ├── python.sh                 # 195 lines - Python ecosystem
        ├── javascript.sh             # 84 lines - NVM & Bun.js
        ├── php.sh                    # 244 lines - PHP with version switching
        ├── ai-cli.sh                 # 210 lines - AI command-line tools
        ├── ai-frameworks.sh          # 214 lines - AI frameworks
        └── menus.sh                  # Interactive menu system
```

---

## 🚀 Installation & Execution

### Method 1: One-Line Installer (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/altudev/1453-wsl-bash-script/master/install.sh | bash
```

**What it does**:
1. Downloads all 13 modular components to `~/.1453-wsl-setup/`
2. Creates launcher script `1453-setup`
3. Prompts to run setup immediately
4. Handles piped input correctly

### Method 2: Direct Execution
```bash
git clone https://github.com/altudev/1453-wsl-bash-script.git
cd 1453-wsl-bash-script
./src/linux-ai-setup-script.sh
```

---

## 🏗️ Architecture Patterns

### Loading Order (CRITICAL)
The main script loads modules in **exactly this order**:

```bash
# Phase 1: Critical initialization
source "lib/init.sh"

# Phase 2: Configurations
source "config/colors.sh"
source "config/php-versions.sh"
source "config/banner.sh"

# Phase 3: Core libraries
source "lib/common.sh"
source "lib/package-manager.sh"

# Phase 4: Feature modules
source "modules/python.sh"
source "modules/javascript.sh"
source "modules/php.sh"
source "modules/ai-cli.sh"
source "modules/ai-frameworks.sh"
source "modules/menus.sh"

# Phase 5: Execute
show_banner
main "$@"
```

### Why Order Matters
1. **`init.sh` FIRST**: Handles CRLF fixes, sets up SCRIPT_DIR
2. **Config next**: Colors, PHP arrays, banner
3. **Libraries**: Common utilities, package manager detection
4. **Modules**: Feature implementations
5. **Menus LAST**: Depends on all other modules

---

## 🔧 Module Guide for LLM Agents

### Core Libraries (`lib/`)

#### `init.sh` - The Self-Healing Core
```bash
# Key function (auto-runs):
# - Detects and fixes Windows CRLF line endings
# - Sets SCRIPT_DIR for all modules
# - Ensures bash shell execution

# CRITICAL: Must be sourced first
source "${SCRIPT_DIR}/lib/init.sh"
```

**What to know**:
- Auto-detects CRLF and fixes with dos2unix/sed/tr
- Uses `exec bash "$0" "$@"` to restart after fix
- Sets up absolute paths for all modules

#### `common.sh` - Shared Utilities
```bash
# Reload shell configuration files
reload_shell_configs() { ... }

# Mask sensitive data for display
mask_secret() { ... }

# Both exported: export -f function_name
```

#### `package-manager.sh` - Distribution Detection
```bash
# Auto-detects: apt, dnf, yum, pacman
# Sets globals: PKG_MANAGER, UPDATE_CMD, INSTALL_CMD
detect_package_manager() { ... }

# Updates system and installs essentials
update_system() { ... }
```

### Configuration Files (`config/`)

#### `colors.sh`
```bash
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'  # No Color
```

**Usage**: All echo statements use color codes:
```bash
echo -e "${GREEN}[SUCCESS]${NC} Installation complete!"
echo -e "${YELLOW}[INFO]${NC} Installing packages..."
```

#### `php-versions.sh`
Contains two critical arrays:
```bash
# Supported PHP versions
PHP_SUPPORTED_VERSIONS=("7.4" "8.1" "8.2" "8.3" "8.4" "8.5")

# Extensions for Laravel
PHP_EXTENSION_PACKAGES=(curl zip xml mbstring tokenizer openssl gd soap intl bcmath pdo_mysql pdo_pgsql pdo_sqlite fpm)
```

#### `banner.sh`
```bash
# Displays 1453 ASCII art and script info
show_banner() {
    clear
    echo -e "${CYAN}"
    # ASCII art...
    echo -e "${NC}"
    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    # Title...
}
```

### Feature Modules (`modules/`)

#### `python.sh` - Python Ecosystem
```bash
install_python()     # Python 3 + pip + venv
install_pip()        # Update pip (handles PEP 668)
install_pipx()       # Install pipx (multiple fallbacks)
install_uv()         # Install UV fast package manager
```

**Key insights**:
- Handles PEP 668 externally-managed-environment errors
- `install_pipx()` tries 3 installation methods (system → manual venv → user)
- All tools update shell RC files and call `reload_shell_configs()`

#### `javascript.sh` - Node.js Ecosystem
```bash
install_nvm()        # Installs NVM v0.40.3 + Node LTS
install_bun()        # Installs Bun.js runtime
```

**Key insights**:
- Downloads NVM directly from GitHub
- Updates .bashrc, .zshrc, .profile with NVM configuration
- Bun installs to `$HOME/.bun`

#### `php.sh` - PHP with Version Management
```bash
ensure_php_repository()     # Adds Ondřej Surý (APT) or Remi (DNF/YUM)
install_composer()          # Composer with SHA384 verification
install_php_version()       # Installs specific PHP version
install_php_version_menu()  # Interactive selection
```

**Key insights**:
- Uses `update-alternatives` for PHP version switching (not shown in modular version)
- Package naming differs: `php8.2` (APT) vs `php82-php` (DNF/YUM)
- Installs 15+ Laravel-ready extensions

#### `ai-cli.sh` - AI Command-Line Tools
```bash
install_claude_code()       # Anthropic's official installer
install_gemini_cli()        # Google AI SDK via pip
install_qwen_cli()          # Qwen via pipx
install_github_cli()        # GitHub CLI (distribution-specific)
install_ai_cli_tools_menu() # Interactive menu
```

**Key insights**:
- Handles dependencies (Python for Gemini, npm for others)
- GitHub CLI uses different methods per distribution
- All tools reload shell configs after installation

#### `ai-frameworks.sh` - AI Frameworks (pipx-based)
```bash
install_supergemini()      # via pipx
install_superqwen()        # via pipx
install_superclaude()      # via pipx
install_ai_frameworks_menu() # Interactive menu
```

**Key insights**:
- All use `pipx` for isolated installations
- Check for existing install and reinstall if present
- Require API keys for actual usage

#### `menus.sh` - Interactive UI
```bash
configure_git()             # Interactive Git setup
prepare_and_configure_git() # update_system + configure_git
show_menu()                 # Display main menu
main()                      # Program loop with multi-choice
```

**Key insights**:
- Supports multi-choice input: `3,7,11` for Python+JS+AI tools
- Runs indefinitely until user selects 0 (exit)
- First thing: `detect_package_manager()`

---

## 🎨 Turkish Language Interface

### All user-facing text is in Turkish:
```bash
echo -e "${YELLOW}[BİLGİ]${NC} Kurulum başlatılıyor..."
echo -e "${GREEN}[BAŞARILI]${NC} Kurulum tamamlandı!"
echo -e "${RED}[HATA]${NC} Bir hata oluştu!"
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
```

### Common Turkish Terms:
- **BİLGİ** = INFO
- **BAŞARILI** = SUCCESS
- **UYARI** = WARNING
- **HATA** = ERROR
- **Kurulum** = Installation
- **Seçiminizi yapın** = Make your selection

### Menu System (Turkish):
```bash
echo -e "  ${GREEN}1${NC}) Tam Kurulum (Önerilen)"
echo -e "  ${GREEN}2${NC}) Hazırlık (Sistem güncelleme + Git)"
echo -e "  ${GREEN}0${NC}) Çıkış"
echo -ne "\n${YELLOW}Seçiminizi yapın: ${NC}"
```

---

## 🔍 Common Patterns

### 1. Installation Pattern
```bash
install_tool() {
    echo -e "\n${BLUE}╔═══════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Installing tool..."
    echo -e "${BLUE}╚═══════════════════════╝${NC}"

    # Check if already installed
    if command -v tool &> /dev/null; then
        echo -e "${GREEN}[SUCCESS]${NC} Already installed: $(tool --version)"
        return 0
    fi

    # Installation steps...
    curl -fsSL https://example.com/install | bash

    # Reload shell
    reload_shell_configs

    # Verify
    if command -v tool &> /dev/null; then
        echo -e "${GREEN}[SUCCESS]${NC} Installation complete!"
        return 0
    else
        echo -e "${RED}[ERROR]${NC} Installation failed!"
        return 1
    fi
}
```

### 2. Menu Pattern
```bash
show_tool_menu() {
    echo -e "\n${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         Tool Installation             ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
    echo -e "  ${GREEN}1${NC}) Install Tool A"
    echo -e "  ${GREEN}2${NC}) Install Tool B"
    echo -e "  ${GREEN}3${NC}) Install All"
    echo -e "  ${GREEN}0${NC}) Return to main menu"

    echo -ne "\n${YELLOW}Select: ${NC}"
    read -r choice

    case $choice in
        1) install_tool_a ;;
        2) install_tool_b ;;
        3) install_tool_a && install_tool_b ;;
        0) return ;;
        *) echo -e "${RED}[ERROR]${NC} Invalid selection!" ;;
    esac
}
```

### 3. Package Manager Pattern
```bash
# Detect once at startup
detect_package_manager

# Use throughout
eval "$INSTALL_CMD" package1 package2 package3

# Different commands per manager
if [ "$PKG_MANAGER" = "apt" ]; then
    eval "$INSTALL_CMD" package
elif [ "$PKG_MANAGER" = "dnf" ]; then
    eval "$INSTALL_CMD" package
fi
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Windows CRLF Line Endings
**Error**: `syntax error near unexpected token 'elif'`

**Solution**: `init.sh` auto-detects and fixes this
```bash
# Or manually:
sed -i 's/\r$//' script.sh
dos2unix script.sh
```

### Issue 2: PEP 668 Externally-Managed-Environment
**Error**: Cannot install packages globally

**Solution**: `install_pip()` handles this
```bash
# Automatically adds --break-system-packages
python3 -m pip install package --break-system-packages
```

### Issue 3: Interactive Prompt in Pipe
**Problem**: `read` fails when piped through curl

**Solution**: `install.sh` fixes this
```bash
if [ -t 0 ]; then
    read -r response
else
    read -r response </dev/tty
fi
```

---

## 📊 Dependencies & Prerequisites

### System Requirements
- **OS**: WSL (Windows Subsystem for Linux)
- **Shell**: Bash (not sh)
- **Internet**: For downloading packages and tools

### Prerequisites Installed by Script
- curl
- wget
- git
- jq
- zip, unzip, 7zip
- build-essential / Development Tools

### Runtime Dependencies per Module
- **Python**: python3, python3-pip
- **JavaScript**: curl (for downloads)
- **PHP**: Software dependencies for repository config
- **AI Tools**: Varies (Python, npm, pipx)

### Package Managers Supported
1. **APT** - Debian/Ubuntu
2. **DNF** - Fedora/RHEL 8+
3. **YUM** - RHEL/CentOS 7
4. **Pacman** - Arch Linux

---

## 🔑 Key Files for LLM Agents

### Critical Files (Must Read)
1. **`src/linux-ai-setup-script.sh`** - Main entry point, shows loading order
2. **`src/lib/init.sh`** - CRLF handling and SCRIPT_DIR setup
3. **`src/lib/common.sh`** - reload_shell_configs, mask_secret
4. **`src/lib/package-manager.sh`** - detect_package_manager, update_system

### Configuration Files
5. **`src/config/colors.sh`** - Color codes used everywhere
6. **`src/config/php-versions.sh`** - PHP versions and extensions arrays

### Module Files (Function Implementations)
7. **`src/modules/python.sh`** - Python, pip, pipx, UV
8. **`src/modules/javascript.sh`** - NVM, Bun.js
9. **`src/modules/php.sh`** - PHP versions, Composer
10. **`src/modules/ai-cli.sh`** - AI CLI tools
11. **`src/modules/ai-frameworks.sh`** - AI frameworks
12. **`src/modules/menus.sh`** - Interactive menus

### Utility Files
13. **`install.sh`** - One-line installer (how users install)
14. **`scripts/fix-crlf.sh`** - Helper for Windows line ending issues

### Documentation
15. **`README.md`** - User guide (Turkish)
16. **`CLAUDE.md`** - Developer guide (THIS FILE)

---

## 🧩 Adding New Features

### To Add a New Tool

1. **Create function in appropriate module**:
```bash
install_newtool() {
    echo -e "\n${BLUE}╔═══════════════════════╗${NC}"
    echo -e "${YELLOW}[BİLGİ]${NC} Installing NewTool..."
    echo -e "${BLUE}╚═══════════════════════╝${NC}"

    # Check if installed
    if command -v newtool &> /dev/null; then
        echo -e "${GREEN}[SUCCESS]${NC} Already installed"
        return 0
    fi

    # Install...
    curl -fsSL https://example.com/install | bash

    # Reload
    reload_shell_configs

    # Verify
    command -v newtool &> /dev/null
}
```

2. **Export function** (at end of module):
```bash
export -f install_newtool
```

3. **Add to menu** (in `menus.sh`):
```bash
show_menu() {
    echo -e "  ${GREEN}14${NC}) New Tool Installation"
    # ...

    case $choice in
        # ...
        14) install_newtool ;;
    esac
}
```

4. **Add to full installation** (in `main()`):
```bash
option_1)  # Full installation
    # ...
    install_newtool
    ;;
```

### Module Selection Guidelines
- **python.sh** - Python-related tools
- **javascript.sh** - Node.js/npm/Bun related
- **php.sh** - PHP/Composer related
- **ai-cli.sh** - Command-line AI tools
- **ai-frameworks.sh** - Python-based AI frameworks
- **menus.sh** - User interface only

---

## 🎓 Testing & Validation

### Syntax Check
```bash
# All modules
for file in src/{lib,config,modules}/*.sh; do
    bash -n "$file" || echo "ERROR in $file"
done

# Main script
bash -n src/linux-ai-setup-script.sh
```

### Shellcheck (if installed)
```bash
shellcheck src/linux-ai-setup-script.sh
shellcheck src/{lib,config,modules}/*.sh
```

### Module Testing
```bash
# Source dependencies
source src/config/colors.sh
source src/lib/common.sh
source src/lib/package-manager.sh
source src/modules/python.sh

# Test function
install_python
```

---

## 📝 Version Information

- **Current Version**: 2.0 Modular Architecture
- **Previous Version**: 1.0 Monolithic (2,331 lines)
- **Backup Location**: `src/linux-ai-setup-script-legacy.sh`
- **Change**: Refactored from 1 file to 14 modular files
- **Compatibility**: 100% backward compatible

---

## 🔗 Quick Reference Links

- **Repository**: https://github.com/altudev/1453-wsl-bash-script
- **Issues**: Report at repository issues page
- **Installation**: `curl -fsSL https://raw.githubusercontent.com/altudev/1453-wsl-bash-script/master/install.sh | bash`
- **License**: MIT

---

## ✅ Summary for LLM Agents

**This is a**: Bash automation script for WSL development environment setup

**Language**: Bash (with Turkish interface)

**Architecture**: Modular (14 files) - not monolithic

**Main entry**: `src/linux-ai-setup-script.sh` loads all modules in specific order

**Key functions**:
- `detect_package_manager()` - Auto-detect APT/DNF/YUM/Pacman
- `reload_shell_configs()` - Update shell after PATH changes
- `install_python()`, `install_nvm()`, `install_php_version()` - Install dev tools
- `install_claude_code()`, `install_supergemini()` - Install AI tools

**Critical patterns**:
- Always call `reload_shell_configs()` after installing tools
- Use `export -f function_name` to make functions available
- Check prerequisites before installation
- Handle PEP 668 for Python packages
- Auto-detect and fix CRLF line endings

**User interface**: Interactive menu with multi-choice support (comma-separated)

**Languages supported**: Turkish (all user-facing text)

**Dependencies**: curl, wget, git (installed automatically)

**Version**: 2.0 modular (refactored from 2,331-line monolithic)
