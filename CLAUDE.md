# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WSL (Windows Subsystem for Linux) automated setup script designed for AI developers. The project has been refactored from a single monolithic script (2,331 lines) into a clean modular architecture for better maintainability. It provides a one-line installer for easy deployment and features a fully Turkish interface for Turkish developers.

**Version**: 2.2.0 (Production-Ready)
**Status**: All critical and high-priority bugs fixed ✅
**Security Level**: LOW risk (previously HIGH)

### Key Features
- **One-line installation** via curl/wget
- **Modular architecture** - 16 files instead of 1 monolithic script
- **Turkish language support** - All messages and prompts in Turkish
- **Interactive menus** - User-friendly interface with multi-choice support
- **Auto-detection** - Package manager and OS detection
- **PEP 668 compliance** - Handles Python's externally-managed environment
- **Security hardened** - No eval usage, SHA256 checksum verification
- **Centralized configuration** - Version and constants management

## Installation Methods

### Quick Installation (Recommended)
One-line installation that downloads all components and sets up everything:

```bash
# Using curl (process substitution - prevents stdin issues)
bash <(curl -fsSL https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)

# Or using wget
bash <(wget -qO- https://raw.githubusercontent.com/ravidulundu/1453-wsl-bash-script/master/install.sh)
```

**Important**: We use process substitution `bash <(curl ...)` instead of piping `curl | bash` to ensure interactive prompts work correctly by keeping stdin connected to the terminal.

This installer:
- Downloads all 16 modular components from GitHub
- Sets up directory structure in `~/.1453-wsl-setup/`
- Creates a launcher script for easy access
- Prompts to run setup immediately (Turkish: "e/E=Evet, Enter=Hayır")

After installation, run:
```bash
~/.1453-wsl-setup/1453-setup
```

### Manual Installation
Clone repository and run directly:
```bash
# Clone repository
git clone https://github.com/ravidulundu/1453-wsl-bash-script.git
cd 1453-wsl-bash-script

# Make executable and run
chmod +x src/linux-ai-setup-script.sh
./src/linux-ai-setup-script.sh
```

### Script Validation
```bash
# Check for syntax errors
bash -n src/linux-ai-setup-script.sh

# Run shellcheck for linting (if installed)
shellcheck src/linux-ai-setup-script.sh
```

## Architecture

### Version 2.2.0 - Secure Modular Architecture

The project has been refactored from a 2,331-line monolithic script into a clean, secure modular architecture with comprehensive security hardening:

#### Repository Structure
```
1453-wsl-bash-script/
├── install.sh                       # One-line installer (Turkish)
├── fix-crlf.sh                     # CRLF line ending fixer
├── README.md                       # Project documentation (Turkish)
├── CLAUDE.md                       # This file - development guide
│
└── src/
    ├── linux-ai-setup-script.sh        # Main entry point (52 lines)
    ├── linux-ai-setup-script-legacy.sh # Original monolithic script (backup)
    │
    ├── lib/                            # Core libraries
    │   ├── init.sh                    # CRLF detection and initialization
    │   ├── common.sh                  # Shared utilities (reload, mask_secret, checksum verification)
    │   └── package-manager.sh        # Package manager detection and secure system updates
    │
    ├── config/                         # Configuration files
    │   ├── colors.sh                  # Terminal color definitions
    │   ├── constants.sh               # Global constants (retry, timeout, disk space, history)
    │   ├── php-versions.sh            # PHP version and extension arrays
    │   ├── tool-versions.sh           # Tool versions and URLs (centralized version management)
    │   └── banner.sh                  # ASCII art and banner display (Turkish)
    │
    └── modules/                        # Feature modules
        ├── python.sh                  # Python ecosystem (Python, pip, pipx, UV)
        ├── javascript.sh              # JavaScript ecosystem (NVM, Bun.js)
        ├── php.sh                     # PHP ecosystem (PHP versions, Composer, Laravel)
        ├── go.sh                      # Go language installation
        ├── modern-tools.sh            # Modern CLI tools (bat, eza, starship, zoxide, fzf, lazygit, lazydocker)
        ├── shell-setup.sh             # Shell environment setup (aliases, functions, bashrc enhancements)
        ├── ai-cli.sh                  # AI CLI tools (Claude Code, Gemini, Qwen, etc.)
        ├── ai-frameworks.sh           # AI frameworks (SuperGemini, SuperQwen, SuperClaude)
        ├── quickstart.sh              # Quick Start mode for beginners
        └── menus.sh                   # Interactive menu system and main loop (Turkish)
```

#### After Installation (via installer)
```
~/.1453-wsl-setup/
├── 1453-setup                      # Launcher script
└── src/
    ├── linux-ai-setup-script.sh    # Main script
    ├── lib/                        # All library files
    ├── config/                     # All config files
    └── modules/                    # All module files
```

### Module Categories
1. **Core Libraries** (`lib/`) - System initialization, shared utilities, secure package management, checksum verification
2. **Configuration** (`config/`) - Colors, constants, PHP versions, tool versions, banner/branding
3. **Python Ecosystem** (`modules/python.sh`) - Python, pip, pipx, UV with PEP 668 compliance
4. **JavaScript Ecosystem** (`modules/javascript.sh`) - NVM and Bun.js installation
5. **PHP Ecosystem** (`modules/php.sh`) - Multiple PHP versions (7.4-8.5) with Laravel support
6. **Go Language** (`modules/go.sh`) - Go language installation and configuration
7. **Modern CLI Tools** (`modules/modern-tools.sh`) - Modern replacements for traditional tools (bat, eza, starship, zoxide, fzf, vivid, fastfetch, lazygit, lazydocker)
8. **Shell Environment** (`modules/shell-setup.sh`) - Custom aliases (62+), functions, bashrc enhancements, history settings, FZF configuration, Starship prompt
9. **AI CLI Tools** (`modules/ai-cli.sh`) - Claude Code, Gemini, Qwen, OpenCode, Copilot, GitHub CLI, Qoder CLI
10. **AI Frameworks** (`modules/ai-frameworks.sh`) - SuperGemini, SuperQwen, SuperClaude
11. **Quick Start Mode** (`modules/quickstart.sh`) - Simplified UX with presets for beginners
12. **Interactive Menus** (`modules/menus.sh`) - Menu-driven interface with multi-choice support

### Key Implementation Details

**Package Manager Detection**: The script automatically detects and supports:
- APT (Debian/Ubuntu)
- DNF (Fedora/RHEL 8+)
- YUM (RHEL/CentOS)
- Pacman (Arch Linux)

**Shell Configuration Management**: Automatically modifies and reloads:
- `.bashrc`
- `.zshrc`
- `.profile`

**Windows WSL Compatibility**: Handles CRLF line endings automatically at startup using `dos2unix`, `sed`, or `tr`.

**Error Handling**: Uses color-coded output (RED for errors, GREEN for success, YELLOW for warnings) with messages primarily in Turkish.

**Language Support**: The interface is fully in Turkish:
- All prompts and messages in Turkish
- Menu items in Turkish
- Error messages and success notifications in Turkish
- Installation prompts use "e/E=Evet, Enter=Hayır"

**Interactive Prompt Fix**: The installer handles stdin properly when piped through curl/wget using `/dev/tty` redirection for user input.

**Security Features (v2.2.0)**:
- **No eval Usage**: All command injection vulnerabilities eliminated (16 instances fixed)
- **SHA256 Checksum Verification**: Binary downloads verified for integrity (Vivid, Lazygit, Lazydocker)
- **Centralized Version Management**: Dynamic version fetching with offline fallbacks
- **Centralized Constants**: All magic numbers replaced with named constants
- **Safe Array-Based Execution**: Package installation uses safe array patterns instead of eval

## Important Functions

### Core Functions (lib/)
- `detect_package_manager()` - Detects system package manager (`lib/package-manager.sh`)
- `reload_shell_configs()` - Reloads shell configuration files (`lib/common.sh`)
- `update_system()` - Updates system packages with retry mechanism (`lib/package-manager.sh`)
- `mask_secret()` - Masks sensitive data for display (`lib/common.sh`)

### Security Functions (lib/common.sh) - NEW in v2.2.0
- `verify_checksum(file_path, checksum, [checksum_url])` - Verifies SHA256 checksum of downloaded files
  - Supports sha256sum and shasum
  - Case-insensitive comparison
  - Graceful fallback if tool missing
  - Detailed error messages
- `download_with_checksum(url, output, [checksum_url])` - Downloads file with automatic checksum verification
  - Downloads file with curl
  - Automatically fetches and verifies checksum
  - Handles checksums.txt format (multiple files)
  - Parses single .sha256 files
  - Cleans up on failure

### Version Management Functions (config/tool-versions.sh) - NEW in v2.2.0
- `fetch_github_version(repo, fallback)` - Fetches latest version from GitHub API with fallback
- `init_tool_versions()` - Initializes all tool versions (fetches from GitHub or uses fallbacks)

### Python Functions (modules/python.sh)
- `install_python()` - Installs Python with modern pip handling
- `install_pip()` - Installs/updates pip with PEP 668 compliance
- `install_pipx()` - Installs pipx for isolated Python applications
- `install_uv()` - Installs UV fast Python package manager

### JavaScript Functions (modules/javascript.sh)
- `install_nvm()` - Installs Node Version Manager
- `install_bun()` - Installs Bun.js runtime

### PHP Functions (modules/php.sh)
- `ensure_php_repository()` - Configures PHP repositories
- `install_php_version()` - Installs specific PHP version with extensions
- `install_composer()` - Installs Composer package manager
- `install_php_version_menu()` - Interactive PHP version selection

### AI CLI Functions (modules/ai-cli.sh)
- `install_claude_code()` - Installs Claude Code CLI
- `install_gemini_cli()` - Installs Gemini CLI
- `install_github_cli()` - Installs GitHub CLI
- `install_ai_cli_tools_menu()` - Interactive AI tools menu

### Go Functions (modules/go.sh)
- `install_go()` - Installs Go language and configures environment
- `install_go_menu()` - Interactive Go installation menu

### Modern CLI Tools Functions (modules/modern-tools.sh)
- `install_modern_cli_tools()` - Installs all modern CLI tools
- `fix_bat_fd_symlinks()` - Creates bat/fd symlinks for batcat/fdfind (Ubuntu compatibility)
- `install_modern_tools_apt()` - APT-specific installation with bat/fd symlink fix
- `install_modern_tools_dnf()` - DNF/YUM-specific installation with bat/fd symlink fix
- `install_modern_tools_pacman()` - Pacman-specific installation
- Tools installed: bat, ripgrep, fd-find, eza, starship, zoxide, fzf, vivid, fastfetch, lazygit, lazydocker
- **Important**: Ubuntu installs `batcat` and `fdfind`, symlinks to `bat` and `fd` are auto-created in `~/.local/bin`

### Shell Environment Functions (modules/shell-setup.sh)
- `setup_custom_shell()` - Main shell configuration function
- `setup_bash_aliases()` - Creates ~/.bash_aliases with 62+ custom aliases
- `setup_custom_functions()` - Adds custom bash functions (mcd, make)
- `setup_bashrc_enhancements()` - Enhances .bashrc with history, FZF, modern tools integration
- `setup_starship_config()` - Creates Starship prompt configuration

### AI CLI Functions (modules/ai-cli.sh)
- `install_claude_code()` - Installs Claude Code CLI
- `install_gemini_cli()` - Installs Gemini CLI
- `install_github_cli()` - Installs GitHub CLI
- `install_ai_cli_tools_menu()` - Interactive AI tools menu

### AI Framework Functions (modules/ai-frameworks.sh)
- `install_supergemini()` - Installs SuperGemini framework
- `install_superqwen()` - Installs SuperQwen framework
- `install_superclaude()` - Installs SuperClaude framework
- `install_ai_frameworks_menu()` - Interactive frameworks menu

### Quick Start Functions (modules/quickstart.sh)
- `run_quickstart_mode()` - Main Quick Start flow
- `show_presets()` - Display installation presets
- `generate_installation_plan()` - Build tool list based on preset
- `execute_installation_plan()` - Install tools automatically (non-interactive)
  - **PHP**: Installs PHP 8.3 automatically (stable version)
  - **AI CLI**: Installs Claude Code + GitHub CLI automatically
  - **AI Frameworks**: Installs SuperClaude automatically

### Menu System (modules/menus.sh)
- `configure_git()` - Interactive Git configuration
- `show_menu()` - Main interactive menu display
- `show_mode_selection()` - Quick Start vs Advanced mode selection
- `run_advanced_mode()` - Advanced mode menu loop
- `main()` - Main program entry point

### Cleanup Functions (modules/cleanup.sh)
- `cleanup_system_packages()` - Removes system packages installed by update_system()
  - Removes: jq, zip, unzip, p7zip-full, build-essential (APT)
  - Removes: Development Tools group (DNF/YUM), base-devel (Pacman)
  - Preserves: curl, wget, git (critical system dependencies)
- `cleanup_python()` - Removes Python ecosystem
  - Removes: pipx, UV, pip cache
  - Removes: python3-pip, python3-venv (APT packages)
  - Preserves: python3 (may be system critical)
- `cleanup_nodejs()` - Removes Node.js and NVM
  - Removes: ~/.nvm directory, Bun.js, shell configuration
- `cleanup_php()` - Removes PHP ecosystem
  - Removes: All PHP versions (php7.4, php8.0, php8.1, php8.2, php8.3, etc.)
  - Removes: Composer, ~/.composer
  - Removes: Ondřej Surý PPA repository
- `cleanup_go()` - Removes Go installation
  - Removes: /usr/local/go, GOPATH/GOROOT from shell configs
- `cleanup_modern_tools()` - Removes modern CLI tools
  - APT packages: bat, ripgrep, fd-find, fzf
  - Manual installs: starship, zoxide, eza, vivid, fastfetch, lazygit, lazydocker
  - Symlinks: ~/.local/bin/bat, ~/.local/bin/fd
- `cleanup_ai_tools()` - Removes AI CLI tools
  - Pipx tools: claude, qoder, gemini-cli, opencode, qwen
  - GitHub Copilot CLI (via npm)
  - GitHub CLI (via APT + repository cleanup)
- `cleanup_ai_frameworks()` - Removes AI frameworks (SuperGemini, SuperQwen, SuperClaude)
- `cleanup_shell_configs()` - Removes shell configuration changes
  - Removes: ~/.bash_aliases, starship config, FZF
  - Cleans: .bashrc of all script modifications
- `cleanup_installations()` - Removes all installations (keeps configs)
- `cleanup_full_reset()` - Complete rollback to pre-installation state
  - Removes EVERYTHING: all packages, tools, configs, installation directory
  - Goal: Return WSL to fresh installation state
- `show_cleanup_menu()` - Interactive cleanup menu
- `show_individual_cleanup_menu()` - Individual component cleanup

**Important**: The cleanup script now provides complete rollback functionality. When users select "Full Reset", the script removes EVERYTHING it installed, including APT packages, repositories, manual installations, and configuration changes.

## Development Notes

### Working with the Modular Architecture
When modifying the script:
1. **Identify the correct module** - Determine which module your changes belong to
2. **Maintain module boundaries** - Keep functions in their appropriate modules
3. **Use shared utilities** - Leverage functions in `lib/common.sh` for common tasks
4. **Follow the loading order** - Ensure dependencies are loaded before dependent modules
5. **Test module independently** - Source and test individual modules when possible

### Module Loading Order
The main script loads modules in this specific order:
1. `lib/init.sh` - CRLF detection (must be first)
2. Configuration files (`config/*.sh`)
3. Core libraries (`lib/*.sh`)
4. Feature modules (`modules/*.sh`)
5. Menu system last (depends on all other modules)

### Adding New Tools
To add a new installation function:
1. **Choose the appropriate module** - Add to existing module or create new one
2. **Create function** following naming pattern `install_<tool_name>()`
3. **Check if tool exists** before installation using `command -v`
4. **Add PATH modifications** to appropriate shell RC files
5. **Call `reload_shell_configs()`** after installation
6. **Update menu** - Add entry in `modules/menus.sh` if needed
7. **Export function** - Add `export -f function_name` at module end

### PHP Version Management
The script uses `update-alternatives` for PHP version switching. When adding new PHP versions:
1. Add version to `PHP_SUPPORTED_VERSIONS` array
2. Ensure all extensions in `PHP_EXTENSION_PACKAGES` are installed
3. Configure alternatives in `install_php_version()`

### MCP Server Integration
MCP (Model Context Protocol) servers are managed through:
- `cleanup_magic_mcp()` - SuperGemini servers
- `cleanup_qwen_mcp()` - SuperQwen servers
- `cleanup_claude_mcp()` - SuperClaude servers

## Testing Approach

### Automated Validation Script

**NEW:** A comprehensive validation script (`test-setup.sh`) is now available to verify installations:

```bash
# Run validation test
./test-setup.sh

# Verbose output
./test-setup.sh --verbose

# JSON report
./test-setup.sh --json > report.json

# Save to log file
./test-setup.sh --log results.log

# Snapshot/X-ray mode
./test-setup.sh --snapshot
```

The validation script checks:
1. **System Information** - OS, kernel, WSL, package manager
2. **Basic Tools** - git, curl, wget, jq, build essentials
3. **Python Ecosystem** - Python, pip, pipx, UV
4. **JavaScript Ecosystem** - NVM, Node.js, npm, Bun.js
5. **PHP Ecosystem** - PHP versions, Composer, extensions
6. **Go Language** - Go, GOPATH, GOROOT
7. **Modern CLI Tools** - bat, eza, starship, zoxide, fzf, lazygit, lazydocker
8. **Shell Environment** - aliases, functions, bashrc enhancements
9. **AI CLI Tools** - Claude Code, Gemini CLI, GitHub CLI
10. **AI Frameworks** - SuperGemini, SuperQwen, SuperClaude
11. **Docker** - Docker Engine, lazydocker
12. **Installation Directory** - ~/.1453-wsl-setup structure

Output includes:
- Total tests, passed, failed, warnings
- Category-based statistics
- Detailed failure and warning lists
- Success rate percentage
- Duration

### Syntax Validation
```bash
# Test main script syntax
bash -n src/linux-ai-setup-script.sh

# Test validation script
bash -n test-setup.sh

# Test all modules at once
for file in src/{lib,config,modules}/*.sh; do
    echo "Checking: $file"
    bash -n "$file"
done

# Run shellcheck for linting (if installed)
shellcheck src/linux-ai-setup-script.sh src/{lib,config,modules}/*.sh test-setup.sh
```

### Module Testing
```bash
# Test individual module by sourcing dependencies
source src/config/colors.sh
source src/lib/common.sh
source src/lib/package-manager.sh
source src/modules/python.sh

# Test specific function
install_python
```

### Integration Testing
```bash
# Test in Docker container (recommended)
docker run -it ubuntu:latest /bin/bash
# Copy entire src/ directory and test

# Run the modular script
./src/linux-ai-setup-script.sh

# Compare with legacy script behavior
./src/linux-ai-setup-script-legacy.sh
```

## Common Issues and Solutions

1. **CRLF Line Endings**: Script auto-fixes on first run
2. **Permission Denied**: Run `chmod +x` on the script (installer handles this automatically)
3. **PEP 668 Errors**: Script handles externally-managed-environment automatically
4. **Missing Dependencies**: Script installs prerequisites automatically
5. **Shell Not Reloading**: Script calls `reload_shell_configs()` automatically
6. **Interactive Prompt in Pipe**: Fixed with `/dev/tty` redirection in installer
7. **bat/fd commands not found**: Ubuntu installs as `batcat`/`fdfind` - script auto-creates symlinks in `~/.local/bin`
   - Symlinks: `bat` → `batcat`, `fd` → `fdfind`
   - `~/.local/bin` automatically added to PATH
   - Run `source ~/.bashrc` or restart terminal to apply

## Version History

### v2.2.0 (Current) - Security Hardened Production Release
**Release Date**: 2025-11-15
**Status**: Production-Ready ✅

#### Security Fixes
- ✅ **PHASE 1 (CRITICAL)**: Eliminated all eval command injection vulnerabilities
  - 16 eval instances in active modules → safe array-based execution
  - Files: python.sh, php.sh, ai-cli.sh, go.sh, package-manager.sh
  - Pattern: `eval "$INSTALL_CMD"` → safe array execution

- ✅ **PHASE 2a (HIGH)**: Centralized version management
  - Created `config/tool-versions.sh` (113 lines)
  - Dynamic GitHub API version fetching
  - Offline fallback support
  - Tools: NVM, Vivid, Lazygit, Lazydocker

- ✅ **PHASE 2b (HIGH)**: SHA256 checksum verification
  - Added `verify_checksum()` and `download_with_checksum()` functions
  - Binary integrity verification for Vivid, Lazygit, Lazydocker
  - Supply chain security implemented

- ✅ **PHASE 3a (MEDIUM)**: Centralized constants
  - Created `config/constants.sh` (106 lines)
  - 18+ magic numbers → named constants
  - Categories: retry, timeout, disk space, history

#### Statistics
- 🔴 CRITICAL bugs: 29 → 0 (100% FIXED)
- 🟡 HIGH bugs: 3 → 0 (100% FIXED)
- 🟢 MEDIUM bugs: 2 → 1 (50% FIXED)
- Security Risk: HIGH → LOW ✅
- Compliance: Production-ready ✅

#### Commits
- `c03ad1a` - Docs: Katkıda bulunanlar listesine Ravi DULUNDU eklendi
- `c5d4774` - Docs: Update README.md to v2.2.0
- `dfa4782` - Docs: Update BUG-REPORT.md - All Critical/High Priority Bugs FIXED
- `e95d081` - Code Quality: PHASE 3a Complete - Centralize constants
- `7b2092e` - Security: PHASE 2b Complete - Add checksum verification
- `8bdf895` - Config: PHASE 2a Complete - Centralize tool versions
- `b4fb8f4` - Security: PHASE 1 Complete - Remove eval injection

### v2.0 - Modular Architecture
- Refactored from monolithic (2,331 lines) to modular (14 files)
- Added one-line installer (`install.sh`)
- Full Turkish language support
- Fixed interactive prompt issue when piped
- Fixed GitHub URL references
- Created comprehensive module structure
- Added launcher script for easy access
- Maintained 100% backward compatibility

### v1.0 - Original Monolithic Version
- Single file implementation
- Mixed Turkish/English messages
- Manual installation required
- Available as `linux-ai-setup-script-legacy.sh`

## Project Information

- **Repository**: https://github.com/ravidulundu/1453-wsl-bash-script
- **Language**: Bash with Turkish interface
- **Target Platform**: WSL (Windows Subsystem for Linux)
- **Target Audience**: Turkish AI developers and "Vibe Coders"
- **Installation Directory**: `~/.1453-wsl-setup/` (via installer)

## What Gets Installed

### Development Tools
- Git configuration (interactive setup)
- curl, wget, jq, zip, unzip, 7zip
- Build essentials (gcc, make, etc.)

### Python Ecosystem
- Python 3.x
- pip (with PEP 668 compliance)
- pipx (isolated Python applications)
- UV (ultra-fast Python package manager)

### JavaScript Ecosystem
- NVM (Node Version Manager)
- Node.js LTS
- npm
- Bun.js

### PHP Ecosystem
- Multiple PHP versions (7.4, 8.1, 8.2, 8.3, 8.4, 8.5)
- Composer
- Laravel-ready PHP extensions

### AI CLI Tools
- Claude Code CLI
- Qoder CLI
- Gemini CLI (Google AI SDK)
- Qwen CLI
- OpenCode CLI
- GitHub Copilot CLI
- GitHub CLI

### AI Frameworks
- SuperGemini Framework
- SuperQwen Framework
- SuperClaude Framework
- MCP server support for all frameworks
