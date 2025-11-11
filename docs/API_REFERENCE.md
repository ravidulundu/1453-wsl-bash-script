# API Reference: 1453 WSL Bash Script

## 📚 Table of Contents

1. [Core Library Functions](#core-library-functions)
2. [Python Module Functions](#python-module-functions)
3. [JavaScript Module Functions](#javascript-module-functions)
4. [PHP Module Functions](#php-module-functions)
5. [AI CLI Module Functions](#ai-cli-module-functions)
6. [AI Frameworks Module Functions](#ai-frameworks-module-functions)
7. [Go Module Functions](#go-module-functions)
8. [Menu Module Functions](#menu-module-functions)
9. [Configuration Functions](#configuration-functions)

---

## Core Library Functions

### `detect_package_manager()`
**File**: `src/lib/package-manager.sh:6`

**Purpose**: Auto-detects the system package manager and sets global variables.

**Variables Set**:
- `PKG_MANAGER`: Package manager name ("apt", "dnf", "yum", or "pacman")
- `UPDATE_CMD`: Full update command with sudo
- `INSTALL_CMD`: Full install command with sudo

**Supported Package Managers**:
- APT (Debian/Ubuntu)
- DNF (Fedora/RHEL 8+)
- YUM (RHEL/CentOS 7)
- Pacman (Arch Linux)

**Returns**: Exit code 0 on success, 1 if no supported package manager found

**Usage Example**:
```bash
detect_package_manager
echo "Using package manager: $PKG_MANAGER"
echo "Install command: $INSTALL_CMD"
```

**Notes**:
- Must be called before any package installation
- Exported variables are available to all modules

---

### `update_system()`
**File**: `src/lib/package-manager.sh:39`

**Purpose**: Updates system packages and installs essential development tools.

**Actions Performed**:
1. Runs system package update
2. Installs essential tools: curl, wget, git, jq, zip, unzip, p7zip
3. Installs build tools: build-essential (APT) or Development Tools (DNF/YUM/Pacman)

**Dependencies**:
- `detect_package_manager()` must be called first

**Returns**: Exit code 0 on success

**Usage Example**:
```bash
update_system
```

**Packages Installed**:
- **Universal**: curl, wget, git, jq, zip, unzip, p7zip
- **APT**: build-essential
- **DNF/YUM**: Development Tools group
- **Pacman**: base-devel

---

### `reload_shell_configs([mode])`
**File**: `src/lib/common.sh:8`

**Purpose**: Reloads shell configuration files to apply PATH changes.

**Parameters**:
- `mode` (optional): "verbose" (default) or "silent"
  - "verbose": Shows confirmation message
  - "silent": No output

**Returns**: Exit code 0 on success

**Usage Example**:
```bash
# With verbose output
reload_shell_configs

# Silent mode
reload_shell_configs silent
```

**Shell Files Updated**:
- For bash: `.bashrc`, `.profile`, `.zshrc`
- For zsh: `.zshrc`, `.bashrc`, `.profile`
- For other shells: `.bashrc`, `.zshrc`, `.profile`

**Notes**:
- Automatically detects current shell
- Sources the most appropriate RC file found
- Used after installing tools that modify PATH

---

### `mask_secret(secret_string)`
**File**: `src/lib/common.sh:48`

**Purpose**: Masks sensitive data for secure display (shows first 4 and last 4 characters).

**Parameters**:
- `secret_string`: The sensitive string to mask

**Returns**: Masked string on stdout

**Usage Example**:
```bash
api_key="12345678901234567890"
masked=$(mask_secret "$api_key")
echo "API Key: $masked"  # Output: 1234*********7890
```

**Behavior**:
- Strings ≤8 characters: Displayed as-is
- Strings >8 characters: First 4 + asterisks + last 4

**Notes**:
- Useful for displaying API keys, passwords, tokens
- Does not modify the original string

---

## Python Module Functions

### `install_python()`
**File**: `src/modules/python.sh:7`

**Purpose**: Installs Python 3, pip, and venv module.

**Actions**:
1. Checks if Python 3 is already installed
2. Installs python3, python3-pip, python3-venv via system package manager
3. Verifies installation

**Returns**: Exit code 0 if installed or already present, 1 on failure

**Usage Example**:
```bash
install_python
python3 --version
```

**Packages Installed**:
- python3
- python3-pip
- python3-venv

**Notes**:
- Returns success if Python is already installed
- Uses system package manager (APT/DNF/YUM/Pacman)

---

### `install_pip()`
**File**: `src/modules/python.sh:29`

**Purpose**: Updates pip to the latest version with PEP 668 compliance.

**Actions**:
1. Ensures Python 3 is installed
2. Upgrades pip
3. Handles "externally-managed-environment" errors
4. Shows usage tips

**PEP 668 Handling**:
```bash
# If externally-managed-environment error occurs:
python3 -m pip install --upgrade pip --break-system-packages
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_pip
pip --version
```

**Notes**:
- Checks for PEP 668 error and handles it automatically
- Provides usage instructions and best practices

---

### `install_pipx()`
**File**: `src/modules/python.sh:63`

**Purpose**: Installs pipx for isolated Python application installations.

**Installation Methods** (in order):
1. System package manager
2. Manual installation with temporary venv
3. User installation with --break-system-packages

**Actions**:
1. Checks for Python 3
2. Attempts system package installation
3. Falls back to manual installation if needed
4. Ensures PATH is configured
5. Updates shell RC files
6. Runs `pipx ensurepath`

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_pipx
pipx --version
pipx install <package>
```

**PATH Additions**:
- Adds `$HOME/.local/bin` to PATH
- Updates .bashrc, .zshrc, .profile

**Notes**:
- Handles multiple installation fallbacks
- Manages PATH automatically
- Essential for AI framework installations

---

### `install_uv()`
**File**: `src/modules/python.sh:155`

**Purpose**: Installs UV (Ultra-fast Python package installer) from Astral.

**Installation Source**:
- Official installer: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Actions**:
1. Downloads and installs UV
2. Adds Cargo bin to PATH
3. Updates shell RC files
4. Sources cargo environment

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_uv
uv --version
uv pip install <package>
uv venv
```

**PATH Additions**:
- Adds `$HOME/.cargo/bin` to PATH
- Updates .bashrc, .zshrc, .profile

**Notes**:
- UV is an extremely fast Python package manager
- Alternative to pip with better performance

---

## JavaScript Module Functions

### `install_nvm()`
**File**: `src/modules/javascript.sh:7`

**Purpose**: Installs Node Version Manager (NVM) and Node.js LTS.

**Actions**:
1. Downloads NVM v0.40.3
2. Installs to `$HOME/.nvm` or `$XDG_CONFIG_HOME/nvm`
3. Updates shell RC files with NVM configuration
4. Installs Node.js LTS version
5. Sets LTS as active version

**NVM Configuration Added**:
```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

**Returns**: Exit code 0 on success (output shows Node.js and npm versions)

**Usage Example**:
```bash
install_nvm
node -v
npm -v
nvm list
```

**Notes**:
- Requires curl
- Updates .bashrc, .zshrc, .profile
- Loads NVM configuration in current session

---

### `install_bun()`
**File**: `src/modules/javascript.sh:43`

**Purpose**: Installs Bun.js (fast JavaScript runtime).

**Installation Source**:
- Official installer: `curl -fsSL https://bun.sh/install | bash`

**Actions**:
1. Downloads Bun installer
2. Installs to `$HOME/.bun`
3. Updates shell RC files
4. Reloads configurations
5. Verifies installation

**Environment Variables Set**:
```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_bun
bun --version
bun init
bun add <package>
```

**Notes**:
- Alternative to Node.js/npm
- Much faster package installation
- Supports TypeScript out of the box

---

## PHP Module Functions

### `ensure_php_repository()`
**File**: `src/modules/php.sh:7`

**Purpose**: Configures PHP package repositories for different distributions.

**Repository Configuration**:
- **APT (Debian/Ubuntu)**: Ondřej Surý PPA
- **DNF/YUM (Fedora/RHEL)**: Remi repository
- **Pacman (Arch)**: Manual configuration required

**Actions**:
1. Detects package manager
2. Checks if repository is already configured
3. Adds repository if missing
4. Updates package cache (APT)

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
ensure_php_repository
```

**Notes**:
- Must be called before PHP installation
- Prevents duplicate repository additions
- Essential for accessing multiple PHP versions

---

### `install_composer()`
**File**: `src/modules/php.sh:52`

**Purpose**: Installs Composer PHP package manager with signature verification.

**Security Features**:
1. Downloads installer signature from https://composer.github.io/installer.sig
2. Downloads installer from https://getcomposer.org/installer
3. Verifies SHA384 signature
4. Installs to /usr/local/bin/composer

**Actions**:
1. Checks for existing Composer installation
2. Ensures PHP is installed
3. Downloads installer with signature
4. Verifies signature (fails if mismatch)
5. Installs globally

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_composer
composer --version
composer require <package>
```

**Installation Path**: `/usr/local/bin/composer`

**Notes**:
- Signature verification prevents tampering
- Requires PHP to be installed first
- Installs globally for all users

---

### `install_php_version(version)`
**File**: `src/modules/php.sh:120`

**Purpose**: Installs specific PHP version with Laravel-ready extensions.

**Parameters**:
- `version`: PHP version to install (e.g., "8.2", "8.3")

**Supported Versions**:
- 7.4, 8.1, 8.2, 8.3, 8.4, 8.5

**Extensions Installed**:
- curl, zip, xml, mbstring, tokenizer, openssl, gd, soap, intl, bcmath
- pdo_mysql, pdo_pgsql, pdo_sqlite, fpm

**Package Manager Differences**:
- **APT**: `php8.2`, `php8.2-cli`, `php8.2-curl`, etc.
- **DNF/YUM**: `php82-php`, `php82-php-cli`, `php82-php-curl`, etc.
- **Pacman**: Manual configuration required

**Returns**: Exit code 0 on success

**Usage Example**:
```bash
install_php_version "8.3"
php -v
php -m  # List modules
```

**Notes**:
- Calls `ensure_php_repository()` first
- Handles package naming differences
- Skips redundant extensions (tokenizer, fpm)

---

### `install_php_version_menu()`
**File**: `src/modules/php.sh:210`

**Purpose**: Interactive menu for selecting and installing PHP versions.

**Actions**:
1. Displays numbered list of supported PHP versions
2. Accepts user selection
3. Installs selected version(s)
4. Supports "Install all" option

**Menu Options**:
1. PHP 7.4
2. PHP 8.1
3. PHP 8.2
4. PHP 8.3
5. PHP 8.4
6. PHP 8.5
7. Install all versions
8. Return to main menu

**Returns**: None (interactive function)

**Usage Example**:
```bash
install_php_version_menu
# User selects: 3 (PHP 8.2)
```

**Notes**:
- User-interactive function
- Calls `install_php_version()` internally
- Validates user input

---

## AI CLI Module Functions

### `install_claude_code()`
**File**: `src/modules/ai-cli.sh:7`

**Purpose**: Installs Claude Code CLI from Anthropic.

**Installation**:
- Downloads from: https://github.com/anthropics/claude-code/releases/latest/download/installer.sh
- Runs official installer script

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_claude_code
claude-code --version
```

**Notes**:
- Requires curl
- Reloads shell configs after installation
- Official Anthropic installer

---

### `install_gemini_cli()`
**File**: `src/modules/ai-cli.sh:26`

**Purpose**: Installs Google Gemini CLI via Python package.

**Dependencies**:
- Python 3 (installs if missing via `install_python()`)

**Installation**:
```bash
python3 -m pip install google-generativeai [--break-system-packages]
```

**Returns**: Exit code 0 on success

**Usage Example**:
```bash
install_gemini_cli
# Note: Actual Gemini CLI usage requires Google AI setup
```

**Notes**:
- Installs Python if not present
- Uses pip with PEP 668 handling

---

### `install_opencode_cli()`
**File**: `src/modules/ai-cli.sh:44`

**Purpose**: Installs OpenCode CLI via npm.

**Dependencies**:
- npm/Node.js (installs NVM if missing)

**Installation**:
```bash
npm install -g opencode-cli
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_opencode_cli
opencode --help
```

**Notes**:
- Installs NVM if npm not found
- Reloads shell configs

---

### `install_qwen_cli()`
**File**: `src/modules/ai-cli.sh:68`

**Purpose**: Installs Qwen CLI via pipx.

**Dependencies**:
- pipx (installs if missing via `install_pipx()`)

**Installation**:
```bash
pipx install qwen-cli
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_qwen_cli
qwen --help
```

**Notes**:
- Ensures pipx is installed first
- Isolated installation via pipx

---

### `install_copilot_cli()`
**File**: `src/modules/ai-cli.sh:92`

**Purpose**: Installs GitHub Copilot CLI via npm.

**Dependencies**:
- npm/Node.js (installs NVM if missing)

**Installation**:
```bash
npm install -g @githubnext/github-copilot-cli
```

**Returns**: Exit code 0

**Usage Example**:
```bash
install_copilot_cli
github-copilot-cli auth login
```

**Post-Installation**:
- Prompts user to authenticate with GitHub
- Command: `github-copilot-cli auth`

**Notes**:
- Installs NVM if npm not found
- Requires GitHub account for authentication

---

### `install_github_cli()`
**File**: `src/modules/ai-cli.sh:113`

**Purpose**: Installs GitHub CLI (gh) via distribution-specific methods.

**Installation Methods**:
- **APT**: Adds GitHub GPG key and repository
- **DNF/YUM**: Adds GitHub repository
- **Pacman**: Installs from community repository

**Actions**:
1. Adds GitHub GPG key (APT)
2. Adds GitHub repository to sources
3. Updates package cache
4. Installs gh package

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_github_cli
gh --version
gh auth login
```

**Notes**:
- Method varies by distribution
- Requires authentication: `gh auth login`

---

### `install_ai_cli_tools_menu()`
**File**: `src/modules/ai-cli.sh:144`

**Purpose**: Interactive menu for installing AI CLI tools.

**Menu Options**:
1. Claude Code CLI
2. Gemini CLI
3. OpenCode CLI
4. Qwen CLI
5. GitHub Copilot CLI
6. GitHub CLI
7. Qoder CLI
8. Install all
9. Return to main menu

**Returns**: None (interactive function)

**Usage Example**:
```bash
install_ai_cli_tools_menu
# User selects: 8 (Install all)
```

**Notes**:
- Calls individual install functions
- Supports bulk installation
- User-interactive

---

### `install_qoder_cli()`
**File**: `src/modules/ai-cli.sh:184`

**Purpose**: Installs Qoder CLI.

**Installation**:
- Downloads from: https://qoder.com/install
- Runs official installer script

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_qoder_cli
qoder --version
```

**Notes**:
- Requires curl
- Reloads shell configs after installation
- AI-powered development assistant

---

## AI Frameworks Module Functions

### `install_supergemini()`
**File**: `src/modules/ai-frameworks.sh:7`

**Purpose**: Installs SuperGemini framework via pipx.

**Dependencies**:
- pipx (installs if missing via `install_pipx()`)

**Actions**:
1. Checks for existing installation
2. Uninstalls if present (for clean reinstall)
3. Installs via pipx
4. Reloads shell configurations

**Installation**:
```bash
pipx install supergemini
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_supergemini
supergemini --model gemini-pro
```

**Notes**:
- Provides upgrade if already installed
- Shows usage tips after installation

---

### `install_superqwen()`
**File**: `src/modules/ai-frameworks.sh:41`

**Purpose**: Installs SuperQwen framework via pipx.

**Dependencies**:
- pipx (installs if missing via `install_pipx()`)

**Actions**:
1. Checks for existing installation
2. Uninstalls if present
3. Installs via pipx
4. Reloads shell configurations

**Installation**:
```bash
pipx install superqwen
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_superqwen
superqwen --model qwen-turbo
export QWEN_API_KEY='your-api-key'
```

**Notes**:
- Requires API key setup
- Shows configuration tips

---

### `install_superclaude()`
**File**: `src/modules/ai-frameworks.sh:75`

**Purpose**: Installs SuperClaude framework via pipx.

**Dependencies**:
- pipx (installs if missing via `install_pipx()`)

**Actions**:
1. Checks for existing installation
2. Uninstalls if present
3. Installs via pipx
4. Reloads shell configurations

**Installation**:
```bash
pipx install superclaude
```

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_superclaude
superclaude --model claude-3
export ANTHROPIC_API_KEY='your-api-key'
```

**Notes**:
- Requires API key setup
- Shows configuration tips

---

### `remove_supergemini()`
**File**: `src/modules/ai-frameworks.sh:109`

**Purpose**: Uninstalls SuperGemini framework.

**Actions**:
1. Checks if installed via pipx list
2. Uninstalls using pipx

**Returns**: Exit code 0 (no error if not installed)

**Usage Example**:
```bash
remove_supergemini
```

**Notes**:
- Safe to call even if not installed
- Uses pipx uninstall

---

### `install_ai_frameworks_menu()`
**File**: `src/modules/ai-frameworks.sh:151`

**Purpose**: Interactive menu for installing AI frameworks.

**Menu Options**:
1. SuperGemini
2. SuperQwen
3. SuperClaude
4. Install all
5. Return to main menu

**Returns**: None (interactive function)

**Usage Example**:
```bash
install_ai_frameworks_menu
# User selects: 4 (Install all)
```

**Notes**:
- Installs all three frameworks
- User-interactive

---

### `remove_ai_frameworks_menu()`
**File**: `src/modules/ai-frameworks.sh:179`

**Purpose**: Interactive menu for removing AI frameworks.

**Menu Options**:
1. Remove SuperGemini
2. Remove SuperQwen
3. Remove SuperClaude
4. Remove all
5. Return to main menu

**Returns**: None (interactive function)

**Usage Example**:
```bash
remove_ai_frameworks_menu
# User selects: 4 (Remove all)
```

**Notes**:
- Removes all three frameworks
- User-interactive

---

## Go Module Functions

### `is_go_installed()`
**File**: `src/modules/go.sh:7`

**Purpose**: Checks if Go is already installed and available.

**Returns**: Exit code 0 if installed, 1 if not installed

**Usage Example**:
```bash
if is_go_installed; then
    echo "Go is installed: $(go version)"
else
    echo "Go is not installed"
fi
```

**Notes**:
- Simple command availability check
- Used by installation functions

---

### `configure_go_env()`
**File**: `src/modules/go.sh:11`

**Purpose**: Configures Go environment variables and PATH.

**Actions**:
1. Adds `/usr/local/go/bin` to PATH
2. Sets `GOPATH=$HOME/go`
3. Adds `$GOPATH/bin` to PATH
4. Updates shell RC files (.bashrc, .zshrc, .profile)

**Returns**: Exit code 0 on success

**Usage Example**:
```bash
configure_go_env
```

**PATH Additions**:
- `export PATH=$PATH:/usr/local/go/bin`
- `export GOPATH=$HOME/go`
- `export PATH=$PATH:$GOPATH/bin`

**Notes**:
- Prevents duplicate PATH entries
- Updates all common shell configuration files

---

### `install_go_official()`
**File**: `src/modules/go.sh:45`

**Purpose**: Installs Go using official binary from go.dev.

**Actions**:
1. Detects system architecture (amd64, arm64)
2. Gets latest Go version from go.dev
3. Downloads official binary tarball
4. Removes old installation (if exists)
5. Extracts to `/usr/local/go`
6. Configures environment
7. Verifies installation

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_go_official
go version
```

**Installation Path**: `/usr/local/go`

**Download URL**: `https://go.dev/dl/go<version>.linux-<arch>.tar.gz`

**Notes**:
- Downloads latest stable version
- Requires curl and sudo privileges
- Handles architecture detection automatically

---

### `install_go_package()`
**File**: `src/modules/go.sh:108`

**Purpose**: Installs Go using system package manager.

**Package Manager Support**:
- **APT**: `golang-go`
- **DNF**: `golang`
- **YUM**: `golang`
- **Pacman**: `go`

**Actions**:
1. Checks if Go is already installed
2. Uses appropriate package manager command
3. Configures environment
4. Verifies installation

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_go_package
```

**Notes**:
- Faster than official binary method
- May not install latest version
- Uses system package manager

---

### `install_go()`
**File**: `src/modules/go.sh:168`

**Purpose**: Main Go installation function with intelligent fallback.

**Actions**:
1. Checks if Go is already installed
2. Tries package manager installation first (faster)
3. Falls back to official binary if package manager fails
4. Provides feedback on installation method used

**Returns**: Exit code 0 on success, 1 on failure

**Usage Example**:
```bash
install_go
```

**Installation Strategy**:
1. Primary: Package manager (fast, may not be latest)
2. Fallback: Official binary (latest version)

**Notes**:
- Intelligent selection of installation method
- Recommended for most users
- Shows which method was used

---

### `install_go_menu()`
**File**: `src/modules/go.sh:191`

**Purpose**: Interactive menu for Go installation method selection.

**Menu Options**:
1. Otomatik Kurulum (Önerilen) - Uses `install_go()`
2. Resmi Binary Kurulumu - Uses `install_go_official()`
3. Paket Yöneticisi Kurulumu - Uses `install_go_package()`
4. Ana menüye dön - Returns to main menu

**Returns**: None (interactive function)

**Usage Example**:
```bash
install_go_menu
# User selects: 1 (Automatic installation)
```

**Notes**:
- User-interactive function
- Allows method selection
- Validates user input

---

### `remove_go()`
**File**: `src/modules/go.sh:217`

**Purpose**: Uninstalls Go completely from the system.

**Actions**:
1. Removes Go binary directory (`/usr/local/go`)
2. Removes Go configuration from shell RC files
3. Reloads shell configurations
4. Provides removal confirmation

**Returns**: Exit code 0 (no error if not installed)

**Usage Example**:
```bash
remove_go
```

**Notes**:
- Safe to call even if Go is not installed
- Cleans up PATH and GOPATH configurations
- Removes from all shell RC files

---

### `show_go_info()`
**File**: `src/modules/go.sh:251`

**Purpose**: Displays current Go installation information.

**Information Displayed**:
- Installed version (`go version`)
- Go root directory (`go env GOROOT`)
- GOPATH location (`go env GOPATH`)
- Go binary PATH

**Returns**: None (displays information)

**Usage Example**:
```bash
show_go_info
```

**Output Example**:
```
Kurulu Sürüm: go version go1.21.0 linux/amd64
Go Dizini: /usr/local/go
GOPATH: /home/user/go
PATH: /usr/local/go/bin
```

**Notes**:
- Shows helpful Go configuration information
- Called by users to verify installation
- All output in Turkish

---

## Menu Module Functions

### `configure_git()`
**File**: `src/modules/menus.sh:7`

**Purpose**: Interactively configures Git user name and email.

**Actions**:
1. Prompts for Git username
2. Prompts for Git email
3. Sets global Git configuration

**Returns**: None (interactive function)

**Usage Example**:
```bash
configure_git
# User enters: "John Doe"
# User enters: "john@example.com"

git config --global user.name  # Shows: John Doe
git config --global user.email # Shows: john@example.com
```

**Configuration Set**:
```bash
git config --global user.name "$git_user"
git config --global user.email "$git_email"
```

**Notes**:
- User-interactive
- Requires user input via stdin
- Sets global configuration

---

### `prepare_and_configure_git()`
**File**: `src/modules/menus.sh:26`

**Purpose**: Convenience function to update system and configure Git.

**Actions**:
1. Calls `update_system()`
2. Calls `configure_git()`

**Returns**: None

**Usage Example**:
```bash
prepare_and_configure_git
```

**Notes**:
- Combines two common operations
- Used in menu option 2

---

### `show_menu()`
**File**: `src/modules/menus.sh:32`

**Purpose**: Displays the main installation menu.

**Menu Options**:
1. Full Installation (Recommended)
2. Preparation (System update + Git)
3. Python Installation
4. Pip Update
5. Pipx Installation
6. UV Installation
7. NVM Installation
8. Bun.js Installation
9. PHP Installation
10. Composer Installation
11. AI CLI Tools
12. AI Frameworks
13. Remove AI Frameworks
14. Go Installation
0. Exit

**Returns**: None (display only)

**Usage Example**:
```bash
show_menu
# Displays menu to stdout
```

**Notes**:
- Called by main program loop
- Uses color-coded output

---

### `main()`
**File**: `src/modules/menus.sh:54`

**Purpose**: Main program loop handling user input and menu selections.

**Actions**:
1. Detects package manager
2. Runs interactive menu loop
3. Handles multi-choice input (comma-separated)
4. Routes to appropriate functions
5. Loops until user exits

**Input Format**:
- Single choice: `3`
- Multiple choices: `3,7,11`

**Multi-Choice Examples**:
- `3,14` - Install Python and Go
- `7,8` - Install NVM and Bun.js
- `11,12` - Install AI CLI tools and frameworks

**Returns**: None (runs indefinitely until exit)

**Usage Example**:
```bash
main
# Interactive session starts
```

**Notes**:
- Program entry point
- Multi-choice support
- Loops until option 0 (exit)

---

## Configuration Functions

### `show_banner()`
**File**: `src/config/banner.sh:6`

**Purpose**: Displays 1453-themed ASCII banner and script information.

**Actions**:
1. Clears screen
2. Displays 1453 ASCII art
3. Shows script title and version
4. Displays GitHub URL
5. Shows current date/time

**Returns**: None (output to stdout)

**Usage Example**:
```bash
show_banner
```

**Banner Content**:
- 1453 ASCII art in cyan
- Title: "1453.AI - WSL Vibe Coder'lar İçin Otomatik Kurulum Rehberi"
- Version: v2.0 Modular
- GitHub URL
- Current timestamp

**Notes**:
- Called at script start
- Turkish language interface

---

## Summary Table

| Category | Functions | File |
|----------|-----------|------|
| Core | `detect_package_manager`, `update_system`, `reload_shell_configs`, `mask_secret` | lib/ |
| Python | `install_python`, `install_pip`, `install_pipx`, `install_uv` | modules/python.sh |
| JavaScript | `install_nvm`, `install_bun` | modules/javascript.sh |
| PHP | `ensure_php_repository`, `install_composer`, `install_php_version`, `install_php_version_menu` | modules/php.sh |
| AI CLI | `install_claude_code`, `install_gemini_cli`, `install_opencode_cli`, `install_qwen_cli`, `install_copilot_cli`, `install_github_cli`, `install_qoder_cli`, `install_ai_cli_tools_menu` | modules/ai-cli.sh |
| AI Frameworks | `install_supergemini`, `install_superqwen`, `install_superclaude`, `remove_supergemini`, `remove_superqwen`, `remove_superclaude`, `install_ai_frameworks_menu`, `remove_ai_frameworks_menu` | modules/ai-frameworks.sh |
| **Go** | **`is_go_installed`, `configure_go_env`, `install_go_official`, `install_go_package`, `install_go`, `install_go_menu`, `remove_go`, `show_go_info`** | **modules/go.sh** |
| Menus | `configure_git`, `prepare_and_configure_git`, `show_menu`, `main` | modules/menus.sh |
| Config | `show_banner` | config/banner.sh |

---

## Best Practices

### Function Usage
1. **Always source dependencies**: Load modules in correct order
2. **Check prerequisites**: Functions handle this automatically
3. **Handle errors**: Functions return exit codes
4. **Reload configs**: After installing tools that modify PATH

### Return Code Convention
- **0**: Success
- **1**: Failure or error

### Interactive Functions
- `main()` - Entry point
- `show_menu()` - Display menu
- `*_menu()` - Interactive selection
- `configure_git()` - Requires user input

### Export Functions
All functions are exported using `export -f function_name` to make them available to sourced scripts.

### Go Installation Recommendations
- **For latest version**: Use `install_go_official()` or `install_go()`
- **For quick installation**: Use `install_go_package()`
- **For user choice**: Use `install_go_menu()`
- **For verification**: Use `show_go_info()`

### Multi-Choice Support
The main menu supports comma-separated selections for efficiency:
- `3,14` - Install Python and Go together
- `7,8,14` - Install JavaScript ecosystem and Go
- `11,12,14` - Install AI tools and Go

This allows users to install multiple tools in a single session.
