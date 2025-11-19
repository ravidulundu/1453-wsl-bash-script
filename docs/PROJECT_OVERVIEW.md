# Project Overview: 1453 WSL Bash Script

## 🎯 Project Purpose

**1453.AI WSL Setup Script** is a comprehensive, modular automation tool for setting up WSL (Windows Subsystem for Linux) environments specifically designed for AI developers and "Vibe Coders." The project provides a one-line installer and interactive menu system to quickly set up a complete development environment.

## 🏗️ Architecture

### Version 2.0 - Modular Architecture

The project has been refactored from a **2,331-line monolithic script** into a clean, maintainable modular architecture with **14 files**, organized into logical categories:

```
1453-wsl-bash-script/
├── install.sh                           # One-line installer (Turkish interface)
├── fix-crlf.sh                         # CRLF line ending fixer helper
├── README.md                           # Project documentation (Turkish)
├── CLAUDE.md                           # Development guide
│
└── src/
    ├── linux-ai-setup-script.sh        # Main entry point (52 lines)
    ├── linux-ai-setup-script-legacy.sh # Original backup (v1.0)
    │
    ├── lib/                            # Core libraries
    │   ├── init.sh                    # CRLF detection & initialization
    │   ├── common.sh                  # Shared utilities
    │   └── package-manager.sh         # Package manager detection
    │
    ├── config/                         # Configuration files
    │   ├── colors.sh                  # Terminal colors
    │   ├── php-versions.sh            # PHP versions & extensions
    │   └── banner.sh                  # ASCII banner display
    │
    └── modules/                        # Feature modules
        ├── python.sh                  # Python ecosystem (Python, pip, pipx, UV)
        ├── javascript.sh              # JavaScript ecosystem (NVM, Bun.js)
        ├── php.sh                     # PHP ecosystem (PHP, Composer, Laravel)
        ├── ai-cli.sh                  # AI CLI tools
        ├── ai-frameworks.sh           # AI frameworks
        └── menus.sh                   # Interactive menu system
```

### Key Architectural Principles

1. **Separation of Concerns**: Each module has a specific responsibility
2. **Dependency Management**: Clear loading order with proper dependencies
3. **Reusability**: Shared utilities in `lib/common.sh`
4. **Maintainability**: Easy to modify individual components
5. **Cross-Platform**: Support for APT, DNF, YUM, Pacman

## 📦 Installation & Deployment

### Quick Installation (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/altudev/1453-wsl-bash-script/master/install.sh | bash
```

This single command:
- Downloads all 13 modular components from GitHub
- Sets up directory structure in `~/.1453-wsl-setup/`
- Creates a launcher script (`1453-setup`)
- Prompts to run setup immediately
- Handles interactive prompts even when piped

### Manual Installation
```bash
git clone https://github.com/altudev/1453-wsl-bash-script.git
cd 1453-wsl-bash-script
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

### Post-Installation Structure
```
~/.1453-wsl-setup/
├── 1453-setup                      # Launcher script
└── src/
    ├── linux-ai-setup-script.sh    # Main script
    ├── lib/                        # All library files
    ├── config/                     # All config files
    └── modules/                    # All module files
```

## 🔧 Technology Stack

### Programming Languages & Runtimes
- **Python 3.x** - With pip, pipx, and UV
- **Node.js** - Via NVM (LTS version)
- **Bun.js** - Modern JavaScript runtime
- **PHP** - Multiple versions (7.4, 8.1, 8.2, 8.3, 8.4, 8.5)

### AI Tools
- **Claude Code CLI** - Anthropic's command-line tool
- **Qoder CLI** - AI-powered development assistant
- **Gemini CLI** - Google AI SDK
- **Qwen CLI** - Alibaba's AI assistant
- **OpenCode CLI** - Open source code assistant
- **GitHub Copilot CLI** - GitHub's AI pair programmer
- **GitHub CLI** - Official GitHub command-line tool

### AI Frameworks
- **SuperGemini** - Gemini-powered development framework
- **SuperQwen** - Qwen-powered development framework
- **SuperClaude** - Claude-powered development framework
- **MCP Server Support** - Model Context Protocol integration

## 🎨 User Interface

### Language: Turkish
The entire interface is in Turkish:
- All prompts and messages
- Menu items and navigation
- Error messages and notifications
- Success confirmations

### Interactive Features
- **Multi-choice support**: Select multiple options with commas
- **Color-coded output**: RED (errors), GREEN (success), YELLOW (info), BLUE (headers), CYAN (prompts)
- **ASCII banner**: 1453-themed visual branding
- **Progress tracking**: Clear installation status

## 🔍 Module Details

### 1. Core Libraries (`lib/`)

#### `init.sh`
- **Purpose**: CRLF self-healing and initialization
- **Critical**: Must be loaded first
- **Features**:
  - Detects Windows CRLF line endings
  - Auto-fixes using dos2unix/sed/tr
  - Sets up `SCRIPT_DIR` for all modules
  - Ensures bash shell execution

#### `common.sh`
- **Purpose**: Shared utilities across all modules
- **Functions**:
  - `reload_shell_configs()` - Updates shell configuration
  - `mask_secret()` - Masks sensitive data for display

#### `package-manager.sh`
- **Purpose**: Package manager detection and system updates
- **Supported**: APT (Debian/Ubuntu), DNF (Fedora), YUM (RHEL/CentOS), Pacman (Arch)
- **Functions**:
  - `detect_package_manager()` - Auto-detects and sets global variables
  - `update_system()` - Updates packages and installs essentials

### 2. Configuration (`config/`)

#### `colors.sh`
- **Purpose**: Terminal color definitions
- **Colors**: RED, GREEN, YELLOW, BLUE, CYAN, NC (No Color)
- **Usage**: Echo statements with color codes

#### `php-versions.sh`
- **Purpose**: PHP version arrays and extension lists
- **Versions**: 7.4, 8.1, 8.2, 8.3, 8.4, 8.5
- **Extensions**: curl, zip, xml, mbstring, tokenizer, openssl, gd, soap, intl, bcmath, pdo_mysql, pdo_pgsql, pdo_sqlite, fpm

#### `banner.sh`
- **Purpose**: 1453 ASCII art and script header
- **Features**: Visual branding, version info, GitHub URL

### 3. Feature Modules (`modules/`)

#### `python.sh`
- **Purpose**: Python ecosystem setup
- **Functions**:
  - `install_python()` - Python 3 with pip and venv
  - `install_pip()` - Pip with PEP 668 compliance
  - `install_pipx()` - Isolated Python applications
  - `install_uv()` - Ultra-fast Python package manager
- **PEP 668 Handling**: `--break-system-packages` flag

#### `javascript.sh`
- **Purpose**: JavaScript/Node.js ecosystem
- **Functions**:
  - `install_nvm()` - Node Version Manager with LTS
  - `install_bun()` - Bun.js runtime
- **Shell Integration**: Updates .bashrc, .zshrc, .profile

#### `php.sh`
- **Purpose**: PHP ecosystem with version management
- **Functions**:
  - `ensure_php_repository()` - Configures Ondřej Surý (APT) or Remi (DNF/YUM)
  - `install_composer()` - Composer with SHA384 verification
  - `install_php_version()` - Specific PHP version with extensions
  - `install_php_version_menu()` - Interactive version selection
- **Package Manager Support**: APT, DNF, YUM, Pacman
- **Extension Support**: 15+ Laravel-ready extensions

#### `ai-cli.sh`
- **Purpose**: AI command-line tools
- **Tools**: Claude Code, Gemini, Qwen, OpenCode, Copilot CLI, GitHub CLI, Qoder
- **Dependencies**: Handles Python, npm, pipx requirements
- **Shell Integration**: reload_shell_configs after installation

#### `ai-frameworks.sh`
- **Purpose**: AI development frameworks
- **Frameworks**: SuperGemini, SuperQwen, SuperClaude
- **Installation**: Uses pipx for isolation
- **Features**: Install and remove functions for each framework
- **MCP Support**: Model Context Protocol integration

#### `menus.sh`
- **Purpose**: Interactive user interface
- **Functions**:
  - `configure_git()` - Git user setup
  - `prepare_and_configure_git()` - System update + Git config
  - `show_menu()` - Main menu display
  - `main()` - Program loop with multi-choice support
- **Multi-choice**: Comma-separated selection support

## 🌟 Key Features

### Multi-Distribution Support
- Debian/Ubuntu (APT)
- Fedora/RHEL (DNF)
- CentOS/RHEL (YUM)
- Arch Linux (Pacman)

### Automatic Configuration
- Git interactive setup
- Shell configuration (.bashrc, .zshrc, .profile)
- Package manager detection
- PATH management

### Error Handling
- Color-coded status messages
- Automatic CRLF fixing
- Dependency checking
- PEP 668 compliance

### Self-Healing
- Detects and fixes Windows line endings
- Shell detection and configuration
- Package manager fallback strategies

## 🔄 Version History

### v2.0 (Current) - Modular Architecture
- Refactored from monolithic to modular (14 files)
- Added one-line installer
- Full Turkish language support
- Fixed interactive prompt in pipes
- CRLF auto-detection and fixing
- Comprehensive module structure

### v1.0 - Original Monolithic
- Single 2,331-line script
- Mixed language interface
- Manual installation only
- Available as `linux-ai-setup-script-legacy.sh`

## 👥 Contributors

- **Project Creator**: Alper Tunga
- **Developer**: Tamer KARACA (A.K.A THE KING)
- **Contributors**: FitzGPT, Tuğser OKUR
- **Version**: 2.0 (Modular)

## 📄 License

MIT License - See [LICENSE.md](LICENSE.md) for details

## 🐛 Troubleshooting

### Common Issues

1. **Permission Denied**: `chmod +x script.sh`
2. **CRLF Line Endings**: Use `scripts/fix-crlf.sh` or `sed -i 's/\r$//' script.sh`
3. **Missing Dependencies**: Script installs prerequisites automatically
4. **Shell Not Reloading**: Restart terminal or `source ~/.bashrc`

### Validation Commands

```bash
# Syntax check
bash -n src/linux-ai-setup-script.sh

# Module syntax check
for file in src/{lib,config,modules}/*.sh; do
    bash -n "$file"
done

# Shellcheck (if installed)
shellcheck src/linux-ai-setup-script.sh src/{lib,config,modules}/*.sh
```

## 🎓 Usage Examples

### Full Installation
```bash
# Option 1: One-liner installer
curl -fsSL https://raw.githubusercontent.com/altudev/1453-wsl-bash-script/master/install.sh | bash

# Option 2: Manual
git clone https://github.com/altudev/1453-wsl-bash-script.git
cd 1453-wsl-bash-script
./src/linux-ai-setup-script.sh

# Then select: 1 (Full Installation)
```

### Individual Component Installation
```bash
# Python ecosystem only
./src/linux-ai-setup-script.sh
# Select: 3, 4, 5, 6

# JavaScript ecosystem only
./src/linux-ai-setup-script.sh
# Select: 7, 8

# AI tools only
./src/linux-ai-setup-script.sh
# Select: 11, 12
```

### Multi-Selection Example
```bash
# Install Python + JavaScript at once
./src/linux-ai-setup-script.sh
# Enter: 3,7
```

## 🔗 Links

- **Repository**: https://github.com/altudev/1453-wsl-bash-script
- **Documentation**: See README.md for user guide
- **Development**: See CLAUDE.md for development guide
